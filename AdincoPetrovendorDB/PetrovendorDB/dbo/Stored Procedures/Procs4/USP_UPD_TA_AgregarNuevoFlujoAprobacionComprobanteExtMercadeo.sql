USE [Petrovendor]
GO
DROP PROC IF EXISTS [USP_UPD_TA_AgregarNuevoFlujoAprobacionComprobanteExtMercadeo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <28-01-2026>
-- Description:	Cambio de flujo de aprobación de comprobante extranjero mercadeo
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_TA_AgregarNuevoFlujoAprobacionComprobanteExtMercadeo]  
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionPedido INT, 
@IdNuevoFlujoAprobacion INT,
@IdOperacion INT,
@MensajeAsignacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @FECHAMODIFICACION DATETIME  = GETDATE()
	 --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN 

	 DECLARE @IdESTATUSACTUAL INT 	
	 CREATE TABLE #OLD_APROBADORES(
	 IdTarea INT, 
	 IdAprobador INT, 
	 IdOperacion INT, 
	 NoSecuencia INT)

	 SELECT @IdESTATUSACTUAL= IdEstatusOperacion 
	 FROM dbo.TA_Operacion (NOLOCK)
	 WHERE IdOperacion=@IdOperacion

	 IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN
	 BEGIN 
	 	
		INSERT INTO #OLD_APROBADORES
		SELECT IdTarea,IdAprobador, IdOperacion, NoSecuencia 
		FROM TA_Tarea
		WHERE IdOperacion= @IdOperacion AND Activo=1

		-- AGREGAR AL HISTORIAL LOS APROBADORES ELIMINADOS
	    INSERT INTO TA_HistorialFlujoTarea(
		Descripcion,
		IdOperacion,
		Fecha,
		IdEstadoFlujo)
		SELECT  
		CONCAT('El usuario ',ISNULL(UE.Nombre,' usuario no identificado '),' ha eliminado al usuario ' ,
		ISNULL(UA.Nombre,' usuario no identificado '),  ' de la aprobación del comprobante extranjero'),
		@IdOperacion,
		@FECHAMODIFICACION,
		10--> ESTATUS DE ELIMINACIÓN DE  SELECT * FROM dbo.TA_EstadoFlujoTarea WHERE Idestado=10
		FROM dbo.TA_Tarea (NOLOCK)  T
		LEFT JOIN dbo.S_Usuario (NOLOCK) UA 
			ON T.IdAprobador = UA.IdUsuario
		LEFT JOIN dbo.S_Usuario (NOLOCK) UE 
			ON UE.IdUsuario = @IdUsuario --> USUARIO ACTUAL
		WHERE T.Activo=1
		AND T.IdOperacion=@IdOperacion 

		--APROBADORES ACTUALES PASARLOS A ELIMINADOS 
		UPDATE TA_Tarea 
		SET Activo = 0,
		IdEstatus = 12, ---> ELIMINADO
		EliminadoPor=@IdUsuario,
		EliminadoEl = @FECHAMODIFICACION
		WHERE Activo = 1
		AND IdOperacion = @IdOperacion

		---ACTUALIZAR EL NUEVO FLUJO DE APROBACION EN LA OPERACION
		UPDATE TA_Operacion 
		SET IdEstadoFlujo=1, --> CTE EN APROBACIÓN
		IdFlujoTarea = @IdNuevoFlujoAprobacion
		WHERE IdOperacion=@IdOperacion		

		--AGREGAR NUEVOS APROBADORES 
		INSERT INTO TA_Tarea(
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
		SELECT 'Aprobación de Comprobante de extranjero',
		@FECHAMODIFICACION, 
		1, 
		1,
		0, 
		IdUsuario, 
		NoSecuencia,
		@IdOperacion, 
		@IdUsuario, 
		@MensajeAsignacion
		FROM dbo.TA_Aprobador (NOLOCK)
		WHERE IdFlujoTarea=@IdNuevoFlujoAprobacion

		---AGREGAR AL HISTORIAL LOS NUEVOS APROBADORES 
		INSERT INTO TA_HistorialFlujoTarea(
		Descripcion,
		IdOperacion,
		Fecha,
		IdEstadoFlujo)
		SELECT  
		CONCAT('El usuario ',ISNULL(UE.Nombre,' usuario no identificado '),'  ha asignado como aprobador del comprobante extranjero al usuario  ' , ISNULL(UA.Nombre,' usuario no identificado ')),
		@IdOperacion,
		@FECHAMODIFICACION,
		8--> REASIGNACIÓN DE TAREA 
		FROM dbo.TA_Aprobador (NOLOCK) A
		LEFT JOIN dbo.S_Usuario (NOLOCK) UA 
			ON A.IdUsuario = UA.IdUsuario
		LEFT JOIN dbo.S_Usuario (NOLOCK) UE 
			ON UE.IdUsuario = @IdUsuario --> USUARIO ACTUAL
		WHERE A.IdFlujoTarea=@IdNuevoFlujoAprobacion
			
		-- TABLA 1 --INFORMACIÓN DEL NUEVO FLUJO
		SELECT 'SUCCESS' AS Response,
		@IdNuevoFlujoAprobacion AS IdFlujoTarea,
		@IdUsuario AS IdAsignador

		-- TABLA 2 --INFORMACIÓN DE LOS USUARIOS ELIMINADOS DEL FLUJO
		    SELECT 
			IdUsuarioAprobadorEliminado = U.IdUsuario,
			NombreAprobadorEliminado = U.Nombre,
			CorreoAprobadorEliminado = U.Correo,
			NombreUsuarioElimino = URC.Nombre,
			PG.IdPedido,
			P.IdSolicitudPedido,
			AP.IdAceptacionPedido,
			NombreContrato = CONCAT(ISNULL(C.NumeroContrato,'-'),'-',ISNULL(AC.NombreAreaContractual,'-'))
			FROM #OLD_APROBADORES TAE
			JOIN TA_Tarea TE	
				ON TAE.IdTarea = TE.IdTarea
			JOIN S_Usuario U 
				ON TE.IdAprobador = U.IdUsuario
				AND ISNULL(U.Activo,0) = 1
			LEFT JOIN S_Usuario URC
				ON URC.IdUsuario = @IdUsuario
			LEFT JOIN MM_AceptacionPedido AP
				ON AP.IdAceptacionPedido = @IdAceptacionPedido
			LEFT JOIN MM_Pedido P
				ON AP.IdPedido = P.IdPedido
			LEFT JOIN MM_Pedidos PG
				ON P.IdPedido = PG.IdIdentificador
				AND P.IdProveedorCompras = PG.IdProveedorCliente
				AND PG.IdTipoPedido IN (2,4,6) --> CTES DE MERCADEO, AD DIRECTA, ORDEN TRABAJO
			LEFT JOIN Adinco..CO_Contrato C
				ON P.IdContrato = C.IdContrato
			LEFT JOIN Adinco..CO_AreaContractual AC
				ON C.IdAreaContractual = AC.IdAreaContractual
			WHERE TE.IdOperacion = @IdOperacion
			GROUP BY 
			U.IdUsuario,
			U.Nombre,
			U.Correo,
			URC.Nombre,
			PG.IdPedido,
			P.IdSolicitudPedido,
			AP.IdAceptacionPedido,
			C.NumeroContrato,
			AC.NombreAreaContractual

	 END 
	 ELSE 
	 BEGIN
		DECLARE @EstatusActual NVARCHAR(MAX)
		SELECT @EstatusActual=ISNULL(@EstatusActual,'') FROM  dbo.TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL
		SELECT 'ESTATUS_NOENAPROBACION' AS Response,@EstatusActual AS EstatusActual
	 END 
 

END

 
