
Create Proc sp_S_InsertarNotificacionError
@pIdNotificacion int,
@pError varchar(350)
As

	declare @pIdNotificacionError int

	select @pIdNotificacionError = isnull(max(IdNotificacionError),0) + 1
	from [S_NotificacionError]

	insert into [dbo].[S_NotificacionError](
		IdNotificacionError,
		IdNotificacion,
		Error,
		FechaRegistro
	)
	values(
		@pIdNotificacionError,
		@pIdNotificacion,
		@pError,
		getdate()
	)
	

