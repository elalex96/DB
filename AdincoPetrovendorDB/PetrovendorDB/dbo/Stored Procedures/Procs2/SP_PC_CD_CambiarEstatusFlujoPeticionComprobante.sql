
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 28-03-17
-- Description:	 Actualiza el Estatus de de la operacion
-- =============================================

CREATE PROCEDURE [dbo].[SP_PC_CD_CambiarEstatusFlujoPeticionComprobante] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT 
	
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
	INNER JOIN TA_Tarea AS T ON T.IdOperacion = TAO.IdOperacion
	WHERE TAO.IdOperacion = @IdOperacion AND T.IdEstatus <> 7)

	--- T.IdEstatus <> 7 ---> Es Cancelado por Reasignación ---

	SET @CountEstPen = (SELECT	COUNT(IdEstatus) AS TOTAL
	FROM TA_Operacion TAO
	INNER JOIN TA_Tarea AS T ON T.IdOperacion = TAO.IdOperacion 
	WHERE TAO.IdOperacion = @IdOperacion  AND T.IdEstatus = 1)
	
	SET @CountEstApr = (SELECT	COUNT(IdEstatus) AS TOTAL
	FROM TA_Operacion TAO
	INNER JOIN TA_Tarea AS T ON T.IdOperacion = TAO.IdOperacion
	WHERE TAO.IdOperacion = @IdOperacion  AND T.IdEstatus = 2)


	SET @CountEstRech = (SELECT	COUNT(IdEstatus) AS TOTAL
	FROM TA_Operacion TAO
	INNER JOIN TA_Tarea AS T ON T.IdOperacion = TAO.IdOperacion
	WHERE TAO.IdOperacion = @IdOperacion  AND T.IdEstatus = 3)

		
	BEGIN
		IF (@CountEstRech > 0)
			BEGIN
			--- Actualizar el Estatus de la Operacion ---> Se cancela la Tarea 
			UPDATE TA_Operacion SET IdEstatusOperacion = 3, IdEstadoFlujo = 4,  @Resultado = 3, FechaModificacion= GETDATE() WHERE IdOperacion = @IdOperacion
			---Actualizar los estatus que aun no a sido aprobados(Pendientes) ---> Se cancelan por cancelación las tareas no evaluadas
			UPDATE TA_TAREA SET IdEstatus= 4 
			WHERE IdTarea IN (SELECT T.IdTarea 
							  FROM TA_Tarea AS T
							  INNER JOIN TA_TareaOperacion AS TAO ON TAO.IdTarea = T.IdTarea
							  WHERE TAO.IdOperacion = @IdOperacion AND T.IdEstatus= 1)

			SET @DescripcionH = 'Se ha Finalizado la aprobación del Comprobante Extranjero  '

			INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
			VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

			


			END  
		ELSE
			IF (@CountEstApr = @CountTarea)
			BEGIN
				--Actualizar el Estatus de la Operacion y el Estado del Flujo ---> Tarea Aprobada

				UPDATE TA_Operacion SET IdEstatusOperacion = 2,IdEstadoFlujo = 3, @Resultado = 2,  FechaModificacion= GETDATE() WHERE IdOperacion = @IdOperacion
				
				SET @DescripcionH = 'Se ha Finalizado la aprobación  del Comprobante Extranjero  '

				INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
				VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

				

			END 
			ELSE
			UPDATE TA_Operacion SET IdEstatusOperacion = 1,IdEstadoFlujo = 2, @Resultado = 1, FechaModificacion= GETDATE() WHERE IdOperacion = @IdOperacion
	
			
	END
	
	----SELECT @Resultado AS EstadoFlujo

 END


