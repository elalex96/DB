
CREATE procedure [dbo].[CF_CambiarCapitalContableActual]
	@IdCapacidadFinanciera INT,
	@IdProveedor int

AS
BEGIN
	UPDATE dbo.CF_CapacidadFinanciera
		SET Actual = 0
		WHERE IdProveedor = @IdProveedor

	UPDATE dbo.CF_CapacidadFinanciera
		SET Actual = 1
		WHERE IdCapacidadFinanciera = @IdCapacidadFinanciera AND IdProveedor = @IdProveedor

	DECLARE @Capital FLOAT, @IdTipoMoneda INT

	SET @Capital = (SELECT CapacidadFinanciera FROM dbo.CF_CapacidadFinanciera WHERE IdCapacidadFinanciera = @IdCapacidadFinanciera)
	SET @IdTipoMoneda = (SELECT IdTipoMoneda FROM dbo.CF_CapacidadFinanciera WHERE IdCapacidadFinanciera = @IdCapacidadFinanciera)

	UPDATE dbo.S_Proveedor
		SET CapitalContable = @Capital,
			IdTipoMoneda = @IdTipoMoneda
		WHERE IdProveedor = @IdProveedor

END
