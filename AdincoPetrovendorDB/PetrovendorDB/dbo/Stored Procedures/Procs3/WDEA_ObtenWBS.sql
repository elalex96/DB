CREATE PROCEDURE [dbo].[WDEA_ObtenWBS]
@IdUsuario int,
@IdContrato int
AS
BEGIN
	SELECT W.Id,W.WBS,W.CreadoEl,W.CreadoPor,W.IdContrato,W.Activo
	FROM WDEA_WBS W
	LEFT JOIN WDEA_WBSLineaPresupuesto WLP
		ON W.Id = WLP.IdWBS
		AND WLP.Activo = 1 
		AND WLP.IdContrato= @IdContrato
	WHERE 
	W.ACTIVO = 1
	AND WLP.Id IS NULL 
	AND W.IDCONTRATO = @IdContrato
	
END