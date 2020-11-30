
CREATE procedure [dbo].[CF_EliminarCapitalContable]
	@IdCapacidadFinanciera INT

AS
BEGIN
	DELETE dbo.CF_CapacidadFinanciera
	WHERE IdCapacidadFinanciera = @IdCapacidadFinanciera
END
