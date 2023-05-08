CREATE Proc p_IN_AL_ValidarPermisoModifUsuario
@pIdUsuarioAdinco int
as

	if exists (
		select 1
		from AP_Usuario u
		inner join [dbo].[AP_PerfilUsuario] pu on pu.UsuarioID = u.UsuarioID
		inner join AP_Perfil p on p.IdPerfil = pu.PerfilID
		where u.UsuarioID = @pIdUsuarioAdinco and
		p.IdRol = 1 --ADMINISTRADOR
		AND ISNULL(U.IsGrupo,0)	=	0
		
	)
	begin
		select cast(1 as bit)
	end
	else
		select cast(0 as bit)

