USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_PV_GuardarConfiguracionAdjudicacionDirecta'
)
    DROP PROCEDURE USP_INS_PV_GuardarConfiguracionAdjudicacionDirecta;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 23/07/2023
-- Description: guardar configuracion de carga/descarga de adjudicacion drecta issue: https://github.com/Adinco/petrovendor/issues/2395
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_PV_GuardarConfiguracionAdjudicacionDirecta]
	-- Add the parameters for the stored procedure here
	@IdContrato INT,
	@IdUsuario INT
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
		IdContrato,
		Operadora,
		Proveedor,
		Activo,
		CreadoEl
	)
		VALUES
	(
		'DOC_AD',
		'Validacion en procura para mostrar la carga/descarga del archivo de adjudicacion directa',
		@IdContrato,
		1,
		0,
		1,
		GETDATE()
	);

	SELECT SCOPE_IDENTITY();

END
