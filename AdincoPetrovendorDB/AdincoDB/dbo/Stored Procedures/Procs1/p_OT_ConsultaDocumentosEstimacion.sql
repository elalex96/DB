------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE procedure p_OT_ConsultaDocumentosEstimacion
@pIdOt int,
@pIdContrato int = 0,
@pIdUsuario int = 0,
@pFechaInicio DateTime=null,
@pFechaFin DateTime=null
as
begin 

	select a.AWSDocumentoId,a.Bucket,a.Folder,a.UUIDAmazon,a.NombreArchivo,a.meta,
	a.CreadoEl,SemanaDel=null,SemanaAl=null
	from [dbo].[OT_ProgramaAdjunto] ot
	inner join AWS_Documentos a on a.AWSDocumentoId = OT.AWSDocumentoId
	where IdOTSolicitud = @pIdOt
	union 
	select a.AWSDocumentoId,a.Bucket,a.Folder,a.UUIDAmazon,a.NombreArchivo,a.meta,
	a.CreadoEl, SemanaDel = ots.FechaInicioSemana,SemanaAl = ots.FechaFinSemana
	from [dbo].[OT_ProgramaAdjuntoSemana] ots
	inner join OT_SolicitudMaterial otm on otm.IdOTSolicitudMaterial = ots.IdOTSolicitudMaterial
	inner join AWS_Documentos a on a.AWSDocumentoId = ots.AWSDocumentoId
	where otm.IdOTSolicitud = @pIdOt and
	(
		(@pFechaInicio between ots.FechaInicioSemana and  ots.FechaFinSemana) OR
		(@pFechaFin between ots.FechaInicioSemana and  ots.FechaFinSemana) OR
		(
			@pFechaInicio <=  ots.FechaFinSemana and @pFechaInicio <= ots.FechaInicioSemana AND
			@pFechaFin >=  ots.FechaFinSemana and @pFechaFin >= ots.FechaInicioSemana 
		) 
	)
	order by SemanaDel desc,a.CreadoEl desc

end




