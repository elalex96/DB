
CREATE procedure [dbo].[AD_SP_ComboInstalaciones]
	@IdContrato INT

AS
BEGIN
	SELECT
		i.IdInstalacion,
		i.NombreInstalacion
    FROM Adinco.dbo.CO_Instalacion AS i
	INNER JOIN adinco.dbo.CO_Contrato AS c ON c.IdAreaContractual = i.IdAreaContractual
	WHERE c.IdContrato = @IdContrato
		AND ISNULL(i.Activo,0) = 1
END