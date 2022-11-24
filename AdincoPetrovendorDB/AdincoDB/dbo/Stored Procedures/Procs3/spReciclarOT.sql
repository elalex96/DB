
create proc spReciclarOT
(
	@pIdOTSolicitud		int,
	@pFolio				varchar(30),
	@pObjeto			varchar(600),
	@pFechaFin			datetime,
	@pFechaIni			datetime,
	@pIdUsuario			int,
	@pIdCentroCostos	int
)
as
begin
	BEGIN TRY 

		declare	@IdOTSolicitud	int,
				@prefijo varchar(50),
				@count int,
				@idSubcontrato int


		select @prefijo = PrefijoOT + '-',
		@idSubcontrato = sc.IdSubcontrato
		from SC_Subcontrato sc
		inner join OT_Solicitud ot on ot.IdSubcontrato = sc.IdSubcontrato
		where ot.IdOTSolicitud = @pIdOTSolicitud

		select @idSubcontrato = IdSubcontrato
		from OT_Solicitud
		where IdOTSolicitud = @pIdOTSolicitud


		select @count = count(*)+1
		from OT_Solicitud
		where idsubcontrato = @idSubcontrato

		set @prefijo = @prefijo + cast(@count as varchar)

		select @IdOTSolicitud = isnull(max(IdOTSolicitud),0)+1 from OT_Solicitud

		insert into OT_Solicitud
					(
						IdOTSolicitud,		IdSubContrato,		Folio,					FechaInicio,	FechaFin,				PlazoEjecucion,		CreadoPor,		CreadoEl,
						ModificadoPor,		ModificadoEl,		IsActivo,				IsEliminado,	IdPresupuesto,			Objeto,				IdOTEstatus,	FechaFinExtendida,
						IdOTEstatusAnt,		IdMatContratista,	IdMatSubcontratista,	IdCentroCosto,	ProgIniPorProveedor,	IdMoneda,			CapturaManual,	SAPPR,
						IdTerminos,			Notas,				FechaAprobacionSAPPR
					)
		select			@IdOTSolicitud,		IdSubContrato,		@prefijo,				@pFechaIni,			@pFechaFin,				PlazoEjecucion,		@pIdUsuario,	GETDATE(),
						null,				null,				IsActivo,				IsEliminado,		IdPresupuesto,			@pObjeto,			1,				FechaFinExtendida,
						IdOTEstatusAnt,		IdMatContratista,	IdMatSubcontratista,	@pIdCentroCostos,	ProgIniPorProveedor,	IdMoneda,			CapturaManual,	null,
						IdTerminos,			Notas,				null
		from			OT_Solicitud
		where			IdOTSolicitud	=	@pIdOTSolicitud


		declare	@IdOTSolicitudMaterial	int
		select	@IdOTSolicitudMaterial	= isnull(max(IdOTSolicitudMaterial),0)+1 from OT_SolicitudMaterial

		--select @IdOTSolicitud, @IdOTSolicitudMaterial 
	
		insert into		OT_SolicitudMaterial
					(
						IdOTSolicitudMaterial,		IdOTSolicitud,			IdSCMaterial,		Cantidad,				CreadoPor,			CreadoEl,		
						ModificadoPor,				ModificadoEl,			IdServicio,			FechaProgramaInicio,	FechaProgramaFin,	Comentarios 
					)
	
		select			Id = ROW_NUMBER() OVER (	ORDER BY IdOTSolicitudMaterial   )+@IdOTSolicitudMaterial,
						@IdOTSolicitud,				IdSCMaterial,		Cantidad,				@pIdUsuario,			GETDATE(),				
						null,						null,				IdServicio,				@pFechaIni,	@pFechaFin,	Comentarios 
		from			OT_SolicitudMaterial
		where			IdOTSolicitud	=	@pIdOTSolicitud
		and				Cantidad		>	0


		insert into [dbo].[OT_LineaPresupuesto](
			IdOTSolicitud,IdLineaPresupuestoMes,CreadoPor,CreadoEl
		)
		select @IdOTSolicitud,IdLineaPresupuestoMes,@pIdUsuario,getdate()
		from [OT_LineaPresupuesto]
		where IdOTSolicitud	=	@pIdOTSolicitud

	
		insert into		OT_SolicitudInstalacion
					(
						IdOTSolicitud,				IdInstalacion,		CreadoPor,		CreadoEl
					)
		select			@IdOTSolicitud,				IdInstalacion,		@pIdUsuario,	getdate()
		from			OT_SolicitudInstalacion
		where			IdOTSolicitud			=	@pIdOTSolicitud

		exec p_OT_SolicitudPrograma_Ajuste_Upd @IdOTSolicitud

		select ErrorMessage = '', IdOTSolicitud = @IdOTSolicitud
	end try
	BEGIN CATCH  
     --code to run if error occurs
	--is generated in try
		select ErrorMessage = ERROR_MESSAGE()
	END CATCH
end

