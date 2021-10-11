USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ConsultarEntregablesTiemposEntrega]    Script Date: 07/10/2021 12:15:25 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/10/2021
-- Description:	Consulta dell catalogo de tiempos de entrega
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ConsultarEntregablesTiemposEntrega]
	-- Add the parameters for the stored procedure here
	@TiempoEntrega NVARCHAR(MAX)
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
	JOIN dbo.EN_MarcoLegal AS ML ON ML.IdMarcoLegal = E.IdMarcoLegal
	WHERE E.TiempoEntrega = @TiempoEntrega
	AND E.IsActivo = 1

END
