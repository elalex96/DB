--Created by: Luis David De La Cruz Bautista
--Made for: Joining Refacturas 
--Created at : 03/04/2018
CREATE PROCEDURE [dbo].[SP_FACTURAS_CONTRATO]   
    @IDContrato INT
AS   
SELECT 
IdFactura,
Serie,
Folio,
Fecha,
FormaPago,
NoCertificado,
CondicionesDePago,
SubTotal,Moneda, 
MontoConIva,
TipoComprobante,
MetodoPago,
LugarExpedicion,
UUID,FechaTimbrado, 
FechaRecepcion, 
emisor 
from FI_Factura where IdContrato = @IDContrato


