
create PROCEDURE [db_owner].[SP_CF_EliminarEdoCuenta]
	@IdEdoCuenta int
AS
BEGIN    
	delete from CF_EdoCuentaDocumentos
		where IdEdoCuenta = @IdEdoCuenta
END
