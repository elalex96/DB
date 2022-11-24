
CREATE proc [dbo].[sp_CentroCostoFiltro_Grd]
as
begin

	--select @IdCentroCostos = 331, @IdProveedor = 907

	select		ccf.IdCentroCosto,
				CentroCosto				=	cc.CentroCosto,
				ccf.IdProveedor,
				Proveedor				=	p.RazonSocial,
				ccf.IdUsuario,
				Usuario					=	u.Nombre
	from		CentroCostoFiltro		ccf
	inner join	CC_CentroCosto			cc
	on			ccf.IdCentroCosto		=	cc.IdCentroCosto
	left join	S_Proveedor				p
	on			ccf.IdProveedor			=	p.IdProveedor
	and			cc.IdProveedor			=	p.IdProveedor
	and			p.IdProveedor			is not null
	and			cc.IdProveedor			is not null
	inner join	S_Usuario				u
	on			u.IdUsuario				=	ccf.IdUsuario
	and			u.IsEliminado			=	0
	and			u.Activo				=	1
	and			ccf.Activo				=	1
	--where		p.IdProveedor			is not null
	--and			cc.IdProveedor			is not null
	
			
end