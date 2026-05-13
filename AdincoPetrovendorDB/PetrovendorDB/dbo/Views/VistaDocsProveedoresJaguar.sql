/*No Carta de Contenido, No RPPC
	select * from S_Proveedor where RazonSocial like '%jaguar%'  or RazonSocial like '%pantera%'
		select * from S_TipoDocumento*/
CREATE VIEW dbo.VistaDocsProveedoresJaguar
AS
SELECT DISTINCT TOP (100) PERCENT P.RFC, P.RazonSocial, doc.IdDocumento, tipo.NombreTipoDocumento
FROM            dbo.S_Documento_S3 AS doc RIGHT OUTER JOIN
                         dbo.S_TipoDocumento AS tipo ON tipo.IdTipoDocumento = doc.IdTipoDocumento INNER JOIN
                         dbo.S_TipoValidacionDoc AS valid ON valid.IdTipoValidacionDoc = doc.IdTipoValidacionDocumento INNER JOIN
                         dbo.S_Proveedor AS P ON P.IdProveedor = doc.IdProveedor INNER JOIN
                         dbo.MM_Pedido AS PD ON PD.IdSubcontratista = P.IdProveedor
WHERE        (doc.Activo = 1) AND (doc.IdTipoValidacionDocumento = 1003) AND (doc.IdTipoDocumento NOT IN (23, 15)) AND (PD.IdProveedorCompras IN (606, 676, 690, 1315, 1424, 2390)) AND (PD.IdEstatusEliminado IS NULL)
ORDER BY P.RazonSocial, tipo.NombreTipoDocumento

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
         Begin Table = "doc"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tipo"
            Begin Extent = 
               Top = 6
               Left = 317
               Bottom = 119
               Right = 537
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "valid"
            Begin Extent = 
               Top = 6
               Left = 575
               Bottom = 102
               Right = 774
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 6
               Left = 812
               Bottom = 136
               Right = 1055
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PD"
            Begin Extent = 
               Top = 6
               Left = 1093
               Bottom = 136
               Right = 1328
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaDocsProveedoresJaguar';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaDocsProveedoresJaguar';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaDocsProveedoresJaguar';

