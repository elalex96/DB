create proc p_AP_UsuarioMenuAccion_Sel
@pUrl varchar(250),
@pUsuarioId int
as


	select 
		ma.IdUsuario,ma.MenuDId,ma.IdAccion,ma.Permitir
	from [dbo].[AP_MenuD] m
	inner join [dbo].[AP_UsuarioMenuAccion]  ma on ma.MenuDId = m.MenuId and ma.IdUsuario = @pUsuarioId
	inner join AP_Acciones a on a.IdAccion = ma.IdAccion
	where Url like '%'+isnull(@pUrl,'')+'%'