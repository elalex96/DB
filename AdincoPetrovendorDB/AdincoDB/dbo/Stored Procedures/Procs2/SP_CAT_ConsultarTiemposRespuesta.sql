USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ConsultarTiemposRespuesta]    Script Date: 07/10/2021 12:17:49 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/10/2021
-- Description:	Consulta dell catalogo de tiempos de respuesta
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ConsultarTiemposRespuesta]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		TE.IdTiempoRespuesta,
		TE.TiempoRespuesta,
		(SELECT COUNT(1) FROM dbo.EN_Entregable AS E WHERE E.IdTiempoRespuesta = TE.IdTiempoRespuesta) AS EntregablesUsados
	FROM dbo.EN_TiempoRespuesta AS TE
	ORDER BY EntregablesUsados DESC;

END
