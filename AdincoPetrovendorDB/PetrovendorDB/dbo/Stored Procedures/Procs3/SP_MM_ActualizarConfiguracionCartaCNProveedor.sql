USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ActualizarConfiguracionCartaCNProveedor'
)
    DROP PROCEDURE SP_MM_ActualizarConfiguracionCartaCNProveedor;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Alexander Gomez
-- Update: 19/07/2023
-- Description:	se agregan validaciones de configuraciones issue: https://github.com/Adinco/petrovendor/issues/2388
-- =============================================
CREATE PROCEDURE SP_MM_ActualizarConfiguracionCartaCNProveedor
	-- Add the parameters for the stored procedure here
	@IdConfiguracionProveedoresOperadoras INT,
	@IdContrato INT,
	@Activo BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE PV_ConfiguracionProveedoresOperadoras
	SET IdContrato = @IdContrato,
		Activo = @Activo
	WHERE IdConfiguracionProveedoresOperadoras = @IdConfiguracionProveedoresOperadoras;

END
GO
