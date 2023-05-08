CREATE VIEW [dbo].[ConsultaGastosGS]
AS

     /*Consulta general*/

     SELECT --DISTINCT 
     C.NumeroContrato, 
     ACC.NombreAreaContractual, 
     R.IdRegistro, 
     --CONCAT(S.NombreServicio AS Servicio, 
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
         THEN LTRIM(RTRIM(F.Serie+' '+F.Folio))
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
     CASE
         WHEN P.ciep = 1
         THEN TS.NombreTipoServicio
         ELSE ACNH.DescripcionActividadPetrolera
     END AS TipoDeServicio,
     CASE
         WHEN P.ciep = 1
         THEN ACIEP.NombreActividad
         ELSE SAP.SubactividadPetrolera
     END AS Actividad,
     CASE
         WHEN P.ciep = 1
         THEN RI.NombreRubro
         ELSE TP.TareaPetrolera
     END AS SubActividad, 
     ER.NombreEstado AS EstadoValidacion, 
     A.NombreArea AS Area, 
     R.Comentarios, 
     CA.ClasificacionAnexo4 AS Anexo4,
     CASE
         WHEN R.CvTipoDocFacturacion = 1
         THEN F.IdFactura
         WHEN R.CvTipoDocFacturacion IN(2, 3)
         THEN PC.IdPedimentoComprobante
     END AS Identificador, 
     LPM.IdLineaPresupuestoMes AS LineaPresupuesto, 
     P.Nombre AS Presupuesto, 
     TR.FechaPago AS FechaTransferencia, 
     ISNULL(TR.MontoPagado, 0) AS MontoTransferencia, 
     ISNULL(TP.id_Tarea, '') AS [Id_Tarea], 
     ISNULL(GR.Descripcion, '') AS [RubroCN], 
     R.PCN AS [PCN], 
     ISNULL(F.MontoConIva, '') AS [MontoFacturaConIVA], 
     ISNULL(F.Moneda, '') AS [MonedaFactura], 
     ISNULL(F.UUID, '') AS [UUID], 
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
            END AS RFC
     FROM dbo.CO_LineaPresupuestoMes LPM(NOLOCK)
          LEFT JOIN dbo.CO_Servicio S(NOLOCK) ON LPM.IdServicio = S.IdServicio
          LEFT JOIN dbo.CO_Instalacion I(NOLOCK) ON LPM.IdInstalacion = I.IdInstalacion
          LEFT JOIN dbo.CO_Registro R(NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes
          LEFT JOIN dbo.CO_GastosRubro GR(NOLOCK) ON R.IdGastoRubro = GR.IdGastoRubro
          LEFT JOIN dbo.FI_Factura F(NOLOCK) ON F.IdFactura = R.IdFactura
          LEFT JOIN dbo.FI_pedimentocomprobante PC(NOLOCK) ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
          LEFT JOIN dbo.PV_Subcontratista SF(NOLOCK) ON F.IdSubcontratista = SF.IdSubcontratista
          LEFT JOIN dbo.PV_Subcontratista SPC(NOLOCK) ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
          LEFT JOIN dbo.CO_Instalacion IR(NOLOCK) ON R.IdInstalacion = IR.IdInstalacion
          LEFT JOIN dbo.AP_Usuario U(NOLOCK) ON R.IdUsuarioCreadoPor = U.UsuarioID
          LEFT JOIN dbo.CO_TipoServicio TS(NOLOCK) ON LPM.IdTipoServicio = TS.IdTipoServicio
          LEFT JOIN dbo.CO_ActividadCIEP ACIEP(NOLOCK) ON LPM.IdActividad = ACIEP.IdActividad
          LEFT JOIN dbo.CO_SubactividadCIEP SCIEP(NOLOCK) ON LPM.IdSubactividad = SCIEP.IdSubactividad
          LEFT JOIN dbo.CO_EstadoRegistro ER(NOLOCK) ON R.IdEstado = ER.IdEstadoRegistro
          LEFT JOIN dbo.CO_Area A(NOLOCK) ON A.IdArea = LPM.IdArea
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
          LEFT JOIN dbo.CO_ClasificacionAnexo4 CA(NOLOCK) ON LPM.IdAnexo4 = CA.IdAnexo4
          LEFT JOIN dbo.CO_Presupuesto P(NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto
          LEFT JOIN dbo.CO_ActividadPetroleraCNH ACNH(NOLOCK) ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
          LEFT JOIN dbo.CO_SubactividadPetrolera SAP(NOLOCK) ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
          LEFT JOIN dbo.CO_RubroInterno RI(NOLOCK) ON LPM.IdRubroInterno = RI.IdRubroInterno
          LEFT JOIN dbo.CO_TareaPetrolera TP(NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
          LEFT JOIN dbo.CO_AnioContractual AC(NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual
          LEFT JOIN dbo.CO_Contrato C(NOLOCK) ON C.IdContrato = AC.IdContrato
          LEFT JOIN dbo.CO_Contratista CC(NOLOCK) ON CC.IdContratista = C.IdContratista
          LEFT JOIN dbo.CO_AreaContractual ACC(NOLOCK) ON ACC.IdAreaContractual = C.IdAreaContractual
          LEFT JOIN dbo.FI_TransferFactura TF(NOLOCK) ON F.IdFactura = TF.IdFactura
          LEFT JOIN dbo.FI_Transfer TR(NOLOCK) ON TF.IdTransfer = TR.IdTransferencia
          LEFT JOIN Petrovendor.dbo.FI_Factura FP(NOLOCK) ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT
          AND FP.UUID IS NOT NULL
                                           AND FP.Activa = 1
                                                             AND ISNULL(FP.IsEliminado, 0) <> 1
          LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF(NOLOCK) ON AF.IdFactura = FP.IdFactura
          LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP(NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
          LEFT JOIN Petrovendor.dbo.MM_Pedido(NOLOCK) AS PP ON PP.IdPedido = AP.IdPedido
                                                               AND PP.IdContrato =10011
          LEFT JOIN Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP(NOLOCK) ON ACP.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                            AND ACP.IdEstatus = 2
                                                                            AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
          LEFT JOIN dbo.CO_CatalogoCuentaSH CCSH(NOLOCK) ON CCSH.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH
          LEFT JOIN dbo.AWS_DocAwsDocAdinco DADA(NOLOCK) ON F.IdFactura = DADA.IdDocAdinco
          LEFT JOIN dbo.MM_BS_Actividad MA(NOLOCK) ON R.IdCBSISH = MA.IdActividad
     WHERE C.IdContrato=10011 
     GROUP BY C.NumeroContrato, 
              ACC.NombreAreaContractual, 
              PC.NumeroPedimento, 
              --S.NombreServicio, 
			  SUBSTRING(CONCAT(ACNH.id_Actividad, ' - ', SAP.[id_Sub-actividad], ' - ', TP.id_Tarea, ' - ', S.NombreServicio), 1, 255),
              I.NombreInstalacion, 
              LPM.AC_FEC_INI, 
              LPM.AC_FEC_FIN, 
              F.Fecha, 
              LTRIM(RTRIM(F.Serie+' '+F.Folio)), 
              SF.RazonSocial, 
              IR.NombreInstalacion, 
              R.InicioEjecucion, 
              R.FinEjecucion, 
              F.Fecha, 
              U.Nombre, 
              R.MontoRegistro, 
              TMF.TipoMonedaCorto, 
              R.MesPresentacion,
              CASE
                  WHEN P.ciep = 1
                  THEN TS.NombreTipoServicio
                  ELSE ACNH.DescripcionActividadPetrolera
              END,
              CASE
                  WHEN P.ciep = 1
                  THEN ACIEP.NombreActividad
                  ELSE SAP.SubactividadPetrolera
              END,
              CASE
                  WHEN P.ciep = 1
                  THEN RI.NombreRubro
                  ELSE TP.TareaPetrolera
              END, 
              R.IdRegistro, 
              ER.NombreEstado, 
              A.NombreArea, 
              R.Comentarios, 
              CA.ClasificacionAnexo4, 
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
              TR.FechaPago, 
              ISNULL(TR.MontoPagado, 0), 
              ISNULL(TP.id_Tarea, ''), 
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
            END;


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = -808
      End
      Begin Tables = 
         Begin Table = "LPM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 305
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 343
               Bottom = 135
               Right = 533
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 267
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "R"
            Begin Extent = 
               Top = 138
               Left = 321
               Bottom = 267
               Right = 600
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "GR"
            Begin Extent = 
               Top = 6
               Left = 571
               Bottom = 101
               Right = 757
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "F"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 399
               Right = 288
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PC"
            Begin Extent = 
               Top = 270
               Left = 326
               Bottom = 399
               Right = 638
            End
            DisplayFlags = 280
            TopColumn = 0
         ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosGS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'End
         Begin Table = "SF"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 531
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SPC"
            Begin Extent = 
               Top = 402
               Left = 306
               Bottom = 531
               Right = 536
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IR"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 663
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "U"
            Begin Extent = 
               Top = 402
               Left = 574
               Bottom = 531
               Right = 771
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TS"
            Begin Extent = 
               Top = 534
               Left = 321
               Bottom = 663
               Right = 535
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ACIEP"
            Begin Extent = 
               Top = 534
               Left = 573
               Bottom = 663
               Right = 784
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SCIEP"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 795
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ER"
            Begin Extent = 
               Top = 666
               Left = 293
               Bottom = 795
               Right = 486
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "A"
            Begin Extent = 
               Top = 666
               Left = 524
               Bottom = 795
               Right = 710
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TMF"
            Begin Extent = 
               Top = 798
               Left = 38
               Bottom = 927
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TCDF"
            Begin Extent = 
               Top = 798
               Left = 279
               Bottom = 927
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TMPC"
            Begin Extent = 
               Top = 798
               Left = 503
               Bottom = 927
               Right = 706
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TCDPC"
            Begin Extent = 
               Top = 930
               Left = 38
               Bottom = 1059
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CA"
            Begin Extent = 
               Top = 930
               Left = 262
               Bottom = 1059
               Right = 473
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 930
               Left = 511
            ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosGS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'   Bottom = 1059
               Right = 729
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ACNH"
            Begin Extent = 
               Top = 1062
               Left = 38
               Bottom = 1191
               Right = 302
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SAP"
            Begin Extent = 
               Top = 1062
               Left = 340
               Bottom = 1191
               Right = 570
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RI"
            Begin Extent = 
               Top = 1062
               Left = 608
               Bottom = 1191
               Right = 794
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TP"
            Begin Extent = 
               Top = 1194
               Left = 38
               Bottom = 1323
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AC"
            Begin Extent = 
               Top = 1194
               Left = 267
               Bottom = 1323
               Right = 469
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 1194
               Left = 507
               Bottom = 1323
               Right = 767
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CC"
            Begin Extent = 
               Top = 1326
               Left = 38
               Bottom = 1455
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ACC"
            Begin Extent = 
               Top = 1326
               Left = 292
               Bottom = 1455
               Right = 528
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TF"
            Begin Extent = 
               Top = 1458
               Left = 38
               Bottom = 1587
               Right = 285
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TR"
            Begin Extent = 
               Top = 1458
               Left = 323
               Bottom = 1587
               Right = 568
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosGS';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 3, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosGS';

