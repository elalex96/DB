CREATE FUNCTION [dbo].[fnGetComentariosEntregable]
(
	@IdInstanciaEntregable INT
)
RETURNS VARCHAR(8000)
AS
BEGIN
--SET LANGUAGE Spanish;

DECLARE @COMENTARIOS VARCHAR(8000) = ''

	SELECT @COMENTARIOS =  @COMENTARIOS + ISNULL(U.Nombre,'') + ' el ' + CONVERT(VARCHAR(16), EI.CreadoEl, 20) +
	' Comento: '+ ISNULL(EI.Comentario,'') + CHAR(13)
		FROM EN_EntregableInstanciaComentario EI
			JOIN dbo.AP_Usuario U
				ON EI.UsuarioId=U.UsuarioID 
		WHERE EI.EntregableInstanciaId = @IdInstanciaEntregable
			  AND EI.Activo = 1

	RETURN @COMENTARIOS
END