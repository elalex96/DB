
create proc [dbo].[p_AWS_InsertarDocumento_antes]
(
	@pAWSDocumentoId		int OUT,
	@pNombreArchivo			varchar(250),
	@pFolder				varchar(100),
	@pUUIDAmazon			uniqueidentifier,
	@pMeta					varchar(200),
	@pBucket				varchar(50),
	@pCreadoPor				int,
	@pAWSDocumentoPadreId	int,
	@pHashSHA256			varchar(1000)
)
as
begin

	select @pAWSDocumentoId = isnull(max(AWSDocumentoId),0) + 1
	from [AWS_Documentos]
	

	insert into [AWS_Documentos](
									AWSDocumentoId,		NombreArchivo,		UUIDAmazon,		Meta,
									Bucket,				CreadoPor,			CreadoEl,		ModificadoPor,
									ModificadoEl,		Folder,				HashSHA256)
	select							@pAWSDocumentoId,	@pNombreArchivo,	@pUUIDAmazon,	@pMeta,
									@pBucket,			@pCreadoPor,		getdate(),		null,
									null,				@pFolder,			@pHashSHA256

	if(isnull(@pAWSDocumentoPadreId,0) > 0)
	begin

		insert into [dbo].[AWS_DocumentosRelacion]
		select @pAWSDocumentoPadreId,@pAWSDocumentoId,getdate(),@pCreadoPor,null,null
	end
end