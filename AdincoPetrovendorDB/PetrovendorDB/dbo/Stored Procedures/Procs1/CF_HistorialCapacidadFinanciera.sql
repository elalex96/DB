
CREATE procedure [dbo].[CF_HistorialCapacidadFinanciera]
	@IdProveedor INT

AS
BEGIN
	SELECT IdCapacidadFinanciera,
			CapacidadFinanciera,
			IdTipoMoneda,
			Anio,
			Actual
		FROM dbo.CF_CapacidadFinanciera
		WHERE IdProveedor = @IdProveedor
END

