create procedure p_AP_ListaAccionesMenuUsuario
as
begin
	select UMA.Id,A.Descripcion,U.Nombre, U.Usuario,M.InnerHtml, M.Url,UMA.Permitir from 
	AP_UsuarioMenuAccion as UMA
	join AP_Usuario as U on UMA.IdUsuario = U.UsuarioID
	join AP_MenuD as M on UMA.MenuDId = M.MenuId
	join AP_Acciones as A on UMA.IdAccion = A.IdAccion
	where UMA.Permitir = 1
end