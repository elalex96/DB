-- =============================================
-- Author:		Manuel Cruz
-- Create date: 03-01-17
-- Description:	Hace la consulta para que en la parte Web muesre en una tabla el listado e historico de las tareas
				-- que tiene el usuario Asignador ordenados de forma descendente
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaMostrarListaTareasAsignador]
	-- Add the parameters for the stored procedure here
	@IdUsuario INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT T.IdTarea AS '# Tarea', T.NombreTarea AS 'Nombre Tarea', T.FechaRegistro AS 'Fecha de registro', E.Nombre AS Estatus, P.Nombre AS Prioridad
	FROM TaTarea T
	JOIN TaTareaAsignador TA ON TA.IdTarea = T.IdTarea
	JOIN TaPrioridad P ON P.IdPrioridad = T.IdPrioridad
	JOIN TaEstatus E ON E.IdEstatus = T.IdEstatus
	JOIN AP_Usuario U ON U.UsuarioID = TA.IdUsuario
	WHERE U.UsuarioID = @IdUsuario AND U.IsActivo = 1
	ORDER BY T.FechaRegistro DESC

END


