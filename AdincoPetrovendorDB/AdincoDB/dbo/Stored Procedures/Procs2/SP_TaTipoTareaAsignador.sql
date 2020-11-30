-- =============================================
-- Author:		Manuel Cruz
-- Create date: 05-01-17
-- Description:	Realiza una consulta a la tabla TipoTarea para devolver a la parte Web los tipos de Tarea
				-- que puede asignar el usuario logeado de acuerdo al parámetro recibido @IdUsuario
				-- consultado el tipo de usuario que fue resibido
-- =============================================
CREATE PROCEDURE [dbo].[SP_TaTipoTareaAsignador] 
	-- Add the parameters for the stored procedure here
	@IdUsuario INT
AS
BEGIN
	DECLARE @TipoUsuario INT
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	CREATE TABLE #TipoTarea(Descripcion varchar(max),id int)

	INSERT INTO #TipoTarea(Descripcion,id) VALUES('-- Seleccione una opción --',0)

	INSERT INTO #TipoTarea(Descripcion,id)
	SELECT TipTap.NombreTipoTarea as Descripcion, TipTap.IdTipoTarea as id FROM TaTipo T
	JOIN TaTipoTarea TipTap ON T.IdTipoTarea = TipTap.IdTipoTarea
	JOIN TaTipoUsuario TU ON T.IdTipoUsuario = TU.IdTipoUsuario
	WHERE IdUsuario = @IdUsuario AND TU.IdTipoUsuario = 2

	SELECT Descripcion,id FROM #TipoTarea

END


