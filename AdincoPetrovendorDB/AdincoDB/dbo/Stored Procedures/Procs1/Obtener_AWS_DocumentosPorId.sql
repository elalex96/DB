CREATE PROCEDURE  Obtener_AWS_DocumentosPorId
    @AWSDocumentoId INT
AS    
BEGIN       
	SELECT AWSDocumentoId,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta
		FROM AWS_Documentos (NOLOCK) WHERE AWSDocumentoId = @AWSDocumentoId
END




