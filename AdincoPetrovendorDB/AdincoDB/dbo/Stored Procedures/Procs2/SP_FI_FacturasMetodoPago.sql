-- =============================================
-- Author:      Manuel Cruz
-- Create date: 22-08-2019
-- Description:    
-- =============================================
-- Author:      Marcos Garcia
-- Create date: 20-12-2019
-- Description: * Agregar Numero de Contrato   
--				* Agregar facturas de FI_FacturaContrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturasMetodoPago]
--[SP_FI_FacturasMetodoPago] 3,1
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SELECT F.IdFactura, 
                F.Serie, 
                C.NumeroContrato, 
                F.Folio, 
                F.Fecha,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                    THEN F.FormaPago
                    WHEN F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN F.MetodoPago
                END AS FormaPago, 
                F.SubTotal, 
                F.Moneda, 
                F.MontoConIva, 
                F.TipoComprobante,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                END AS MetodoPago, 
                SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                F.UUID, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor
         FROM dbo.FI_Factura F
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
         WHERE C.IdContrato = @IdContrato
               AND F.TipoComprobante <> 'P'
               AND (F.MetodoPago LIKE '%exhibi%'
                    OR F.MetodoPago LIKE '%PUE%'
                    OR F.FormaPago LIKE '%exhibi%'
                    OR F.FormaPago LIKE '%PUE%')
               AND tf.IdTransferFactura IS NULL
         GROUP BY F.IdFactura, 
                  F.Serie, 
                  C.NumeroContrato, 
                  F.Folio, 
                  F.Fecha,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                      THEN F.FormaPago
                      WHEN F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                      THEN F.MetodoPago
                  END, 
                  F.SubTotal, 
                  F.Moneda, 
                  F.MontoConIva, 
                  F.TipoComprobante,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                      THEN 'PUE'
                      WHEN F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN 'PPD'
                  END, 
                  SUBSTRING(F.LugarExpedicion, 0, 15), 
                  F.UUID, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor
         UNION
         --
         SELECT F.IdFactura, 
                F.Serie, 
                C.NumeroContrato, 
                F.Folio, 
                F.Fecha,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                    THEN F.FormaPago
                    WHEN F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN F.MetodoPago
                END AS FormaPago, 
                F.SubTotal, 
                F.Moneda, 
                F.MontoConIva, 
                F.TipoComprobante,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                END AS MetodoPago, 
                SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                F.UUID, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor
         FROM dbo.FI_Factura F
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
              JOIN dbo.FI_FacturaContrato FC ON FC.IdFactura = F.IdFactura
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
         WHERE FC.IdContrato = @IdContrato
               AND F.TipoComprobante <> 'P'
               AND (F.MetodoPago LIKE '%exhibi%'
                    OR F.MetodoPago LIKE '%PUE%'
                    OR F.FormaPago LIKE '%exhibi%'
                    OR F.FormaPago LIKE '%PUE%')
               AND tf.IdTransferFactura IS NULL
         GROUP BY F.IdFactura, 
                  F.Serie, 
                  C.NumeroContrato, 
                  F.Folio, 
                  F.Fecha,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                      THEN F.FormaPago
                      WHEN F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                      THEN F.MetodoPago
                  END, 
                  F.SubTotal, 
                  F.Moneda, 
                  F.MontoConIva, 
                  F.TipoComprobante,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                      THEN 'PUE'
                      WHEN F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN 'PPD'
                  END, 
                  SUBSTRING(F.LugarExpedicion, 0, 15), 
                  F.UUID, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor
         UNION
         --
         SELECT F.IdFactura, 
                F.Serie, 
                C.NumeroContrato, 
                F.Folio, 
                F.Fecha,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                    THEN F.FormaPago
                    WHEN F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN F.MetodoPago
                END AS FormaPago, 
                F.SubTotal, 
                F.Moneda, 
                F.MontoConIva, 
                F.TipoComprobante,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                END AS MetodoPago, 
                SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                F.UUID, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor
         FROM dbo.FI_Factura AS F
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
              LEFT JOIN dbo.FI_CPDocRelacionado CPDR ON F.UUID = CPDR.IdDocumento
              LEFT JOIN dbo.FI_ComplementoDePago CP ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = CP.IdFactura
         WHERE C.IdContrato = @IdContrato
               AND F.TipoComprobante <> 'P'
               AND (F.MetodoPago LIKE '%parcia%'
                    OR F.MetodoPago LIKE '%dife%'
                    OR F.MetodoPago LIKE '%PPD%'
                    OR F.FormaPago LIKE '%parcia%'
                    OR F.FormaPago LIKE '%dife%'
                    OR F.FormaPago LIKE '%PPD%')
               AND TF.IdTransferFactura IS NULL
         GROUP BY F.IdFactura, 
                  F.Serie, 
                  C.NumeroContrato, 
                  F.Folio, 
                  F.Fecha,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                      THEN F.FormaPago
                      WHEN F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN F.MetodoPago
                  END, 
                  F.SubTotal, 
                  F.Moneda, 
                  F.MontoConIva, 
                  F.TipoComprobante,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                      THEN 'PUE'
                      WHEN F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN 'PPD'
                  END, 
                  SUBSTRING(F.LugarExpedicion, 0, 15), 
                  F.UUID, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor
         UNION
         --
         SELECT F.IdFactura, 
                F.Serie, 
                C.NumeroContrato, 
                F.Folio, 
                F.Fecha,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                    THEN F.FormaPago
                    WHEN F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN F.MetodoPago
                END AS FormaPago, 
                F.SubTotal, 
                F.Moneda, 
                F.MontoConIva, 
                F.TipoComprobante,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                END AS MetodoPago, 
                SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                F.UUID, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor
         FROM dbo.FI_Factura AS F
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
              JOIN dbo.FI_FacturaContrato FC ON FC.IdFactura = F.IdFactura
              LEFT JOIN dbo.FI_CPDocRelacionado CPDR ON F.UUID = CPDR.IdDocumento
              LEFT JOIN dbo.FI_ComplementoDePago CP ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = CP.IdFactura
         WHERE FC.IdContrato = @IdContrato
               AND F.TipoComprobante <> 'P'
               AND (F.MetodoPago LIKE '%parcia%'
                    OR F.MetodoPago LIKE '%dife%'
                    OR F.MetodoPago LIKE '%PPD%'
                    OR F.FormaPago LIKE '%parcia%'
                    OR F.FormaPago LIKE '%dife%'
                    OR F.FormaPago LIKE '%PPD%')
               AND TF.IdTransferFactura IS NULL
         GROUP BY F.IdFactura, 
                  F.Serie, 
                  C.NumeroContrato, 
                  F.Folio, 
                  F.Fecha,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                      THEN F.FormaPago
                      WHEN F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN F.MetodoPago
                  END, 
                  F.SubTotal, 
                  F.Moneda, 
                  F.MontoConIva, 
                  F.TipoComprobante,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                      THEN 'PUE'
                      WHEN F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN 'PPD'
                  END, 
                  SUBSTRING(F.LugarExpedicion, 0, 15), 
                  F.UUID, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor
         UNION         
         --
         SELECT F.IdFactura, 
                F.Serie, 
                C.NumeroContrato, 
                F.Folio, 
                F.Fecha,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                    THEN F.FormaPago
                    WHEN F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN F.MetodoPago
                END AS FormaPago, 
                F.SubTotal, 
                F.Moneda, 
                F.MontoConIva, 
                F.TipoComprobante,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                END AS MetodoPago, 
                SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                F.UUID, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor
         FROM dbo.FI_Factura AS F
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
         WHERE C.IdContrato = @IdContrato
               AND F.TipoComprobante <> 'P'
               AND (F.MetodoPago LIKE '%parcia%'
                    OR F.MetodoPago LIKE '%dife%'
                    OR F.MetodoPago LIKE '%PPD%'
                    OR F.FormaPago LIKE '%parcia%'
                    OR F.FormaPago LIKE '%dife%'
                    OR F.FormaPago LIKE '%PPD%')
               AND TF.IdTransferFactura IS NULL
         GROUP BY F.IdFactura, 
                  F.Serie, 
                  C.NumeroContrato, 
                  F.Folio, 
                  F.Fecha,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                      THEN F.FormaPago
                      WHEN F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN F.MetodoPago
                  END, 
                  F.SubTotal, 
                  F.Moneda, 
                  F.MontoConIva, 
                  F.TipoComprobante,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                      THEN 'PUE'
                      WHEN F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN 'PPD'
                  END, 
                  SUBSTRING(F.LugarExpedicion, 0, 15), 
                  F.UUID, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor
         UNION
         --
         SELECT F.IdFactura, 
                F.Serie, 
                C.NumeroContrato, 
                F.Folio, 
                F.Fecha,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                    THEN F.FormaPago
                    WHEN F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN F.MetodoPago
                END AS FormaPago, 
                F.SubTotal, 
                F.Moneda, 
                F.MontoConIva, 
                F.TipoComprobante,
                CASE
                    WHEN F.MetodoPago LIKE '%exhibi%'
                         OR F.MetodoPago LIKE '%PUE%'
                         OR F.FormaPago LIKE '%exhibi%'
                         OR F.FormaPago LIKE '%PUE%'
                    THEN 'PUE'
                    WHEN F.MetodoPago LIKE '%parcia%'
                         OR F.MetodoPago LIKE '%dife%'
                         OR F.MetodoPago LIKE '%PPD%'
                         OR F.FormaPago LIKE '%parcia%'
                         OR F.FormaPago LIKE '%dife%'
                         OR F.FormaPago LIKE '%PPD%'
                    THEN 'PPD'
                END AS MetodoPago, 
                SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                F.UUID, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor
         FROM dbo.FI_Factura AS F
              JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
              JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
              JOIN dbo.FI_FacturaContrato FC ON F.IdContrato = FC.IdContrato
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = F.IdFactura
         WHERE FC.IdContrato = @IdContrato
               AND F.TipoComprobante <> 'P'
               AND (F.MetodoPago LIKE '%parcia%'
                    OR F.MetodoPago LIKE '%dife%'
                    OR F.MetodoPago LIKE '%PPD%'
                    OR F.FormaPago LIKE '%parcia%'
                    OR F.FormaPago LIKE '%dife%'
                    OR F.FormaPago LIKE '%PPD%')
               AND TF.IdTransferFactura IS NULL
         GROUP BY F.IdFactura, 
                  F.Serie, 
                  C.NumeroContrato, 
                  F.Folio, 
                  F.Fecha,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                      THEN F.FormaPago
                      WHEN F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN F.MetodoPago
                  END, 
                  F.SubTotal, 
                  F.Moneda, 
                  F.MontoConIva, 
                  F.TipoComprobante,
                  CASE
                      WHEN F.MetodoPago LIKE '%exhibi%'
                           OR F.MetodoPago LIKE '%PUE%'
                           OR F.FormaPago LIKE '%exhibi%'
                           OR F.FormaPago LIKE '%PUE%'
                      THEN 'PUE'
                      WHEN F.MetodoPago LIKE '%parcia%'
                           OR F.MetodoPago LIKE '%dife%'
                           OR F.MetodoPago LIKE '%PPD%'
                           OR F.FormaPago LIKE '%parcia%'
                           OR F.FormaPago LIKE '%dife%'
                           OR F.FormaPago LIKE '%PPD%'
                      THEN 'PPD'
                  END, 
                  SUBSTRING(F.LugarExpedicion, 0, 15), 
                  F.UUID, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor
         ORDER BY MetodoPago, 
                  F.Fecha DESC;
     END;