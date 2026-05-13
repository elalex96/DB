CREATE VIEW dbo.Bi_Jaguar_Factura
AS
SELECT 
	IdSolicitudPedido AS 'idunico de requisicion', 
	IdAceptacionPedido AS 'IdAceptaciónPedido', 
	IdUnicoFactura  AS 'Idunicofactura', 
	FechaCarga AS 'Fecha de Carga', 
	FechaAprobacion AS 'Fecha de Aprobacion', 
	EstatusPedido 'Estatus de factura', 
	EstatusPago AS 'Estatus Pago',
	AprobadorActual AS 'Aprobador Actual',
	IdPedido AS 'No Pedido',
	FechaRechazo AS 'Fecha rechazo',
	MontoAceptado AS 'Monto aceptado',
	MontoFacturacion AS 'Monto facturación',
	Contrato,
	IdPedidoInterno,
	RazonSocial,
	FacturaFolio AS 'Numero Factura', 
	UUID AS 'UUID',
	CondicionPago AS 'Condicion pago',
	DiasCredito AS 'DiasCredito',
	MonedaFactura AS 'Moneda factura', 
	MonedaPedido AS 'Moneda pedido', 
	MontoAceptadoUSD AS 'Monto Aceptado USD', 
	MontoFacturacionUSD AS 'Monto Facturado USD',
	MontoMes AS 'Monto a pagar'
FROM BI_Facturas
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
         Begin Table = "AP"
            Begin Extent = 
               Top = 6
               Left = 311
               Bottom = 136
               Right = 534
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PS"
            Begin Extent = 
               Top = 6
               Left = 572
               Bottom = 136
               Right = 762
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "F"
            Begin Extent = 
               Top = 6
               Left = 800
               Bottom = 136
               Right = 1014
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "R"
            Begin Extent = 
               Top = 6
               Left = 1052
               Bottom = 136
               Right = 1289
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TAO"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "E"
            Begin Extent = 
               Top = 138
               Left = 267
               Bottom = 251
               Right = 437
            End
            DisplayFlags = 280
            TopColumn = 0
         End', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Factura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
         Begin Table = "TA"
            Begin Extent = 
               Top = 138
               Left = 475
               Bottom = 268
               Right = 674
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Factura';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Factura';

