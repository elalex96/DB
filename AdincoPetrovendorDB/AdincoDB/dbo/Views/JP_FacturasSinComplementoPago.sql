CREATE VIEW [dbo].[JP_FacturasSinComplementoPago]
AS
     SELECT DISTINCT 
            C.NumeroContrato, 
            F.IdFactura, 
            F.Serie, 
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
            F.Descuento, 
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
                WHEN F.TipoComprobante = 'P'
                THEN 'PPD'
            END AS MetodoPago, 
            F.LugarExpedicion, 
            F.Emisor, 
            S.RazonSocial AS EmisorRazonSocial, 
            F.Receptor, 
            SR.RazonSocial AS ReceptorRazonSocial, 
            F.UUID, 
            F.FechaTimbrado, 
            F.FechaRecepcion, 
            F.UsoCFDI, 
            F.VersionCFDI, 
            F.TotalImpuestosTrasladados, 
            F.TotalImpuestosRetenidos, 
            T.FechaPago AS 'FechaDePago', 
            T.IdTransferencia, 
            'PPD directo con transferencia' AS Filtro
     FROM dbo.FI_Factura F(NOLOCK)
          JOIN dbo.PV_Subcontratista S(NOLOCK) ON S.IdSubcontratista = F.IdSubcontratista
          JOIN dbo.PV_Subcontratista SR(NOLOCK) ON F.Receptor = SR.RFC
          JOIN dbo.CO_Contrato C(NOLOCK) ON C.IdContrato = F.IdContrato
          LEFT JOIN dbo.FI_CPDocRelacionado CPDR(NOLOCK) ON F.UUID = CPDR.IdDocumento
          LEFT JOIN dbo.FI_ComplementoDePago CP(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
          LEFT JOIN dbo.FI_Factura FCP(NOLOCK) ON FCP.IdFactura = CP.IdFactura
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON F.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
     WHERE(F.MetodoPago LIKE '%parcia%'
           OR F.MetodoPago LIKE '%dife%'
           OR F.MetodoPago LIKE '%PPD%'
           OR F.FormaPago LIKE '%parcia%'
           OR F.FormaPago LIKE '%dife%'
           OR F.FormaPago LIKE '%PPD%')
          AND C.IdContratista IN(10005, 10006)
          AND CPDR.IdDocRelacionado IS NULL
          AND T.FechaPago > '2018-08-31'
     UNION
     SELECT DISTINCT 
            C.NumeroContrato, 
            F.IdFactura, 
            F.Serie, 
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
            F.Descuento, 
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
                WHEN F.TipoComprobante = 'P'
                THEN 'PPD'
            END AS MetodoPago, 
            F.LugarExpedicion, 
            F.Emisor, 
            S.RazonSocial AS EmisorRazonSocial, 
            F.Receptor, 
            SR.RazonSocial AS ReceptorRazonSocial, 
            F.UUID, 
            F.FechaTimbrado, 
            F.FechaRecepcion, 
            F.UsoCFDI, 
            F.VersionCFDI, 
            F.TotalImpuestosTrasladados, 
            F.TotalImpuestosRetenidos, 
            T.FechaPago AS 'FechaDePago', 
            T.IdTransferencia, 
            'PPD SIN COMPLEMENTO' AS Filtro
     FROM dbo.FI_Factura F(NOLOCK)
          JOIN dbo.PV_Subcontratista S(NOLOCK) ON S.IdSubcontratista = F.IdSubcontratista
          JOIN dbo.PV_Subcontratista SR(NOLOCK) ON F.Receptor = SR.RFC
          JOIN dbo.CO_Contrato C(NOLOCK) ON C.IdContrato = F.IdContrato
          LEFT JOIN dbo.FI_CPDocRelacionado CPDR(NOLOCK) ON F.UUID = CPDR.IdDocumento
          LEFT JOIN dbo.FI_ComplementoDePago CP(NOLOCK) ON CP.IdComplementoDePago = CPDR.IdComplementoDePago
          LEFT JOIN dbo.FI_Factura FCP(NOLOCK) ON FCP.IdFactura = CP.IdFactura
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON F.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
     WHERE(F.MetodoPago LIKE '%parcia%'
           OR F.MetodoPago LIKE '%dife%'
           OR F.MetodoPago LIKE '%PPD%'
           OR F.FormaPago LIKE '%parcia%'
           OR F.FormaPago LIKE '%dife%'
           OR F.FormaPago LIKE '%PPD%')
          AND C.IdContratista IN(10005, 10006)
          AND CPDR.IdDocRelacionado IS NULL
          AND TF.IdTransfer IS NULL
          AND F.Fecha > '2018-08-31';
