CREATE PROCEDURE [dbo].[SP_TaObtenerEstatus] 
	-- Add the parameters for the stored procedure here
	@IdTarea INT
	
AS
BEGIN
-- =============================================
-- Author:		Manuel Cruz
-- Create date: 02-01-17
-- Description:	SP que obtiene el estatus general de la tarea de acuerdo a las variables declaradas siendo contadores de los
				-- tipos de estatus que han indicado los Aprobadores a una tarea en especifico mandando el parámetro
				-- @IdTarea desde la parte Web. También actualiza la tabla general de la Tarea y la tabla de TareaAprobador,
				-- devolviendo una variable @Resultado que sirve como identificador del tipo de correo que se va a mandar.
-- =============================================
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
    -- LAS ASIGNACIONES SE PUEDEN HACER CON EL SELECT
	--SET @CountTarea = (SELECT COUNT (T.IdTarea) FROM TaTarea T
	SELECT @CountTarea = COUNT (T.IdTarea) FROM TaTarea T
	JOIN TaTareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
	JOIN TaEstatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea

	SELECT @CountEstPen = COUNT (T.IdTarea) FROM TaTarea T
	JOIN TaTareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
	JOIN TaEstatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea AND TA.IdEstatus = 1

	SELECT @CountEstApr = COUNT (T.IdTarea) FROM TaTarea T
	JOIN TaTareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
	JOIN TaEstatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea AND TA.IdEstatus = 2

	SELECT @CountEstRech = COUNT (T.IdTarea) FROM TaTarea T
	JOIN TaTareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
	JOIN TaEstatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea AND TA.IdEstatus = 3

	SELECT @CountEstCanc = COUNT (T.IdTarea) FROM TaTarea T
	JOIN TaTareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
	JOIN TaEstatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea AND TA.IdEstatus = 4


	--IF (@CountEstPen = 0)
	--	IF (@CountEstRech = 0)
	--	BEGIN UPDATE dbo.Tarea SET IdEstatus = 3, @Resultado = 3 WHERE IdTarea = @IdTarea END
	--	ELSE
	--	BEGIN UPDATE dbo.Tarea SET IdEstatus = 4, @Resultado = 4 WHERE IdTarea = @IdTarea END
	--ELSE 
	--UPDATE dbo.Tarea SET IdEstatus = 1, @Resultado = 1 WHERE IdTarea = @IdTarea
	-- ESTE BEGIN ESTA DE MAS:
	--BEGIN
	IF (@CountEstRech > 0)
	BEGIN
	    UPDATE dbo.TaTarea 
		  SET IdEstatus = 3, 
---		  Activo = 'False',	  CUANDO SE TRATA DE CAMPOS TIPO BIT SE PUEDE HACER LA ASGINACION CON 0 Y 1 (FALSO Y VERDADERO)
		  Activo = 0,
		  @Resultado = 3 
	   WHERE IdTarea = @IdTarea
	    UPDATE dbo.TaTareaAprobador 
		  SET IdEstatus = 4 
	   WHERE IdTarea = @IdTarea AND IdEstatus = 1
	END
	ELSE
	BEGIN
	    UPDATE dbo.TaTarea SET IdEstatus = 1 WHERE IdTarea = @IdTarea
	    IF (@CountEstApr = @CountTarea)
	    UPDATE dbo.TaTarea SET IdEstatus = 2, 
	    --Activo = 'False', 
	    Activo = 0,
	    @Resultado = 2 WHERE IdTarea = @IdTarea
	END
	--SELECT @CountTarea AS Aprobadores_por_tarea, @CountEstPen AS Pendientes, @CountEstApr AS Aprobados, @CountEstRech AS Rechazados, @CountEstCanc AS CanceladoRechazo
	SELECT @Resultado AS ValorCorreo
	
END