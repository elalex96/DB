USE PETROVENDOR
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USD_SEL_FI_ObtenerFacturaPdfXmlFacturaPorId'
)
    DROP PROCEDURE USD_SEL_FI_ObtenerFacturaPdfXmlFacturaPorId
GO
-- =============================================  
-- Author: Daniel AC 
-- Create date: 05-09-2025  
-- Description: Obtener PDF Y XML Factura
-- =============================================  
CREATE PROCEDURE [dbo].[USD_SEL_FI_ObtenerFacturaPdfXmlFacturaPorId]
	@IdFactura INT
AS
BEGIN
    SET NOCOUNT ON;

		SELECT 
		ComprobantePDFByte, 
		ComprobanteXMLByte, 
		XML,
		ISNULL(ArchivoPDF,'') AS ArchivoPDF,
		ISNULL(IdTipoPedido,0) AS IdTipoPedido
		FROM [dbo].[FI_Factura]
		WHERE [IdFactura]= @IdFactura

	
END;
 
