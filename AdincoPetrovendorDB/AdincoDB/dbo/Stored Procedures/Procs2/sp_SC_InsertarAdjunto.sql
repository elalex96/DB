
create Proc sp_SC_InsertarAdjunto
	@pIdAdjunto			int out,
	@pIdSubContrato		int,
	@pDescripcion		varchar(250),
	--@pAdjunto			image,
	--@pExtension		varchar(7),
	@pCreadoPor			int,
	@pAWSDocumentoId	int

As
begin
	
	select @pIdAdjunto = isnull(max(IdAdjunto),0) + 1
	from SC_Adjunto

	insert into SC_Adjunto(	IdAdjunto,		IdSubcontrato,		Descripcion,	CreadoPor,		CreadoEl,	AWSDocumentoId)
	select					@pIdAdjunto,	@pIdSubContrato,	@pDescripcion,	@pCreadoPor,	getdate(),	@pAWSDocumentoId
end
