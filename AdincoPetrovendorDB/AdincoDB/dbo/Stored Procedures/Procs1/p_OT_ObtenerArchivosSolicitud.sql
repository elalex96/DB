CREATE proc p_OT_ObtenerArchivosSolicitud
(
	@pIdOTSolicitud	int
)
as
begin
	select		PA.ID,
				sm.IdOTSolicitud,
				awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta
	from		OT_ProgramaAdjuntoSemana		pa
	inner join	AWS_Documentos					awsd
	on			pa.AWSDocumentoId				=	awsd.AWSDocumentoId
	inner join	OT_SolicitudMaterial			sm
	on			sm.IdOTSolicitudMaterial		=	pa.IdOTSolicitudMaterial
	inner join	OT_Solicitud					s
	on			s.IdOTSolicitud					=	sm.IdOTSolicitud
	where		s.IdOTSolicitud					=	@pIdOTSolicitud

	union

	select		PA.ID,
				s.IdOTSolicitud,
				awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta
	from		OT_ProgramaAdjunto		pa
	inner join	AWS_Documentos					awsd
	on			pa.AWSDocumentoId				=	awsd.AWSDocumentoId	
	inner join	OT_Solicitud					s
	on			s.IdOTSolicitud					=	pa.IdOTSolicitud
	where		s.IdOTSolicitud					=	@pIdOTSolicitud
end

