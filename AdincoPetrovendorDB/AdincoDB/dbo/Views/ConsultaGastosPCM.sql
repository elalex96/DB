CREATE VIEW dbo.ConsultaGastosPCM
AS
SELECT        C.NumeroContrato, ACC.NombreAreaContractual, R.IdRegistro, S.NombreServicio AS Servicio, I.NombreInstalacion AS InstalacionPresupuestada, LPM.AC_FEC_INI AS FechaInicio, LPM.AC_FEC_FIN AS FechaFin, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN 'CF' WHEN R.CvTipoDocFacturacion = 2 THEN 'PI' WHEN R.CvTipoDocFacturacion = 3 THEN 'PE' END AS TipoDocumento, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN LTRIM(RTRIM(F.Serie + ' ' + F.Folio)) 
                         WHEN R.CvTipoDocFacturacion = 2 THEN PC.NumeroPedimento WHEN R.CvTipoDocFacturacion = 3 THEN PC.FolioComprobante END AS Numero, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN F.Fecha WHEN R.CvTipoDocFacturacion IN (2, 3) THEN PC.FechaPago END AS FechaDocumento, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN SUM(CASE WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio ELSE 0 END) WHEN R.CvTipoDocFacturacion IN (2, 3) 
                         THEN SUM(CASE WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio ELSE 0 END) END AS MontoUSD, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN SF.RazonSocial WHEN R.CvTipoDocFacturacion IN (2, 3) THEN SPC.RazonSocial END AS Subcontratista, IR.NombreInstalacion AS InstalacionRegistro, R.InicioEjecucion, 
                         R.FinEjecucion, U.Nombre AS CreadoPor, R.MontoRegistro, CASE WHEN R.CvTipoDocFacturacion = 1 THEN TMF.TipoMonedaCorto WHEN R.CvTipoDocFacturacion IN (2, 3) THEN TMPC.TipoMonedaCorto END AS Moneda, 
                         R.MesPresentacion, CASE WHEN P.ciep = 1 THEN TS .NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END AS TipoDeServicio, 
                         CASE WHEN P.ciep = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END AS Actividad, CASE WHEN P.ciep = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END AS SubActividad, 
                         ER.NombreEstado AS EstadoValidacion, A.NombreArea AS Area, R.Comentarios, CA.ClasificacionAnexo4 AS Anexo4, CASE WHEN R.CvTipoDocFacturacion = 1 THEN F.IdFactura WHEN R.CvTipoDocFacturacion IN (2, 3) 
                         THEN PC.IdPedimentoComprobante END AS Identificador, LPM.IdLineaPresupuestoMes AS LineaPresupuesto, P.Nombre AS Presupuesto, TR.FechaPago AS FechaTransferencia, ISNULL(TR.MontoPagado, 0) 
                         AS MontoTransferencia, ISNULL(TP.id_Tarea, '') AS Id_Tarea, ISNULL(GR.Descripcion, '') AS RubroCN, R.PCN, ISNULL(F.MontoConIva, '') AS MontoFacturaConIVA, ISNULL(F.Moneda, '') AS MonedaFactura, ISNULL(F.UUID, '') 
                         AS UUID, ISNULL(F.SubTotal, '') AS SubtotalFactura, CASE WHEN FP.IdFactura IS NOT NULL AND ACP.IdEstatus = 2 AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1 THEN 'Si tiene carta' WHEN DADA.IdDocAdinco IS NOT NULL 
                         THEN 'Si tiene carta' ELSE 'NO TIENE CARTA' END AS CartaContenidoNacional, CCSH.Nivel3, CCSH.Descripcion, F.Fecha
FROM            dbo.CO_LineaPresupuestoMes AS LPM WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.CO_Servicio AS S WITH (NOLOCK) ON LPM.IdServicio = S.IdServicio LEFT OUTER JOIN
                         dbo.CO_Instalacion AS I WITH (NOLOCK) ON LPM.IdInstalacion = I.IdInstalacion LEFT OUTER JOIN
                         dbo.CO_Registro AS R WITH (NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes LEFT OUTER JOIN
                         dbo.CO_GastosRubro AS GR WITH (NOLOCK) ON R.IdGastoRubro = GR.IdGastoRubro LEFT OUTER JOIN
                         dbo.FI_Factura AS F WITH (NOLOCK) ON F.IdFactura = R.IdFactura LEFT OUTER JOIN
                         dbo.FI_PedimentoComprobante AS PC WITH (NOLOCK) ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante LEFT OUTER JOIN
                         dbo.PV_Subcontratista AS SF WITH (NOLOCK) ON F.IdSubcontratista = SF.IdSubcontratista LEFT OUTER JOIN
                         dbo.PV_Subcontratista AS SPC WITH (NOLOCK) ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador LEFT OUTER JOIN
                         dbo.CO_Instalacion AS IR WITH (NOLOCK) ON R.IdInstalacion = IR.IdInstalacion LEFT OUTER JOIN
                         dbo.AP_Usuario AS U WITH (NOLOCK) ON R.IdUsuarioCreadoPor = U.UsuarioID LEFT OUTER JOIN
                         dbo.CO_TipoServicio AS TS WITH (NOLOCK) ON LPM.IdTipoServicio = TS.IdTipoServicio LEFT OUTER JOIN
                         dbo.CO_ActividadCIEP AS ACIEP WITH (NOLOCK) ON LPM.IdActividad = ACIEP.IdActividad LEFT OUTER JOIN
                         dbo.CO_SubactividadCIEP AS SCIEP WITH (NOLOCK) ON LPM.IdSubactividad = SCIEP.IdSubactividad LEFT OUTER JOIN
                         dbo.CO_EstadoRegistro AS ER WITH (NOLOCK) ON R.IdEstado = ER.IdEstadoRegistro LEFT OUTER JOIN
                         dbo.CO_Area AS A WITH (NOLOCK) ON A.IdArea = LPM.IdArea LEFT OUTER JOIN
                         dbo.PV_TipoMoneda AS TMF WITH (NOLOCK) ON TMF.IdMoneda = F.IdMoneda LEFT OUTER JOIN
                         dbo.CO_TipoCambioDiario AS TCDF WITH (NOLOCK) ON TCDF.IdMoneda = TMF.IdMoneda AND DAY(TCDF.Fecha) = DAY(F.Fecha) AND MONTH(TCDF.Fecha) = MONTH(F.Fecha) AND YEAR(TCDF.Fecha) = YEAR(F.Fecha) 
                         LEFT OUTER JOIN
                         dbo.PV_TipoMoneda AS TMPC WITH (NOLOCK) ON TMPC.IdMoneda = PC.IdMoneda LEFT OUTER JOIN
                         dbo.CO_TipoCambioDiario AS TCDPC WITH (NOLOCK) ON TCDPC.IdMoneda = TMPC.IdMoneda AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago) AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago) AND YEAR(TCDPC.Fecha) 
                         = YEAR(PC.FechaPago) LEFT OUTER JOIN
                         dbo.CO_ClasificacionAnexo4 AS CA WITH (NOLOCK) ON LPM.IdAnexo4 = CA.IdAnexo4 LEFT OUTER JOIN
                         dbo.CO_Presupuesto AS P WITH (NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto LEFT OUTER JOIN
                         dbo.CO_ActividadPetroleraCNH AS ACNH WITH (NOLOCK) ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera LEFT OUTER JOIN
                         dbo.CO_SubactividadPetrolera AS SAP WITH (NOLOCK) ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera LEFT OUTER JOIN
                         dbo.CO_RubroInterno AS RI WITH (NOLOCK) ON LPM.IdRubroInterno = RI.IdRubroInterno LEFT OUTER JOIN
                         dbo.CO_TareaPetrolera AS TP WITH (NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera LEFT OUTER JOIN
                         dbo.CO_AnioContractual AS AC WITH (NOLOCK) ON AC.IdAnioContractual = P.IdAnioContractual LEFT OUTER JOIN
                         dbo.CO_Contrato AS C WITH (NOLOCK) ON C.IdContrato = AC.IdContrato LEFT OUTER JOIN
                         dbo.CO_Contratista AS CC WITH (NOLOCK) ON CC.IdContratista = C.IdContratista LEFT OUTER JOIN
                         dbo.CO_AreaContractual AS ACC WITH (NOLOCK) ON ACC.IdAreaContractual = C.IdAreaContractual LEFT OUTER JOIN
                         dbo.FI_TransferFactura AS TF WITH (NOLOCK) ON F.IdFactura = TF.IdFactura LEFT OUTER JOIN
                         dbo.FI_Transfer AS TR WITH (NOLOCK) ON TF.IdTransfer = TR.IdTransferencia LEFT OUTER JOIN
                         Petrovendor.dbo.FI_Factura AS FP WITH (NOLOCK) ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT AND FP.UUID IS NOT NULL AND FP.Activa = 1 AND FP.IsEliminado = 0 LEFT OUTER JOIN
                         Petrovendor.dbo.MM_AceptacionFactura AS AF WITH (NOLOCK) ON AF.IdFactura = FP.IdFactura LEFT OUTER JOIN
                         Petrovendor.dbo.MM_AceptacionPedido AS AP WITH (NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido LEFT OUTER JOIN
                         Petrovendor.dbo.MM_Pedido AS PP WITH (NOLOCK) ON PP.IdPedido = AP.IdPedido AND PP.IdContrato IN (10036) LEFT OUTER JOIN
                         Petrovendor.dbo.MM_AceptacionCartaPCN AS ACP WITH (NOLOCK) ON ACP.IdAceptacionPedido = AP.IdAceptacionPedido AND ACP.IdEstatus = 2 AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1 LEFT OUTER JOIN
                         dbo.CO_CatalogoCuentaSH AS CCSH WITH (NOLOCK) ON CCSH.IdCatalogoCuentasSH = R.IdCatalogoCuentasSH LEFT OUTER JOIN
                         dbo.AWS_DocAwsDocAdinco AS DADA ON F.IdFactura = DADA.IdDocAdinco
WHERE        (C.IdContrato IN (10036))
GROUP BY C.NumeroContrato, ACC.NombreAreaContractual, PC.NumeroPedimento, S.NombreServicio, I.NombreInstalacion, LPM.AC_FEC_INI, LPM.AC_FEC_FIN, F.Fecha, LTRIM(RTRIM(F.Serie + ' ' + F.Folio)), SF.RazonSocial, 
                         IR.NombreInstalacion, R.InicioEjecucion, R.FinEjecucion, F.Fecha, U.Nombre, R.MontoRegistro, TMF.TipoMonedaCorto, R.MesPresentacion, 
                         CASE WHEN P.ciep = 1 THEN TS .NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END, CASE WHEN P.ciep = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END, 
                         CASE WHEN P.ciep = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END, R.IdRegistro, ER.NombreEstado, A.NombreArea, R.Comentarios, CA.ClasificacionAnexo4, F.IdFactura, PC.IdPedimentoComprobante, IR.CUIP, 
                         IR.WelIID, LPM.IdLineaPresupuestoMes, IR.IdInstalacion, P.Nombre, R.CvTipoDocFacturacion, PC.FechaPago, PC.IdMoneda, R.IdRegistro, PC.FolioComprobante, SPC.RazonSocial, TMPC.TipoMonedaCorto, TR.FechaPago, 
                         ISNULL(TR.MontoPagado, 0), ISNULL(TP.id_Tarea, ''), ISNULL(GR.Descripcion, ''), R.PCN, ISNULL(F.MontoConIva, ''), ISNULL(F.Moneda, ''), ISNULL(F.UUID, ''), ISNULL(F.SubTotal, ''), CASE WHEN FP.IdFactura IS NOT NULL AND 
                         ACP.IdEstatus = 2 AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1 THEN 'Si tiene carta' WHEN DADA.IdDocAdinco IS NOT NULL THEN 'Si tiene carta' ELSE 'NO TIENE CARTA' END, CCSH.Nivel3, CCSH.Descripcion, F.Fecha

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
         Left = 0
      End
      Begin Tables = 
         Begin Table = "LPM"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 305
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "S"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "R"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 317
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "GR"
            Begin Extent = 
               Top = 138
               Left = 266
               Bottom = 234
               Right = 452
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "F"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 664
               Right = 288
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PC"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 796
               Right = 350
            End
            DisplayFlags = 280
            TopColumn = 0
         En', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosPCM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'd
         Begin Table = "SF"
            Begin Extent = 
               Top = 798
               Left = 38
               Bottom = 928
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SPC"
            Begin Extent = 
               Top = 930
               Left = 38
               Bottom = 1060
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IR"
            Begin Extent = 
               Top = 1062
               Left = 38
               Bottom = 1192
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "U"
            Begin Extent = 
               Top = 1194
               Left = 38
               Bottom = 1324
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TS"
            Begin Extent = 
               Top = 1326
               Left = 38
               Bottom = 1456
               Right = 252
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ACIEP"
            Begin Extent = 
               Top = 1458
               Left = 38
               Bottom = 1588
               Right = 249
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SCIEP"
            Begin Extent = 
               Top = 1590
               Left = 38
               Bottom = 1720
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ER"
            Begin Extent = 
               Top = 1194
               Left = 273
               Bottom = 1324
               Right = 466
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "A"
            Begin Extent = 
               Top = 1722
               Left = 38
               Bottom = 1852
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TMF"
            Begin Extent = 
               Top = 1722
               Left = 262
               Bottom = 1852
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TCDF"
            Begin Extent = 
               Top = 1854
               Left = 38
               Bottom = 1984
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TMPC"
            Begin Extent = 
               Top = 1854
               Left = 262
               Bottom = 1984
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TCDPC"
            Begin Extent = 
               Top = 1986
               Left = 38
               Bottom = 2116
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CA"
            Begin Extent = 
               Top = 2118
               Left = 38
               Bottom = 2248
               Right = 249
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 2250
               Left = 3', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosPCM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'8
               Bottom = 2380
               Right = 256
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ACNH"
            Begin Extent = 
               Top = 2382
               Left = 38
               Bottom = 2512
               Right = 302
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SAP"
            Begin Extent = 
               Top = 2514
               Left = 38
               Bottom = 2644
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RI"
            Begin Extent = 
               Top = 1986
               Left = 262
               Bottom = 2116
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TP"
            Begin Extent = 
               Top = 2646
               Left = 38
               Bottom = 2776
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AC"
            Begin Extent = 
               Top = 2778
               Left = 38
               Bottom = 2908
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 2910
               Left = 38
               Bottom = 3040
               Right = 298
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CC"
            Begin Extent = 
               Top = 3042
               Left = 38
               Bottom = 3172
               Right = 254
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ACC"
            Begin Extent = 
               Top = 3174
               Left = 38
               Bottom = 3304
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TF"
            Begin Extent = 
               Top = 3306
               Left = 38
               Bottom = 3436
               Right = 285
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TR"
            Begin Extent = 
               Top = 3438
               Left = 38
               Bottom = 3568
               Right = 283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FP"
            Begin Extent = 
               Top = 3570
               Left = 38
               Bottom = 3700
               Right = 268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AF"
            Begin Extent = 
               Top = 3702
               Left = 38
               Bottom = 3832
               Right = 255
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AP"
            Begin Extent = 
               Top = 3834
               Left = 38
               Bottom = 3964
               Right = 277
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PP"
            Begin Extent = 
               Top = 3966
               Left = 38
               Bottom = 4096
               Right = 289
            End
            DisplayFlags = 280
         ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosPCM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane4', @value = N'   TopColumn = 0
         End
         Begin Table = "ACP"
            Begin Extent = 
               Top = 4098
               Left = 38
               Bottom = 4228
               Right = 265
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CCSH"
            Begin Extent = 
               Top = 4230
               Left = 38
               Bottom = 4360
               Right = 259
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "DADA"
            Begin Extent = 
               Top = 4362
               Left = 38
               Bottom = 4492
               Right = 255
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosPCM';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 4, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'ConsultaGastosPCM';

