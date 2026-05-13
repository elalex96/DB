

Create Proc sp_S_ActualizarFinNotificacionTareaBitacora
 @pIdTareaBitacora int,
@pTieneError bit
as

	update [S_NotificacionTareaBitacora]
	set [FinEjecucion] = getdate(),
		TieneError = @pTieneError
	where IdTareaBitacora = @pIdTareaBitacora