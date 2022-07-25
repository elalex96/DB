USE adinco
GO
DROP PROC IF EXISTS EN_ObtenObtenPlantillaConfiguracion
GO
CREATE PROC EN_ObtenObtenPlantillaConfiguracion
@ContratoId int
AS 
BEGIN 
	SELECT 
	CASE WHEN (SELECT count (1) FROM EN_InstanciasEntregable WHERE IdEntregable = CE.IdEntregable AND Activo = 1) > 0 THEN
		'SI'
		else
		'NO'
	END AS 'ProgramarEntregable',
	A.NombreArea, 
	CE.DiasAlerta,
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion, 
	CE.FechaLimiteEntregaRegulador,
	CE.IdEntregable
	FROM EN_InstanciasEntregable IE
	JOIN EN_ContratoEntregable CE 
	ON IE.IdContratoEntregable = CE.IdContratoEntregable
	JOIN EN_Area (NOLOCK) A
	ON CE.IdArea = A.idArea
	JOIN EN_Actividad ACT
	ON IE.ActividadID = ACT.ActividadID
	WHERE 
	IE.Activo = 1
	AND 
	CE.Activo = 1
	AND
	A.Activo = 1
	AND 
	ACT.Activo = 1
	AND
	CE.IdContrato = @ContratoId
end
