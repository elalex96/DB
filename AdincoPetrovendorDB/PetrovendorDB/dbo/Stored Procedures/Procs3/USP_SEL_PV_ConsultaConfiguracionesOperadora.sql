USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_PV_ConsultaConfiguracionesOperadora'
)
    DROP PROCEDURE USP_SEL_PV_ConsultaConfiguracionesOperadora;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/07/2023
-- Description: Consulta de configuracion por operadora issue: https://github.com/Adinco/petrovendor/issues/2395
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_PV_ConsultaConfiguracionesOperadora] 
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT,
	@TipoConfiguracion NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		TipoConfiguracion
	FROM PV_ConfiguracionProveedoresOperadoras (NOLOCK)
	WHERE IdContrato = @IdContrato
		AND TipoConfiguracion = @TipoConfiguracion
		AND Activo = 1
		AND Operadora = 1;
END
