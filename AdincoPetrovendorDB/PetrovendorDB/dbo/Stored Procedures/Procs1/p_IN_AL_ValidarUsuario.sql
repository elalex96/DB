
-- p_IN_AL_ValidarUsuario 'almacenI@procura.com','procura1'
create Proc [dbo].[p_IN_AL_ValidarUsuario]
@pEmail varchar(250),
@pPassword varchar(250)
as

	select IdUsuarioPetrovendor = up.IdUsuario,
			IdUsuarioAdinco = ua.usuarioId,
			Nombre = ua.Nombre,
			FechaRegistro = ua.fchRegistro,
			ImagenPerfil = up.ImagenPerfil
	from Adinco.dbo.AP_Usuario ua
	inner join S_Usuario up on up.Correo COLLATE SQL_Latin1_General_CP1_CI_AS = ua.usuario COLLATE SQL_Latin1_General_CP1_CI_AS
	where usuario = @pEmail and
	Contraseña = @pPassword and
	isnull(ua.IsEliminado,0) = 0
