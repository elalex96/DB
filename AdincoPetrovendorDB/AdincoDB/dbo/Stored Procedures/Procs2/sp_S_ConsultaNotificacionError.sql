Create Proc sp_S_ConsultaNotificacionError
@pIdNotificacion int
As

	select IdNotificacionError,
		IdNotificacion,
		Error,
		FechaRegistro 
	from [S_NotificacionError]
	where IdNotificacion = @pIdNotificacion
	order by fecharegistro desc