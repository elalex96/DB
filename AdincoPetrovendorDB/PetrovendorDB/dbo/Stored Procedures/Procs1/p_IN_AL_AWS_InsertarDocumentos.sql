CREATE proc [dbo].[p_IN_AL_AWS_InsertarDocumentos]
@pAWSDocumentoId	int OUT,
@pNombreArchivo	varchar(250),
@pFolder varchar(100),
@pUUIDAmazon	uniqueidentifier,
@pMeta	varchar(50),
@pBucket	varchar(50),
@pCreadoPor	int,
@pAWSDocumentoPadreId int

as

	select @pAWSDocumentoId = isnull(max(AWSDocumentoId),0) + 1
	from [AWS_Documentos]
	

	insert into [AWS_Documentos](
		AWSDocumentoId,		NombreArchivo,		UUIDAmazon,		Meta,
		Bucket,				CreadoPor,			CreadoEl,		ModificadoPor,
		ModificadoEl,		Folder)
	select @pAWSDocumentoId,@pNombreArchivo,@pUUIDAmazon,@pMeta,
	@pBucket,				@pCreadoPor,		getdate(),		null,
	null,					@pFolder

	if(isnull(@pAWSDocumentoPadreId,0) > 0)
	begin

		insert into [dbo].[AWS_DocumentosRelacion]
		select @pAWSDocumentoPadreId,@pAWSDocumentoId,getdate(),@pCreadoPor,null,null
	end
