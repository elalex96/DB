
CREATE PROCEDURE [dbo].[SP_TC_ConsultarTerminosYcondiciones]
	@idProveedor INT
AS
BEGIN
	
	SELECT IdTerminosYCondiciones, Nombre, Comentario
	FROM dbo.TC_TerminosYCondicionesDocV2
	WHERE IdProveedor =  @idProveedor AND IsActivo = 1

END

