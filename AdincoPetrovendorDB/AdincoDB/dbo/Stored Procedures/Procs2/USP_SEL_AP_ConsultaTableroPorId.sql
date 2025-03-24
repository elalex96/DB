USE [Adinco]
GO
DROP PROCEDURE IF EXISTS USP_SEL_AP_ConsultaTableroPorId
/****** Object:  StoredProcedure [dbo].[USP_SEL_AP_ConsultaTableroPorId]    Script Date: 20/03/2025 01:55:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19/03/2025
-- Description:	Consulta de un los datos de un tablero por Id
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_AP_ConsultaTableroPorId]
	-- Add the parameters for the stored procedure here
	@IdTablero INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		IdTableroContrato,
		IdContrato,
		NombreMostrar,
		Workbook,
		Sheet,
		Tabs,
		Site,
		DNS,
		UserTableau,
		CAST(isnull(MuestraToolbar,0) AS BIT) as MuestraToolbar,
		CreadoEn,
		Activo,
		CAST(ISNULL(HeightPX,1000) AS INT) AS HeightPX,
		idRol,
		Parametros,
		EsVersionCloud
	FROM EN_TableroContrato
	WHERE IdTableroContrato = @IdTablero

END
