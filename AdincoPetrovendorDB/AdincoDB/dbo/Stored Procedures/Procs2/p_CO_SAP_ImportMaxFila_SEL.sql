CREATE PROC p_CO_SAP_ImportMaxFila_SEL
@pIdContratista INT
AS
BEGIN
	SELECT *
	FROM [CO_SAP_ImportMaxFila]
	WHERE IdContratista = @pIdContratista
END