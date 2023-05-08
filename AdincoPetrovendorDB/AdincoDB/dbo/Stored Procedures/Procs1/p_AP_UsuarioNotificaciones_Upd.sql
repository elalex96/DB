-- p_AP_UsuarioNotificaciones_Grd 10,3
create proc p_AP_UsuarioNotificaciones_Upd
@ContratoId int,
@UsuarioId int,
@TipoNotificacionId int,
@Activo bit
as

	if not exists (
		select 1
		from [AP_UsuarioNotificaciones]
		where ContratoId = @ContratoId and
		UsuarioId = @UsuarioId and
		TipoNotificacionId = @TipoNotificacionId
	)
	begin
		insert into [AP_UsuarioNotificaciones](
			ContratoId,UsuarioId,TipoNotificacionId,Desactivar,CreadoEl
		)
		values(@ContratoId,@UsuarioId,@TipoNotificacionId,case when isnull(@Activo,0) = 1 then 0 else 1 end,getdate())
	end
	else
	begin
		update [AP_UsuarioNotificaciones]
		set Desactivar = case when isnull(@Activo,0) = 1 then 0 else 1 end
		where ContratoId = @ContratoId and
		UsuarioId = @UsuarioId and
		TipoNotificacionId = @TipoNotificacionId
	end