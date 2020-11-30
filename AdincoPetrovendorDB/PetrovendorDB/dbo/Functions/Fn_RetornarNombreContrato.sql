-- =============================================
-- Author: Pedro Acuña
-- Create date: 28/08/2018
-- Description: retornar el nombre del contrato
-- =============================================

CREATE FUNCTION Fn_RetornarNombreContrato
	( @IdContrato INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		SELECT		@retorno = CO_Contrato.NumeroContrato + N' - ' + CO_AreaContractual.NombreAreaContractual
		FROM		Adinco.dbo.CO_Contrato
		INNER JOIN	Adinco.dbo.CO_AreaContractual
			ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
		WHERE		IdContrato = @IdContrato

		RETURN @retorno
	END
