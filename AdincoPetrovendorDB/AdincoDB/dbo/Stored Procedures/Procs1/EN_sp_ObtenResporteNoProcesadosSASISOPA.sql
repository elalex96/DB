USE Adinco
GO
DROP PROCEDURE IF EXISTS EN_sp_ObtenResporteNoProcesadosSASISOPA
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 10/Marzo/2022
-- Description:	Obtiene las solicitudes de exportación no procesadas
-- =============================================
GO
CREATE PROC EN_sp_ObtenResporteNoProcesadosSASISOPA
AS
BEGIN
	SELECT * 
	FROM EN_Documentos_BitacoraReporteSASISOPA 
	WHERE Procesado = 0
	order by FechaCreacion asc
END