USE [Petrovendor]
GO

/****** Object:  View [dbo].[Bi_Jaguar_Recepcion]    Script Date: 30/03/2021 10:33:13 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



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