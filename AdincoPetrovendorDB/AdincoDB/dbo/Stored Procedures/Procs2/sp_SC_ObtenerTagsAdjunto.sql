
CREATE PROC sp_SC_ObtenerTagsAdjunto
AS


	SELECT DISTINCT Descripcion
	FROM dbo.SC_Adjunto
	ORDER BY Descripcion
