
CREATE Proc p_IN_AL_ConsultaUsuario
@pIdContrato int
as

	select IdUsuario = uadinco.UsuarioID,ca.IdContrato, u.Nombre,u.Correo
	from Petrovendor.dbo.IN_Almacen a
	inner join Petrovendor.[dbo].[IN_ContratoAlmacen] ca on ca.IdAlmacen = a.IdAlmacen
	INNER JOIN Petrovendor.[dbo].[S_UsuarioAlmacen] ua on ua.IdAlmacen = ca.IdAlmacen
	inner join Petrovendor.dbo.S_Usuario u on u.Idusuario = ua.IdUsuario
	inner join AP_Usuario uadinco on uadinco.Usuario COLLATE SQL_Latin1_General_CP1_CI_AS = u.Correo COLLATE SQL_Latin1_General_CP1_CI_AS
	where ca.IdContrato = @pIdContrato AND
	U.IsEliminado = 0
	AND ISNULL(uadinco.IsGrupo,0)	=	0
	group by ca.IdContrato,uadinco.UsuarioID,u.Nombre,u.Correo

