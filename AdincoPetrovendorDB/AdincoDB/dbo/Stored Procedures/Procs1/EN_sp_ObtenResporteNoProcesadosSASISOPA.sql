CREATE PROC EN_sp_ObtenResporteNoProcesadosSASISOPA
AS
BEGIN
	SELECT * 
	FROM EN_Documentos_BitacoraReporteSASISOPA 
	WHERE Procesado = 0
	order by FechaCreacion asc
END