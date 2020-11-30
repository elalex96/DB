CREATE PROCEDURE dbo.sp_obtenerEntregablesPorContrato
		@IdContrato as int
AS    
BEGIN
	SELECT 
			CEN.IdContratoEntregable,
			EN.IdEntregable,	
			RTRIM(LTRIM(EN.DocumentoEntregable)) AS DocumentoEntregable
	FROM
			EN_Entregable EN INNER JOIN EN_ContratoEntregable CEN ON EN.IdEntregable = CEN.IdEntregable
			AND EN.BITJOA = 0
	WHERE	CEN.IdContrato = @IdContrato
	ORDER BY RTRIM(LTRIM(EN.DocumentoEntregable))
END