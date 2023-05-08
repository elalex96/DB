CREATE PROC p_CO_SAPPO_BuscarPOSinImportacion
@pIdContrato INT,
@pPOListado VARCHAR(MAX)
AS

	SELECT *
	INTO #TMP_List
	FROM [dbo].[fnSplitString](@pPOListado,',')

	SELECT TOP 1 TMP.splitdata
	FROM #TMP_List TMP
	LEFT JOIN CO_SAPPO PO ON PO.SAPPONumber = TMP.splitdata AND
								PO.IdContrato = @pIdContrato
	WHERE PO.SAPPONumber IS NULL
