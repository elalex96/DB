

CREATE VIEW [dbo].[OgarrioEstatusFacturas]
AS
     SELECT DISTINCT 
            C.NumeroContrato, 
            F.IdFactura, 
            F.Serie, 
            F.Folio, 
            F.Fecha,
            CASE
                WHEN F.MetodoPago LIKE '%parcia%'
                     OR F.MetodoPago LIKE '%dife%'
                     OR F.MetodoPago LIKE '%PPD%'
                THEN F.FormaPago
                WHEN F.FormaPago LIKE '%parcia%'
                     OR F.FormaPago LIKE '%dife%'
                     OR F.FormaPago LIKE '%PPD%'
                THEN F.MetodoPago
            END AS FormaPago, 
            F.SubTotal, 
            F.Moneda, 
            F.MontoConIva, 
            F.TipoComprobante,
            CASE
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
            T.MontoPagado, 
            'PPD directo con transferencia' AS Filtro,
			CASE  WHEN isnull(ff.IdFactura,0) =0 then 'Finanzas' else 'Procura' END AS Origen
     FROM dbo.FI_Factura F(NOLOCK)
          LEFT JOIN dbo.PV_Subcontratista S(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SR(NOLOCK) ON F.Receptor = SR.RFC
          LEFT JOIN dbo.CO_Contrato C(NOLOCK) ON F.IdContrato = C.IdContrato
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON F.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer T(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
          LEFT JOIN dbo.FI_CPDocRelacionado CPDR ON F.UUID = CPDR.IdDocumento
		  LEFT JOIN Petrovendor.dbo.FI_Factura ff  ON  f.uuid  = ff.UUID collate Modern_Spanish_CI_AS 
     WHERE(F.MetodoPago LIKE '%parcia%'
           OR F.MetodoPago LIKE '%dife%'
           OR F.MetodoPago LIKE '%PPD%'
           OR F.FormaPago LIKE '%parcia%'
           OR F.FormaPago LIKE '%dife%'
           OR F.FormaPago LIKE '%PPD%')
          AND C.IdContrato = 10038
          AND T.IdTransferencia IS NOT NULL
--AND CPDR.IdDocRelacionado IS NULL
--AND YEAR(F.Fecha) > 2019
     UNION
     SELECT DISTINCT 
            C.NumeroContrato, 
            F.IdFactura, 
            F.Serie, 
            F.Folio, 
            F.Fecha,
            CASE
                WHEN F.MetodoPago LIKE '%parcia%'
                     OR F.MetodoPago LIKE '%dife%'
                     OR F.MetodoPago LIKE '%PPD%'
                THEN F.FormaPago
                WHEN F.FormaPago LIKE '%parcia%'
                     OR F.FormaPago LIKE '%dife%'
                     OR F.FormaPago LIKE '%PPD%'
                THEN F.MetodoPago
            END AS FormaPago, 
            F.SubTotal, 
            F.Moneda, 
            F.MontoConIva, 
            F.TipoComprobante,
            CASE
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
            T.MontoPagado, 
            'PPD Con Complemento' AS Filtro,
			CASE  WHEN isnull(ff.IdFactura,0) =0 then 'Finanzas' else 'Procura' END  AS Origen
     FROM dbo.FI_Factura F(NOLOCK)
          LEFT JOIN dbo.PV_Subcontratista S(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SR(NOLOCK) ON F.Receptor = SR.RFC
          LEFT JOIN dbo.CO_Contrato C(NOLOCK) ON F.IdContrato = C.IdContrato
          LEFT JOIN dbo.FI_CPDocRelacionado CPDR(NOLOCK) ON F.UUID = CPDR.IdDocumento
          LEFT JOIN dbo.FI_ComplementoDePago CP(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
          LEFT JOIN dbo.FI_Factura FCP(NOLOCK) ON CP.IdFactura = FCP.IdFactura
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON CP.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer T(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
		  LEFT JOIN Petrovendor.dbo.FI_Factura ff ON f.uuid = ff.UUID  collate Modern_Spanish_CI_AS 
     WHERE(F.MetodoPago LIKE '%parcia%'
           OR F.MetodoPago LIKE '%dife%'
           OR F.MetodoPago LIKE '%PPD%'
           OR F.FormaPago LIKE '%parcia%'
           OR F.FormaPago LIKE '%dife%'
           OR F.FormaPago LIKE '%PPD%')
          AND C.IdContrato = 10038
          AND CPDR.IdDocRelacionado IS NOT NULL
          AND T.IdTransferencia IS NOT NULL
--AND YEAR(F.Fecha) > 2019
     UNION
     SELECT DISTINCT 
            C.NumeroContrato, 
            F.IdFactura, 
            F.Serie, 
            F.Folio, 
            F.Fecha,
            CASE
                WHEN F.MetodoPago LIKE '%parcia%'
                     OR F.MetodoPago LIKE '%dife%'
                     OR F.MetodoPago LIKE '%PPD%'
                THEN F.FormaPago
                WHEN F.FormaPago LIKE '%parcia%'
                     OR F.FormaPago LIKE '%dife%'
                     OR F.FormaPago LIKE '%PPD%'
                THEN F.MetodoPago
            END AS FormaPago, 
            F.SubTotal, 
            F.Moneda, 
            F.MontoConIva, 
            F.TipoComprobante,
            CASE
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
            T.MontoPagado, 
            'PPD SIN COMPLEMENTO' AS Filtro,
			CASE  WHEN isnull(ff.IdFactura,0) =0 then 'Finanzas' else 'Procura' end AS Origen
     FROM dbo.FI_Factura F(NOLOCK)
          LEFT JOIN dbo.PV_Subcontratista S(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SR(NOLOCK) ON F.Receptor = SR.RFC
          LEFT JOIN dbo.CO_Contrato C(NOLOCK) ON F.IdContrato = C.IdContrato
          LEFT JOIN dbo.FI_CPDocRelacionado CPDR(NOLOCK) ON F.UUID = CPDR.IdDocumento
          LEFT JOIN dbo.FI_ComplementoDePago CP(NOLOCK) ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
          LEFT JOIN dbo.FI_Factura FCP(NOLOCK) ON CP.IdFactura = FCP.IdFactura
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON F.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer T(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
		  LEFT JOIN Petrovendor.dbo.FI_Factura ff ON f.uuid = ff.UUID  collate Modern_Spanish_CI_AS 
     WHERE(F.MetodoPago LIKE '%parcia%'
           OR F.MetodoPago LIKE '%dife%'
           OR F.MetodoPago LIKE '%PPD%'
           OR F.FormaPago LIKE '%parcia%'
           OR F.FormaPago LIKE '%dife%'
           OR F.FormaPago LIKE '%PPD%')
          AND C.IdContrato = 10038
          AND CPDR.IdDocRelacionado IS NULL
          AND T.IdTransferencia IS NULL
--AND YEAR(F.Fecha) > 2019
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
            T.MontoPagado,
            CASE
                WHEN T.IdTransferencia IS NULL
                THEN 'SIN PAGO PUE'
                WHEN T.IdTransferencia IS NOT NULL
                THEN 'Pagado PUE'
            END AS Filtro,
			CASE  WHEN isnull(ff.IdFactura,0) =0 then 'Finanzas' else 'Procura' end AS Origen
     FROM dbo.FI_Factura F(NOLOCK)
          LEFT JOIN dbo.PV_Subcontratista S(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SR(NOLOCK) ON F.Receptor = SR.RFC
          LEFT JOIN dbo.CO_Contrato C(NOLOCK) ON F.IdContrato = C.IdContrato
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON F.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer T(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
		  LEFT JOIN Petrovendor.dbo.FI_Factura ff ON f.uuid = ff.UUID  collate Modern_Spanish_CI_AS 
     WHERE(F.MetodoPago LIKE '%exhibi%'
           OR F.MetodoPago LIKE '%PUE%'
           OR F.FormaPago LIKE '%exhibi%'
           OR F.FormaPago LIKE '%PUE%')
          AND C.IdContrato = 10038
--AND YEAR(F.Fecha) > 2019
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
            T.MontoPagado,
            CASE
                WHEN T.IdTransferencia IS NULL
                THEN 'COMPLEMENTO SIN LIGAR'
                WHEN T.IdTransferencia IS NOT NULL
                THEN 'Complemento Ligado'
            END AS Filtro,
			CASE  WHEN isnull(ff.IdFactura,0) =0 then 'Finanzas' else 'Procura' end AS Origen
     FROM dbo.FI_Factura F(NOLOCK)
          LEFT JOIN dbo.PV_Subcontratista S(NOLOCK) ON F.IdSubcontratista = S.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SR(NOLOCK) ON F.Receptor = SR.RFC
          LEFT JOIN dbo.CO_Contrato C(NOLOCK) ON F.IdContrato = C.IdContrato
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON F.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer T(NOLOCK) ON TF.IdTransfer = T.IdTransferencia
		  LEFT JOIN Petrovendor.dbo.FI_Factura ff ON f.uuid = ff.UUID  collate Modern_Spanish_CI_AS 
     WHERE F.TipoComprobante = 'P'
           AND C.IdContrato = 10038;
--AND YEAR(F.Fecha) > 2019
