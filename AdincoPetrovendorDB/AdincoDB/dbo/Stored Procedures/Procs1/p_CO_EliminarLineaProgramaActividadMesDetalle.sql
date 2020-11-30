create Proc p_CO_EliminarLineaProgramaActividadMesDetalle
@pId	int
as

	delete [CO_LineaProgramaActividadMesDetalle]
	where id = @pId