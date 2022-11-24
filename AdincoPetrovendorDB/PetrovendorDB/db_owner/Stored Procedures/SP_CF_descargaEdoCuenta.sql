
create PROCEDURE [db_owner].[SP_CF_descargaEdoCuenta]
	@IdEdoCuenta int
AS
BEGIN    
	select EdoCuenta, NombreDoc
		from CF_EdoCuentaDocumentos
		where IdEdoCuenta = @IdEdoCuenta
END
