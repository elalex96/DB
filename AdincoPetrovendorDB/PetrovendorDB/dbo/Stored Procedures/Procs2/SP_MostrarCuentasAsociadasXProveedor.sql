-- =============================================
-- Author:		<Abel Rivera>
-- Modificado por: <Jose Roman>
-- Create date: <22/01/2018>
-- Description:	<Se consulta las cuentas asociadas por contratista y subcontratista>
-- =============================================
CREATE PROCEDURE SP_MostrarCuentasAsociadasXProveedor
	@IdContratista INT,
	--@IdSubContratista INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN

    SELECT sb.IdCtaBancariaProveedor, p.RazonSocial, cb.Titular, cb.NumeroCuenta, tm.TipoMoneda
	FROM dbo.PV_CuentaBancaria AS cb
		INNER JOIN dbo.PV_CuentaBancariaSubContratista AS sb ON sb.IdCuentaBancaria = cb.DatoBancarioID
		INNER JOIN dbo.S_Proveedor p ON p.IdProveedor = sb.IdSubcontratista
		INNER JOIN dbo.PV_TipoMoneda tm ON tm.IdMoneda = cb.TipoMonedaID
	WHERE cb.IdProveedor = @IdContratista
		--AND sb.IdSubcontratista = @IdSubContratista
		AND cb.IsEliminado = 0
		AND sb.IsActivo = 1
END

