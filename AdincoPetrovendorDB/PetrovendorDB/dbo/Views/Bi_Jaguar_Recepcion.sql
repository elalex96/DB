CREATE VIEW [dbo].[Bi_Jaguar_Recepcion]
AS
SELECT IdPedidoUnico AS 'idunico pedido',
       BI_Recepcion.IdSolicitudPedido AS 'idunico de requisición',
       BI_Recepcion.IdAceptacionPedido AS 'IdAceptacionPedido',
       NumeroAceptacion AS 'N° de Aceptación',
       NumeroContrato AS 'Contrato',
       BI_Recepcion.IdPedido AS 'N° Pedido',
       BI_Recepcion.MaterialCotizadoTextoC AS 'Partida(Pedido)',
	   BI_Recepcion.MaterialCotizadoTextoL AS 'Descripción',
       NombreRecibidoPor AS 'Recibido Por',   
	   CantidadPedido AS 'Cantidad Pedido',    
       CantidadAcceptada AS 'Cantidad Aceptada',
	   CantidadRestante	AS 'Cantidad Restante',
       MontoAceptado AS 'Monto Aceptado',
       FechaRecepcion AS 'Fecha de Recepción',
	   EstatusCN	AS 'Estatus CN',
	   LugarEntrega	AS 'Lugar de Entrega',
	   BI_Recepcion.Partida  AS 'Partida',
	   BI_Recepcion.PrecioUnitario AS 'Precio unitario',
	   Instalacion,
	    PartidaReq AS 'Partida requisicion',
		PartidaDetalleReq AS 'Partida requisicion detalle',
		DescripcionGralReq AS 'Descripcion pedido', 
		Solicitante AS 'Solicitante',
		Comprador AS 'Comprador', 
		FechaPedido AS 'Fecha pedido', 
		Moneda AS 'Moneda pedido', 
		MontoAceptadoUSD AS 'Monto Aceptado USD',
		BI_Recepcion.Proveedor AS 'Proveedor',
		NoPartidaDetalle AS 'NoPartidaDetalle',
		UUID AS 'UUID',
		PedidoCerrado AS 'Pedido cerrado',
		EstatusPago AS 'Estatus pago',
		SubtotalPedidoUSD AS 'Subtotal Pedido USD',
		EstatusConfirmacion AS 'Estatus confirmacion',
		Presupuesto AS 'Presupuesto',
		Tarea  AS 'Tarea',
		Modelo AS 'Modelo',
		Marca AS 'Marca',
		NumeroParte AS 'Numero parte',
		CentroCosto AS 'Centro costo',
		ADN,
		IdMaterial
	FROM
		BI_Recepcion


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
         Begin Table = "S"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 275
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "CO"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PS"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PD"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 796
               Right = 291
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "M"
            Begin Extent = 
               Top = 798
               Left = 38
               Bottom = 928
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "O"
            Begin Extent = 
               Top = 6
               Left = 311
               Bottom = 136
               Right = 554
            End
            DisplayFlags = 280
            TopColumn = 0
         End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Recepcion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'         Begin Table = "SPD"
            Begin Extent = 
               Top = 6
               Left = 592
               Bottom = 136
               Right = 865
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Pr"
            Begin Extent = 
               Top = 6
               Left = 903
               Bottom = 136
               Right = 1146
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "U"
            Begin Extent = 
               Top = 138
               Left = 313
               Bottom = 268
               Right = 549
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Un"
            Begin Extent = 
               Top = 6
               Left = 1184
               Bottom = 136
               Right = 1354
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TM"
            Begin Extent = 
               Top = 138
               Left = 587
               Bottom = 268
               Right = 774
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TAO"
            Begin Extent = 
               Top = 138
               Left = 812
               Bottom = 268
               Right = 1003
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ES"
            Begin Extent = 
               Top = 138
               Left = 1041
               Bottom = 251
               Right = 1211
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TA"
            Begin Extent = 
               Top = 252
               Left = 1041
               Bottom = 382
               Right = 1240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ESTA"
            Begin Extent = 
               Top = 270
               Left = 320
               Bottom = 383
               Right = 490
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "US"
            Begin Extent = 
               Top = 270
               Left = 528
               Bottom = 400
               Right = 764
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SPL"
            Begin Extent = 
               Top = 384
               Left = 802
               Bottom = 514
               Right = 1113
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "INS"
            Begin Extent = 
               Top = 402
               Left = 266
               Bottom = 532
               Right = 495
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Recepcion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Recepcion';

