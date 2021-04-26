CREATE proc p_SIPACImportacion_Download
@pId int
as

	select AWS.*
	from SIPAC_ImportBitacora b
	inner join AWS_Documentos aws on aws.AWSDocumentoId = b.IdAWSExcel
	where Id = @pid 