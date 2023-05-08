CREATE PROC p_CO_SAPGR_BuscarGRSinImportacion
@pIdContrato INT,
@pGRReferenceList VARCHAR(MAX)
AS

	SELECT *
	INTO #TMP_List
	FROM [dbo].[fnSplitString](@pGRReferenceList,',')

	SELECT TOP 1 TMP.splitdata
	FROM #TMP_List TMP
	LEFT JOIN CO_SAPGR GR ON GR.MatDocN = TMP.splitdata AND
								GR.IdContrato = @pIdContrato
	WHERE GR.MatDocN IS NULL

	
