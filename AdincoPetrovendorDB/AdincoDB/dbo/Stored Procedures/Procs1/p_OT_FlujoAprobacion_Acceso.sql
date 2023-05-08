-- p_OT_FlujoAprobacion_Acceso 1,3,2,0
CREATE proc p_OT_FlujoAprobacion_Acceso
@pTipoFlujoAprobacionId int,
@pIdContrato int,
@pUsuarioId int,
@pIdOTSolicitud int
as

	declare @idCC int

	select @idCC = isnull(IdCentroCosto,0)
	from OT_Solicitud 
	where IdOTSolicitud = @pIdOTSolicitud
	


	select  CreadorOT  = cast( isnull(MAX(case when fe.Orden = 1 then 1 else 0 end),0) as bit),
			AprobadorOT =cast(isnull(MAX(case when fe.Orden = 2 then 1 else 0 end),0) as bit),
			ValidadorCantOT = cast(isnull(MAX(case when fe.Orden = 3 then 1 else 0 end),0) as bit),
			GeneradorEstimacion = cast(isnull(MAX(case when fe.Orden = 4 then 1 else 0 end),0) as bit),
			AceptacionServicioOT = cast(isnull(MAX(case when fe.Orden = 5 then 1 else 0 end),0) as bit)	,
			AdminContratos = cast(isnull(MAX(case when fe.Orden = 6 then 1 else 0 end),0) as bit),
			ConsultaContratos = cast(isnull(MAX(case when fe.Orden = 7 then 1 else 0 end),0) as bit)
	
	from [AP_FlujoAprobacionEstatus] fe
	inner join [AP_FlujoAprobacionEstatusUsuarios] fu on fu.FlujoAprobacionEstatusId = fe.FlujoAprobacionEstatusId
	inner join [AP_FlujoAprobacionContratos] fc on fc.IdContrato = @pIdContrato
	inner join [AP_FlujoAprobacion] fa on fa.FlujoAprobacionId = fc.FlujoAprobacionId and
											fa.TipoFlujoAprobacionId = fe.TipoFlujoAprobacionId
	inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = fu.usuarioId and
												isnull(@idCC,0) in (0,ucc.IdCentroCosto )
	where fe.TipoFlujoAprobacionId = @pTipoFlujoAprobacionId  and
	fc.IdContrato = @pIdContrato and
	fu.usuarioId = @pUsuarioId

	