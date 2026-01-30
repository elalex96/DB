USE [Petrovendor]
GO
DROP PROC IF EXISTS [USP_UPD_TA_RemoverAprobadorComprobanteExtMercadeo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <02-08-19>
-- Description:	Se elimina aprobador de flujo de aprobación, se reinicia a los aprobadores que ya estaban como aprobados
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_TA_RemoverAprobadorComprobanteExtMercadeo] 
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionPedido  INT, 
@IdTarea INT,
@IdOperacion INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @FechaMod DATETIME = GETDATE()
	 
	 --VALIDAR QUE LA APROBACIÓN ESTE EN ESTATUS DE EN_APROBACIÓN 
	 DECLARE @AprobadoresActivos INT 
	 DECLARE @IdESTATUSACTUAL INT 
	 DECLARE @IdUsuarioEliminado INT
	 DECLARE @Descripcion NVARCHAR(MAX)
	 DECLARE @IdFlujoAprobacion INT 
	 DECLARE @TipoFlujo INT 
	 DECLARE @NoSecuencia INT 
	 CREATE TABLE #Aprobadores(IdTarea INT,  NewNoSecuencia INT)
	 CREATE TABLE #TAREAS_APROBADAS(IdTarea INT, FechaCambioEstatus DATETIME, Comentantario NVARCHAR(MAX),IdEstatus INT)

	 SELECT @IdESTATUSACTUAL= IdEstatusOperacion 
	 FROM dbo.TA_Operacion WHERE IdOperacion=@IdOperacion
	 
	 IF ISNULL(@IdESTATUSACTUAL,0) = 1 --APROBACIÓN TIENE QUE ESTAR EN APROBACIÓN
	 BEGIN 		

		SELECT @AprobadoresActivos= COUNT(IdTarea) 
		FROM TA_Tarea
		WHERE IdOperacion=@IdOperacion
		AND Activo=1
		
		--> LA APROBACIÓN SIEMPRE DEBE TENER AL MENOS UN APROBADOR DE COMPROBANTE EXTRANJERO, SI NO, NO SE ELIMINA EL APROBADOR ACTUAL 
		IF @AprobadoresActivos > 1 
		BEGIN 

			---ACTUALIZAR 
			 UPDATE dbo.TA_Tarea  
			 SET Activo  = 0, --> DESACTIVAMOS LA APROBACIÓN 
			 IdEstatus = 12, --> ELIMINADO
			 EliminadoPor = @IdUsuario,
			 EliminadoEl = @FechaMod
			 WHERE IdTarea = @IdTarea
			 AND IdOperacion = @IdOperacion 

			 SELECT @IdUsuarioEliminado = IdAprobador 
			 FROM dbo.TA_Tarea 
			 WHERE IdTarea = @IdTarea

			 --AGREGAR DETALLE AL HISTORIAL DE OPERACION 
			  SET @Descripcion = 'El usuario '+
							ISNULL((SELECT Nombre FROM S_Usuario WHERE IdUsuario = @IdUsuario),' - ')+ 
							' ha eliminado al usuario ' +
							ISNULL((SELECT Nombre FROM S_Usuario U WHERE IdUsuario = @IdUsuarioEliminado),' - ') + ' de la aprobación del comprobante extranjero'
							
			INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
			VALUES(@Descripcion,@IdOperacion,@FechaMod,10)		  
			  

			 --- VALIDAR EL TIPO DE FLUJO SI ES SERIAL SE TIENE QUE ACTUALIZAR NO SECUENCIA	
			SELECT @IdFlujoAprobacion= IdFlujoTarea 
			FROM  TA_Operacion 
			WHERE IdOperacion =@IdOperacion

			SELECT @TipoFlujo=IdTipoFlujo 
			FROM  TA_FlujoTarea 
			WHERE IdFlujoTarea=@IdFlujoAprobacion

			IF @TipoFlujo = 1 -->	APROBACIÓN SERIAL 
			BEGIN 
				--SE TIENE QUE ACTUALIZAR EL NO DE SECUENCIA DE LOS APROBADORES ACTIVOS 
				INSERT INTO #Aprobadores
				(IdTarea,
				NewNoSecuencia)			 			
				SELECT IdTarea, 
				ROW_NUMBER() OVER(ORDER BY NoSecuencia ASC) AS  NewNoSecuencia
				FROM dbo.TA_Tarea 
				WHERE IdOperacion =@IdOperacion ---> 
				AND Activo=1  --> ESTEN ACTIVOS 
				ORDER BY NoSecuencia ASC

				UPDATE T
				SET T.NoSecuencia=A.NewNoSecuencia
				FROM dbo.TA_Tarea T
				JOIN #Aprobadores A 
				ON T.IdTarea = A.IdTarea
					
			 END 

			 --ACTUALIZAR APROBADORES QUE YA HABIAN APROBADO EL COMPROBANTE DE COMPRA (REINICIO)

			INSERT INTO #TAREAS_APROBADAS(IdTarea, FechaCambioEstatus, Comentantario, IdEstatus)
			SELECT IdTarea, FechaCambioEstatus, Comentario, IdEstatus
			FROM TA_Tarea  
			WHERE IdOperacion=@IdOperacion 
			AND Activo=1 
			AND IdEstatus = 2 --> ESTATUS APROBADO 

			UPDATE T
			SET T.IdEstatus=1, --- REINICIO DE ESTATUS
			T.FechaCambioEstatus=NULL 
			FROM TA_Tarea  T 
			JOIN #TAREAS_APROBADAS TA 
			ON T.IdTarea = TA.IdTarea
			AND T.IdOperacion=@IdOperacion
		
			INSERT INTO TA_HistorialFlujoTarea(Descripcion,IdOperacion,Fecha,IdEstadoFlujo)
			SELECT CONCAT('Reinicio de aprobación del usuario ', ISNULL(U.Nombre,''), ', Última modificación: ',FORMAT(TA.FechaCambioEstatus,'dd/MM/yyyy hh:mm tt'),' del Estatus Aprobado al Estatus Pendiente.', 'Modificación (Eliminación de un aprobador del flujo 
de aprobación) realizada por ', ISNULL(UR.Nombre,'')), T.IdOperacion,@FechaMod, 6 --> Tarea Reiniciada
			FROM #TAREAS_APROBADAS TA
			JOIN TA_Tarea T 
				ON  TA.IdTarea = T.IdTarea
			LEFT JOIN S_Usuario U 
				ON T.IdAprobador = U.IdUsuario
			LEFT JOIN S_Usuario UR 
				ON UR.IdUsuario = @IdUsuario
			AND T.IdOperacion = @IdOperacion


			-- TABLA 1
			SELECT 'SUCCESS' AS Response

			-- TABLA 2 ---> USUARIOS QUE YA NO FORMAN PARTE DEL FLUJO DE APROBACIÓN
			SELECT 
			IdUsuarioAprobadorEliminado = U.IdUsuario,
			NombreAprobadorEliminado = U.Nombre,
			CorreoAprobadorEliminado = U.Correo,
			NombreUsuarioElimino = URC.Nombre,
			PG.IdPedido,
			P.IdSolicitudPedido,
			AP.IdAceptacionPedido,
			NombreContrato = CONCAT(ISNULL(C.NumeroContrato,'-'),'-',ISNULL(AC.NombreAreaContractual,'-'))
			FROM TA_Tarea TE			
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
			WHERE TE.IdTarea = @IdTarea
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
			 
			 -- TABLA 3
			 ---APROBADORES A LOS QUE SE LES REINICIO SU APROBACIÓN POR UNA ELIMINACIÓN
			 
			SELECT 
				T.IdTarea,
				T.IdOperacion,
				IdAceptacionPedido = @IdAceptacionPedido 
			FROM #TAREAS_APROBADAS  AS TA 
				JOIN TA_Tarea T
					ON TA.IdTarea = T.IdTarea 					
				JOIN S_Usuario U 
					ON T.IdAprobador = U.IdUsuario
			WHERE T.IdOperacion = @IdOperacion	
			AND ISNULL(U.Activo,0) = 1
			AND T.Activo = 1
			GROUP BY
			T.IdTarea,
			T.IdOperacion
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
		SELECT 'ELIMINACION_NOREALIZADA' AS RESPONSE,
		@EstatusActual AS EstatusActual
	 END 



END