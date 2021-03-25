USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_RemoverAprobadorFacturaNotaCredito'
)
    DROP PROCEDURE SP_TA_RemoverAprobadorFacturaNotaCredito;
GO 
/****** Object:  StoredProcedure [dbo].[SP_TA_RemoverAprobadorFactura]    Script Date: 24/03/2021 03:37:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <24-03-2021>
-- Description:	Agregue, reinicio de aprobación de los aprobadores que ya tenian un estatus de aprobado y consulta para reenviarles notificación de reinicio
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_RemoverAprobadorFacturaNotaCredito] --420, 2
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionPedido  INT, 
@IdTarea INT,
@IdOperacion INT, 
@IdNotaCredito INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @FechaMod DATETIME = GETDATE()
	 
	 --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN 

	 DECLARE @IdESTATUSACTUAL INT 

	 SELECT @IdESTATUSACTUAL= IdEstatusOperacion FROM dbo.TA_Operacion WHERE IdOperacion=@IdOperacion
	 
	 IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN
	 BEGIN 
		
		DECLARE @AprobadoresActivos INT 

		SELECT @AprobadoresActivos= COUNT(IdTarea) 
		FROM dbo.TA_Tarea WHERE IdOperacion=@IdOperacion AND Activo=1
		
		--> LA APROBACIÓN SIEMPRE DEBE TENER AL MENOS UN APROBADOR DE FACTURA, SI NO, NO SE ELIMINA EL APROBADOR ACTUAL 
		IF @AprobadoresActivos > 1 
		BEGIN 

			---ACTUALIZAR 
			 UPDATE dbo.TA_Tarea  
			 SET Activo  = 0, --> DESACTIVAMOS LA APROBACIÓN 
			 IdEstatus = 12, --> ELIMINADO
			 EliminadoPor=@IdUsuario,
			 EliminadoEl=@FechaMod
			 WHERE IdTarea = @IdTarea
			 AND IdOperacion=@IdOperacion 

			 DECLARE @IdUsuarioEliminado INT , @Descripcion NVARCHAR(MAX)
			 SELECT @IdUsuarioEliminado=IdAprobador FROM dbo.TA_Tarea WHERE IdTarea=@IdTarea

			 --AGREGAR DETALLE AL HISTORIAL DE OPERACION 
			  SET @Descripcion = 'El usuario '+
							(SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario)+ 
							' ha eliminado al usuario ' +
							(SELECT Nombre FROM S_Usuario U WHERE IdUsuario = @IdUsuarioEliminado) + ' de la aprobación de la nota de crédito'
							
			INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
			VALUES(@Descripcion,@IdOperacion,@FechaMod,10)		  
			  

			 --- VALIDAR EL TIPO DE FLUJO SI ES SERIAL SE TIENE QUE ACTUALIZAR NO SECUENCIA
			 DECLARE @IdFlujoAprobacion INT 
			 DECLARE @TipoFlujo INT 
			 DECLARE @NoSecuencia INT 

			SELECT @IdFlujoAprobacion= IdFlujoTarea FROM  dbo.TA_Operacion WHERE IdOperacion =@IdOperacion
			SELECT @TipoFlujo=IdTipoFlujo FROM  dbo.TA_FlujoTarea WHERE IdFlujoTarea=@IdFlujoAprobacion

			--IF @TipoFlujo = 1 -->	APROBACIÓN SERIAL 
			--BEGIN 
			--SE TIENE QUE ACTUALIZAR EL NO DE SECUENCIA DE LOS APROBADORES ACTIVOS 
			CREATE TABLE #Aprobadores(IdTarea INT,  NewNoSecuencia INT )
			
			INSERT INTO #Aprobadores
			(IdTarea,NewNoSecuencia)
			 			
			SELECT IdTarea, ROW_NUMBER() OVER(ORDER BY NoSecuencia ASC) AS  NewNoSecuencia
			FROM dbo.TA_Tarea 
			WHERE IdOperacion =@IdOperacion ---> 
			AND Activo=1  --> ESTEN ACTIVOS 
			ORDER BY NoSecuencia ASC

			UPDATE T
			SET T.NoSecuencia=A.NewNoSecuencia
			FROM dbo.TA_Tarea T
			INNER JOIN #Aprobadores A ON A.IdTarea = T.IdTarea
					
			 --END 

			 --ACTUALIZAR ESTATUS DE LOS APROBADORES QUE YA HABIAN APROBADO LA NOTA DE CREDITO DE APROBADA A EN APROBACIÓN (REINICIO)
			CREATE TABLE #TAREAS_APROBADAS(IdTarea INT, FechaCambioEstatus DATETIME, Comentario NVARCHAR(MAX),IdEstatus INT,NoSecuencia INT)

			INSERT INTO #TAREAS_APROBADAS(IdTarea, FechaCambioEstatus, Comentario, IdEstatus,NoSecuencia)
			SELECT IdTarea, FechaCambioEstatus, Comentario, IdEstatus,NoSecuencia
			FROM dbo.TA_Tarea 
			WHERE IdOperacion=@IdOperacion 
			AND Activo=1 AND IdEstatus=2 --> ESTATUS APROBADO 

			
			UPDATE T
			SET T.IdEstatus=CASE
							   WHEN @TipoFlujo = 1 --> APROBACIÓN SERIAL  
									AND T.NoSecuencia > 1 THEN
								   9 --> SIN INICIAR APROBACIÓN -->SOLO APLICA PARA SERIALES DONDE NUM SECUENCIA ES MAYOR A 1   
							   ELSE
								   1 --> EN APROBACIÓN  
							END, --- REINICIO DE ESTATUS
			T.FechaCambioEstatus=NULL 
			FROM dbo.TA_Tarea  T 
			WHERE Activo=1
			AND T.IdOperacion=@IdOperacion

		
			INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
			SELECT CONCAT('Reinicio de aprobación del usuario ', ISNULL(U.Nombre,''), ', Última modificación: ',FORMAT(TA.FechaCambioEstatus,'dd/MM/yyyy hh:mm tt'),' del Estatus Aprobado al Estatus Pendiente.', 'Modificación (Eliminación de un aprobador del flujo de aprobación) realizada por ', ISNULL(UR.Nombre,'')), T.IdOperacion,@FechaMod, 6 --> Tarea Reiniciada
			FROM #TAREAS_APROBADAS TA
			INNER JOIN dbo.TA_Tarea T ON T.IdTarea = TA.IdTarea
			LEFT JOIN dbo.S_Usuario U ON U.IdUsuario=T.IdAprobador
			LEFT JOIN dbo.S_Usuario UR ON UR.IdUsuario=@IdUsuario
			AND T.IdOperacion=@IdOperacion

			SELECT 'SUCCESS' AS RESPONSE --> TABLA 1

			 --INFORMACIÓN DEL APROBADOR ACTUAL PARA ENVIARLE NOTIFICACIÓN DE QUE HA SIDO REMOVIDO DE LA APROBACIÓN --> TABLA 2
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
			   P.IdPedido,					--10
			   ISNULL(UE.Nombre, 'No identificado') AS UsuarioElimino --11
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
			LEFT JOIN S_Usuario UE 
				 ON UE.IdUsuario=@IdUsuario ---> usuario
		WHERE A.IdOperacion = @IdOperacion
			  AND AD.IdTarea=@IdTarea	--->  DEL USUARIO QUE SE LE ELIMINO LA INFORMACION
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
				 P.IdPedido,
				  UE.Nombre
			
			-- ---APROBADORES A LOS QUE SE LES REINICIO SU APROBACIÓN POR UNA ELIMINACIÓN --> TABLA 3
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
		FROM #TAREAS_APROBADAS TR
			JOIN TA_Tarea AD 
				ON TR.IdTarea=AD.IdTarea
			JOIN TA_Operacion A
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
			  AND AD.IdEstatus = 1 ---> PARA QUE SOLO MANDE NOTIFICACIÓN A LOS APROBADORES QUE ESTAN PENDIENTES DE APROBAR YA SEA SERIAL PARALELO  
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
			SELECT 'AGREGARNUEVOAPROBADOR' AS RESPONSE
		END 		  

	 END 
	 ELSE 
	 BEGIN
		DECLARE @EstatusActual NVARCHAR(MAX)
		SELECT @EstatusActual=ISNULL(@EstatusActual,'') FROM  dbo.TA_Estatus WHERE IdEstatus=@IdESTATUSACTUAL
		SELECT 'ELIMINACION_NOREALIZADA' AS RESPONSE,@EstatusActual AS EstatusActual
	 END 



END
