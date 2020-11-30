
-- p_AP_UsuarioNotificaciones_Seg 3,10061
create proc p_AP_UsuarioNotificaciones_Seg
@pIdContrato int,
@pUsuarioId int
as	


	select  distinct fe.FlujoAprobacionEstatusId	
	from [AP_FlujoAprobacionEstatus] fe
	inner join [AP_FlujoAprobacionEstatusUsuarios] fu on fu.FlujoAprobacionEstatusId = fe.FlujoAprobacionEstatusId
	inner join [AP_FlujoAprobacionContratos] fc on fc.IdContrato = @pIdContrato
	inner join [AP_FlujoAprobacion] fa on fa.FlujoAprobacionId = fc.FlujoAprobacionId and
											fa.TipoFlujoAprobacionId = fe.TipoFlujoAprobacionId
	inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = fu.usuarioId 
	where fe.TipoFlujoAprobacionId = 1 /*Flujo Control de Obra*/  and
	fc.IdContrato = @pIdContrato and
	fu.usuarioId = @pUsuarioId

	



