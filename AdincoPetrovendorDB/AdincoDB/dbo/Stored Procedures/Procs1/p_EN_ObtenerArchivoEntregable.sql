-- p_AWS_ObtenerArchivo 1
CREATE Proc [dbo].[p_EN_ObtenerArchivoEntregable]
@pAWSDocumentoId int out

as

	select 
		DocumentoEntregableId,
		idContratoEntregable,
		idInstanciaEntregable,
		Bucket,
		Folder,
		UUIDAmazon,
		NombreArchivo,
		Meta,
		CreadoPor,
		CreadoEl,
		ModificadoPor,
		ModificadoEl
	from EN_EntregableDocumento doc
	where DocumentoEntregableId = @pAWSDocumentoId
	
