Create Proc sp_CO_EliminarRegistroCEE
@pIdRegistro int
AS

	delete CO_Registro
	where idRegistro = @pIdRegistro