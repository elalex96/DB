-- =============================================
-- Author:		<Jose Roman>
-- Create date: <24/01/2018>
-- Description:	<Consulta de formatos de cuentas asociadas a un subcontratista(Procura) >
-- =============================================

CREATE procedure DB_SP_ConsultarFormatosSubContratista
	@IdSubContratista INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN

	SELECT  dcb.IdDocCuentaBancaria,
			p.RazonSocial,
			cb.NumeroCuenta
		FROM dbo.PV_CuentaBancaria AS cb
			INNER JOIN dbo.PV_CuentaBancariaSubContratista cs ON cs.IdCuentaBancaria = cb.DatoBancarioID
			INNER JOIN dbo.PV_DocumentoCuentaBancaria AS dcb ON dcb.IdCuentaBancaria = cs.IdCtaBancariaProveedor
			INNER JOIN dbo.S_Proveedor p ON p.IdProveedor = cb.IdProveedor
		WHERE cs.IdSubcontratista = @IdSubContratista
			AND cs.IsActivo = 1 
			AND dcb.IsActivo = 1
			AND cb.IsEliminado = 0

END
