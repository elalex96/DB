USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_AD_ActualizarExclucionAnioFiscalFacturas'
)
    DROP PROCEDURE USP_UPD_AD_ActualizarExclucionAnioFiscalFacturas;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <17/01/2023>
-- Description:	<Actualizar registro de exclucion de año fiscal para carga de facturas>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UPD_AD_ActualizarExclucionAnioFiscalFacturas]
	-- Add the parameters for the stored procedure here
	@RFCOperadora NVARCHAR(100),
	@AnioExclucion INT,
	@FechaVigencia DATETIME,
	@ModificadoPor INT,
	@Activo BIT,
	@Id INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE FacturasExcluirRestriccionAnioFiscal
	SET FechaVigencia = @FechaVigencia,
		ModificadoPor = @ModificadoPor,
		Activo = @Activo,
		ModificadoEl = GETDATE()
	WHERE RFCOperadora = @RFCOperadora
		AND AnioExclucion = @AnioExclucion;

END
