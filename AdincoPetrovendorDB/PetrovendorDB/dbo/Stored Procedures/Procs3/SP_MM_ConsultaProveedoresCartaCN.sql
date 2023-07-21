USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultaProveedoresCartaCN'
)
    DROP PROCEDURE SP_MM_ConsultaProveedoresCartaCN;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/07/2023>
-- Description:	<consulta de la generacion de cartas CN de proveedor a proveedor> issue: https://github.com/Adinco/petrovendor/issues/2388
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaProveedoresCartaCN]
	-- Add the parameters for the stored procedure here
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
	WHERE TipoConfiguracion = 'CARTA_PR_PR'
	ORDER BY CreadoEl DESC;

END
