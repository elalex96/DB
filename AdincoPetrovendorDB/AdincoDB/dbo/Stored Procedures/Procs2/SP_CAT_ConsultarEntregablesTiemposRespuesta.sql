USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ConsultarEntregablesTiemposRespuesta]    Script Date: 07/10/2021 12:20:30 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/10/2021
-- Description:	Consulta dell catalogo de tiempos de respuesta
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ConsultarEntregablesTiemposRespuesta]
	-- Add the parameters for the stored procedure here
	@IdTiempoRespuesta INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		E.Consecutivo,
		E.DocumentoEntregable,
		ML.MarcoLegal
	FROM dbo.EN_Entregable AS E
	JOIN dbo.EN_MarcoLegal AS ML ON E.IdMarcoLegal = ML.IdMarcoLegal
	WHERE E.IdTiempoRespuesta = @IdTiempoRespuesta;

END
