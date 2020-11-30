create PROCEDURE [dbo].[SP_CO_ConsultaAños]
AS
BEGIN

SELECT 
	DISTINCT anio 
	FROM dbo.AP_Calendario 
	WHERE anio BETWEEN 2010 AND 2035
END 