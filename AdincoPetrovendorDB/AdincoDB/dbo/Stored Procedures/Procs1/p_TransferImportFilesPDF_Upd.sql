-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_TransferImportFilesPDF_Upd 3,959,'CCN-LTS1402219N38-4.pdf'
CREATE proc [dbo].[p_TransferImportFilesPDF_Upd]
@pIdContrato int,
@pIdTransfer int,
@pFileName varchar(300),
@pConcepto varchar(300),
@pNumeroPolizaContable int
as

	--select *
	--from FI_Transfer t
	--inner join CO_Contrato c on c.IdContrato = t.IdContrato
	--inner join  [dbo].[FI_TransferFilesImport] ti on ti.IdContratista = c.IdContratista and
	--												ti.FileName = rtrim(@pFileName) and 
	--												Procesado = 1 and
	--												TieneError = 0
	--inner join AWS_Documentos aws on aws.AWSDocumentoId = ti.AWSDocumentoId
	--where t.IdTransferencia =@pIdTransfer and
	--t.idContrato = @pIdContrato
	--and rtrim(isnull(@pFileName,'')) <> ''

	update FI_Transfer 
	set AWSPDFId = aws.AWSDocumentoId,
		HashSHA256  = aws.HashSHA256
	from FI_Transfer t
	inner join CO_Contrato c on c.IdContrato = t.IdContrato
	inner join  [dbo].[FI_TransferFilesImport] ti on ti.IdContratista = c.IdContratista and
													ti.FileName = rtrim(@pFileName) and 
													Procesado = 1 and
													TieneError = 0
	inner join AWS_Documentos aws on aws.AWSDocumentoId = ti.AWSDocumentoId
	where t.IdTransferencia =@pIdTransfer and
	t.idContrato = @pIdContrato
	and rtrim(isnull(@pFileName,'')) <> ''

	--select Concepto ,NumeroPolizaContable from  FI_Transfer

	update FI_Transfer
	set 
	Concepto				= @pConcepto
	,NumeroPolizaContable	= @pNumeroPolizaContable
	WHERE 
	IdTransferencia			= @pIdTransfer 
	--and idContrato			= @pIdContrato

