USE [Petrovendor]
GO


IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Bi_Jaguar_Requisicion'
)
    DROP VIEW Bi_Jaguar_Requisicion;
	
GO

CREATE VIEW [dbo].[Bi_Jaguar_Requisicion]
AS
	SELECT
		IdUnicoDeRequisicion	AS 'idunico de requisicion',
		Contrato,
		FechaRegistro,
		Solicitante,
		IdRequisicion,
--		Periodo,
		Presupuesto,
		EstatusRequisicion	AS 'Estatus Requisición',
		Tarea,
		Subtarea,
		NombreInstalacion 'Nombre Instalacion',
		LugarEntrega	AS 'Lugar entrega',
--		Eliminado,
		BI_Requisicion.Concepto,
		BI_Requisicion.Descripcion	AS 'Descripción',
		AprobadorActual	AS 'Aprobador Actual',
		BI_Requisicion.IdSolicitudPedidoDetalle	AS 'Partida',
		TienePedido,
		FechaAprobacion,
		EstatusCotizacion  AS  'Estatus cotización',
		DescripcionGral AS 'Descripcion pedido', 
		NoPartidaDetalle AS 'No partida detalle',
		ObservacionPartidaReq AS 'Observacion detalle requisicion',
		BI_Requisicion.Modelo AS 'Modelo',
		BI_Requisicion.Marca AS 'Marca',
		BI_Requisicion.NumeroParte AS 'Numero parte',
		CentroCosto AS 'Centro costo',
		SPD.IdMaterial,
		CantidadProveedoresCotizaron AS 'Cantidad de proveedores que cotizaron' 
	FROM	BI_Requisicion	(NOLOCK)
	LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD 
		ON BI_Requisicion.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle

--EN TAB REQUISICIÓN
--AQUI NECESITAS SOLO LAS REQUISICIONES QUE TIENEN UN PEDIDO RELACIONADO O SERIAN TODAS LAS REQUISICIONES SIN IMPORTAR TENGAN O NO PEDIDOS? -->SON TODAS 
--SI BUSCAS LAS REQUISICIONES APROBADAS SE ESTA REALIZADNO MAL LA RELACIÓN YA QUE ESTAS RELACIONANDO UN ID INCORRECTO CON LA OPERACIÓN --> CORREGIDO
--LAS APROBACIONES DE PEDIDO TIENEN UN TIPOOPERACION=2 EN TA_OPERACIÓN Y SE RELACIONAN DIRECMENTE CON MM_SOLICITUDPEDIDO.IDSOLICITUD=TA_OPERACION.IDDOCUMENTO -->SON TODAS 
--LOS DOMICILIOS DE ENTREGA SON POR PARTIDA 
--LA INSTALACION ES POR DETALLE
--EL PRESUPUESTO ES POR CABECERA
--LA LINEA PRESUPUESTO ES POR DETALLE 
--EL CENTRO DE COSTO ES POR DETALLE
--LA TAREA PETROLERA ES POR DETALLE 
-- APLICANDO EL Distinct SE REDUCE CANTIDAD SOLO POR REQUISICIÓN 
GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane1', @value = N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[35] 3) )"
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
         Begin Table = "R"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 275
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Pe"
            Begin Extent = 
               Top = 138
               Left = 38
               Bottom = 268
               Right = 273
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SPD"
            Begin Extent = 
               Top = 270
               Left = 38
               Bottom = 400
               Right = 311
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "S"
            Begin Extent = 
               Top = 402
               Left = 38
               Bottom = 532
               Right = 349
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "L"
            Begin Extent = 
               Top = 534
               Left = 38
               Bottom = 664
               Right = 289
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 666
               Left = 38
               Bottom = 796
               Right = 282
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "U"
            Begin Extent = 
               Top = 798
               Left = 38
               Bottom = 928
               Right = 274
            End
            DisplayFlags = 280
            TopColumn = 0
         End
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Requisicion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPane2', @value = N'
         Begin Table = "P"
            Begin Extent = 
               Top = 930
               Left = 38
               Bottom = 1060
               Right = 240
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TP"
            Begin Extent = 
               Top = 930
               Left = 278
               Bottom = 1060
               Right = 453
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ST"
            Begin Extent = 
               Top = 6
               Left = 1528
               Bottom = 136
               Right = 1742
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "I"
            Begin Extent = 
               Top = 1194
               Left = 38
               Bottom = 1324
               Right = 267
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 1062
               Left = 271
               Bottom = 1192
               Right = 456
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TAO"
            Begin Extent = 
               Top = 1326
               Left = 38
               Bottom = 1456
               Right = 229
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "TA"
            Begin Extent = 
               Top = 1326
               Left = 267
               Bottom = 1456
               Right = 466
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "E"
            Begin Extent = 
               Top = 1458
               Left = 38
               Bottom = 1571
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PA"
            Begin Extent = 
               Top = 6
               Left = 313
               Bottom = 136
               Right = 592
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "PC"
            Begin Extent = 
               Top = 6
               Left = 630
               Bottom = 136
               Right = 804
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
', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Requisicion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_DiagramPaneCount', @value = 2, @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'Bi_Jaguar_Requisicion';

