CREATE PROCEDURE [dbo].[sp_ObtenerDocumentos]
(
    @IdTopic INT
)
AS
BEGIN
	SELECT IdDocumento, Documento, NombreArchivo, Extension FROM dbo.JA_Documento WHERE IdTopic = @IdTopic
END	
