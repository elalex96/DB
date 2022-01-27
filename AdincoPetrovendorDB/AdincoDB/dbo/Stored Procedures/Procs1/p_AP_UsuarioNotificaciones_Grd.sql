-- p_AP_UsuarioNotificaciones_Grd 10,3
create proc p_AP_UsuarioNotificaciones_Grd
@pUsuarioId int,
@pContratoId int
as

	select t.TipoNotificacionId,
			Flujo = f.Descripcion,
			t.TipoNotificacion,
			t.Descripcion,
			Activo = cast(case when isnull(un.Desactivar,0) = 1 then 0 else 1 end as bit),
			UsuarioId = @pUsuarioId,
			ContratoId = @pContratoId
	from S_NotificacionTipoFlujo t
	left join AP_FlujoAprobacionTipos f on f.TipoFlujoAprobacionId = t.TipoFlujoAprobacionId
	left join [AP_UsuarioNotificaciones] un on un.ContratoId = @pContratoId and
												un.UsuarioId = @pUsuarioId and
												un.TipoNotificacionId = t.TipoNotificacionId
	WHERE t.Activo = 1
	group by t.TipoNotificacionId,
	f.Descripcion,
	t.TipoNotificacion,
	un.Desactivar,
	t.Descripcion