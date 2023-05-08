
CREATE PROC p_CO_SAPSES_BuscarSESSinImportacion
@pIdContrato INT,
@pSESListado VARCHAR(MAX)
AS

	SELECT *
	INTO #TMP_List
	FROM [dbo].[fnSplitString](@pSESListado,',')

	SELECT TOP 1 TMP.splitdata
	FROM #TMP_List TMP
	LEFT JOIN CO_SAPSES SES ON SES.SESNumber = TMP.splitdata AND
								SES.IdContrato = @pIdContrato
	WHERE SES.SESNumber IS NULL


	