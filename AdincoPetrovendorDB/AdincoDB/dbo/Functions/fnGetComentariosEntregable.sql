CREATE FUNCTION [dbo].[fnGetComentariosEntregable]
(
	@IdInstanciaEntregable INT
)
RETURNS VARCHAR(8000)
AS
BEGIN
--SET LANGUAGE Spanish;
-- FUNCION HECHA PARA LOS TABLEROS DE EQUINOR

DECLARE @COMENTARIOS VARCHAR(8000) = ''

	SELECT @COMENTARIOS =  @COMENTARIOS + ISNULL(EI.Comentario,'') + ' ' + CHAR(13)
		FROM EN_EntregableInstanciaComentario EI
			JOIN dbo.AP_Usuario U
				ON EI.UsuarioId=U.UsuarioID 
		WHERE EI.EntregableInstanciaId = @IdInstanciaEntregable
			  AND EI.Activo = 1

	RETURN @COMENTARIOS
END