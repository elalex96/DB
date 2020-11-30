-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 28-03-17
-- Description:	 Actualiza el Estatus de de la operacion
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 05/03/2018
-- Description:	 Textos a retornar
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_CambiarEstatusFlujo] 
	-- Add the parameters for the stored procedure here
	@IdOperacion INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--WAITFOR DELAY '00:01:00';

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

    SET @CountTarea =  (SELECT	COUNT(IdEstatus) FROM TA_Tarea WHERE IdOperacion = @IdOperacion AND IdEstatus <> 7 )
	--- T.IdEstatus <> 7 ---> Es Cancelado por Reasignación ---
	SET @CountEstPen = (SELECT COUNT(IdEstatus) FROM TA_Tarea WHERE IdOperacion = @IdOperacion  AND IdEstatus = 1)
	
	SET @CountEstApr = (SELECT COUNT(IdEstatus) FROM TA_Tarea WHERE IdOperacion = @IdOperacion  AND IdEstatus = 2)

	SET @CountEstRech = (SELECT	COUNT(IdEstatus) FROM TA_Tarea WHERE IdOperacion = @IdOperacion  AND IdEstatus = 3)

		
	BEGIN
		IF (@CountEstRech > 0)
			BEGIN
			--- Actualizar el Estatus de la Operacion ---> Se cancela la Tarea 
			UPDATE TA_Operacion SET IdEstatusOperacion = 3, IdEstadoFlujo = 4, @Resultado = 3 WHERE IdOperacion = @IdOperacion
			---Actualizar los estatus que aun no a sido aprobados(Pendientes) ---> Se cancelan por cancelación las tareas no evaluadas
			UPDATE TA_TAREA SET IdEstatus= 4 
			WHERE IdTarea IN (SELECT IdTarea 
							  FROM TA_Tarea
							  WHERE IdOperacion = @IdOperacion AND IdEstatus= 1)

			SET @DescripcionH = 'Se ha Finalizado la aprobación de la Tarea '

			INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
			VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)


			END  
		ELSE
			IF (@CountEstApr = @CountTarea)
			BEGIN
				--Actualizar el Estatus de la Operacion y el Estado del Flujo ---> Tarea Aprobada

				UPDATE TA_Operacion SET IdEstatusOperacion = 2,IdEstadoFlujo = 3, @Resultado = 2 WHERE IdOperacion = @IdOperacion
				
				SET @DescripcionH = 'Se ha Finalizado la aprobación de la Tarea '

				INSERT INTO TA_HistorialFlujoTarea(IdOperacion,Fecha,Descripcion,IdEstadoFlujo)
				VALUES(@IdOperacion,GETDATE(),@DescripcionH,7)

			END 
			--ELSE
			--BEGIN

			--	UPDATE TA_Operacion SET IdEstatusOperacion = 1,IdEstadoFlujo = 2, @Resultado = 1 WHERE IdOperacion = @IdOperacion
				
			--END
			
	
			
	END
	
	----SELECT @Resultado AS EstadoFlujo

 END

