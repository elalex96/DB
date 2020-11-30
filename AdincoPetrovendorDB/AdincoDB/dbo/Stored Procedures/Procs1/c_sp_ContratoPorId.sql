CREATE PROCEDURE c_sp_ContratoPorId
@IdContrato int
as
begin
	SELECT	
			CO_Contrato.NumeroContrato + ' - ' + CO_AreaContractual.NombreAreaContractual AS Contrato,
			CO_Contrato.IdContrato,
			ISNULL(CO_AreaContractual.IdAreaContractual, 0) as IdAreaContractual,
			CO_Contrato.NumeroContrato,
			CO_AreaContractual.NombreAreaContractual
			
		FROM CO_Contrato 
		INNER JOIN CO_AreaContractual
		ON CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
	WHERE IdContrato = @IdContrato
end
