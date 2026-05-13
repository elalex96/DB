CREATE VIEW dbo.VistaCuentasBancariasJaguar
AS
SELECT DISTINCT 
                         TOP (100) PERCENT CB.DatoBancarioID AS ID, P.RFC, UPPER(P.RazonSocial) AS Proveedor, UPPER(CB.Titular) AS Titular, B.Banco, ISNULL(CB.NumeroCuenta, '-') AS Cuenta, ISNULL(CB.CuentaClave, '-') AS CLABE, 
                         MO.TipoMonedaCorto AS Moneda
FROM            dbo.FI_Transfer AS T (NOLOCK)
		INNER JOIN
		dbo.CO_Contrato AS C (NOLOCK)
				ON C.IdContrato = T.IdContrato
		INNER JOIN
		dbo.PV_CuentaBancaria AS CB (NOLOCK)
				ON CB.DatoBancarioID = T.IdCuentaDestino 
		INNER JOIN
		dbo.PV_Subcontratista AS P (NOLOCK)
				ON P.IdSubcontratista = CB.IdProveedor 
		INNER JOIN
		dbo.PV_Banco AS B (NOLOCK)
				ON B.BancoID = CB.BancoID 
		LEFT OUTER JOIN
        dbo.PV_TipoMoneda AS MO (NOLOCK)
				 ON CB.TipoMonedaID = MO.IdMoneda
WHERE        (C.IdContratista IN (10005, 10006, 10017, 10022))
ORDER BY Proveedor

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
         Begin Table = "T"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 273
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 311
               Bottom = 136
               Right = 555
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CB"
            Begin Extent = 
               Top = 6
               Left = 593
               Bottom = 136
               Right = 775
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "P"
            Begin Extent = 
               Top = 6
               Left = 813
               Bottom = 136
               Right = 1027
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 1065
               Bottom = 136
               Right = 1235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "MO"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 225
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
      ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaCuentasBancariasJaguar';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'   Output = 720
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaCuentasBancariasJaguar';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'VistaCuentasBancariasJaguar';

