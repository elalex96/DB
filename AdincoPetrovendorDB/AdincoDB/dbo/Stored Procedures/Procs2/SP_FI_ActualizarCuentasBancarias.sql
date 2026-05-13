-- =============================================
-- Author:		Daniel AC
-- Create date: 24/05/2017
-- Description:	Obtiene la razon social del subcontratista
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ActualizarCuentasBancarias] 
	-- Add the parameters for the stored procedure here
	@Titular nvarchar(300),
	@BancoID int,
	@Sucursal nvarchar(300),
	@NumeroCuenta nvarchar(300),
	@CuentaClave nvarchar(300) ,
	@NumeroTarjeta nvarchar(300),
	@IdTipoCuenta int ,
	@Predeterminado bit,
	@TipoMonedaID int ,
    @DatoBancarioID int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   	UPDATE PV_CuentaBancaria
	SET 
	Titular= @Titular,
	BancoID  = @BancoID,
	Sucursal = @Sucursal,
	NumeroCuentA = @NumeroCuenta,
	CuentaClave = @CuentaClave,
	NumeroTarjeta = @NumeroTarjeta,
	IdTipoCuenta = @IdTipoCuenta,
	Predeterminado = @Predeterminado,
	TipoMonedaID = @TipoMonedaID
	WHERE DatoBancarioID = @DatoBancarioID


END

