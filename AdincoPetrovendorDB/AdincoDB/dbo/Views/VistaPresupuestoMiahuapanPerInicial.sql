CREATE VIEW dbo.VistaPresupuestoMiahuapanPerInicial
AS
SELECT        dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes, dbo.CO_Presupuesto.Nombre AS Presupuesto, dbo.CO_TipoServicio.ID_TIPOSER, dbo.CO_TipoServicio.NombreTipoServicio, dbo.CO_TipoServicio.Orden, 
                         dbo.CO_ActividadCIEP.ID_CATACTIV, dbo.CO_ActividadCIEP.NombreActividad, dbo.CO_SubactividadCIEP.ID_CATSUBACTIV, dbo.CO_SubactividadCIEP.NombreSubactividad, 
                         dbo.CO_Clasificacion.NombreClasificacion, dbo.CO_LineaPresupuestoMes.AC_TERMINADO, dbo.CO_Instalacion.IdInstalacionPemex, dbo.CO_Instalacion.NombreInstalacion, dbo.CO_Instalacion.EsBolsa, 
                         dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES, dbo.CO_Servicio.NombreServicio, dbo.CO_Unidad.Unidad, dbo.CO_LineaPresupuestoMes.AC_FEC_INI, dbo.CO_LineaPresupuestoMes.AC_FEC_FIN, 
                         dbo.CO_ActividadHidrocarburoCIEP.ID_CATACTHC, dbo.CO_ActividadHidrocarburoCIEP.NombreActividadHidrocarburo, dbo.CO_LineaPresupuestoMes.ID_PADRE, dbo.CO_Area.NombreArea, 
                         dbo.CO_Rubro.ID_RUBRO1, dbo.CO_Rubro.ID_RUBRO2, dbo.CO_Rubro.ID_RUBRO3, dbo.CO_Rubro.CLAVE_RUBRO, dbo.CO_Rubro.NombreRubro, dbo.CO_LineaPresupuestoMes.Volumetria, 
                         dbo.CO_LineaPresupuestoMes.PrecioUnitario, dbo.CO_LineaPresupuestoMes.Monto, dbo.CO_ClasificacionAnexo4.ClasificacionAnexo4, dbo.CO_ClasificacionAnexo4.Clave, 
                         dbo.CO_RubroInterno.NombreRubro AS RubroInterno, dbo.CO_RubroInterno.Clave AS Expr2, dbo.CO_LineaPresupuestoMes.CPXOPX, dbo.CO_LineaPresupuestoMes.IdLineaProgramaActividadMes
FROM            dbo.CO_LineaPresupuestoMes LEFT OUTER JOIN
                         dbo.CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = dbo.CO_Instalacion.IdInstalacion LEFT OUTER JOIN
                         dbo.CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = dbo.CO_Servicio.IdServicio LEFT OUTER JOIN
                         dbo.CO_Unidad ON dbo.CO_Servicio.IdUnidad = dbo.CO_Unidad.IdUnidad LEFT OUTER JOIN
                         dbo.CO_ActividadHidrocarburoCIEP ON dbo.CO_LineaPresupuestoMes.IdActvidadHidrocarburo = dbo.CO_ActividadHidrocarburoCIEP.IdActividadHidrocarburo LEFT OUTER JOIN
                         dbo.CO_Area ON dbo.CO_LineaPresupuestoMes.IdArea = dbo.CO_Area.IdArea LEFT OUTER JOIN
                         dbo.CO_Rubro ON dbo.CO_LineaPresupuestoMes.IdRubro = dbo.CO_Rubro.IdRubro LEFT OUTER JOIN
                         dbo.CO_ClasificacionAnexo4 ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = dbo.CO_ClasificacionAnexo4.IdAnexo4 LEFT OUTER JOIN
                         dbo.CO_RubroInterno ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = dbo.CO_RubroInterno.IdRubroInterno LEFT OUTER JOIN
                         dbo.CO_ActividadCIEP ON dbo.CO_Instalacion.IdActividad = dbo.CO_ActividadCIEP.IdActividad AND dbo.CO_LineaPresupuestoMes.IdActividad = dbo.CO_ActividadCIEP.IdActividad LEFT OUTER JOIN
                         dbo.CO_Presupuesto ON dbo.CO_LineaPresupuestoMes.IdPresupuesto = dbo.CO_Presupuesto.IdPresupuesto LEFT OUTER JOIN
                         dbo.CO_TipoServicio ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = dbo.CO_TipoServicio.IdTipoServicio LEFT OUTER JOIN
                         dbo.CO_SubactividadCIEP ON dbo.CO_LineaPresupuestoMes.IdSubactividad = dbo.CO_SubactividadCIEP.IdSubactividad AND 
                         dbo.CO_ActividadCIEP.IdActividad = dbo.CO_SubactividadCIEP.IdActividad LEFT OUTER JOIN
                         dbo.CO_Clasificacion ON dbo.CO_LineaPresupuestoMes.IdClasificacion = dbo.CO_Clasificacion.IdClasificacion
WHERE        (dbo.CO_LineaPresupuestoMes.IdPresupuesto = 2)

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
         Begin Table = "CO_LineaPresupuestoMes"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 289
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Instalacion"
            Begin Extent = 
               Top = 6
               Left = 327
               Bottom = 136
               Right = 556
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Servicio"
            Begin Extent = 
               Top = 6
               Left = 594
               Bottom = 136
               Right = 768
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Unidad"
            Begin Extent = 
               Top = 6
               Left = 806
               Bottom = 136
               Right = 976
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_ActividadHidrocarburoCIEP"
            Begin Extent = 
               Top = 6
               Left = 1014
               Bottom = 136
               Right = 1268
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Area"
            Begin Extent = 
               Top = 6
               Left = 1306
               Bottom = 136
               Right = 1476
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Rubro"
            Begin Extent = 
               Top = 6
               Left = 1514
               Bottom = 136
               Right = 1684
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaPresupuestoMiahuapanPerInicial';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_ClasificacionAnexo4"
            Begin Extent = 
               Top = 6
               Left = 1722
               Bottom = 136
               Right = 1917
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_RubroInterno"
            Begin Extent = 
               Top = 6
               Left = 1955
               Bottom = 136
               Right = 2125
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_ActividadCIEP"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 233
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Presupuesto"
            Begin Extent = 
               Top = 138
               Left = 271
               Bottom = 268
               Right = 473
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_TipoServicio"
            Begin Extent = 
               Top = 138
               Left = 511
               Bottom = 268
               Right = 709
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_SubactividadCIEP"
            Begin Extent = 
               Top = 138
               Left = 747
               Bottom = 268
               Right = 948
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO_Clasificacion"
            Begin Extent = 
               Top = 138
               Left = 986
               Bottom = 251
               Right = 1186
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
      Begin ColumnWidths = 11
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaPresupuestoMiahuapanPerInicial';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaPresupuestoMiahuapanPerInicial';

