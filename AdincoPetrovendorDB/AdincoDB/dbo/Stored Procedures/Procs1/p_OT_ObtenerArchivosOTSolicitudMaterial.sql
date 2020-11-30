CREATE proc p_OT_ObtenerArchivosOTSolicitudMaterial --5245,'20200601','20200607'
(
	@pIdOTSolicitudMaterial int,
	@del datetime,
	@al datetime
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
	where		PA.IdOTSolicitudMaterial		=	@pIdOTSolicitudMaterial
	AND
		PA.FechaInicioSemana	=	@del
	AND
		PA.FechaFinSemana	=	@al

end


