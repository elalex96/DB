
create proc p_CO_EliminarLineaProgramaActividadMes
@pIdLineaProgramaActividadMes	int 
as

	delete [CO_LineaProgramaActividadMes]
	where IdLineaProgramaActividadMes = @pIdLineaProgramaActividadMes