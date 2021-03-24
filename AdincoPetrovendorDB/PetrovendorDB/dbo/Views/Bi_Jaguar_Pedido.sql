CREATE VIEW dbo.Bi_Jaguar_Pedido
AS
	  SELECT  
       IdPedido AS 'idpedido unico', 
	   BI_Pedido.IdSolicitudPedido AS 'idunico de requisicion',     
	   FechaPedido AS 'Fecha de pedido', 
	   RazonSocial AS 'Proveedor', 
	   MaterialCotizadoTextoC AS 'Concepto',
	   MaterialCotizadoTextoL AS 'Descripción',
	   Nombre AS 'Comprador', 
	   NumeroPedido AS 'Numero de Pedido',  
       EstatusPedido AS 'Estatus Pedido',       
	   BI_Pedido.IdSolicitudPedidoDetalle AS 'Partida',       
       BI_Pedido.Cantidad AS 'Cantidad', 
       UnidadProveedor AS 'Unidad', 
       PrecioUnitario AS 'Precio Unitario', 
       Subtotal AS 'Subtotal', 
       AprobadorActual AS 'Aprobador actual',
       FechaAprobado AS 'Fecha Aprobado', 
       FechaEntregaInicial AS 'Fecha Entrega Inicial', 
       FechaEntregaFinal AS 'Fecha Entrega Final', 
	   ConfirmacionPedido AS 'Confirmación Pedido', 
       DiasCredito AS 'Dias de Credito', --> DIAS DE CREDITO ESTAN POR DETALLE DE CADA MATERIAL DEL PEDIDO
       Moneda AS 'Moneda', 
--	   Eliminado  AS 'Eliminado'
		Contrato,
		Periodo,
		Corporativo,
		Instalacion,
		FechaRechazo AS   'Fecha rechazo',
		NoPartidaDetalle,
		DescripcionGralReq AS 'Descripcion pedido', 
		Solicitante AS 'Solicitante',
		SubtotalUSD AS 'Subtotal USD',
		PartidaReq AS 'Partida requisicion',
		PartidaDetalleReq AS 'Partida requisicion detalle',
		ObservacionPartidaReq AS 'Observacion detalle requisicion',
		PedidoCerrado AS 'Pedido cerrado',
		Presupuesto AS 'Presupuesto',
		Tarea  AS 'Tarea',
		Modelo AS 'Modelo',
		Marca AS 'Marca',
		NumeroParte AS 'Numero parte',
		CentroCosto AS 'Centro costo',
		SPD.IdMaterial
	 FROM
		BI_Pedido
	LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
		ON BI_Pedido.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
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
         Begin Table = "EPJ"
            Begin Extent = 
               Top = 6
               Left = 311
               Bottom = 136
               Right = 568
            End
            DisplayFlags = 280
            TopColumn = 0
         End
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
               Top = 798
               Left = 38
               Bottom = 928
               Right = 291
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "UC"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 796
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "M"
            Begin Extent = 
               Top = 930
               Left = 38
               Bottom = 1060
               Right = 279
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "UM"
            Begin Extent = 
               Top = 138
               Left = 266
               Bottom = 268
               Right = 436
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
         Alias = 2745
         Table = 1170
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Pedido';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'         Output = 720
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Pedido';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Pedido';

