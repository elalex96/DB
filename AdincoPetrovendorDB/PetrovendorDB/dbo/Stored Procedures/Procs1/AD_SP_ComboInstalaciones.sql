
CREATE procedure [dbo].[AD_SP_ComboInstalaciones]
	@IdContrato INT

AS
BEGIN

	SELECT
		i.IdInstalacion,
		i.NombreInstalacion
    FROM Adinco.dbo.CO_Instalacion AS i (NOLOCK)
	 JOIN adinco.dbo.CO_Contrato AS c (NOLOCK) ON c.IdAreaContractual = i.IdAreaContractual and c.IdContrato = @IdContrato
	WHERE ISNULL(i.Activo,0) = 1
		
END