
CREATE procedure [db_owner].[SP_PrimerInicioSesion]
	@IdEdoCuenta int
as 
begin
	select IdTipoUsuario from S_USUARIO 
	where IdTipoUsuario in (5, 6) and Activo = 1
		and IdUsuario in (select IdUsuario from S_UsuarioProveedor where IdProveedor = @IdEdoCuenta)
end

