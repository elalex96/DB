-- =============================================
-- Author:		<Jose Roman>
-- Create date: <22/01/2018>
-- Description:	<Se agrega funcionalidad para que permita un predeterminado por Tipo de moneda y se agregan parametros de contrato>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SegInsertarCuenta]
	-- Add the parameters for the stored procedure here
	@Banco int,
	@Titular nvarchar(200),
	@Sucursal nvarchar(200),
	@NumeroCuenta nvarchar(50),
	@CuentaClabe nvarchar(20),
	@TipoMoneda int,
	@Predeterminado bit,
	@IdProveedor int,
	@NombreCuentaInterbancaria INT,
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

    -- Insert statements for procedure here
	
	if @Predeterminado > 0
	begin
		update PV_CuentaBancaria
			set Predeterminado = 0
			where Predeterminado = 1
					AND IdProveedor = @IdProveedor
					AND TipoMonedaID = @TipoMoneda
	end

	insert into dbo.PV_CuentaBancaria
	(
		BancoID,
		Titular,
		Sucursal,
		NumeroCuenta,
		CuentaClabe,
		TipoMonedaID,
		IdProveedor,
		Predeterminado,
		TipoCuentaInterbancaria,
		IsEliminado
	 )
	values
	(
		@Banco,
		@Titular,
		@Sucursal,
		@NumeroCuenta,
		@CuentaClabe,
		@TipoMoneda,
		@IdProveedor,
		@Predeterminado,
		@NombreCuentaInterbancaria,
		0
	)


	select @@identity

END
