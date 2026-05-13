
CREATE VIEW [dbo].[Bi_Jaguar_Pedido]
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
		SPD.IdMaterial,
		TotalPedido AS 'Total pedido',
		TotalPedidoAceptado AS 'Total de Pedido Aceptado'
	 FROM
		BI_Pedido
	 LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
		ON BI_Pedido.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
