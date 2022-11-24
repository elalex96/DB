CREATE Proc [dbo].[sp_CO_EliminarRegistroCEE]
@pIdRegistro int
AS

	delete [CO_RegistroMarkup]
	where GastoId = @pIdRegistro
	delete CO_Registro
	where idRegistro = @pIdRegistro