USE Petrovendor
GO
DROP PROC IF EXISTS SP_CC_INST_ObtenCentrosCostosInstalacion
GO
CREATE PROC SP_CC_INST_ObtenCentrosCostosInstalacion
@IdUsuario int = null,
@IdContrato int = null
AS
BEGIN
	SELECT
		IdCentroCostoInstalacion as Id,
		CC.IdCentroCosto as IdCentroCosto,
		CC.CentroCosto,	
		I.IdInstalacion as IdInstalacion,
		I.NombreInstalacion AS NombreInstalacion
	FROM  CC_CentroCostoInstalacion CCI (NOLOCK)
		JOIN Adinco.dbo.CO_Instalacion AS I (NOLOCK)
		ON CCI.IdInstalacion = I.IdInstalacion
		JOIN adinco.dbo.CO_Contrato AS C (NOLOCK) 
		ON I.IdAreaContractual = C.IdAreaContractual 
		LEFT JOIN CC_CentroCosto CC
		ON CCI.IdCentroCosto = CC.IdCentroCosto
	WHERE  CCI.Activo = 1 
		AND c.IdContrato = @IdContrato
		  ORDER BY CC.CentroCosto,
		  I.NombreInstalacion ASC
END
