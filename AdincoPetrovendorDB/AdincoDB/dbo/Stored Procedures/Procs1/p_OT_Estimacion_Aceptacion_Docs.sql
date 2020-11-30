CREATE proc p_OT_Estimacion_Aceptacion_Docs
@pidOTEstimacion int,
@pIdAceptacion int,
@pError varchar(250) out
as

declare @pIdOt int,	
	
	@pIdContrato int,
	@pFechaInicio datetime,
	@pFechaFin datetime,
	@pIdPedido int,
	@pIdDocumento int,
	@pFolioEstimacion varchar(20)

begin try

	begin tran

select @pIdContrato = sc.idContrato,
	@pFechaInicio = e.FechaCorteInicio,
	@pFechaFin = e.FechaCorteFin,
	@pIdOt = ot.IdOTSolicitud,
	@pIdPedido = e.IdPedido,

	@pFolioEstimacion = e.FolioEstimacion
from OT_Estimacion e
inner join OT_Solicitud ot on ot.IdOTSolicitud = e.idOTSolicitud
inner join SC_Subcontrato sc on sc.IdSubcontrato = ot.IdSubcontrato

where e.IdOTEstimacion = @pidOTEstimacion and
isnull(e.Cancelada,0) = 0



	select a.AWSDocumentoId,a.Bucket,a.Folder,a.UUIDAmazon,a.NombreArchivo,a.meta,
	a.CreadoEl,SemanaDel=null,SemanaAl=null
	into #tmpDocumentos
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

	select @pIdPedido = IdPedido
	from petrovendor..MM_Aceptacionpedido
	where IdAceptacionPedido = @pIdAceptacion

	insert into petrovendor..[S_Documento_S3](
	/*IdDocumento,*/	IdTipoDocumento,	IdUsuario,		IdTipoValidacionDocumento,		
	IdProveedor,	Activo,				Documento,		CreadoPor,
	CreadoEl,		ModificadoPor,		ModificadoEl,	Descripcion,
	Carpeta,		Identificador,		Mime,			Extension,
	NombreDocumento,Duplicado,			SizeDocumento,	IdDocumentoTabla
	)
	select 12/*Aceptación pedido*/,p.CreadoPor,null,
	p.IdProveedorCompras,1,				null,			p.CreadoPor,
	getdate(),		null,				null,			null,
	tmp.Folder + '/',tmp.UUIDAmazon,	tmp.meta,		null	,
	tmp.NombreArchivo,null,				null,			null	
	from petrovendor..MM_Pedido p
	inner join #tmpDocumentos tmp on tmp.AWSDocumentoId = tmp.AWSDocumentoId
	where IdPedido = @pIdPedido

	select @pIdDocumento = scope_identity()

	
	insert into petrovendor..[MM_AceptacionDocumento](
	IdAceptacionDocumento,IdDocumento,Comentario,NombreDocumento,Activo
	)
	select @pIdAceptacion,@pIdDocumento,'Documentos importados de manera automática por estimación '+@pFolioEstimacion,
	tmp.NombreArchivo,1
	from #tmpDocumentos  tmp 

	 


	drop table #tmpDocumentos

	commit tran
end try
begin catch

	rollback tran
	set @pError = cast(error_line() as varchar) + error_message() 
end catch

