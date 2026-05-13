
CREATE procedure [dbo].[ME_DescargarDocumentoPorRespuesta]
	@IdRespuesta INT
AS
BEGIN
	SELECT nombre, Documento
		FROM dbo.ME_DocumentoRespuesta
		WHERE IdRespuesta = @IdRespuesta
END
