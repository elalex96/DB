USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CentroCostoFiltro_Grd'
)
    DROP PROCEDURE sp_CentroCostoFiltro_Grd;

/****** Object:  StoredProcedure [dbo].[sp_CentroCostoFiltro_Grd]    Script Date: 13/07/2021 01:17:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

