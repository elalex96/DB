-- =============================================
-- Author:		Manuel Cruz
-- Create date: 02-01-17
-- Description:	Hace la consulta para que en la parte Web muesre en una tabla el listado e historico de las tareas
				-- que tiene el usuario Aprobador ordenados de forma descendente
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaMostrarListaTareasAprobador] 
	-- Add the parameters for the stored procedure here
	@IdUsuario INT
 	
AS
BEGIN
	 
	SET NOCOUNT ON;

	SELECT T.IdTarea AS '# Tarea', T.NombreTarea AS 'Nombre Tarea', T.FechaRegistro AS 'Fecha de registro', E.Nombre AS 'Estatus', P.Nombre AS 'Prioridad'
	FROM TaTarea T
	LEFT JOIN TaTareaAprobador TA ON TA.IdTarea = T.IdTarea
	LEFT JOIN TaPrioridad P ON P.IdPrioridad = T.IdPrioridad
	LEFT JOIN TaEstatus E ON E.IdEstatus = T.IdEstatus
	INNER JOIN AP_Usuario U ON U.UsuarioID = TA.IdUsuario
	WHERE U.UsuarioID = @IdUsuario AND U.IsActivo = 1
	ORDER BY T.FechaRegistro DESC 
	
END


