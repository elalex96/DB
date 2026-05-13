-- =============================================
-- Author:		Manuel Cruz
-- Create date: 02-01-17
-- Description:	SP que obtiene el estatus general de la tarea de acuerdo a las variables declaradas siendo contadores de los
				-- tipos de estatus que han indicado los Aprobadores a una tarea en especifico mandando el parámetro
				-- @IdTarea desde la parte Web. También actualiza la tabla general de la Tarea y la tabla de TareaAprobador,
				-- devolviendo una variable @Resultado que sirve como identificador del tipo de correo que se va a mandar.
-- =============================================
CREATE PROCEDURE [dbo].[sp_ObtenerEstatus] 
	-- Add the parameters for the stored procedure here
	@IdTarea INT
	
AS
BEGIN
	DECLARE @IdEstatus INT
	DECLARE @CountTarea INT
	DECLARE @CountEstPen INT
	DECLARE @CountEstApr INT
	DECLARE @CountEstRech INT
	DECLARE @CountEstCanc INT
	DECLARE @Resultado INT = 1

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SET @CountTarea = (SELECT COUNT (T.IdTarea) FROM Tarea T
	JOIN TareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN Usuario Us ON TA.IdUsuario = Us.IdUsuario
	JOIN Estatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea)

	SET @CountEstPen = (SELECT COUNT (T.IdTarea) FROM Tarea T
	JOIN TareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN Usuario Us ON TA.IdUsuario = Us.IdUsuario
	JOIN Estatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea AND TA.IdEstatus = 1)

	SET @CountEstApr = (SELECT COUNT (T.IdTarea) FROM Tarea T
	JOIN TareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN Usuario Us ON TA.IdUsuario = Us.IdUsuario
	JOIN Estatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea AND TA.IdEstatus = 3)

	SET @CountEstRech = (SELECT COUNT (T.IdTarea) FROM Tarea T
	JOIN TareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN Usuario Us ON TA.IdUsuario = Us.IdUsuario
	JOIN Estatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea AND TA.IdEstatus = 4)

	SET @CountEstCanc = (SELECT COUNT (T.IdTarea) FROM Tarea T
	JOIN TareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN Usuario Us ON TA.IdUsuario = Us.IdUsuario
	JOIN Estatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea AND TA.IdEstatus = 5)


	--IF (@CountEstPen = 0)
	--	IF (@CountEstRech = 0)
	--	BEGIN UPDATE dbo.Tarea SET IdEstatus = 3, @Resultado = 3 WHERE IdTarea = @IdTarea END
	--	ELSE
	--	BEGIN UPDATE dbo.Tarea SET IdEstatus = 4, @Resultado = 4 WHERE IdTarea = @IdTarea END
	--ELSE 
	--UPDATE dbo.Tarea SET IdEstatus = 1, @Resultado = 1 WHERE IdTarea = @IdTarea
	
	BEGIN
	IF (@CountEstRech > 0)
	BEGIN
	UPDATE dbo.Tarea SET IdEstatus = 4, Activo = 'False', @Resultado = 4 WHERE IdTarea = @IdTarea
	UPDATE dbo.TareaAprobador SET IdEstatus = 5 WHERE IdTarea = @IdTarea AND IdEstatus = 1
	END
	ELSE
	UPDATE dbo.Tarea SET IdEstatus = 1 WHERE IdTarea = @IdTarea
	IF (@CountEstApr = @CountTarea)
	UPDATE dbo.Tarea SET IdEstatus = 3, Activo = 'False', @Resultado = 3 WHERE IdTarea = @IdTarea
	END
	--SELECT @CountTarea AS Aprobadores_por_tarea, @CountEstPen AS Pendientes, @CountEstApr AS Aprobados, @CountEstRech AS Rechazados, @CountEstCanc AS CanceladoRechazo
	SELECT @Resultado AS ValorCorreo
	
END

