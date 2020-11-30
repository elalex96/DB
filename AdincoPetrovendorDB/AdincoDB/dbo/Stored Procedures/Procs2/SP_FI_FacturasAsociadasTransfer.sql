-- =============================================
-- Author:		Manuel CD
-- Create date: 14-09-2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturasAsociadasTransfer] 
-- Add the parameters for the stored procedure here
@IdTran     INT, 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT F.IdFactura, 
                F.TipoComprobante, 
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
                F.Emisor, 
                SUM(CASE
                        WHEN CP.IdFactura IS NULL
                        THEN TF.MontoPagado
                        ELSE CP.Monto
                    END) AS MontoPagado
         FROM dbo.FI_Transfer AS T
              JOIN dbo.FI_TransferFactura AS TF ON T.IdTransferencia = TF.IdTransfer
              JOIN dbo.FI_Factura AS F ON TF.IdFactura = F.IdFactura
              JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
              LEFT JOIN dbo.FI_ComplementoDePago CP ON CP.IdFactura = F.IdFactura
         WHERE T.IdTransferencia = @IdTran
               AND T.IdContrato = @IdContrato
         GROUP BY F.IdFactura, 
                  F.TipoComprobante, 
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

         --
         UNION
         --

         SELECT CASE
                    WHEN F.IdFactura IS NULL
                    THEN 0
                    ELSE F.IdFactura
                END AS IdFactura,
                CASE
                    WHEN F.IdFactura IS NULL
                    THEN '¡NO CARGADO EN ADINCO!'
                    ELSE F.TipoComprobante
                END AS TipoComprobante, 
                F.Serie, 
                F.Folio, 
                F.Fecha, 
                F.FormaPago, 
                F.SubTotal, 
                F.Moneda, 
                F.MontoConIva, 
                F.MetodoPago, 
                CPDR.IdDocumento AS UUID, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor, 
                CPDR.ImpPagado AS MontoPagado
         --SELECT * 
         FROM dbo.FI_CPDocRelacionado AS CPDR
              LEFT JOIN dbo.FI_ComplementoDePago CP ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
              LEFT JOIN dbo.FI_Factura F ON CPDR.IdDocumento = F.UUID
              LEFT JOIN dbo.FI_TransferFactura AS TF ON CP.IdFactura = TF.IdFactura
              LEFT JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer
              LEFT JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
         WHERE T.IdTransferencia = @IdTran
               AND T.IdContrato = @IdContrato
         GROUP BY CASE
                      WHEN F.IdFactura IS NULL
                      THEN 0
                      ELSE F.IdFactura
                  END,
                  CASE
                      WHEN F.IdFactura IS NULL
                      THEN '¡NO CARGADO EN ADINCO!'
                      ELSE F.TipoComprobante
                  END, 
                  F.Serie, 
                  F.Folio, 
                  F.Fecha, 
                  F.FormaPago, 
                  F.SubTotal, 
                  F.Moneda, 
                  F.MontoConIva, 
                  F.MetodoPago, 
                  CPDR.IdDocumento, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor, 
                  CPDR.ImpPagado;
         --SP_FI_FacturasAsociadasTransfer 653
     END;