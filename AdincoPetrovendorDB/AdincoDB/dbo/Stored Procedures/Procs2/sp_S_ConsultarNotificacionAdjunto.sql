Create Proc sp_S_ConsultarNotificacionAdjunto
@pIdNotificacion int
as

	select IdNotificacionAdjunto,
			IdNotificacion,
			NombreArchivo,
			Adjunto,
			CreadoPor,
			CreadoEl
	from [dbo].[S_NotificacionAdjunto] 
	where idNotificacion = @pIdNotificacion