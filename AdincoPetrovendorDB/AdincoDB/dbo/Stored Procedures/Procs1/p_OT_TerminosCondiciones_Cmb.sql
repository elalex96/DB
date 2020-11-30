-- p_OT_TerminosCondiciones_Sel 10005
create proc p_OT_TerminosCondiciones_Cmb
@pIdContratista int
as

	select distinct t.IdTerminosYCondiciones,
		t.Nombre,
		t.Comentario
	from CO_Contratista con 
	inner join Petrovendor..S_Proveedor prov on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = con.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
	inner join PEtrovendor..TC_TerminosYCondicionesDocV2 t on t.IdProveedor = prov.Idproveedor 
	where con.IdContratista = @pIdContratista
	