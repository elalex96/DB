CREATE proc p_OT_ObtenerArchivosOTSolicitud
(
	@pIdOTSolicitud int
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
	where		sm.IdOTSolicitud				=	@pIdOTSolicitud

	union 

	select pa.ID,
			PA.IdOTSolicitud,
			awsd.Bucket,
				awsd.Folder,
				awsd.UUIDAmazon,
				awsd.NombreArchivo,
				awsd.Meta
	from [dbo].[OT_ProgramaAdjunto] pa
	INNER JOIN AWS_Documentos					awsd
	on		   pa.AWSDocumentoId				=	awsd.AWSDocumentoId
	WHERE PA.IdOTSolicitud = @pIdOTSolicitud

end
