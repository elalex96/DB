CREATE VIEW [V_PCN]
AS
     SELECT C.NumeroContrato, 
            P.Nombre,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN 'CF'
                WHEN R.CvTipoDocFacturacion = 2
                THEN 'PI'
                WHEN R.CvTipoDocFacturacion = 3
                THEN 'PE'
            END AS TipoDocumento, 
            ISNULL(F.UUID, '') AS [UUID],
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN LTRIM(RTRIM(F.Serie+' '+F.Folio))
                WHEN R.CvTipoDocFacturacion = 2
                THEN PC.NumeroPedimento
                WHEN R.CvTipoDocFacturacion = 3
                THEN PC.FolioComprobante
            END AS Numero,
            --ISNULL(F.SubTotal, '') AS [SubtotalFactura], 
            VP.ValorFactura, 
            ISNULL(F.Moneda, '') AS [MonedaFactura], 
            ISNULL(F.MontoConIva, '') AS [MontoFacturaConIVA], 
            F.FechaTimbrado,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN SF.RazonSocial
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN SPC.RazonSocial
            END AS Subcontratista, 
            ISNULL(GR.Descripcion, '') AS [RubroCN], 
            R.PCN AS [PCN],
            CASE
                WHEN FP.IdFactura IS NOT NULL
                     AND ACP.IdEstatus = 2
                     AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
                THEN 'Si tiene carta'
                WHEN DADA.IdDocAdinco IS NOT NULL
                THEN 'Si tiene carta'
                ELSE 'NO TIENE CARTA'
            END AS CartaContenidoNacional,
            CASE
                WHEN R.IdCBSISH IS NULL
                THEN 'SIN CLASIFICAR'
                ELSE CONCAT(MA.Codigo, ' - ', MA.Nombre)
            END AS 'Catalogo Bienes/Servicios Sector Hidrocarburos', 
            PS.IdPedido AS 'No. Pedido', 
            RQ.MotivoUrgencia,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN SF.RFC
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN SPC.RFC
            END AS RFC
     FROM dbo.CO_LineaPresupuestoMes LPM(NOLOCK)
          LEFT JOIN dbo.CO_Registro R(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
          LEFT JOIN dbo.CO_GastosRubro GR(NOLOCK) ON R.IdGastoRubro = GR.IdGastoRubro
          LEFT JOIN dbo.FI_Factura F(NOLOCK) ON F.IdFactura = R.IdFactura
          LEFT JOIN dbo.FI_pedimentocomprobante PC(NOLOCK) ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
          LEFT JOIN dbo.PV_Subcontratista SF(NOLOCK) ON F.IdSubcontratista = SF.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SPC(NOLOCK) ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
          LEFT JOIN dbo.PV_TipoMoneda TMF(NOLOCK) ON TMF.IdMoneda = F.IdMoneda
          LEFT JOIN dbo.CO_TipoCambioDiario TCDF(NOLOCK) ON TCDF.IdMoneda = TMF.IdMoneda
                                                            AND DAY(TCDF.Fecha) = DAY(F.Fecha)
                                                            AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
                                                            AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
          LEFT JOIN dbo.PV_TipoMoneda TMPC(NOLOCK) ON TMPC.IdMoneda = PC.IdMoneda
          LEFT JOIN dbo.CO_TipoCambioDiario TCDPC(NOLOCK) ON TCDPC.IdMoneda = TMPC.IdMoneda
                                                             AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
                                                             AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
                                                             AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
          LEFT JOIN dbo.CO_Presupuesto P(NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto
          LEFT JOIN dbo.CO_RubroInterno RI(NOLOCK) ON LPM.IdRubroInterno = RI.IdRubroInterno
          LEFT JOIN dbo.CO_AnioContractual AC(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
          LEFT JOIN dbo.CO_Contrato C(NOLOCK) ON C.IdContrato = AC.IdContrato
          LEFT JOIN Petrovendor.dbo.FI_Factura FP(NOLOCK) ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT
                                                             AND FP.UUID IS NOT NULL
                                                             AND FP.Activa = 1
                                                             AND ISNULL(FP.IsEliminado, 0) <> 1
          LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF(NOLOCK) ON AF.IdFactura = FP.IdFactura
          LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP(NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
          LEFT JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle AS APD(NOLOCK) ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
          LEFT JOIN Petrovendor.dbo.MM_PCN_ValoresPesos AS VP(NOLOCK) ON APD.IdAceptacionPedidoDetalle = VP.IdAceptacionPedidoDetalle
          LEFT JOIN Petrovendor.dbo.MM_Pedido(NOLOCK) AS PP ON PP.IdPedido = AP.IdPedido
                                                               AND PP.IdContrato = 10018
          LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido RQ ON PP.IdSolicitudPedido = RQ.IdSolicitudPedido
          LEFT JOIN Petrovendor.dbo.MM_Pedidos PS ON PP.IdPedido = PS.IdIdentificador
          LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP(NOLOCK) ON ACP.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                            AND ACP.IdEstatus = 2
                                                                            AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
          LEFT JOIN dbo.CO_CatalogoCuentaSH CCSH(NOLOCK) ON CCSH.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
          LEFT JOIN dbo.AWS_DocAwsDocAdinco DADA(NOLOCK) ON F.IdFactura = DADA.IdDocAdinco
          LEFT JOIN dbo.MM_BS_Actividad MA(NOLOCK) ON R.IdCBSISH = MA.IdActividad
     WHERE F.IdContrato IN(10015, 10014, 10017, 10016, 10019, 10020, 10021, 10022, 10023, 10024, 10018, 10052, 10043)
     GROUP BY C.NumeroContrato, 
              PC.NumeroPedimento, 
              LTRIM(RTRIM(F.Serie+' '+F.Folio)), 
              SF.RazonSocial, 
              PS.IdPedido, 
              RQ.MotivoUrgencia, 
              P.Nombre, 
              R.CvTipoDocFacturacion, 
              PC.FolioComprobante, 
              SPC.RazonSocial, 
              TMPC.TipoMonedaCorto, 
              F.FechaTimbrado, 
              ISNULL(GR.Descripcion, ''), 
              R.PCN, 
              ISNULL(F.MontoConIva, ''), 
              ISNULL(F.Moneda, ''), 
              ISNULL(F.UUID, ''),
              --ISNULL(F.SubTotal, ''),
              VP.ValorFactura,
              CASE
                  WHEN FP.IdFactura IS NOT NULL
                       AND ACP.IdEstatus = 2
                       AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
                  THEN 'Si tiene carta'
                  WHEN DADA.IdDocAdinco IS NOT NULL
                  THEN 'Si tiene carta'
                  ELSE 'NO TIENE CARTA'
              END,
              CASE
                  WHEN R.IdCBSISH IS NULL
                  THEN 'SIN CLASIFICAR'
                  ELSE CONCAT(MA.Codigo, ' - ', MA.Nombre)
              END,
              CASE
                  WHEN R.CvTipoDocFacturacion = 1
                  THEN SF.RFC
                  WHEN R.CvTipoDocFacturacion IN(2, 3)
                  THEN SPC.RFC
              END;
