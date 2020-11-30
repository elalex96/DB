CREATE proc p_ObtenerUsuariosFotos
as

	select UsuarioID,Foto
	from AP_Usuario
	where foto is not null
	AND ISNULL(IsGrupo,0)	=	0

