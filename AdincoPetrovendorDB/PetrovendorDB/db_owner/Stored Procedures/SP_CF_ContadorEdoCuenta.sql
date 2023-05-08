
CREATE PROCEDURE [db_owner].[SP_CF_ContadorEdoCuenta]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@anio int

AS
BEGIN
	
	select count(IdEdoCuenta)
		from CF_EdoCuentaDocumentos
		where IdProveedor = @IdProveedor
			and Año = @anio

END