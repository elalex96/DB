
-- p_EN_ObtenerEntregableRondas 1
create proc p_EN_ObtenerEntregableRondas 
@pIdEntregable int
as

	Select 
		r.IdRonda,
		Seleccionado = case when er.idRonda is not null then 1 else 0 end,
		r.Ronda
	from EN_Rondas r
	left join EN_EntregableRonda er on er.idRonda = r.idRonda and er.idEntregable = @pIdEntregable
