Create Proc p_EliminarCalibracionSistemas
@pIdCalibracion	int 
as

	delete PR_CalibracionSistemas
	where IdCalibracion = @pIdCalibracion