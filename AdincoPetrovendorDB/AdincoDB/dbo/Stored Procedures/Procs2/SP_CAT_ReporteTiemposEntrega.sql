USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ReporteTiemposEntrega]    Script Date: 07/10/2021 12:16:48 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/10/2021
-- Description:	Consulta dell catalogo de tiempos de entrega
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ReporteTiemposEntrega]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		TE.IdTiempoEntrega,
		TE.TiempoEntrega,
		(SELECT COUNT(1) FROM dbo.EN_Entregable AS E WHERE E.TiempoEntrega = TE.TiempoEntrega AND E.IsActivo = 1) AS EntregablesUsados
	INTO #TIEMPOSENTREGA
	FROM dbo.EN_TiempoEntrega AS TE
	ORDER BY EntregablesUsados DESC;

	SELECT
		TE.TiempoEntrega,
		TE.EntregablesUsados,
		E.Consecutivo,
		E.DocumentoEntregable,
		ML.MarcoLegal
	FROM dbo.EN_Entregable AS E
	JOIN dbo.EN_MarcoLegal AS ML ON ML.IdMarcoLegal = E.IdMarcoLegal
	JOIN #TIEMPOSENTREGA AS TE ON E.TiempoEntrega = TE.TiempoEntrega
	AND E.IsActivo = 1
	ORDER BY TE.EntregablesUsados DESC;

END
