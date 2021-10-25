USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ReporteTiemposEntrega]    Script Date: 19/10/2021 04:35:07 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/10/2021
-- Description:	Consulta dell catalogo de ETAPAS
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ReporteEtapas]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		E.IdEtapa,
		E.Etapa,
		(SELECT COUNT(1) FROM dbo.EN_Entregable AS EN WHERE EN.IdEtapa = E.IdEtapa AND EN.IsActivo = 1) AS EntregablesUsados
	INTO #ETAPAS
	FROM dbo.EN_Etapa AS E
	ORDER BY EntregablesUsados DESC;

	SELECT
		TE.Etapa,
		TE.EntregablesUsados,
		E.Consecutivo,
		E.DocumentoEntregable,
		ML.MarcoLegal
	FROM dbo.EN_Entregable AS E
	JOIN dbo.EN_MarcoLegal AS ML ON ML.IdMarcoLegal = E.IdMarcoLegal
	JOIN #ETAPAS AS TE ON E.IdEtapa = TE.IdEtapa
	AND E.IsActivo = 1
	ORDER BY TE.EntregablesUsados DESC;

END