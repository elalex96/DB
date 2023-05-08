CREATE VIEW [dbo].[Estatus_de_pedidos_PCM]
AS
	SELECT
		Contrato,
		OrdenCompra	AS [Pedido/OrdenCompra], 
		SolicitudPedido,
		Ej.CreadoEl,
		DiasPedido	AS [Dias del Pedido], 
		Proveedor,
		CorreoProveedor,
		RFC,
		Estado,
		EJ.Version,
		Moneda,
		TipoPedido,
		Aprobadores,
		EstatusAprobador,
		EstatusFactura,
		EstatusPago,
		Factura,
		EstatusRecepcionServicio,
		EstatusCN,
		Entidad_Jaguar AS Entidad,
		CuentaOrigen,
		CuentaDestino,
		FechaRegistroTranferencia,
		MontoTransfer,
		MonedaTransfer,
		MontoTotalOrdenCompra,
		Instalacion,
		Motivo,
		CASE WHEN PedidoCancelado = 0 THEN 'NO' ELSE 'SI' END AS PedidoCancelado,
		MontoAceptacion,
		DiasCredito,
		FechaPagoSegunDiasCredito,
		FechaIngreso,
		UUIDFactura,
		UUIDComplemento,
		UltimaFechaAprobaciones,
		FechaTransferencia,
		FechaCotizacion,
		FechaAprobacionOC,
		FechaAprobacionCartaCN,
		FechaAprobacionFactura,
		FechaFactura,
		ActividadPetrolera,
		SubactividadPetrolera,
		TareaPetrolera,
		Servicio AS Subtarea,
		PA.Nombre,
		EJ.MesSIPAC
	FROM
		EstatusPedidosJaguar EJ	(NOLOCK)
		 LEFT JOIN 
			MM_AceptacionPedidoDetalleInstalacion ADI (NOLOCK)
			ON EJ.IdAceptacionPedido = ADI.IdAceptacionPedido
		 LEFT JOIN
			Adinco.dbo.CO_LineaPresupuestoMes ALM (NOLOCK)
			ON ADI.IdLineaPresupuesto = ALM.IdLineaPresupuestoMes
		 LEFT JOIN
			Adinco.dbo.CO_Presupuesto PA (NOLOCK)
			ON ALM.IdPresupuesto = PA.IdPresupuesto
	WHERE
		EJ.IdProveedorCompras IN	(863)
