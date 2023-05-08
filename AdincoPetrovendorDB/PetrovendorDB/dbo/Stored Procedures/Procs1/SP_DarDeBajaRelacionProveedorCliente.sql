-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23/01/2018>
-- Description:	<Dar de baja relacion Proveedor Cliente>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DarDeBajaRelacionProveedorCliente]
	@IdCtaBancariaProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	update PV_CuentaBancariaSubContratista
		set IsActivo = 0
		where IdCtaBancariaProveedor = @IdCtaBancariaProveedor

	UPDATE dbo.PV_DocumentoCuentaBancaria 
		SET IsActivo = 0 
		WHERE IdCuentaBancaria = @IdCtaBancariaProveedor
END

