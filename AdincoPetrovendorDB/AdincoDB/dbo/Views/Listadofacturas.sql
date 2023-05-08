CREATE VIEW [dbo].[Listadofacturas]
AS
SELECT IdFactura,emisor,FechaTimbrado,serie,folio,SubTotal,FormaPago,
       MontoConIva,UUID,Moneda,TipoComprobante FROM dbo.FI_Factura (NOLOCK)