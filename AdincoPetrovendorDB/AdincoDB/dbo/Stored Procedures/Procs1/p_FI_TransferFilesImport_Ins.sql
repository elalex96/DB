create proc p_FI_TransferFilesImport_Ins
@pId int out,
@pIdImportacion int out,
@pIdContratista int,
@pAWSDocumentoId int,
@pProcesado bit,
@pTieneError bit,
@pError varchar(50) out,
@pCreadoPor int,
@pFileName varchar(300)
as

	select @pId = isnull(max(id),0) + 1
	from [FI_TransferFilesImport]
	if(@pAWSDocumentoId = 0)
		set @pAWSDocumentoId = null

	if(@pIdImportacion = 0)
	begin
		select @pIdImportacion = isnull(max(IdImportacion),0) + 1
		from [FI_TransferFilesImport]
	end


	insert into [FI_TransferFilesImport](
		Id,			IdImportacion,		IdContratista,		AWSDocumentoId,		Procesado,
		TieneError,	Error,				CreadoEl,			CreadoPor,			FileName
	)
	select @pId,	@pIdImportacion,	@pIdContratista,	@pAWSDocumentoId, @pProcesado,
	@pTieneError,	@pError,			getdate(),			@pCreadoPor,		@pFileName