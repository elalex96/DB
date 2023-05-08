
CREATE VIEW [dbo].[FacturasEmitidas_Jaguar]
AS

select
    F.IdFactura,
    C.NumeroContrato,
    F.Emisor,
    F.Receptor,
    SC.RazonSocial,
    F.UUID,
    D.Descripcion,
    F.Folio,
    F.SubTotal,
    F.MontoConIva,
    F.Moneda,
    F.FormaPago,
    F.TipoComprobante,
    F.MetodoPago,
    F.FechaTimbrado,
    F.FechaRecepcion
from FI_Factura F
    join FI_CFDIConcepto D on F.IdFactura = D.IdFactura
    join CO_Contrato C on F.IdContrato = C.IdContrato
    join PV_Subcontratista SC on F.Receptor = SC.RFC
where Emisor in ('JEP1709042B1','PEP170906DI5')

