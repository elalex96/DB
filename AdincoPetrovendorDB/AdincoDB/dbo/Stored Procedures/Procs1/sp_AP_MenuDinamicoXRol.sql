-- =============================================
-- Author:		Ricardo Camara
-- Create date: 13/06/2018
-- Description:	Para obtener menu dinamico en base a idRol
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_MenuDinamicoXRol]
    @IdRol int = 0,
	@idioma INT=0
AS
BEGIN
	SET NOCOUNT ON;

	SELECT-- M.* 
	M.MenuId,
       M.Orden,
       M.ElementId,
       M.Class,
       CASE @idioma
           WHEN 2 THEN
               M.InnerHtmlingles
           ELSE
               M.InnerHtml
       END AS InnerHtml,
       M.Url,
       M.MenuPadreId,
       M.Visible
	FROM AP_MenuDPorRol MR 
	INNER JOIN AP_MenuD M ON M.MenuId = MR.IdMenu 
	WHERE MR.IdRol = @IdRol AND MR.Visible = 1
	ORDER BY M.Orden
END


