
-- =============================================
-- Author:		<Jose Roman>
-- ALTER date: <08/05/2018>
-- Description:	<Se obtiene la url del webservice para ejecutar algun metodo>
-- =============================================

CREATE procedure [dbo].[WS_SP_ConsultadeURLPorID] 
	@IdURL INT
AS
BEGIN
	SELECT [URL]
	FROM dbo.WS_URLsMetodos
	WHERE IdUrlsMetodos = @IdURL
END
