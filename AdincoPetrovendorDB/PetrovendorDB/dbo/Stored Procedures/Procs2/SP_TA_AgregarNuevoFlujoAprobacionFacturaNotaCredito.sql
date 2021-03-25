USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_AgregarNuevoFlujoAprobacionFacturaNotaCredito'
)
    DROP PROCEDURE SP_TA_AgregarNuevoFlujoAprobacionFacturaNotaCredito;
GO 
/****** Object:  StoredProcedure [dbo].[SP_TA_AgregarNuevoFlujoAprobacionFacturaNotaCredito]    Script Date: 23/03/2021 01:35:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <23-03-2021>
-- Description:	<Consulta usuarios con rol de aprobación de factura para nota de credito>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_AgregarNuevoFlujoAprobacionFacturaNotaCredito]  
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionPedido INT, 
@IdNuevoFlujoAprobacion INT,
@IdOperacion INT,
@IdNotaCredito INT,
@MensajeAsignacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @FECHAMODIFICACION DATETIME  = GETDATE()
	DECLARE @TipoFlujo INT
	 --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN 

	  DECLARE @IdESTATUSACTUAL INT 

	 SELECT @IdESTATUSACTUAL= IdEstatusOperacion FROM dbo.TA_Operacion WHERE IdOperacion=@IdOperacion
	 IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN
	 BEGIN 

		CREATE TABLE #OLD_APROBADORES(IdTarea INT, IdAprobador INT, IdOperacion INT, NoSecuencia INT)

		INSERT INTO #OLD_APROBADORES
		SELECT IdTarea,IdAprobador, IdOperacion, NoSecuencia FROM TA_Tarea WHERE IdOperacion= @IdOperacion AND Activo=1

		
		-- AGREGAR AL HISTORIAL LOS APROBADORES ELIMINADOS
	    INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
		SELECT  
		CONCAT('El usuario ',ISNULL(UE.Nombre,' usuario no identificado '),' ha eliminado al usuario ' , ISNULL(UA.Nombre,' usuario no identificado '),  ' de la aprobación de la nota de crédito'),
		@IdOperacion,
		@FECHAMODIFICACION,
		10--> ESTATUS DE ELIMINACIÓN DE  SELECT * FROM dbo.TA_EstadoFlujoTarea WHERE Idestado=10
		FROM dbo.TA_Tarea  T
		LEFT JOIN dbo.S_Usuario UA ON UA.IdUsuario=T.IdAprobador
		LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario --> USUARIO ACTUAL
		WHERE T.Activo=1
		AND T.IdOperacion=@IdOperacion 

		--APROBADORES ACTUALES PASARLOS A ELIMINADOS 
		UPDATE TA_Tarea 
		SET Activo=0,
		IdEstatus=12, ---> ELIMINADO SELECT * FROM TA_Estatus where IdEstatus=12
		EliminadoPor=@IdUsuario,
		EliminadoEl=@FECHAMODIFICACION
		WHERE Activo=1
		AND IdOperacion=@IdOperacion

		---ACTUALIZAR EL NUEVO FLUJO DE APROBACION EN LA OPERACION
		UPDATE dbo.TA_Operacion 
		SET IdEstadoFlujo=1,
		IdFlujoTarea=@IdNuevoFlujoAprobacion
		WHERE IdOperacion=@IdOperacion		

		SELECT @TipoFlujo=IdTipoFlujo FROM  dbo.TA_FlujoTarea WHERE IdFlujoTarea=@IdNuevoFlujoAprobacion

		--AGREGAR NUEVOS APROBADORES 
		INSERT INTO dbo.TA_Tarea(
		NombreTarea,
		FechaRegistro,
		IdEstatus,
		Activo,
		Visto,
		IdAprobador,
		NoSecuencia,
		IdOperacion,
		AsignadoPor,
		MensajeAsignacion)	
		SELECT 
		'Aprobación de Nota de crédito',
		@FECHAMODIFICACION, 
		CASE
               WHEN @TipoFlujo = 1 --> APROBACIÓN SERIAL  
                    AND NoSecuencia > 1 THEN
                   9 --> SIN INICIAR APROBACIÓN SOLO APLICA PARA SERIALES DONDE NUM SECUENCIA ES MAYOR A 1   
               ELSE
                   1 --> EN APROBACIÓN  
        END, 
		1,
		0, 
		IdUsuario, 
		NoSecuencia,
		@IdOperacion, 
		@IdUsuario, 
		@MensajeAsignacion
		FROM dbo.TA_Aprobador 
		WHERE IdFlujoTarea=@IdNuevoFlujoAprobacion
		ORDER BY NoSecuencia ASC

		---AGREGAR AL HISTORIAL LOS NUEVOS APROBADORES 
		 INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
		SELECT  
		CONCAT('El usuario ',ISNULL(UE.Nombre,' usuario no identificado '),'  ha asignado como aprobador de la nota de crédito al usuario  ' , ISNULL(UA.Nombre,' usuario no identificado ')),
		@IdOperacion,
		@FECHAMODIFICACION,
		8--> REASIGNACIÓN DE TAREA 
		FROM dbo.TA_Aprobador A
		LEFT JOIN dbo.S_Usuario UA ON UA.IdUsuario=A.IdUsuario
		LEFT JOIN dbo.S_Usuario UE ON UE.IdUsuario=@IdUsuario --> USUARIO ACTUAL
		WHERE A.IdFlujoTarea=@IdNuevoFlujoAprobacion
				
		SELECT 'SUCCESS'

		    --RETORNAR APROBADORES PARA ENVIAR NOTIFICACIONES
		SELECT AD.IdTarea,                 --0  
			   AD.IdAprobador,             --1  
			   U.Nombre,                   --2  
			   U.Correo,                   --3  
			   AD.IdOperacion,             --4  
			   AD.NoSecuencia,             --5  
			   PG.IdPedido,                --6  
			   AP.IdAceptacionPedido,      --7  
			   NC.IdAceptacionNotaCredito, --8  
			   P.IdSolicitudPedido,        --9  
			   P.IdPedido
		FROM dbo.TA_Tarea AD
			JOIN dbo.TA_Operacion A
				ON AD.IdOperacion = A.IdOperacion
			JOIN dbo.S_Usuario U
				ON AD.IdAprobador = U.IdUsuario
			JOIN dbo.MM_AceptacionNotaCredito NC
				ON A.IdDocumento = NC.IdAceptacionNotaCredito
			JOIN dbo.MM_AceptacionPedido AP
				ON NC.IdAceptacionPedido = AP.IdAceptacionPedido
			INNER JOIN dbo.MM_Pedido P
				ON AP.IdPedido = P.IdPedido
			JOIN dbo.MM_Pedidos PG
				ON P.IdPedido = PG.IdIdentificador
				   AND PG.IdProveedorCliente = P.IdProveedorCompras
		WHERE A.IdOperacion = @IdOperacion
			  AND AD.IdEstatus = 1 ---> PARA QUE SOLO MANDE NOTIFICACIÓN A LOS APROBADORES QUE ESTAN PENDIENTES DE APROBAR YA SERA SERIAL PARALELO  
			  AND A.IdTipoOperacion = 17 -->APROBACIÓN DE NOTA DE CRÉDITO  
		GROUP BY AD.IdTarea,                 --0  
				 AD.IdAprobador,             --1  
				 U.Nombre,                   --2  
				 U.Correo,                   --3  
				 AD.IdOperacion,             --4  
				 AD.NoSecuencia,             --5  
				 PG.IdPedido,                --6  
				 AP.IdAceptacionPedido,      --7  
				 NC.IdAceptacionNotaCredito, --8  
				 P.IdSolicitudPedido,        --9  
				 P.IdPedido;

	 END 
	 ELSE 
	 BEGIN
		DECLARE @EstatusActual NVARCHAR(MAX)
		SELECT @EstatusActual=ISNULL(@EstatusActual,'') FROM  dbo.TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL
		SELECT 'ESTATUS_NOENAPROBACION' AS Response,@EstatusActual AS EstatusActual
	 END 
 

END

 
