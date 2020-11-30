-- =============================================
-- Author:		Manuel Cruz
-- Create date: 10-05-2018
-- Description:	
-- =============================================
-- Author:		Marcos Garcia 
-- Alter date:  20-12-2018
-- Description:	* Agregar Numero de Contrato
--				* Agregar el Complemento para las facturas de FI_FacturaContrato
-- =============================================
-- Author:		Marcos Garcia
-- Alter date:  09-01-2020
-- Description:	* Agregar MAX() en FechaDePago
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaComprobantesRecibosPagos] 
-- [SP_FI_ConsultaComprobantesRecibosPagos] 11200,3,10002,0,1
-- Add the parameters for the stored procedure here
@IdProveedor       INT, 
@IdContrato        INT, 
@IdUsuario         INT, 
@IdTransferFacPago INT, 
@IdAccion          INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         --========================       
         IF OBJECT_ID('tempdb..#IdFacturaComplemento', 'U') IS NOT NULL
             DROP TABLE #IdFacturaComplemento;
         --========================  
         CREATE TABLE #IdFacturaComplemento
         (IdFactura   INT, 
          FormadePago NVARCHAR(MAX), 
          Moneda      NVARCHAR(MAX), 
          Monto       MONEY, 
          FechaDePago DATETIME
         );
         --========================
         INSERT INTO #IdFacturaComplemento
         (IdFactura, 
          FormadePago, 
          Moneda, 
          Monto, 
          FechaDePago
         )
                SELECT CP.IdFactura, 
                       Cp.FormaDePagoP, 
                       Cp.MonedaP, 
                       Cp.Monto, 
                       Cp.FechaDePago
                FROM dbo.FI_FacturaContrato FC
                     JOIN dbo.FI_Factura F ON F.IdFactura = FC.IdFactura
                     JOIN dbo.FI_CPDocRelacionado DC ON DC.IdDocumento = F.UUID
                     JOIN dbo.FI_ComplementoDePago Cp ON Cp.IdComplementoDePago = DC.IdComplementoDePago
                WHERE FC.IdContrato = @IdContrato
                GROUP BY Cp.IdFactura, 
                         Cp.FormaDePagoP, 
                         Cp.MonedaP, 
                         Cp.Monto, 
                         Cp.FechaDePago; 
         --========================
         -- Insert statements for procedure here
         IF(@IdTransferFacPago = 0
            AND @IdAccion = 0)
             BEGIN
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        CP.FormaDePagoP AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(CP.FechaDePago AS DATE)) AS FechaDePago, 
                        CP.MonedaP, 
                        SUM(CP.Monto) AS MontoPagado
                 FROM dbo.FI_ComplementoDePago CP
                      JOIN dbo.FI_Factura F ON CP.IdFactura = F.IdFactura
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.IdContrato = @IdContrato
                       AND F.TipoComprobante = 'P'
                       AND TF.IdTransfer IS NULL
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          CP.FormaDePagoP, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          CP.MonedaP
                 --
                 UNION
                 --
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        c.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        CP.FormaDePagoP AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(CP.FechaDePago AS DATE)) AS FechaDePago, 
                        CP.MonedaP, 
                        SUM(CP.Monto) AS MontoPagado
                 FROM dbo.FI_ComplementoDePago CP
                      JOIN dbo.FI_Factura F ON CP.IdFactura = F.IdFactura
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.IdContrato = @IdContrato
                       AND F.TipoComprobante = 'P'
                       AND ISNULL(F.VarTransfer, 0) = 1
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          CP.FormaDePagoP, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          CP.MonedaP
                 ---
                 UNION
                 ---
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        FC.FormadePago AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(FC.FechaDePago AS DATE)) AS FechaDePago, 
                        FC.Moneda, 
                        SUM(FC.Monto) AS MontoPagado
                 FROM dbo.FI_Factura F
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN #IdFacturaComplemento FC ON FC.IdFactura = F.IdFactura
                      LEFT JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND TF.IdTransfer IS NULL
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          FC.FormadePago, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          FC.Moneda
                 UNION
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        FC.FormadePago AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(FC.FechaDePago AS DATE)) AS FechaDePago, 
                        FC.Moneda, 
                        SUM(FC.Monto) AS MontoPagado
                 FROM dbo.FI_Factura F
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN #IdFacturaComplemento FC ON FC.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND ISNULL(F.VarTransfer, 0) = 1
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          FC.FormadePago, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          FC.Moneda
                 ORDER BY F.IdFactura DESC;
             END;
         IF(@IdTransferFacPago <> 0
            AND @IdAccion <> 0)
             BEGIN
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        CP.FormaDePagoP AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(CP.FechaDePago AS DATE)) AS FechaDePago, 
                        CP.MonedaP, 
                        SUM(CP.Monto) AS MontoPagado
                 FROM dbo.FI_ComplementoDePago CP
                      JOIN dbo.FI_Factura AS F ON CP.IdFactura = F.IdFactura
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.IdContrato = @IdContrato
                       AND F.TipoComprobante = 'P'
                       AND TF.IdTransfer IS NULL
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          CP.FormaDePagoP, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          CP.MonedaP
                 UNION                 
                 ---
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        CP.FormaDePagoP AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(CP.FechaDePago AS DATE)) AS FechaDePago, 
                        CP.MonedaP, 
                        SUM(CP.Monto) AS MontoPagado
                 FROM dbo.FI_ComplementoDePago CP
                      JOIN dbo.FI_Factura AS F ON CP.IdFactura = F.IdFactura
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.IdContrato = @IdContrato
                       AND F.TipoComprobante = 'P'
                       AND TF.IdTransfer = @IdTransferFacPago
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          CP.FormaDePagoP, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          CP.MonedaP
                 UNION
                 ----------------------------
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        CP.FormaDePagoP AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(CP.FechaDePago AS DATE)) AS FechaDePago, 
                        CP.MonedaP, 
                        SUM(CP.Monto) AS MontoPagado
                 FROM dbo.FI_ComplementoDePago CP
                      JOIN dbo.FI_Factura AS F ON CP.IdFactura = F.IdFactura
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND F.IdContrato = @IdContrato
                       AND F.TipoComprobante = 'P'
                       AND ISNULL(F.VarTransfer, 0) = 1
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          CP.FormaDePagoP, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          CP.MonedaP
                 UNION
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        FC.FormadePago AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(FC.FechaDePago AS DATE)) AS FechaDePago, 
                        FC.Moneda, 
                        SUM(FC.Monto) AS MontoPagado
                 FROM dbo.FI_Factura F
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN #IdFacturaComplemento FC ON FC.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND TF.IdTransfer = @IdTransferFacPago
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          FC.FormadePago, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          FC.Moneda
                 UNION
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        FC.FormadePago AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(FC.FechaDePago AS DATE)) AS FechaDePago, 
                        FC.Moneda, 
                        SUM(FC.Monto) AS MontoPagado
                 FROM dbo.FI_Factura F
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN #IdFacturaComplemento FC ON FC.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                      LEFT JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND TF.IdTransfer IS NULL
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          FC.FormadePago, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          FC.Moneda
                 UNION
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        F.Serie, 
                        C.NumeroContrato, 
                        F.Folio, 
                        F.Fecha, 
                        F.FormaPago AS MetodoDePago, 
                        F.SubTotal, 
                        F.Moneda, 
                        F.MontoConIva, 
                        F.TipoComprobante, 
                        FC.FormadePago AS FormaDePago, 
                        F.LugarExpedicion, 
                        F.UUID, 
                        F.FechaTimbrado, 
                        F.FechaRecepcion, 
                        SUBSTRING(S.RazonSocial, 0, 30) AS RazonSocial, 
                        F.Emisor, 
                        MAX(CAST(FC.FechaDePago AS DATE)) AS FechaDePago, 
                        FC.Moneda, 
                        SUM(FC.Monto) AS MontoPagado
                 FROM dbo.FI_Factura F
                      JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
                      JOIN #IdFacturaComplemento FC ON FC.IdFactura = F.IdFactura
                      JOIN dbo.PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                 WHERE F.IdSubcontratista = @IdProveedor
                       AND ISNULL(F.VarTransfer, 0) = 1
                 GROUP BY SUBSTRING(S.RazonSocial, 0, 30), 
                          F.IdFactura, 
                          F.Serie, 
                          C.NumeroContrato, 
                          F.Folio, 
                          F.Fecha, 
                          F.FormaPago, 
                          F.SubTotal, 
                          F.Moneda, 
                          F.MontoConIva, 
                          F.TipoComprobante, 
                          FC.FormadePago, 
                          F.LugarExpedicion, 
                          F.UUID, 
                          F.FechaTimbrado, 
                          F.FechaRecepcion, 
                          F.Emisor, 
                          FC.Moneda
                 ORDER BY F.IdFactura DESC;
             END;
     END;