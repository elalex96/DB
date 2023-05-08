CREATE VIEW [dbo].[Proveedor_RFC]
AS
SELECT DISTINCT TOP (100) PERCENT dbo.admin_ordencompra.proveedor, dbo.admin_cuentasprov.codigo, dbo.admin_cuentasprov.rfc, dbo.admin_cuentasprov.id_
FROM            dbo.admin_ordencompra INNER JOIN
                         dbo.admin_cuentasprov ON dbo.admin_ordencompra.id_proveedor = dbo.admin_cuentasprov.codigo
WHERE        (dbo.admin_ordencompra.fecha_ocomp >= '2013-01-01') AND (dbo.admin_ordencompra.Aprobado = 'True') AND (dbo.admin_ordencompra.desaprobado = 'FALSE') AND (dbo.admin_ordencompra.oc_auto <> 1) AND 
                         (dbo.admin_ordencompra.num_orden > 0)
GROUP BY dbo.admin_ordencompra.proveedor, dbo.admin_cuentasprov.codigo, dbo.admin_cuentasprov.rfc, dbo.admin_cuentasprov.id_
ORDER BY dbo.admin_ordencompra.proveedor, dbo.admin_cuentasprov.codigo


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[17] 3) )"
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
         Begin Table = "admin_ordencompra"
            Begin Extent = 
               Top = 6
               Left = 241
               Bottom = 330
               Right = 704
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "admin_cuentasprov"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 344
               Right = 203
            End
            DisplayFlags = 280
            TopColumn = 17
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 9420
         Width = 1770
         Width = 3930
         Width = 2595
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Proveedor_RFC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 1, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Proveedor_RFC';

