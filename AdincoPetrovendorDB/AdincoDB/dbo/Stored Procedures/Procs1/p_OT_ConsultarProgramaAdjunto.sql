
create proc p_OT_ConsultarProgramaAdjunto
(
	@pIdOTSolicitud int
)
as
begin

	select		pa.ID,
				pa.IdOTSolicitud,
				NombreAdjunto			=	d.NombreArchivo,
				Adjunto					=	'',
				pa.CreadoPor,
				pa.CreadoEl,
				pa.AWSDocumentoId,
				UUIDAmazon,
				Bucket
	from		OT_ProgramaAdjunto		pa
	inner join	AWS_Documentos			d
	on			pa.AWSDocumentoId		=	d.AWSDocumentoId
	where		IdOTSolicitud			=	@pIdOTSolicitud
end