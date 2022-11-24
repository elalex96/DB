CREATE VIEW dbo.BI_Contratos
AS
SELECT 
	C.IdContrato, 
	C.NumeroContrato, 
	CC.NombreContratista, 
	AC.NombreAreaContractual, 
	TC.TipoContratoCorto
FROM CO_CONTRATO C
JOIN CO_Contratista CC
	ON C.IdContratista = CC.IdContratista
	AND C.Activo = 1
	AND ISNULL(C.ContratoFicticio,0) = 0
JOIN CO_AreaContractual AC
	ON C.IdAreaContractual = AC.IdAreaContractual
JOIN
	CO_TipoContrato TC
	ON	C.IdTipoContrato = TC.IdTipoContrato

