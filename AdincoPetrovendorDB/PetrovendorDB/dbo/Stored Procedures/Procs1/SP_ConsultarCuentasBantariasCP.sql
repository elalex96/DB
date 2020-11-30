-- =============================================
-- Author:		<Jose Roman>
-- Create date: <23/01/2018>
-- Description:	<Consulta de cuentas bancarias disponibles para asociar>
-- =============================================
CREATE PROCEDURE SP_ConsultarCuentasBantariasCP
	@IdProveedor INT,
	@IdSubContratista INT,
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

	select cb.DatoBancarioID, 
			cb.Titular, 
			cb.NumeroCuenta, 
			cb.CuentaClabe,
			tcib.NombreCuentaInterbancaria,
			tm.TipoMoneda
		FROM PV_CuentaBancaria cb 
			INNER join PV_TipoCuentaInterbancaria tcib on cb.TipoCuentaInterbancaria = tcib.IdTipoCuentaInterbancaria
			INNER JOIN dbo.PV_TipoMoneda tm ON tm.IdMoneda = cb.TipoMonedaID
	where cb.IdProveedor = @IdProveedor and IsEliminado = 0
		AND cb.TipoMonedaID NOT IN (SELECT DISTINCT cb.TipoMonedaID 
									FROM PV_CuentaBancariaSubContratista cs
										INNER JOIN dbo.PV_CuentaBancaria cb ON cb.DatoBancarioID = cs.IdCuentaBancaria
									WHERE cb.IdProveedor = @IdProveedor AND cb.IsEliminado = 0 AND cs.IdSubcontratista = @IdSubContratista AND cs.IsActivo = 1)

END

