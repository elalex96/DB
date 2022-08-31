use Petrovendor
GO
DROP PROCEDURE IF EXISTS WDEA_ObtenWBS
GO
CREATE PROCEDURE WDEA_ObtenWBS
@IdUsuario int,
@IdContrato int
AS
BEGIN
	SELECT Id,WBS,CreadoEl,CreadoPor,IdContrato,Activo
	FROM WDEA_WBS
	WHERE 
	ACTIVO = 1
	AND 
	IDCONTRATO = @IdContrato
END
