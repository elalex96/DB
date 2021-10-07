USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ConsultarTiemposEntrega]    Script Date: 07/10/2021 12:10:36 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/10/2021
-- Description:	Consulta dell catalogo de tiempos de entrega
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ConsultarTiemposEntrega]
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
	FROM dbo.EN_TiempoEntrega AS TE
	ORDER BY EntregablesUsados DESC;

END
