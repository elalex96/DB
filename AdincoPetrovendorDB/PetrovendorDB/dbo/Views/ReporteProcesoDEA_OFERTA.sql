



CREATE VIEW [dbo].[ReporteProcesoDEA_OFERTA] AS

	SELECT
		IdSolicitudPedido AS No_Solicitud_Pedido,
		Folio,
		Descripcion,
		CentroCosto AS Centro_Costo,
		Fecha1aAsignacionFechaCargaPR AS Fecha_1a_Asignacion_Fecha_Carga_PR,
		CompradorAsignado1 AS Comprador_Asignado1,
		Fecha2aAsignacion AS Fecha_2a_Asignacion,
		CompradorAsignado2 AS Comprador_Asignado2,
		Dias2aAsignacion AS Dias_2a_Asignacion,
		Comprador,
		NumeroProveedores AS Numero_Proveedores,
		FechaEnvioCotizacion AS Fecha_Envio_Cotizacion,
		DiasEnvioCotizacion AS Dias_Envio_Cotizacion,
		DiasSolicitudOferta AS Dias_Solicitud_Oferta,
		NumeroProveedoresCotizaron AS Numero_Proveedores_Cotizaron,
		FechaRecepcionUltimaCotizacion AS Fecha_Recepcion_Ultima_Cotizacion,
		DiasRecepcionUltimaCotizacion AS Dias_Recepcion_Ultima_Cotizacion,
		FechaEnvioPedido AS Fecha_Envio_Pedido,
		NumeroPedido AS Numero_Pedido,
		DiasEnvioPedido AS Dias_Envio_Pedido,
		FechaAprobacionPedido AS Fecha_Aprobacion_Pedido,
		DiasAprobacionPedido AS Dias_Aprobacion_Pedido,
		EstatusAprobacionPedido AS Estatus_Aprobacion_Pedido,
		DiasAsignacionProveedor AS Dias_Asignacion_Proveedor,
		NumeroPOSAP AS Numero_PO_SAP,
		FechaRelacionPOSAP AS Fecha_Relacion_PO_SAP,
		DiasRelacionPOSAP AS Dias_Relacion_PO_SAP,
		FechaConfirmacionPedido AS Fecha_Confirmacion_Pedido,
		DiasConfirmacionPedido AS Dias_Confirmacion_Pedido,
		DiasTotal AS Dias_Total,
		EstatusFinal AS Estatus_Final
	FROM dbo.DEA_ProcesoOferta;

