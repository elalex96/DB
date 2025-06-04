USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS USP_SEL_PV_ConsultaConfiguracionesPorOperadora
/****** Object:  StoredProcedure [dbo].[USP_SEL_PV_ConsultaConfiguracionesPorOperadora]    Script Date: 04/06/2025 09:48:36 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/06/2025
-- Description: Consulta de los contratos que tienen la configuracion 
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_PV_ConsultaConfiguracionesPorOperadora]
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
	ORDER BY CreadoEl DESC;

END
