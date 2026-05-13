
CREATE Proc sp_S_MarcarEnviadaNotificacion
@pIdNotificacion int,
@pModificadoPor int=0
As

	update S_Notificacion with (rowlock)
	set Enviada = 1,
		ModificadoPor = case when @pModificadoPor > 0 then @pModificadoPor else null end,
		ModificadoEl = getdate(),
		FechaEnvio = getdate()
	where IdNotificacion = @pIdNotificacion

