CREATE PROCEDURE [dbo].[SP_MM_DescargarDocumentoAnexo]
	@IdDocumentoAnexo INT
AS
BEGIN

	SELECT Nombre, '' AS Documento, Carpeta, Identificador, Extension, Mime
		FROM dbo.MM_DocumentosAnexos
		WHERE IdDocumentoAnexo = @IdDocumentoAnexo

END