
create proc p_OT_CentroCostos_Cmb2
	@pIdContrato	int,
	@pUsuarioId		int
as
begin
	select		cc.IdCentroCosto,
				cc.CentroCosto ,
				cc.IdProveedor
	from		petrovendor..Cc_centrocosto						cc
	inner join	Adinco..CO_Contrato								c 
	on			c.IdContrato									=		@pIdContrato
	inner join	Adinco..CO_Contratista							cont 
	on			cont.IdContratista								=		c.IdContratista
	inner join	petrovendor..s_proveedor						prov 
	on			prov.RFC collate SQL_Latin1_General_CP1_CI_AS	=		cont.RFC COLLATE SQL_Latin1_General_CP1_CI_AS  
	and			prov.IdProveedor								=		cc.IdProveedor
	where		cc.IsActivo										=		1
	group by	cc.IdCentroCosto,
				cc.CentroCosto ,
				cc.IdProveedor
	order by	cc.CentroCosto

end

