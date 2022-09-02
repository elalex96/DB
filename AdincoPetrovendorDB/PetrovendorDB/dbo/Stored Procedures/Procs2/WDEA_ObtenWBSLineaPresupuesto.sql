use Petrovendor
go
DROP PROCEDURE IF EXISTS WDEA_ObtenWBSLineaPresupuesto
GO
CREATE PROCEDURE WDEA_ObtenWBSLineaPresupuesto
@IdUsuario int,
@IdContrato int
AS
BEGIN
	SELECT WL.Id,WBS.WBS,IdLineaPresupuesto 
	FROM WDEA_WBSLineaPresupuesto WL
	JOIN WDEA_WBS WBS ON WL.IdWBS = WBS.Id
	AND WL.Activo = 1
	AND WBS.Activo = 1
	WHERE 
	WBS.IdContrato = @IdContrato
	ORDER BY WL.id 
	DESC
END
