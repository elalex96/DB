

Create Proc sp_S_ActualizarNotificacionTareaBitacora
 @pIdTareaBitacora int
as

	update [S_NotificacionTareaBitacora]
	set [FinEjecucion] = getdate()
	where IdTareaBitacora = @pIdTareaBitacora
