-- =============================================
-- Author:           Daniel AC
-- Create date: 26-09-2019
-- Description: Se agrego validación de ISNULL(isEliminado,0)=0
-- =============================================
CREATE PROCEDURE [dbo].[SP_CF_ContadorEdoCuenta]
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@anio int

AS
BEGIN
	
	select count(IdEdoCuenta)
		from CF_EdoCuentaDocumentos
		where IdProveedor = @IdProveedor
			and Año = @anio
			AND ISNULL(isEliminado,0)=0

END