-- =============================================
-- Author:        Manuel CD
-- Create date: 25-0817
-- Description:    
-- =============================================
--20180731: Reyna Olvera
--Modificado para mostrar los montos de dicha transferencia correctamente
-- =============================================
--20180912: Reyna Olvera
--MUestra el tipo de cambio diari del día de la factura
-- =============================================
--20190304: Manuel Cruz
--Facturas para contratos de jaguar tabla relacion dbo.FI_FacturaContrato
-- =============================================
--20190329: Manuel Cruz
--Filtro para solo PUE y PPD
-- =============================================
--20191220: Marcos Garcia
--Agregar Numero de Contrato
--Agregar UNION para las facturas que estan en FI_FacturaContrato se muestren al estar en una Transferencia
-- =============================================

CREATE PROCEDURE [dbo].[SP_FI_FacturasProveedorTransfer]
--[SP_FI_FacturasProveedorTransfer] 10016,11634
--[SP_FI_FacturasProveedorTransfer] 10094,3,1,0,0 
--[SP_FI_FacturasProveedorTransfer] 10094,3,1,963,1
--[SP_FI_FacturasProveedorTransfer] 10094,3,1,0,1
--[SP_FI_FacturasProveedorTransfer] 10058,3,1,0,0 
--[SP_FI_FacturasProveedorTransfer] 10058,3,1,948,1
--[SP_FI_FacturasProveedorTransfer] 10049,3,10002,1050,1
-- Add the parameters for the stored procedure here
@IdSubcontratista INT, 
@IdContrato       INT, 
@IdUsuario        INT, 
@IdTransfer       INT, 
@Accion           INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SET LANGUAGE spanish;
         --PUE = 1
         --PPD = 2
         IF(@IdTransfer = 0
            AND @Accion = 0)
             BEGIN
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
                        F.NoCertificado, 
                        F.CondicionesDePago, 
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
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor, 
                        TF.MontoPagado AS MontoPagado, 
                        TCD.TipoCambio AS TCD
                 FROM dbo.CO_Contrato AS C (NOLOCK)
				 JOIN dbo.FI_Factura AS F (NOLOCK)
					   ON C.IdContrato = F.IdContrato
							  AND C.IdContrato = @IdContrato
							  AND F.TipoComprobante <> 'P'
				 JOIN dbo.PV_Subcontratista AS S (NOLOCK)
						   ON F.IdSubcontratista = S.IdSubcontratista
							  AND S.IdSubcontratista = @IdSubcontratista
                 LEFT JOIN dbo.FI_TransferFactura TF (NOLOCK)
						   ON TF.IdFactura = F.IdFactura
                 LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK)
						   ON CONVERT(DATE, F.Fecha) = TCD.Fecha
                              AND TCD.IdMoneda = 1
                 WHERE --S.IdSubcontratista = @IdSubcontratista
                 --      AND C.IdContrato = @IdContrato
                 --      AND F.TipoComprobante <> 'P'
                       (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                       AND TF.IdTransferFactura IS NULL
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
                          F.NoCertificado, 
                          F.CondicionesDePago, 
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
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          S.RazonSocial, 
                          F.Emisor, 
                          TF.MontoPagado, 
                          TCD.TipoCambio
                 UNION
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
                        F.NoCertificado, 
                        F.CondicionesDePago, 
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
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor, 
                        TF.MontoPagado AS MontoPagado, 
                        TCD.TipoCambio AS TCD
                 FROM dbo.FI_Factura AS F	(NOLOCK)
                   JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						ON F.IdFactura = FC.IdFactura
						AND FC.IdContrato = @IdContrato
						AND F.TipoComprobante <> 'P'
                   JOIN dbo.PV_Subcontratista AS S(NOLOCK)
						ON F.IdSubcontratista = S.IdSubcontratista
						AND S.IdSubcontratista = @IdSubcontratista
                   JOIN dbo.CO_Contrato AS C (NOLOCK)
						ON F.IdContrato = C.IdContrato
                   LEFT JOIN dbo.FI_TransferFactura TF (NOLOCK)
						ON TF.IdFactura = F.IdFactura
                   LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK)
						ON CONVERT(DATE, F.Fecha) = TCD.Fecha
                          AND TCD.IdMoneda = 1
                 WHERE --S.IdSubcontratista = @IdSubcontratista
                       --AND FC.IdContrato = @IdContrato
                       --AND F.TipoComprobante <> 'P'
                        (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                       AND TF.IdTransferFactura IS NULL
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
                          F.NoCertificado, 
                          F.CondicionesDePago, 
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
         IF(@IdTransfer <> 0
            AND @Accion <> 0)
             BEGIN
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
                        F.NoCertificado, 
                        F.CondicionesDePago, 
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
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor, 
                        TF.MontoPagado AS MontoPagado, 
                        TCD.TipoCambio AS TCD
                 FROM dbo.CO_Contrato AS C (NOLOCK)
					  JOIN dbo.FI_Factura AS F (NOLOCK)
						   ON C.IdContrato = F.IdContrato
							  AND C.IdContrato = @IdContrato
							  AND F.TipoComprobante <> 'P'
                      JOIN dbo.PV_Subcontratista AS S (NOLOCK)
						   ON F.IdSubcontratista = S.IdSubcontratista	 
                      LEFT JOIN dbo.FI_TransferFactura TF (NOLOCK)
						   ON TF.IdFactura = F.IdFactura
                      LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK)
						   ON CONVERT(DATE, F.Fecha) = TCD.Fecha
                              AND TCD.IdMoneda = 1
                 WHERE --S.IdSubcontratista = @IdSubcontratista
                       --AND C.IdContrato = @IdContrato
                       --AND F.TipoComprobante <> 'P'
                       (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                       AND TF.IdTransferFactura IS NULL
                 --AND tf.IdTransfer = @IdTransfer
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
                          F.NoCertificado, 
                          F.CondicionesDePago, 
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
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          S.RazonSocial, 
                          F.Emisor, 
                          TF.MontoPagado, 
                          TCD.TipoCambio
                 UNION
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
                        F.NoCertificado, 
                        F.CondicionesDePago, 
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
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor, 
                        TF.MontoPagado AS MontoPagado, 
                        TCD.TipoCambio AS TCD
                 FROM dbo.FI_Factura AS F	(NOLOCK)
                    JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						ON F.IdFactura = FC.IdFactura
						AND FC.IdContrato = @IdContrato
						AND F.TipoComprobante <> 'P'
                    JOIN dbo.PV_Subcontratista AS S (NOLOCK)
						ON F.IdSubcontratista = S.IdSubcontratista
						AND S.IdSubcontratista = @IdSubcontratista
                    JOIN dbo.CO_Contrato AS C (NOLOCK)
						ON F.IdContrato = C.IdContrato
                    LEFT JOIN dbo.FI_TransferFactura TF	(NOLOCK)
						ON TF.IdFactura = F.IdFactura
                    LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK)
						ON CONVERT(DATE, F.Fecha) = TCD.Fecha
                          AND TCD.IdMoneda = 1
                 WHERE S.IdSubcontratista = @IdSubcontratista
                       AND FC.IdContrato = @IdContrato
                       AND F.TipoComprobante <> 'P'
                       AND (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                       AND TF.IdTransferFactura IS NULL
                 --AND tf.IdTransfer = @IdTransfer
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
                          F.NoCertificado, 
                          F.CondicionesDePago, 
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
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          S.RazonSocial, 
                          F.Emisor, 
                          TF.MontoPagado, 
                          TCD.TipoCambio
                 UNION
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
                        F.NoCertificado, 
                        F.CondicionesDePago, 
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
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor, 
                        TF.MontoPagado AS MontoPagado, 
                        TCD.TipoCambio AS TCD
                 FROM dbo.FI_Factura AS F	(NOLOCK)
					JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						ON F.IdFactura = FC.IdFactura
						AND FC.IdContrato = @IdContrato
						AND F.TipoComprobante <> 'P'
					JOIN dbo.PV_Subcontratista AS S		(NOLOCK)
						ON F.IdSubcontratista = S.IdSubcontratista
						AND S.IdSubcontratista = @IdSubcontratista
					JOIN dbo.CO_Contrato AS C	(NOLOCK)
						ON F.IdContrato = C.IdContrato
					LEFT JOIN dbo.FI_TransferFactura TF (NOLOCK)
						ON TF.IdFactura = F.IdFactura
					LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK)
						ON CONVERT(DATE, F.Fecha) = TCD.Fecha
					AND TCD.IdMoneda = 1
                 WHERE S.IdSubcontratista = @IdSubcontratista
                       AND FC.IdContrato = @IdContrato
                       AND F.TipoComprobante <> 'P'
                       AND (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                       -- AND TF.IdTransferFactura IS NULL
                       AND tf.IdTransfer = @IdTransfer
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
                          F.NoCertificado, 
                          F.CondicionesDePago, 
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
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          S.RazonSocial, 
                          F.Emisor, 
                          TF.MontoPagado, 
                          TCD.TipoCambio
                 UNION
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
                        F.NoCertificado, 
                        F.CondicionesDePago, 
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
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        S.RazonSocial, 
                        F.Emisor, 
                        TF.MontoPagado AS MontoPagado, 
                        TCD.TipoCambio AS TCD
                 FROM dbo.CO_Contrato AS C (NOLOCK)
				      JOIN dbo.FI_Factura AS F (NOLOCK)
					       ON C.IdContrato = F.IdContrato
							  AND C.IdContrato = @IdContrato
					          AND F.TipoComprobante <> 'P'
                      JOIN dbo.PV_Subcontratista AS S (NOLOCK)
					       ON F.IdSubcontratista = S.IdSubcontratista
							  AND S.IdSubcontratista = @IdSubcontratista
                      JOIN dbo.FI_TransferFactura TF (NOLOCK)
					       ON TF.IdFactura = F.IdFactura
                      LEFT JOIN dbo.CO_TipoCambioDiario TCD (NOLOCK)
					       ON CONVERT(DATE, F.Fecha) = TCD.Fecha
                              AND TCD.IdMoneda = 1
                 WHERE S.IdSubcontratista = @IdSubcontratista
                       AND C.IdContrato = @IdContrato
                       AND F.TipoComprobante <> 'P'
                       AND (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                       AND TF.IdTransfer = @IdTransfer
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
                          F.NoCertificado, 
                          F.CondicionesDePago, 
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
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          S.RazonSocial, 
                          F.Emisor, 
                          TF.MontoPagado, 
                          TCD.TipoCambio
                 ORDER BY F.IdFactura DESC;

                 --EXEC SP_FI_FacturasProveedorTransfer 3, 10080,2,0
             END;
     END;