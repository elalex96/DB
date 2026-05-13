-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarCuentasBancarias]
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select cb.DatoBancarioID, cb.BancoID,b.Banco, cb.Titular, cb.Sucursal, cb.NumeroCuenta, cb.cuentaClabe, cb.TipoMonedaID,tm.TipoMoneda, cb.IdProveedor, cb.Predeterminado,
	cb.TipoCuentaInterbancaria,tcib.NombreCuentaInterbancaria, cb.EstadoCuentaDelBanco
	from PV_CuentaBancaria cb
	inner join PV_TipoCuentaInterbancaria tcib
	on cb.TipoCuentaInterbancaria = tcib.IdTipoCuentaInterbancaria
	inner join PV_Banco b
	on cb.BancoID = b.BancoID
	inner join PV_TipoMoneda tm
	on cb.TipoMonedaID = tm.IdMoneda
	where cb.IdProveedor = @IdProveedor and cb.IsEliminado = 0

END

