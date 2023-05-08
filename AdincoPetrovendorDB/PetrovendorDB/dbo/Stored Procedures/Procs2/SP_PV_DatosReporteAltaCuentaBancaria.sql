-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_DatosReporteAltaCuentaBancaria]
	-- Add the parameters for the stored procedure here
	@IdTipoBanco int,
	@TitularCuenta nvarchar(200),
	@CuentaSucursal nvarchar(200),
	@NumeroCuenta nvarchar(50),
	@CuentaClave nvarchar(20),
	@IdMoneda int,
	@IdProveedor int,
	@TipoCuentaInterbancaria int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @TipoBanco NVARCHAR(MAX) = (SELECT Banco FROM PV_Banco WHERE BancoID = @IdTipoBanco)

	DECLARE @TitularCuent NVARCHAR(MAX) = (@TitularCuenta)

	DECLARE @CuentaSuc NVARCHAR(MAX) = (@NumeroCuenta)

	DECLARE @CuentaClav NVARCHAR(MAX) = (@CuentaClave)

	DECLARE @Moneda NVARCHAR(MAX) = (SELECT TipoMoneda FROM PV_TipoMoneda WHERE IdMoneda = @IdMoneda)

	DECLARE @Proveedor  NVARCHAR(MAX) = (SELECT CONCAT(RazonSocial,' ' ,RegimenCapital) FROM S_Proveedor WHERE IdProveedor = @IdProveedor) 

	DECLARE @TipoCuenta NVARCHAR(MAX) = (SELECT NombreCuentaInterbancaria FROM PV_TipoCuentaInterbancaria WHERE IdTipoCuentaInterbancaria = @TipoCuentaInterbancaria)

	SELECT @TipoBanco AS TipoBanco,
			@TitularCuent AS TitulardelaCuenta,
			@CuentaSuc AS CuentaSucursal,
			@CuentaClav AS CuentaClave,
			@Moneda AS Moneda,
			@Proveedor AS Proveedor,
			@TipoCuenta AS TipoCunetaInterbancaria
END

