CREATE VIEW dbo.Bi_Jaguar_Aprobaciones
AS
	SELECT 
		IdPedidoUnico AS  'Idunico Pedido',
		IdRequicion as 'id de requisicion',
		Aprobador1 AS 'Aprobador1',
		Aprobador2 AS 'Aprobador2',
		Aprobador3 AS 'Aprobador3',
		Aprobador4 AS 'Aprobador4',
		Aprobador5 AS 'Aprobador5',
		Aprobador6 AS 'Aprobador6',
		TipoAprobacion AS 'Tipo de aprobación'
	FROM BI_Aprobaciones 
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
         Begin Table = "PS"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AP"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 136
               Right = 489
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SPD"
            Begin Extent = 
               Top = 6
               Left = 527
               Bottom = 136
               Right = 800
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SP"
            Begin Extent = 
               Top = 6
               Left = 838
               Bottom = 136
               Right = 1075
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PO"
            Begin Extent = 
               Top = 6
               Left = 1113
               Bottom = 136
               Right = 1356
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 273
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TAP"
            Begin Extent = 
               Top = 138
               Left = 311
               Bottom = 268
               Right = 502
            End
            DisplayFlags = 280
            TopColumn = 0
        ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Aprobaciones';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N' End
         Begin Table = "T"
            Begin Extent = 
               Top = 138
               Left = 540
               Bottom = 268
               Right = 739
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TA"
            Begin Extent = 
               Top = 138
               Left = 777
               Bottom = 268
               Right = 976
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TB"
            Begin Extent = 
               Top = 138
               Left = 1014
               Bottom = 268
               Right = 1213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TC"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 237
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TD"
            Begin Extent = 
               Top = 270
               Left = 275
               Bottom = 400
               Right = 474
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "T6"
            Begin Extent = 
               Top = 270
               Left = 512
               Bottom = 400
               Right = 711
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Aprobaciones';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Aprobaciones';

