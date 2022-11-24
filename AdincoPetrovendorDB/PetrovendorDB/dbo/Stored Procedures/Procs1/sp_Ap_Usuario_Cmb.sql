
CREATE proc sp_Ap_Usuario_Cmb  
(  
	@IdContrato  int  
)  
as  
begin  
	select		u.UsuarioID,  
				u.Usuario,  
				u.Nombre   
	from		Ap_Usuario			u  
	inner join	AP_PerfilUsuario	pu  
	on			u.UsuarioID			=	pu.UsuarioID
	and			IsActivo			=	1
	inner join	AP_Perfil			p  
	on			p.IdPerfil			=	pu.PerfilID  
	where		p.IdContrato		=	@IdContrato  
	AND			ISNULL(IsGrupo,0)	=	0
end  
