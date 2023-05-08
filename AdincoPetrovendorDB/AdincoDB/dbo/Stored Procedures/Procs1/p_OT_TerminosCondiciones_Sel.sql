-- p_OT_TerminosCondiciones_Sel 10005
create proc p_OT_TerminosCondiciones_Sel
@pIdContratista int
as

	select distinct t.*
	from CO_Contratista con 
	inner join Petrovendor..S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = con.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
	inner join PEtrovendor..TC_TerminosYCondicionesDocV2 t on t.IdProveedor = prov.Idproveedor 
	where t.IdTerminosYCondiciones = @pIdContratista
	