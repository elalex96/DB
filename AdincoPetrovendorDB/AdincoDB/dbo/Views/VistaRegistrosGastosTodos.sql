
CREATE VIEW [dbo].[VistaRegistrosGastosTodos]
AS
SELECT        TOP (100) PERCENT dbo.CO_Servicio.NombreServicio AS Servicio, dbo.CO_Instalacion.NombreInstalacion AS InstalacionPresupuestada, dbo.CO_LineaPresupuestoMes.AC_FEC_INI AS FechaInicio, 
                         dbo.CO_LineaPresupuestoMes.AC_FEC_FIN AS FechaFin, dbo.FI_Factura.Fecha AS FechaFactura, SUM(CASE WHEN ISNULL(co_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(co_Registro.MontoRegistro, 0) 
                         / CO_TipoCambioMensual.TipoCambio ELSE 0 END) AS MontoUSD, dbo.FI_Factura.Serie + '-' + dbo.FI_Factura.Folio AS NumeroFactura, dbo.PV_Subcontratista.RazonSocial AS Subcontratista, 
                         InstalacionRegistro.NombreInstalacion AS InstalacionRegistro, dbo.CO_Registro.InicioEjecucion, dbo.CO_Registro.FinEjecucion, dbo.AP_Usuario.Nombre AS CreadoPor, dbo.CO_Registro.MontoRegistro, 
                         dbo.PV_TipoMoneda.TipoMonedaCorto AS Moneda, dbo.CO_Registro.MesPresentacion, dbo.CO_TipoServicio.NombreTipoServicio AS TipoDeServicio, dbo.CO_ActividadCIEP.NombreActividad AS Actividad, 
                         dbo.CO_SubactividadCIEP.NombreSubactividad AS SubActividad, dbo.CO_Registro.IdRegistro AS NumeroOperacion, dbo.CO_EstadoRegistro.NombreEstado AS EstadoValidacion, 
                         dbo.CO_Area.NombreArea AS Area, dbo.CO_Registro.Comentarios, dbo.CO_ClasificacionAnexo4.ClasificacionAnexo4 AS Anexo4, dbo.FI_Factura.IdFactura AS IdentificadorFactura, 
                         dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes AS LineaPresupuesto, dbo.CO_Presupuesto.Nombre AS Presupuesto
FROM            dbo.CO_LineaPresupuestoMes LEFT OUTER JOIN
                         dbo.CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = dbo.CO_Servicio.IdServicio LEFT OUTER JOIN
                         dbo.CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = dbo.CO_Instalacion.IdInstalacion LEFT OUTER JOIN
                         dbo.CO_Registro ON dbo.CO_Registro.IdPrograma = dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes LEFT OUTER JOIN
                         dbo.FI_Factura ON dbo.FI_Factura.IdFactura = dbo.CO_Registro.IdFactura LEFT OUTER JOIN
                         dbo.PV_Subcontratista ON dbo.FI_Factura.IdSubcontratista = dbo.PV_Subcontratista.IdSubcontratista LEFT OUTER JOIN
                         dbo.CO_Instalacion AS InstalacionRegistro ON dbo.CO_Registro.IdInstalacion = InstalacionRegistro.IdInstalacion LEFT OUTER JOIN
                         dbo.AP_Usuario ON dbo.CO_Registro.IdUsuarioCreadoPor = dbo.AP_Usuario.UsuarioID LEFT OUTER JOIN
                         dbo.CO_TipoServicio ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = dbo.CO_TipoServicio.IdTipoServicio LEFT OUTER JOIN
                         dbo.CO_ActividadCIEP ON dbo.CO_LineaPresupuestoMes.IdActividad = dbo.CO_ActividadCIEP.IdActividad LEFT OUTER JOIN
                         dbo.CO_SubactividadCIEP ON dbo.CO_LineaPresupuestoMes.IdSubactividad = dbo.CO_SubactividadCIEP.IdSubactividad LEFT OUTER JOIN
                         dbo.CO_EstadoRegistro ON dbo.CO_Registro.IdEstado = dbo.CO_EstadoRegistro.IdEstadoRegistro LEFT OUTER JOIN
                         dbo.CO_Area ON dbo.CO_Area.IdArea = dbo.CO_LineaPresupuestoMes.IdArea LEFT OUTER JOIN
                         dbo.PV_TipoMoneda ON dbo.PV_TipoMoneda.IdMoneda = dbo.FI_Factura.IdMoneda LEFT OUTER JOIN
                         dbo.CO_TipoCambioMensual ON dbo.CO_TipoCambioMensual.IdMoneda = dbo.FI_Factura.IdMoneda AND dbo.CO_TipoCambioMensual.IdMes = MONTH(dbo.CO_Registro.MesPresentacion) AND 
                         dbo.CO_TipoCambioMensual.Anio = YEAR(dbo.CO_Registro.MesPresentacion) LEFT OUTER JOIN
                         dbo.CO_ClasificacionAnexo4 ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = dbo.CO_ClasificacionAnexo4.IdAnexo4 LEFT OUTER JOIN
                         dbo.CO_Presupuesto ON dbo.CO_LineaPresupuestoMes.IdPresupuesto = dbo.CO_Presupuesto.IdPresupuesto
WHERE        (dbo.CO_Presupuesto.IdPresupuesto IN (10005, 10006, 10004)) AND (dbo.CO_Registro.IdRegistro IS NOT NULL)
GROUP BY dbo.CO_Servicio.NombreServicio, dbo.CO_Instalacion.NombreInstalacion, dbo.CO_LineaPresupuestoMes.AC_FEC_INI, dbo.CO_LineaPresupuestoMes.AC_FEC_FIN, dbo.FI_Factura.Fecha, 
                         dbo.FI_Factura.Serie + '-' + dbo.FI_Factura.Folio, dbo.PV_Subcontratista.RazonSocial, InstalacionRegistro.NombreInstalacion, dbo.CO_Registro.InicioEjecucion, dbo.CO_Registro.FinEjecucion, 
                         dbo.FI_Factura.Fecha, dbo.AP_Usuario.Nombre, dbo.CO_Registro.MontoRegistro, dbo.PV_TipoMoneda.TipoMonedaCorto, dbo.CO_Registro.MesPresentacion, dbo.CO_TipoServicio.NombreTipoServicio, 
                         dbo.CO_ActividadCIEP.NombreActividad, dbo.CO_SubactividadCIEP.NombreSubactividad, dbo.CO_Registro.IdRegistro, dbo.CO_EstadoRegistro.NombreEstado, dbo.CO_Area.NombreArea, 
                         dbo.CO_Registro.Comentarios, dbo.CO_ClasificacionAnexo4.ClasificacionAnexo4, dbo.FI_Factura.IdFactura, InstalacionRegistro.CUIP, InstalacionRegistro.WelIID, 
                         dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes, InstalacionRegistro.IdInstalacion, dbo.CO_Presupuesto.Nombre, dbo.CO_Registro.Fila
ORDER BY dbo.CO_Registro.Fila

GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[28] 3) )"
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
         Begin Table = "CO_LineaPresupuestoMes"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 305
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Servicio"
            Begin Extent = 
               Top = 6
               Left = 343
               Bottom = 136
               Right = 533
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Instalacion"
            Begin Extent = 
               Top = 6
               Left = 571
               Bottom = 136
               Right = 816
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Registro"
            Begin Extent = 
               Top = 6
               Left = 854
               Bottom = 136
               Right = 1101
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "FI_Factura"
            Begin Extent = 
               Top = 6
               Left = 1139
               Bottom = 136
               Right = 1369
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PV_Subcontratista"
            Begin Extent = 
               Top = 6
               Left = 1407
               Bottom = 136
               Right = 1637
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "InstalacionRegistro"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaRegistrosGastosTodos';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'283
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AP_Usuario"
            Begin Extent = 
               Top = 138
               Left = 321
               Bottom = 268
               Right = 507
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_TipoServicio"
            Begin Extent = 
               Top = 138
               Left = 545
               Bottom = 268
               Right = 759
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_ActividadCIEP"
            Begin Extent = 
               Top = 138
               Left = 797
               Bottom = 268
               Right = 1008
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_SubactividadCIEP"
            Begin Extent = 
               Top = 138
               Left = 1046
               Bottom = 268
               Right = 1263
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_EstadoRegistro"
            Begin Extent = 
               Top = 138
               Left = 1301
               Bottom = 268
               Right = 1494
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Area"
            Begin Extent = 
               Top = 138
               Left = 1532
               Bottom = 268
               Right = 1718
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PV_TipoMoneda"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 241
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_TipoCambioMensual"
            Begin Extent = 
               Top = 270
               Left = 279
               Bottom = 400
               Right = 505
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_ClasificacionAnexo4"
            Begin Extent = 
               Top = 270
               Left = 543
               Bottom = 400
               Right = 754
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Presupuesto"
            Begin Extent = 
               Top = 270
               Left = 792
               Bottom = 400
               Right = 1010
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaRegistrosGastosTodos';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaRegistrosGastosTodos';

