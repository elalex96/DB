
create proc p_ActualizarFotoUsuario
@pUsuarioId int,
@pFoto image
as

	update AP_Usuario
	set Foto = @pFoto
	where UsuarioID = @pUsuarioId
