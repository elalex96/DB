USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_INS_AD_GuardarExclucionAnioFiscalFacturas'
)
    DROP PROCEDURE USP_INS_AD_GuardarExclucionAnioFiscalFacturas;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/01/2024>
-- Description:	<Guardado de exclucion de año fiscal para carga de facturas>
-- =============================================
CREATE PROCEDURE [dbo].[USP_INS_AD_GuardarExclucionAnioFiscalFacturas]
	-- Add the parameters for the stored procedure here
	@RFC NVARCHAR(100),
	@AnioExclucion INT,
	@FechaVigencia DATETIME,
	@CreadoPor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @EXISTE_RFC_ANIO INT = (SELECT TOP 1 Id FROM FacturasExcluirRestriccionAnioFiscal (NOLOCK) WHERE RFCOperadora = @RFC AND AnioExclucion = @AnioExclucion);

	IF ISNULL(@EXISTE_RFC_ANIO,0) = 0
	BEGIN
		
		INSERT INTO FacturasExcluirRestriccionAnioFiscal
		(
			RFCOperadora,
			AnioExclucion,
			FechaVigencia,
			CreadoPor,
			CreadoEl,
			Activo
		)
		VALUES
		(
			@RFC,
			@AnioExclucion,
			@FechaVigencia,
			@CreadoPor,
			GETDATE(),
			1
		);

		SELECT 'GUARDADO_EXITOSO'

	END
	ELSE
	BEGIN

		SELECT 'La operadora y el año que deseas agregar ya existen, busca el registro en el listado si es que deseas modificarlo.'

	END
END
