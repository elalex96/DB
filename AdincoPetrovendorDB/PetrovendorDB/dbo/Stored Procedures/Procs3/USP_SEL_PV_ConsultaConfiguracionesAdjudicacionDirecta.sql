USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_PV_ConsultaConfiguracionesAdjudicacionDirecta'
)
    DROP PROCEDURE USP_SEL_PV_ConsultaConfiguracionesAdjudicacionDirecta;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/07/2023
-- Description: Consulta de los contratos que tienen la configuracion de carga/descarga 
--				de documento de adjudicacion directa issue: https://github.com/Adinco/petrovendor/issues/2395
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_PV_ConsultaConfiguracionesAdjudicacionDirecta]
/*--------------------parametros contrato  --------------------*/
	@IdContrato INT, 
	@IdUsuario INT 
/*-------------------------------------------------------------*/
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		IdConfiguracionProveedoresOperadoras,
		TipoConfiguracion,
		Descripcion,
		RFC,
		IdContrato,
		Activo,
		CreadoEl
	FROM PV_ConfiguracionProveedoresOperadoras (NOLOCK)
	WHERE TipoConfiguracion = 'DOC_AD'
	ORDER BY CreadoEl DESC;

END
