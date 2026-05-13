CREATE VIEW dbo.Bi_Jaguar_CN
AS
   SELECT   
   P.IdSolicitudPedido as 'idunico de requisicion',
   Ac.IdAceptacionPedido   as 'IdAceptaciónPedido',
   Ac.CreadoEl AS 'Fecha de Carga',
   CAST(AC.FechaEvaluacion as date) as 'Fecha de Aprobación',
   TD.TipoValidacion as 'Estatus'
  FROM MM_AceptacionCartaPCN AS AC  (NOLOCK)
  INNER JOIN S_Documento_S3 AS D (NOLOCK) ON AC.IdDocumento =D.IdDocumento    
  INNER JOIN MM_AceptacionPedido AS AP (NOLOCK) ON  AC.IdAceptacionPedido  = AP.IdAceptacionPedido 
  INNER JOIN MM_Pedido AS P (NOLOCK) ON AP.IdPedido= P.IdPedido  
  INNER JOIN S_TipoValidacionDoc AS TD (NOLOCK) ON AC.IdEstatus =TD.IdTipoValidacionDoc   
  INNER JOIN MM_Pedidos AS PG (NOLOCK) ON P.IdPedido = PG.IdIdentificador AND P.IdProveedorCompras=PG.IdProveedorCliente 
  WHERE  P.IdProveedorCompras IN (606, 676, 690, 1315, 1424)
  AND ISNULL(AC.IdEstatusEliminado,0) <> 1  --> QUE NO ESTEN ELIMINADOS  

--TAB CN 
-- SE REPITEN POR QUE PUEDE SER QUE LA CARTA SE SUBA N VECES HASTA SER APROBADA 
-- NECESITAS UNA RELACIÓN PARA LAS ACEPTACIONES QUE SE LES EXCLUYO LA CARTA DE CONTENIDO NACIONAL?

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
         Begin Table = "P"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 273
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PD"
            Begin Extent = 
               Top = 6
               Left = 311
               Bottom = 136
               Right = 564
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "O"
            Begin Extent = 
               Top = 6
               Left = 602
               Bottom = 136
               Right = 845
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "S"
            Begin Extent = 
               Top = 6
               Left = 883
               Bottom = 136
               Right = 1156
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "A"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 261
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AD"
            Begin Extent = 
               Top = 138
               Left = 299
               Bottom = 268
               Right = 531
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "AC"
            Begin Extent = 
               Top = 138
               Left = 569
               Bottom = 268
               Right = 780
            End
            DisplayFlags = 280
            TopColumn = 0
         End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_CN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
         Begin Table = "E"
            Begin Extent = 
               Top = 138
               Left = 818
               Bottom = 251
               Right = 988
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_CN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_CN';

