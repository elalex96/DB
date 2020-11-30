
CREATE Proc p_IN_AL_ConsultaUsuarioAlmacen
@pIdUsuario int,
@pIdContrato int
as

	select *,
	Asignada = cast(case when ualm.IdUsuario is not null then 1 else 0 end as bit)
	from Petrovendor.dbo.IN_Almacen a
	inner join Petrovendor.[dbo].[IN_ContratoAlmacen] ca on ca.IdAlmacen = a.IdAlmacen and
										ca.IdContrato = @pIdContrato
	inner join AP_Usuario ua on ua.UsuarioID = @pIdUsuario
	inner join Petrovendor.dbo.S_Usuario up on up.Correo COLLATE SQL_Latin1_General_CP1_CI_AS = ua.Usuario COLLATE SQL_Latin1_General_CP1_CI_AS
	left join Petrovendor.dbo.S_UsuarioAlmacen ualm on ualm.IdUsuario =up.IdUsuario AND
													ualm.IdAlmacen = a.IdAlmacen
													AND ISNULL(UA.IsGrupo,0)	=	0

