
-- p_AWS_ObtenerArchivo 1
CREATE Proc [dbo].[p_Scoc_ObtenerArchivoFormatoAmazon]
@pAWSDocumentoId int out

as

	select 
		
		
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		CreadoPor,
		CreadoEl,
		ModificadoPor,
		ModificadoEl
	from SCOC_FormatoAmazon doc
	where FormatoAmazonID = @pAWSDocumentoId
	