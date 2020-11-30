CREATE VIEW dbo.GastosAmatitlan2020
AS
SELECT        R.IdRegistro, S.NombreServicio AS Servicio, I.NombreInstalacion AS InstalacionPresupuestada, LPM.AC_FEC_INI AS FechaInicio, LPM.AC_FEC_FIN AS FechaFin, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN 'CF' WHEN R.CvTipoDocFacturacion = 2 THEN 'PI' WHEN R.CvTipoDocFacturacion = 3 THEN 'PE' END AS TipoDocumento, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN LTRIM(RTRIM(isnull(F.Serie, '') + ' ' + isnull(F.Folio, ''))) 
                         WHEN R.CvTipoDocFacturacion = 2 THEN PC.NumeroPedimento WHEN R.CvTipoDocFacturacion = 3 THEN PC.FolioComprobante END AS Numero, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN F.Fecha WHEN R.CvTipoDocFacturacion IN (2, 3) THEN PC.FechaPago END AS FechaDocumento, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN SUM(CASE WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN ROUND(ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio, 2) ELSE 0 END) WHEN R.CvTipoDocFacturacion IN (2, 3) 
                         THEN SUM(CASE WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN ROUND(ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio, 2) ELSE 0 END) END AS MontoUSD, 
                         CASE WHEN R.CvTipoDocFacturacion = 1 THEN SF.RazonSocial WHEN R.CvTipoDocFacturacion IN (2, 3) THEN SPC.RazonSocial END AS Subcontratista, IR.NombreInstalacion AS InstalacionRegistro, R.InicioEjecucion, 
                         R.FinEjecucion, U.Nombre AS CreadoPor, R.MontoRegistro, CASE WHEN R.CvTipoDocFacturacion = 1 THEN TMF.TipoMonedaCorto WHEN R.CvTipoDocFacturacion IN (2, 3) THEN TMPC.TipoMonedaCorto END AS Moneda, 
                         R.MesPresentacion, CASE WHEN P.ciep = 1 THEN TS .NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END AS TipoDeServicio, 
                         CASE WHEN P.ciep = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END AS Actividad, CASE WHEN P.ciep = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END AS SubActividad, 
                         ER.NombreEstado AS EstadoValidacion, A.NombreArea AS Area, R.Comentarios, CA.ClasificacionAnexo4 AS Anexo4, CASE WHEN R.CvTipoDocFacturacion = 1 THEN F.IdFactura WHEN R.CvTipoDocFacturacion IN (2, 3) 
                         THEN PC.IdPedimentoComprobante END AS Identificador, LPM.IdLineaPresupuestoMes AS LineaPresupuesto, P.Nombre AS Presupuesto, TCDF.TipoCambio, ISNULL(F.UUID, '') AS [UUID FACTURA PROVEEDOR PRIMARIO]
FROM            dbo.CO_LineaPresupuestoMes AS LPM WITH (NOLOCK) LEFT OUTER JOIN
                         dbo.CO_Servicio AS S WITH (NOLOCK) ON LPM.IdServicio = S.IdServicio LEFT OUTER JOIN
                         dbo.CO_Instalacion AS I WITH (NOLOCK) ON LPM.IdInstalacion = I.IdInstalacion LEFT OUTER JOIN
                         dbo.CO_Registro AS R WITH (NOLOCK) ON R.IdPrograma = LPM.IdLineaPresupuestoMes LEFT OUTER JOIN
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
                         dbo.CO_TipoCambioMensual AS TCDF WITH (NOLOCK) ON TCDF.IdMoneda = TMF.IdMoneda AND TCDF.Anio = YEAR(F.Fecha) AND TCDF.IdMes = MONTH(F.Fecha) LEFT OUTER JOIN
                         dbo.PV_TipoMoneda AS TMPC WITH (NOLOCK) ON TMPC.IdMoneda = PC.IdMoneda LEFT OUTER JOIN
                         dbo.CO_TipoCambioMensual AS TCDPC WITH (NOLOCK) ON TCDPC.IdMoneda = TMPC.IdMoneda AND TCDPC.Anio = YEAR(PC.FechaPago) AND TCDPC.IdMes = MONTH(PC.FechaPago) LEFT OUTER JOIN
                         dbo.CO_ClasificacionAnexo4 AS CA WITH (NOLOCK) ON LPM.IdAnexo4 = CA.IdAnexo4 LEFT OUTER JOIN
                         dbo.CO_Presupuesto AS P WITH (NOLOCK) ON LPM.IdPresupuesto = P.IdPresupuesto LEFT OUTER JOIN
                         dbo.CO_ActividadPetroleraCNH AS ACNH WITH (NOLOCK) ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera LEFT OUTER JOIN
                         dbo.CO_SubactividadPetrolera AS SAP WITH (NOLOCK) ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera LEFT OUTER JOIN
                         dbo.CO_RubroInterno AS RI WITH (NOLOCK) ON LPM.IdRubroInterno = RI.IdRubroInterno LEFT OUTER JOIN
                         dbo.CO_TareaPetrolera AS TP WITH (NOLOCK) ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
WHERE        (P.IdPresupuesto IN (10048, 10037, 10065, 10075, 10159)) AND (R.IdRegistro IS NOT NULL)
GROUP BY PC.NumeroPedimento, S.NombreServicio, I.NombreInstalacion, LPM.AC_FEC_INI, LPM.AC_FEC_FIN, F.Fecha, LTRIM(RTRIM(ISNULL(F.Serie, '') + ' ' + ISNULL(F.Folio, ''))), SF.RazonSocial, IR.NombreInstalacion, 
                         R.InicioEjecucion, R.FinEjecucion, F.Fecha, U.Nombre, R.MontoRegistro, TMF.TipoMonedaCorto, R.MesPresentacion, CASE WHEN P.ciep = 1 THEN TS .NombreTipoServicio ELSE ACNH.DescripcionActividadPetrolera END, 
                         CASE WHEN P.ciep = 1 THEN ACIEP.NombreActividad ELSE SAP.SubactividadPetrolera END, CASE WHEN P.ciep = 1 THEN RI.NombreRubro ELSE TP.TareaPetrolera END, R.IdRegistro, ER.NombreEstado, A.NombreArea, 
                         R.Comentarios, CA.ClasificacionAnexo4, F.IdFactura, PC.IdPedimentoComprobante, IR.CUIP, IR.WelIID, LPM.IdLineaPresupuestoMes, IR.IdInstalacion, P.Nombre, R.CvTipoDocFacturacion, PC.FechaPago, PC.IdMoneda, 
                         R.IdRegistro, PC.FolioComprobante, SPC.RazonSocial, TMPC.TipoMonedaCorto, TCDF.TipoCambio, ISNULL(F.UUID, '')

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
               Top = 6
               Left = 343
               Bottom = 136
               Right = 533
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 6
               Left = 571
               Bottom = 136
               Right = 816
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "R"
            Begin Extent = 
               Top = 6
               Left = 854
               Bottom = 136
               Right = 1133
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "F"
            Begin Extent = 
               Top = 6
               Left = 1171
               Bottom = 136
               Right = 1419
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PC"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 350
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SF"
            Begin Extent = 
               Top = 138
               Left = 388
               Bottom = 268
               Right = 618
            End
            DisplayFlags = 280
            TopColumn = 0
         End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'GastosAmatitlan2020';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
         Begin Table = "SPC"
            Begin Extent = 
               Top = 138
               Left = 656
               Bottom = 268
               Right = 886
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "IR"
            Begin Extent = 
               Top = 138
               Left = 924
               Bottom = 268
               Right = 1169
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "U"
            Begin Extent = 
               Top = 138
               Left = 1207
               Bottom = 268
               Right = 1403
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TS"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 251
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ACIEP"
            Begin Extent = 
               Top = 270
               Left = 289
               Bottom = 400
               Right = 500
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SCIEP"
            Begin Extent = 
               Top = 270
               Left = 538
               Bottom = 400
               Right = 755
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ER"
            Begin Extent = 
               Top = 270
               Left = 793
               Bottom = 400
               Right = 986
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "A"
            Begin Extent = 
               Top = 270
               Left = 1024
               Bottom = 400
               Right = 1210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TMF"
            Begin Extent = 
               Top = 270
               Left = 1248
               Bottom = 400
               Right = 1450
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TCDF"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TMPC"
            Begin Extent = 
               Top = 402
               Left = 301
               Bottom = 532
               Right = 503
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TCDPC"
            Begin Extent = 
               Top = 402
               Left = 541
               Bottom = 532
               Right = 766
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CA"
            Begin Extent = 
               Top = 402
               Left = 804
               Bottom = 532
               Right = 1016
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 402
               Left = 1054
               Bottom = 532
               Right = 1272
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ACNH"
            Begin Extent = 
               Top = 534
               Left = 38
   ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'GastosAmatitlan2020';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane3', @value = N'            Bottom = 664
               Right = 302
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SAP"
            Begin Extent = 
               Top = 534
               Left = 340
               Bottom = 664
               Right = 570
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "RI"
            Begin Extent = 
               Top = 534
               Left = 608
               Bottom = 664
               Right = 794
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TP"
            Begin Extent = 
               Top = 534
               Left = 832
               Bottom = 664
               Right = 1022
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'GastosAmatitlan2020';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 3, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'GastosAmatitlan2020';

