create procedure SP_PrimerInicioSesion
	@IdEdoCuenta int
as 
begin
	select IdTipoUsuario from S_USUARIO usuario INNER JOIN dbo.S_UsuarioProveedor uProv ON uProv.IdUsuario = usuario.IdUsuario
	where IdTipoUsuario in (4, 5) and Activo = 1 AND uProv.IdProveedor= @IdEdoCuenta
end

