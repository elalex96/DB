--exec sp_FlujosAprobacionUsuario_grd @pIdContrato=3,@pIdContratista=2,@pFlujoAprobacionEstatusId=1,@pTipoFlujoAprobacionId=1
-- sp_FlujosAprobacionUsuario_grd 10038,10013,1,1
create proc sp_FlujosAprobacionUsuario_grd
(
	@pIdContrato				int,
	@pIdContratista				int,
	@pFlujoAprobacionEstatusId	int,
	@pTipoFlujoAprobacionId		int
)
as
begin
	/*
	declare		@pFlujoAprobacionEstatusId	int,
				@pTipoFlujoAprobacionId		int

				select	@pFlujoAprobacionEstatusId	= 1,
						@pTipoFlujoAprobacionId		= 1
						*/
	select		u.UsuarioID,
				Usuario,
				Nombre,
				Activo								=		 0,
				CentroCosto							=		cast('' as varchar(2000))
	into		#tmp1
	from		AP_Perfil							per
	inner join	AP_PerfilUsuario					pu 
	on			pu.PerfilID							=		per.IdPerfil
	inner join	AP_Usuario							u	
	on			u.UsuarioID							=		pu.UsuarioID
	inner join	CO_Contrato							c
	on			per.IdContrato						=		c.IdContrato
	
	where		u.isActivo							=		1
	and			per.IdContrato						=		@pIdContrato
	and			c.IdContratista						=		@pIdContratista
	group by	u.UsuarioID,
				Usuario,
				Nombre
	
	select		per.IdContrato,
				u.UsuarioID,
				Usuario,
				Nombre,
				Activo								=		 1,
				faeu.ActivarNotificacion
	into		#tmp2
	from		AP_Perfil							per
	inner join	AP_PerfilUsuario					pu 
	on			pu.PerfilID							=		per.IdPerfil
	inner join	AP_Usuario							u	
	on			u.UsuarioID							=		pu.UsuarioID
	inner join	CO_Contrato							c
	on			per.IdContrato						=		c.IdContrato
	left join	AP_FlujoAprobacionEstatusUsuarios	faeu
	on			faeu.UsuarioId						=		u.UsuarioID
	and			FlujoAprobacionEstatusId			=		@pFlujoAprobacionEstatusId
	inner join	AP_FlujoAprobacionEstatus			fa
	on			fa.FlujoAprobacionEstatusId			=		faeu.FlujoAprobacionEstatusId
	and			fa.TipoFlujoAprobacionId			=		@pTipoFlujoAprobacionId
	where		u.isActivo							=		1
	and			per.IdContrato						=		@pIdContrato
	and			c.IdContratista						=		@pIdContratista
	group by	u.UsuarioID,
				Usuario,
				Nombre,
				faeu.ActivarNotificacion, per.IdContrato

	--select '#tmp2',* from #tmp2

	select		t1.UsuarioID,
				t1.Usuario,
				t1.Nombre,
				Activo				=	case	when max(t2.Activo) is null then cast(0 as bit) else cast(max(t2.Activo) as bit) end,
				CentroCosto			=	dbo.fn_OT_GetUsuariosCC(0,t1.UsuarioID),
				ActivarNotificacion	=	cast(isnull(t2.ActivarNotificacion,0) as bit)
	from		#tmp1				t1
	left join	#tmp2				t2
	on			t1.UsuarioID		=	t2.UsuarioID
	group by	t1.UsuarioID,
				t1.Usuario,
				t1.Nombre,
				t1.CentroCosto,
				t2.ActivarNotificacion
	order by	Nombre
end

