USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_PV_ActulizarConfiguracionAdjudicacionDirecta'
)
    DROP PROCEDURE USP_UPD_PV_ActulizarConfiguracionAdjudicacionDirecta;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/07/2023
-- Description: actualizacion de configuracion de adjudicacion directa issue: https://github.com/Adinco/petrovendor/issues/2395
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_PV_ActulizarConfiguracionAdjudicacionDirecta]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT,
	@Activo INT,
	@IdConfiguracionProveedoresOperadoras INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE PV_ConfiguracionProveedoresOperadoras
	SET Activo = @Activo,
		IdContrato = @IdContrato
	WHERE IdConfiguracionProveedoresOperadoras = @IdConfiguracionProveedoresOperadoras;

END
