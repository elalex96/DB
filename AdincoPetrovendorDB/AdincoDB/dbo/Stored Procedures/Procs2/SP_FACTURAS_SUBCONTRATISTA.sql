--Created by: Luis David De La Cruz Bautista
--Made for: Joining Refacturas by IdSubcontratista for Refacturas
--Created at : 03/04/2018

--Usage: Select information from a specific sub-contractor
CREATE PROCEDURE [dbo].[SP_FACTURAS_SUBCONTRATISTA]
    @IdSubcontratista int
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
from FI_Factura where IdSubcontratista = @IdSubcontratista

