USE Petrovendor
GO
DROP PROC IF EXISTS SP_Inst_ObtenInstalacionesPorContrato
GO
CREATE PROC SP_Inst_ObtenInstalacionesPorContrato
@IdContrato int = null,
@IdUsuario int = null
AS
BEGIN
	SELECT I.* FROM Adinco.dbo.CO_Instalacion AS I (NOLOCK)
	JOIN adinco.dbo.CO_Contrato AS C (NOLOCK) 
	ON I.IdAreaContractual = C.IdAreaContractual 
	WHERE I.Activo = 1
	AND c.IdContrato = @IdContrato
END
