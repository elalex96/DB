USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_AgregarConfiguracionCartaCNProveedor'
)
    DROP PROCEDURE SP_MM_AgregarConfiguracionCartaCNProveedor;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Update: 19/07/2023
-- Description:	se agregan validaciones de configuraciones issue: https://github.com/Adinco/petrovendor/issues/2388
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarConfiguracionCartaCNProveedor]
	-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO PV_ConfiguracionProveedoresOperadoras 
	(
		TipoConfiguracion,
		Descripcion,
		RFC,
		IdContrato,
		Operadora,
		Proveedor,
		Activo,
		FechaIncio,
		FechaFin,
		CreadoEl,
		CreadoPor
	) 
		VALUES 
	(
		'CARTA_PR_PR',
		'Validacion para que proveedores en especifico generen carta de CN de Proveedor a Proveedor',
		NULL,
		@IdContrato,
		1,
		0,
		1,
		NULL,
		NULL,
		GETDATE(),
		NULL
	);

	SELECT SCOPE_IDENTITY() AS IdConfiguracion

END
