
create proc [dbo].[sp_PermisosUsuario_Get](
	@IdUsuario	int,
	@IdGenerico	int,
	@table		varchar(50)
)
as
begin
		select		ru.IdRolUsuario,
					ru.IdRol,
					ru.IdUsuario
		from		CAT_FlujosDetalle	fd
		inner join	Aprobaciones		a
		on			fd.IdFLujoDetalle	=	a.IdFlujoDetalle
		inner join	AprobacionesDetalle	ad
		on			a.IdAprobacion		=	ad.IdAprobacion
		inner join	RolesFlujosDetalle	rfd
		on			rfd.IdFlujoDetalle	=	fd.IdFlujoDetalle
		inner join	RolesUsuarios		ru
		on			ru.IdRol			=	rfd.IdRol
		where		ad.Aprobado			=	0
		and			fd.Activo			=	1
		and			a.IdGenerico		=	@IdGenerico
		and			a.Tabla				=	@table
		and			ru.IdUsuario		=	@IdUsuario

end

