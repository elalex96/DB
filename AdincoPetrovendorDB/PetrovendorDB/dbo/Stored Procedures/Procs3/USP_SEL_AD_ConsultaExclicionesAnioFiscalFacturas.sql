USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_AD_ConsultaExclicionesAnioFiscalFacturas'
)
    DROP PROCEDURE USP_SEL_AD_ConsultaExclicionesAnioFiscalFacturas;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <16/01/2023>
-- Description:	<Consultar las excluciones de años fiscales diferentes al actual de las operadora>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_AD_ConsultaExclicionesAnioFiscalFacturas] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		FEA.Id,
		FEA.RFCOperadora,
		CONCAT(OP.RFC, ' (', OP.RazonSocial, ')') AS Operadora,
		FEA.AnioExclucion,
		FEA.FechaVigencia,
		USC.Nombre AS CreadoPor,
		FEA.CreadoEl,
		USM.IdUsuario AS ModificadoPor,
		FEA.ModificadoEl,
		FEA.Activo
    FROM FacturasExcluirRestriccionAnioFiscal (NOLOCK) AS FEA
	LEFT JOIN S_Usuario (NOLOCK) AS USC
		ON FEA.CreadoPor = USC.IdUsuario
	LEFT JOIN S_Usuario (NOLOCK) AS USM
		ON FEA.ModificadoPor = USM.IdUsuario
	JOIN S_Proveedor (NOLOCK) AS OP
		ON FEA.RFCOperadora = OP.RFC 
		AND OP.Activo = 1

END
