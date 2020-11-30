Create Proc p_EliminarEquiposAutoconsumo
@pIdContrato	int,
@pIdEquipo	int
as

	delete [PR_EquiposAutoconsumo]
	where IdContrato = @pIdContrato and
		IdEquipo = @pIdEquipo
