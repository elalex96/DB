
create proc p_OT_ObtenerArchivoAdjuntoInfo
(
	@pIdAdjunto	int
)
as
begin
	select		pa.AWSDocumentoId,
				awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta,

				pa.IdAdjunto,
				pa.IdSubcontrato
				
	from		SC_Adjunto				pa
	inner join	AWS_Documentos			awsd
	on			pa.AWSDocumentoId		=	awsd.AWSDocumentoId
	where		pa.IdAdjunto			=	@pIdAdjunto
end

