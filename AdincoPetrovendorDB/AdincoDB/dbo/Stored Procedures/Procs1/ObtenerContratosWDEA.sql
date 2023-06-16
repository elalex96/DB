CREATE PROCEDURE ObtenerContratosWDEA
AS
BEGIN
    SET NOCOUNT ON;
    
	SELECT CO_Contrato.IdContrato, CO_Contrato.IdAreaContractual, CO_Contrato.NumeroContrato, CO_Contrato.DescripcionContrato 
	FROM CO_Contrato
	INNER JOIN DEA_Contratos 
	ON CO_Contrato.IdContrato = DEA_Contratos.IdContrato
END;