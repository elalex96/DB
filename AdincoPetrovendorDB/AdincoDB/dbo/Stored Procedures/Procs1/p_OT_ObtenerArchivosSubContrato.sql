CREATE proc p_OT_ObtenerArchivosSubContrato
(
	@pIdSubContrato	int
)
as
begin
	select		ID = awsd.AWSDocumentoId,
				IdOTSolicitud = 0,
				awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta,
				pa.IdSubContrato
	from		SC_Adjunto	pa
	inner join	AWS_Documentos					awsd
	on			pa.AWSDocumentoId				=	awsd.AWSDocumentoId
	
	where		pa.IdSubContrato					=	@pIdSubContrato
end

