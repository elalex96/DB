
CREATE procedure [dbo].[CF_NuevoCapitalContable]
	@IdProveedor INT,
	@CapacidadFinanciera FLOAT,
	@IdTipoMoneda INT,
	@Anio INT
AS
BEGIN
	INSERT INTO dbo.CF_CapacidadFinanciera
	(
	    IdProveedor,
	    CapacidadFinanciera,
	    IdTipoMoneda,
	    Anio,
		Actual
	)
	VALUES
	(   @IdProveedor,   -- IdProveedor - int
	    @CapacidadFinanciera, -- CapacidadFinanciera - float
	    @IdTipoMoneda,   -- IdTipoMoneda - int
	    @Anio,   -- Anio - int
	    0 -- Actual - bit
	)
END
