ALTER VIEW [dbo].[ConsultaGastosJaguarPanteraAA]
AS
     /*Consulta general*/
	 
     SELECT ISNULL(F.UUID, '') AS [UUID], 
            C.NumeroContrato, 
            ACC.NombreAreaContractual, 
            R.IdRegistro, 
            SUBSTRING(CONCAT(ACNH.id_Actividad, ' - ', SAP.[id_Sub-actividad], ' - ', TP.id_Tarea, ' - ', S.NombreServicio), 1, 255) AS Servicio, 
            I.NombreInstalacion AS InstalacionPresupuestada, 
            LPM.AC_FEC_INI AS FechaInicio, 
            LPM.AC_FEC_FIN AS FechaFin,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN 'CF'
                WHEN R.CvTipoDocFacturacion = 2
                THEN 'PI'
                WHEN R.CvTipoDocFacturacion = 3
                THEN 'PE'
            END AS TipoDocumento,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN LTRIM(RTRIM(isnull(F.Serie,'')+' '+isnull(F.Folio,'')))
                WHEN R.CvTipoDocFacturacion = 2
                THEN PC.NumeroPedimento
                WHEN R.CvTipoDocFacturacion = 3
                THEN PC.FolioComprobante
            END AS Numero,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN F.Fecha
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN PC.FechaPago
            END AS FechaDocumento,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN SUM(CASE
                             WHEN ISNULL(R.MontoRegistro, 0) <> 0
                             THEN ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio
                             ELSE 0
                         END)
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN SUM(CASE
                             WHEN ISNULL(R.MontoRegistro, 0) <> 0
                             THEN ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio
                             ELSE 0
                         END)
            END AS MontoUSD,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN SF.RazonSocial
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN SPC.RazonSocial
            END AS Subcontratista, 
            IR.NombreInstalacion AS InstalacionRegistro, 
            R.InicioEjecucion, 
            R.FinEjecucion, 
            U.Nombre AS CreadoPor, 
            R.MontoRegistro,
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN TMF.TipoMonedaCorto
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN TMPC.TipoMonedaCorto
            END AS Moneda, 
            R.MesPresentacion AS MesPresentacion, 
            ACNH.DescripcionActividadPetrolera AS TipoDeServicio, 
            SAP.SubactividadPetrolera AS Actividad, 
            TP.TareaPetrolera AS SubActividad, 
            ER.NombreEstado AS EstadoValidacion, 
			A.NombreArea AS Area,
            R.Comentarios, 
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN F.IdFactura
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN PC.IdPedimentoComprobante
            END AS Identificador, 
            LPM.IdLineaPresupuestoMes AS LineaPresupuesto, 
            P.Nombre AS Presupuesto,
            CASE
                WHEN TR.FechaPago IS NULL
                THEN TTFCP.FechaPago
                ELSE TR.FechaPago
            END AS FechaTransferencia,
            CASE
                WHEN TR.FechaPago IS NULL
                THEN TTFCP.MontoPagado
                ELSE ISNULL(TR.MontoPagado, 0)
            END AS MontoTransferencia, 
            CONVERT(VARCHAR(150), ISNULL(TP.id_Tarea, '')) AS [Id_Tarea], 
            ISNULL(GR.Descripcion, '') AS [RubroCN], 
            R.PCN AS [PCN], 
            ISNULL(F.MontoConIva, '') AS [MontoFacturaConIVA], 
            ISNULL(F.Moneda, '') AS [MonedaFactura], 
          ISNULL(F.SubTotal, '') AS [SubtotalFactura],
            CASE
                WHEN FP.IdFactura IS NOT NULL
                     AND ACP.IdEstatus = 2
                     AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
                THEN 'Si tiene carta'
                WHEN DADA.IdDocAdinco IS NOT NULL
                THEN 'Si tiene carta'
                ELSE 'NO TIENE CARTA'
            END AS CartaContenidoNacional, 
            CCSH.Nivel3, 
            CCSH.Descripcion,
            CASE
                WHEN R.IdCBSISH IS NULL
                THEN 'SIN CLASIFICAR'
                ELSE CONCAT(MA.Codigo, ' - ', MA.Nombre)
            END AS 'Catalogo Bienes/Servicios Sector Hidrocarburos',
            CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN SF.RFC
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN SPC.RFC
            END AS RFC,
            CASE
                WHEN REPLACE(F.MetodoPago, 'Ó', 'O') LIKE '%SOL%'
                     OR F.MetodoPago LIKE '%PUE%'
                     OR REPLACE(F.FormaPago, 'Ó', 'O') LIKE '%SOL%'
                     OR F.FormaPago LIKE '%PUE%'
                     OR F.MetodoPago LIKE '%CONTADO%'
                     OR F.FormaPago LIKE '%CONTADO%'
                     OR F.MetodoPago LIKE '%UNA%'
                     OR F.FormaPago LIKE '%UNA%'
                THEN 'PUE'
                WHEN F.MetodoPago IS NULL
                     AND F.FormaPago IS NULL
                THEN ''
                ELSE 'PPD'
            END AS [MetodoPago],
            CASE
			    WHEN AWSDOCF.IdFactura IS NOT NULL
				THEN 'Pagado'
                WHEN TF.IdTransferFactura IS NOT NULL
                     AND (F.MetodoPago LIKE '%exhibi%'
                          OR F.MetodoPago LIKE '%PUE%'
                          OR F.FormaPago LIKE '%exhibi%'
                          OR F.FormaPago LIKE '%PUE%')
                THEN 'Pagado'
                WHEN TF.IdTransferFactura IS NOT NULL
                     AND (F.MetodoPago LIKE '%parcia%'
                          OR F.MetodoPago LIKE '%dife%'
                          OR F.MetodoPago LIKE '%PPD%'
                          OR F.FormaPago LIKE '%parcia%'
                          OR F.FormaPago LIKE '%dife%'
                          OR F.FormaPago LIKE '%PPD%')
                THEN 'Pagado SIN COMPLEMENTO'
                WHEN TFCP.IdTransferFactura IS NOT NULL
                THEN 'Pagado CON COMPLEMENTO'
                WHEN TF.IdTransferFactura IS NULL
                     AND TFCP.IdTransferFactura IS NULL
                THEN 'NO Pagado'
            END AS EstatusPago, 
            CONCAT(MONTH(LPM.AC_PRESUP_MES), '-', YEAR(LPM.AC_PRESUP_MES)) AS 'MesPresupuestado', 
            F1.UUID AS UUIDComplemento,
			NoAceptacionServicio		=	AP.IdAceptacionPedido,
			[Pedido/OrdenCompra]		=	P2.IdPedido,
			CASE
                WHEN R.CvTipoDocFacturacion = 1
                THEN (SELECT TipoCambio FROM Petrovendor.dbo.GetTipoCambioActual(1, F.Fecha))
                WHEN R.CvTipoDocFacturacion IN(2, 3)
                THEN (SELECT TipoCambio FROM Petrovendor.dbo.GetTipoCambioActual(1, PC.FechaPago))
            END AS TipoCambio,
			(Petrovendor.dbo.fnObtenCentroCosto(FP.IdFactura)) as CentroCosto
     FROM dbo.CO_LineaPresupuestoMes LPM(NOLOCK)
          JOIN dbo.CO_Servicio S(NOLOCK) ON LPM.IdServicio = S.IdServicio
          LEFT JOIN dbo.CO_Instalacion I(NOLOCK) ON LPM.IdInstalacion = I.IdInstalacion
          JOIN dbo.CO_ActividadPetroleraCNH ACNH(NOLOCK) ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
          JOIN dbo.CO_TareaPetrolera TP(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
          JOIN dbo.CO_SubactividadPetrolera SAP(NOLOCK) ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
          JOIN dbo.CO_Presupuesto P(NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto
          JOIN dbo.CO_AnioContractual AC(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
          JOIN dbo.CO_Contrato C(NOLOCK) ON C.IdContrato = AC.IdContrato
          JOIN dbo.CO_Contratista CC(NOLOCK) ON CC.IdContratista = C.IdContratista
          JOIN dbo.CO_AreaContractual ACC(NOLOCK) ON ACC.IdAreaContractual = C.IdAreaContractual
		  LEFT JOIN dbo.CO_Area A(NOLOCK) ON A.IdArea = LPM.IdArea
          LEFT JOIN dbo.CO_Registro R(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
          LEFT JOIN dbo.CO_GastosRubro GR(NOLOCK) ON R.IdGastoRubro = GR.IdGastoRubro
          LEFT JOIN dbo.FI_Factura F(NOLOCK) ON F.IdFactura = R.IdFactura
		  LEFT JOIN dbo.FacturasAWSDocumentos AWSDOCF (NOLOCK) ON F.IdFactura = AWSDOCF.IdFactura
          LEFT JOIN dbo.FI_PedimentoComprobante PC(NOLOCK) ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
          LEFT JOIN dbo.PV_Subcontratista SF(NOLOCK) ON F.IdSubcontratista = SF.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SPC(NOLOCK) ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
          LEFT JOIN dbo.CO_Instalacion IR(NOLOCK) ON R.IdInstalacion = IR.IdInstalacion
          LEFT JOIN dbo.AP_Usuario U(NOLOCK) ON R.IdUsuarioCreadoPor = U.UsuarioID
          LEFT JOIN dbo.CO_EstadoRegistro ER(NOLOCK) ON R.IdEstado = ER.IdEstadoRegistro
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
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON F.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer TR(NOLOCK) ON TF.IdTransfer = TR.IdTransferencia
          LEFT JOIN dbo.CO_CatalogoCuentaSH CCSH(NOLOCK) ON CCSH.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
          LEFT JOIN dbo.AWS_DocAwsDocAdinco DADA(NOLOCK) ON F.IdFactura = DADA.IdDocAdinco
          LEFT JOIN dbo.MM_BS_Actividad MA(NOLOCK) ON R.IdCBSISH = MA.IdActividad
          LEFT JOIN dbo.FI_CPDocRelacionado FCPDR(NOLOCK) ON F.UUID = FCPDR.IdDocumento
          LEFT JOIN dbo.FI_ComplementoDePago CP(NOLOCK) ON CP.IdComplementoDePago = FCPDR.IdComplementoDePago
          LEFT JOIN dbo.FI_Factura F1(NOLOCK) ON CP.IdFactura = F1.IdFactura
          LEFT JOIN dbo.FI_TransferFactura TFCP(NOLOCK) ON CP.IdFactura = TFCP.IdFactura
          LEFT JOIN dbo.FI_Transfer TTFCP(NOLOCK) ON TFCP.IdTransfer = TTFCP.IdTransferencia
          LEFT JOIN Petrovendor.dbo.FI_Factura FP(NOLOCK) ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT
                                                             AND FP.UUID IS NOT NULL
                                                             AND FP.Activa = 1
                                                             AND ISNULL(FP.IsEliminado, 0) <> 1
          LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF(NOLOCK) ON AF.IdFactura = FP.IdFactura
          LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP(NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
          LEFT JOIN Petrovendor.dbo.MM_Pedido(NOLOCK) AS PP 
		  ON	PP.IdPedido = AP.IdPedido
          AND	PP.IdContrato IN(10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10024, 10043, 10052)
		  left JOIN Petrovendor.dbo.MM_Pedidos P2 ON PP.IdPedido = P2.IdIdentificador
          LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP(NOLOCK) ON ACP.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                            AND ACP.IdEstatus = 2
                                                                            AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
		 LEFT JOIN Petrovendor.dbo.MM_PedidoDetalle as PD
		 ON PP.IdPedido = PD.IdPedido
		 LEFT JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle as APD
		 ON PD.IdPedidoDetalle=APD.IdPedidoDetalle
		 
     WHERE C.IdContrato IN(10014, 10015, 10016, 10017, 10018, 10019, 10020, 10021, 10022, 10023, 10024, 10043, 10052)
     GROUP BY C.NumeroContrato, 
              ACC.NombreAreaContractual, 
              PC.NumeroPedimento, 
              SUBSTRING(CONCAT(ACNH.id_Actividad, ' - ', SAP.[id_Sub-actividad], ' - ', TP.id_Tarea, ' - ', S.NombreServicio), 1, 255), 
              I.NombreInstalacion, 
              LPM.AC_FEC_INI, 
              LPM.AC_FEC_FIN, 
              F.Fecha, 
              LTRIM(RTRIM(isnull(F.Serie,'')+' '+isnull(F.Folio,''))), 
              SF.RazonSocial, 
              IR.NombreInstalacion, 
              R.InicioEjecucion, 
              R.FinEjecucion, 
              F.Fecha, 
              U.Nombre, 
              R.MontoRegistro, 
              TMF.TipoMonedaCorto, 
              R.MesPresentacion, 
              ACNH.DescripcionActividadPetrolera, 
              SAP.SubactividadPetrolera, 
              TP.TareaPetrolera, 
              R.IdRegistro, 
              ER.NombreEstado, 
			  A.NombreArea,
              R.Comentarios, 
              F.IdFactura, 
              PC.IdPedimentoComprobante, 
              IR.CUIP, 
              IR.WelIID, 
              LPM.IdLineaPresupuestoMes, 
              IR.IdInstalacion, 
              P.Nombre, 
              R.CvTipoDocFacturacion, 
              PC.FechaPago, 
              PC.IdMoneda, 
              R.IdRegistro, 
              PC.FolioComprobante, 
              SPC.RazonSocial, 
              TMPC.TipoMonedaCorto,
              CASE
                  WHEN TR.FechaPago IS NULL
                  THEN TTFCP.FechaPago
                  ELSE TR.FechaPago
              END,
              CASE
                  WHEN TR.FechaPago IS NULL
                  THEN TTFCP.MontoPagado
                  ELSE ISNULL(TR.MontoPagado, 0)
              END, 
              CONVERT(VARCHAR(150), ISNULL(TP.id_Tarea, '')), 
              ISNULL(GR.Descripcion, ''), 
              R.PCN, 
              ISNULL(F.MontoConIva, ''), 
              ISNULL(F.Moneda, ''), 
              ISNULL(F.UUID, ''), 
              ISNULL(F.SubTotal, ''),
              CASE
                  WHEN FP.IdFactura IS NOT NULL
                       AND ACP.IdEstatus = 2
                       AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
                  THEN 'Si tiene carta'
                  WHEN DADA.IdDocAdinco IS NOT NULL
                  THEN 'Si tiene carta'
                  ELSE 'NO TIENE CARTA'
              END, 
              CCSH.Nivel3, 
              CCSH.Descripcion,
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
              END,
              CASE
                  WHEN REPLACE(F.MetodoPago, 'Ó', 'O') LIKE '%SOL%'
                       OR F.MetodoPago LIKE '%PUE%'
                       OR REPLACE(F.FormaPago, 'Ó', 'O') LIKE '%SOL%'
                       OR F.FormaPago LIKE '%PUE%'
                       OR F.MetodoPago LIKE '%CONTADO%'
                       OR F.FormaPago LIKE '%CONTADO%'
                       OR F.MetodoPago LIKE '%UNA%'
                       OR F.FormaPago LIKE '%UNA%'
                  THEN 'PUE'
                  WHEN F.MetodoPago IS NULL
                       AND F.FormaPago IS NULL
                  THEN ''
                  ELSE 'PPD'
              END,
              CASE
				WHEN AWSDOCF.IdFactura IS NOT NULL
				THEN 'Pagado'
                  WHEN TF.IdTransferFactura IS NOT NULL
                       AND (F.MetodoPago LIKE '%exhibi%'
                            OR F.MetodoPago LIKE '%PUE%'
                            OR F.FormaPago LIKE '%exhibi%'
                            OR F.FormaPago LIKE '%PUE%')
                  THEN 'Pagado'
                  WHEN TF.IdTransferFactura IS NOT NULL
                       AND (F.MetodoPago LIKE '%parcia%'
                            OR F.MetodoPago LIKE '%dife%'
                            OR F.MetodoPago LIKE '%PPD%'
                            OR F.FormaPago LIKE '%parcia%'
                            OR F.FormaPago LIKE '%dife%'
                            OR F.FormaPago LIKE '%PPD%')
                  THEN 'Pagado SIN COMPLEMENTO'
                  WHEN TFCP.IdTransferFactura IS NOT NULL
                  THEN 'Pagado CON COMPLEMENTO'
                  WHEN TF.IdTransferFactura IS NULL
                       AND TFCP.IdTransferFactura IS NULL
                  THEN 'NO Pagado'
              END, 
              CONCAT(MONTH(LPM.AC_PRESUP_MES), '-', YEAR(LPM.AC_PRESUP_MES)), 
              F1.UUID,
			  AP.IdAceptacionPedido,
			  P2.IdPedido,
			  P.Creadoel,
			  PD.IdMoneda,
			  PD.PrecioUnitario,
			  APD.Cantidad,
			  PC.FechaPago,
			  FP.IdFactura
GO