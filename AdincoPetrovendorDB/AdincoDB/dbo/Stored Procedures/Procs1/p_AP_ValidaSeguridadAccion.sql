CREATE proc p_AP_ValidaSeguridadAccion
@pIdUsuario int,
@pUrlAccion varchar(150),
@pPermitir bit out
as
	set @pPermitir = 0
	

	select @pPermitir = 1
	from AP_Usuario u
	inner join [AP_PerfilUsuario] pu on pu.UsuarioID = u.UsuarioID
	inner join [dbo].[AP_Perfil] per on per.IdPerfil = pu.PerfilID
	inner join AP_MenuDPorRol mRol on mRol.IdRol = per.IdRol
	inner join AP_MenuD men on men.MenuId = mRol.IdMenu and
					men.url like '%' + rtrim(@pUrlAccion) + '%'
	where u.UsuarioID = @pIdUsuario and mrol.visible = 1

	--Revisar si es rol de administrador
	if @pPermitir = 0
	begin
		select @pPermitir = 1
		from AP_Rol rol
		inner join AP_perfil per on per.IdRol = rol.IdRol
		inner join AP_PerfilUsuario pu on pu.PerfilID = per.IdPerfil
		where pu.UsuarioID = @pIdUsuario AND
		ROL.IdRol = 1
	end

	SELECT @pPermitir