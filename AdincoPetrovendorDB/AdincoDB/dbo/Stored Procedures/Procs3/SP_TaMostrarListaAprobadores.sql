-- =============================================
-- Author:		Manuel Cruz
-- Create date: 02-01-17
-- Description:	Muestra en la Web la lista de aprobadores que fueron asignados a una tarea en especifico
				-- el cual se identifica por el parametro que recibe @IdTarea
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaMostrarListaAprobadores] 
	-- Add the parameters for the stored procedure here
	@IdTarea INT
AS
BEGIN
	DECLARE @NombreDestinatario NVARCHAR(MAX)
	DECLARE @Estatus NVARCHAR(MAX)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT US.Nombre AS Nombre, IsNull( TA.Comentario, '') AS Comentario, TA.Fecha AS Fecha, E.Nombre AS Estatus 
	FROM TaTarea T
	JOIN TaTareaAprobador TA ON T.IdTarea = TA.IdTarea
	JOIN AP_Usuario Us ON TA.IdUsuario = Us.UsuarioID
	JOIN TaEstatus E ON TA.IdEstatus = E.IdEstatus
	WHERE T.IdTarea = @IdTarea

END


