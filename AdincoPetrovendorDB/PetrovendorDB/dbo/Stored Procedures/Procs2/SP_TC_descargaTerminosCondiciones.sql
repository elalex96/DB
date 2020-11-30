
CREATE PROCEDURE [dbo].[SP_TC_descargaTerminosCondiciones]
	@idTerminosCondiciones INT
AS
BEGIN
	
	SELECT Documento, Nombre,Comentario
	FROM dbo.TC_TerminosYCondicionesDocV2
	WHERE IdTerminosYCondiciones = @idTerminosCondiciones

END

