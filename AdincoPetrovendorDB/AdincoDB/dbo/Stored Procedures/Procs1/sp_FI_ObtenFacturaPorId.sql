-- =============================================
-- Author:		Reyna Olvera
-- Create date: 31-Agosto-2022
-- Description:	Obtiene información general de la factura
-- ============================================

CREATE PROCEDURE [dbo].[sp_FI_ObtenFacturaPorId]
    @IdFactura INT,
    @IdUsuario INT,
    @IdContrato INT
   
AS
BEGIN
	SELECT ISNULL(Serie,'') AS Serie,ISNULL(Folio,'') AS Folio,Fecha,Sello,FormaPago,NoCertificado,Certificado,CondicionesDePago,SubTotal,
	Descuento,TipoCambio,Moneda,MontoConIva,TipoComprobante,MetodoPago,LugarExpedicion,NumCtaPago,
	Emisor,Receptor,UUID 
	FROM 
		FI_Factura
	WHERE IdFactura = @IdFactura
END;
