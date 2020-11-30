-- p_AWS_ObtenerDocumentos 0
create Proc [dbo].[p_AWS_ObtenerDocumentos]
@pIdContrato int
as

	
	select 

		ID= AWSDocumentoId,
		IDPadre = isnull(rel.AWSDocumentoPadreId,0),
		doc.NombreArchivo	,
		Archivo = ''	
	from [AWS_Documentos] doc
	left join [AWS_DocumentosRelacion] rel on rel.AWSDocumentoHijoId = doc.AWSDocumentoId
	