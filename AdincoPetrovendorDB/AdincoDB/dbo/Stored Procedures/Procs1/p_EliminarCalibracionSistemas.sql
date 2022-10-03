Create Proc p_EliminarCalibracionSistemas
@pIdCalibracion	int,
@UsuarioId INT
as
BEGIN
	EXECUTE PR_SP_InsertBitacoraCalibracion @pIdCalibracion,@UsuarioId,'Eliminación';

	delete PR_CalibracionSistemas
	where IdCalibracion = @pIdCalibracion
END