
Create Proc p_CO_EliminarLineaPresupuestoMes
@pIdLineaPresupuestoMes int

as

	delete CO_LineaPresupuestoMes
	where IdLineaPresupuestoMes = @pIdLineaPresupuestoMes			
		