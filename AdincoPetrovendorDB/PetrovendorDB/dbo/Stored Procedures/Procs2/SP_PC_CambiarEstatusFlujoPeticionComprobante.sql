USE [Petrovendor]
GO
DROP PROC IF EXISTS SP_PC_CambiarEstatusFlujoPeticionComprobante
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 30/01/2026
-- Description:	 Actualiza el Estatus de de la operacion, se debe tomar solo en cuenta tareas activas 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 16/05/2022
-- Description:	 Se descartan en la aprobacion los usuarios eliminados
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_CambiarEstatusFlujoPeticionComprobante] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT,
	@IdAceptacionPedido INT 


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdEstatus INT
	DECLARE @CountTarea INT
	DECLARE @CountEstPen INT
	DECLARE @CountEstApr INT
	DECLARE @CountEstRech INT
	DECLARE @CountEstCanc INT
	DECLARE @Resultado INT = 1
	DECLARE @DescripcionH NVARCHAR(MAX)

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	---Glosario ---
	-- 1 Pendiente
	-- 2 Aceptada
	-- 3 Rechazada
	-- 4 Vencida
	-- 7 Reasignada

    SET @CountTarea =  (SELECT	COUNT(IdEstatus) AS TOTAL
						FROM TA_Operacion TAO
						JOIN TA_Tarea AS T 
							ON TAO.IdOperacion = T.IdOperacion 
						INNER JOIN S_Usuario AS US
							ON T.IdAprobador= US.IdUsuario 
							AND US.Activo = 1
							AND ISNULL(US.IsEliminado,0) = 0
						WHERE TAO.IdOperacion = @IdOperacion 
						AND  T.Activo=1
						AND T.IdEstatus <> 7 -->CTE Cancelado por Reasignacion (TA_Estatus)
						)

	--- T.IdEstatus <> 7 ---> Es Cancelado por Reasignación ---

	SET @CountEstPen = (SELECT	COUNT(IdEstatus) AS TOTAL
						FROM TA_Operacion TAO
						INNER JOIN TA_Tarea AS T 
							ON TAO.IdOperacion  =T.IdOperacion 
						INNER JOIN S_Usuario AS US
							ON T.IdAprobador = US.IdUsuario 
							AND US.Activo = 1
							AND ISNULL(US.IsEliminado,0) = 0
						WHERE TAO.IdOperacion = @IdOperacion  
						AND  T.Activo=1
						AND T.IdEstatus = 1 -->CTE En Aprobación (TA_Estatus)
						)
	
	SET @CountEstApr = (SELECT	COUNT(IdEstatus) AS TOTAL
						FROM TA_Operacion TAO
						INNER JOIN TA_Tarea AS T 
							ON TAO.IdOperacion = T.IdOperacion 
						INNER JOIN S_Usuario AS US
							ON T.IdAprobador = US.IdUsuario 
							AND US.Activo = 1
							AND ISNULL(US.IsEliminado,0) = 0
						WHERE TAO.IdOperacion = @IdOperacion 
						AND  T.Activo=1
						AND T.IdEstatus = 2 -->CTE Aprobada (TA_Estatus)
						)


	SET @CountEstRech = (SELECT	COUNT(IdEstatus) AS TOTAL
						FROM TA_Operacion TAO
						INNER JOIN TA_Tarea AS T 
							ON TAO.IdOperacion = T.IdOperacion 
						INNER JOIN S_Usuario AS US
							ON T.IdAprobador= US.IdUsuario 
							AND US.Activo = 1
							AND ISNULL(US.IsEliminado,0) = 0
						WHERE TAO.IdOperacion = @IdOperacion  
						AND  T.Activo=1
						AND T.IdEstatus = 3-->CTE Rechazada (TA_Estatus)
						)

		
	BEGIN
		IF (@CountEstRech > 0)
			BEGIN
			--- ACTUALIZAR EL ESTATUS DE LA OPERACION ---> SE CANCELA LA TAREA 
			UPDATE TA_Operacion 
			SET IdEstatusOperacion = 3, --> CTE Rechazada (TA_Estatus)
			IdEstadoFlujo = 4,  --> CTE Tarea Rechazada (TA_EstadoFlujoTarea)
			@Resultado = 3,--> CTE Rechazada (TA_Estatus)
			FechaModificacion= GETDATE()
			WHERE IdOperacion = @IdOperacion

			---ACTUALIZAR LOS ESTATUS QUE AUN NO A SIDO APROBADOS(PENDIENTES) ---> SE CANCELAN POR CANCELACIÓN LAS TAREAS NO EVALUADAS
			UPDATE TA_TAREA 
			SET IdEstatus= 4 -->CTE Cancelado por Rechazo (TA_Estatus)
			WHERE  IdOperacion = @IdOperacion 
			AND IdEstatus= 1 -->CTE En Aprobación (TA_Estatus)			

			SET @DescripcionH = 'Se ha Finalizado la aprobación del Pedimento/Comprobante Extranjero  '

			INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
			VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

			


			END  
		ELSE
			IF (@CountEstApr = @CountTarea)
			BEGIN
				--ACTUALIZAR EL ESTATUS DE LA OPERACION Y EL ESTADO DEL FLUJO ---> TAREA APROBADA

				UPDATE TA_Operacion 
				SET IdEstatusOperacion = 2, -->CTE Aprobada (TA_Estatus)
				IdEstadoFlujo = 3, --> CTE Tarea Aprobada (TA_EstadoFlujoTarea)
				@Resultado = 2,  --> CTE Rechazada (TA_Estatus)
				FechaModificacion= GETDATE() 
				WHERE IdOperacion = @IdOperacion
				
				SET @DescripcionH = 'Se ha Finalizado la aprobación  del Pedimento/Comprobante Extranjero  '

				INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
				VALUES(@IdOperacion,GETDATE(),@DescripcionH,7) -->  CTE Tarea Finalizada (TA_EstadoFlujoTarea)

				

			END 
			ELSE
			UPDATE TA_Operacion 
			SET IdEstatusOperacion = 1,-->CTE En Aprobación  (TA_Estatus)
			IdEstadoFlujo = 2, --> CTE Tarea En Aprobacion (TA_EstadoFlujoTarea)
			@Resultado = 1, -->CTE En Aprobación (TA_Estatus)
			FechaModificacion= GETDATE()
			WHERE IdOperacion = @IdOperacion
	
			
	END
	

 END


