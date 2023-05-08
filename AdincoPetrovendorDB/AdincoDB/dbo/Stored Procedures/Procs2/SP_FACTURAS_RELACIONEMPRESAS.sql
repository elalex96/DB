CREATE PROCEDURE [dbo].[SP_FACTURAS_RELACIONEMPRESAS]
@IdContratista int
AS
BEGIN
SELECT 
F.IdFactura,
F.Serie,
F.Folio,
F.Fecha,
F.FormaPago,
F.NoCertificado,
F.CondicionesDePago,
cast (F.SubTotal AS MONEY) AS SubTotal ,Moneda, 
F.MontoConIva,
F.TipoComprobante,
F.MetodoPago,
F.LugarExpedicion,
F.UUID,FechaTimbrado, 
F.UUID,FechaTimbrado, 
F.FechaRecepcion, 
F.UUID,FechaTimbrado, 
F.emisor 
from FI_Factura as F
INNER JOIN CO_RelacionEmpresas AS RE ON F.IdSubcontratista = RE.IdRelacionada
WHERE RE.IdContratista = @IdContratista 
ORDER BY F.fecha desc
END
