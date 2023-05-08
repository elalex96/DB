create proc p_OT_ObtenerArchivosPrograma
(
	@pID int
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
	where		pa.ID							=	@pID

end