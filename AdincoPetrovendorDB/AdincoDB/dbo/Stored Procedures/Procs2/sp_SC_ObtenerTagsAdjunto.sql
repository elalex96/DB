USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_ObtenerTagsAdjunto'
)
    DROP PROCEDURE sp_SC_ObtenerTagsAdjunto; 
	GO 
/****** Object:  StoredProcedure [dbo].[sp_SC_ObtenerTagsAdjunto]    Script Date: 10/07/2023 09:47:18 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: <11/07/202>
-- Description:	SP SE USA EN PAGINA ConsultaOTConvenio DE PETROVENDOR
-- =============================================|
CREATE PROC [dbo].[sp_SC_ObtenerTagsAdjunto]
AS
SET NOCOUNT ON;

	SELECT DISTINCT Descripcion
	FROM dbo.SC_Adjunto (NOLOCK)
	ORDER BY Descripcion
