
CREATE procedure [dbo].[CF_ActualizarCapitalContable]
	@IdCapacidadFinanciera INT,
	@CapacidadFinanciera FLOAT,
	@IdTipoMoneda INT,
	@Anio INT
AS
BEGIN
	UPDATE dbo.CF_CapacidadFinanciera
		SET CapacidadFinanciera = @CapacidadFinanciera,
			IdTipoMoneda = @IdTipoMoneda,
			Anio = @Anio
		WHERE IdCapacidadFinanciera = @IdCapacidadFinanciera

	DECLARE @Activo BIT, @IdProveedor int
    
	SET @Activo = (SELECT Actual FROM dbo.CF_CapacidadFinanciera WHERE IdCapacidadFinanciera = @IdCapacidadFinanciera)
	SET @IdProveedor = (SELECT IdProveedor FROM dbo.CF_CapacidadFinanciera WHERE IdCapacidadFinanciera = @IdCapacidadFinanciera)

	IF(@Activo = 1)
	BEGIN
		UPDATE dbo.S_Proveedor
		SET CapitalContable = @CapacidadFinanciera,
			IdTipoMoneda = @IdTipoMoneda
		WHERE IdProveedor = @IdProveedor
	end
END
