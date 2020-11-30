CREATE FUNCTION fnGetEliminado(@IdTareaOrigen INT)
RETURNS INT
AS
BEGIN
DECLARE @rtn INT;
	SET @rtn=(
	SELECT TOP 1
	o.IdEstatusEliminado
	FROM Petrovendor.dbo.TA_Operacion AS o
	JOIN Petrovendor.dbo.TA_Tarea AS t 
	ON t.IdOperacion = o.IdOperacion
	WHERE 
	t.IdTarea = @IdTareaOrigen
	AND o.IdTipoOperacion IN (2,9) AND ISNULL(o.IdEstatusEliminado, 0) = 0)
	RETURN @rtn;
END
