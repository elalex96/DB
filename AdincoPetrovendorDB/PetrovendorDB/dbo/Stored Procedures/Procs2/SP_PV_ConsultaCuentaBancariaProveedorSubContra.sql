-- =============================================
-- Author:		<Alexander G>
-- Create date: <03/10/2017>
-- Description:	<Cosnulta los datos de las cuentas bancarias y la asocioacion al subcontratista>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaCuentaBancariaProveedorSubContra] 
	-- Add the parameters for the stored procedure here
	@IdCuenta int,
	@IdSubContratista int
AS
BEGIN
	
	DECLARE @SubContrastista NVARCHAR(MAX) = (SELECT RazonSocial FROM S_Proveedor WHERE IdProveedor = @IdSubContratista)

	SELECT CB.Titular, B.Banco, CB.Sucursal, CB.NumeroCuenta, CB.CuentaClabe, TM.TipoMoneda, CONCAT(P.RazonSocial, ' ', P.RegimenCapital) AS RazonSocial, 
		TCI.NombreCuentaInterbancaria, @SubContrastista AS SubContratista
	FROM PV_CuentaBancaria AS CB 
		INNER JOIN S_Proveedor AS P ON P.IdProveedor = CB.IdProveedor
		INNER JOIN PV_Banco AS B ON B.BancoID = CB.BancoID
		INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = CB.TipoMonedaID
		INNER JOIN PV_TipoCuentaInterbancaria AS TCI ON TCI.IdTipoCuentaInterbancaria = CB.TipoCuentaInterbancaria
	WHERE CB.DatoBancarioID = @IdCuenta
END

