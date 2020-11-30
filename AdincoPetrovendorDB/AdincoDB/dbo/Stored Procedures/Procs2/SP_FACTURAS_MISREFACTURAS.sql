CREATE PROCEDURE [dbo].[SP_FACTURAS_MISREFACTURAS]
   @IdContrato INT
AS   

    SET NOCOUNT ON;  
	SELECT DISTINCT F.IdFactura,
                F.Serie,
                F.Folio,
                F.Fecha,
                F.FormaPago,
                F.SubTotal,
                F.Moneda,
                F.MontoConIva,
                F.MetodoPago,
                F.UUID,
                F.FechaRecepcion,
                S.RazonSocial,
                F.Emisor
				from FI_Factura as F
				JOIN PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
				JOIN FI_RelacionRefacturas as RF ON RF.IdFacturaPadre = F.IdFactura
				WHERE  F.IdCOntrato = @IdContrato

