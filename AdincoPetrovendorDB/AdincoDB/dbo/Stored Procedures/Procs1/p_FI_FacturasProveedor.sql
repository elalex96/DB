
-- =============================================
-- Author:		Luis David
-- Create date: 15/08/2019
-- =============================================

CREATE PROCEDURE [dbo].[p_FI_FacturasProveedor] 
-- Add the parameters for the stored procedure here
@IdContrato       INT, 
@IdSubcontratista INT
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT F.IdFactura, 
                F.Serie, 
                F.Folio, 
                F.Fecha, 
                F.FormaPago, 
                F.NoCertificado, 
                F.CondicionesDePago, 
                F.SubTotal, 
                F.Moneda, 
                F.MontoConIva, 
                F.TipoComprobante, 
                F.MetodoPago, 
                SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                F.UUID, 
                F.FechaTimbrado, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor, 
                TF.MontoPagado AS MontoPagado, 
                TCD.TipoCambio AS TCD
         FROM FI_Factura AS F
              LEFT JOIN PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
              LEFT JOIN CO_Contrato AS C ON F.IdContrato = C.IdContrato
              LEFT JOIN FI_TransferFactura TF ON TF.IdFactura = F.IdFactura --AND (tf.IdTransferFactura IS NULL OR TF.IdTransfer=@IdTransfer)
              JOIN dbo.CO_TipoCambioDiario TCD ON CONVERT(DATE, F.Fecha) = TCD.Fecha
                                                  AND TCD.IdMoneda = 1
         WHERE S.IdSubcontratista = @IdSubcontratista
               AND C.IdContrato = @IdContrato
               AND F.TipoComprobante <> 'P'
         GROUP BY F.IdFactura, 
                  F.Serie, 
                  F.Folio, 
                  F.Fecha, 
                  F.FormaPago, 
                  F.NoCertificado, 
                  F.CondicionesDePago, 
                  F.SubTotal, 
                  F.Moneda, 
                  F.MontoConIva, 
                  F.TipoComprobante, 
                  F.MetodoPago, 
                  F.LugarExpedicion, 
                  F.UUID, 
                  F.FechaTimbrado, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor, 
                  TF.MontoPagado, 
                  TCD.TipoCambio
         ORDER BY F.IdFactura DESC;
     END;