


CREATE VIEW [dbo].[ReporteProcesoDEA_ACEPTACIONES] AS

	SELECT
		IdSolicitudPedido AS No_Solicitud_Pedido,
		Folio,
		Descripcion,
		CentroCosto AS Centro_Costo,
		NumeroPedido AS No_Pedido,
		Proveedor,
		FechaPedidoFechaConfirmacion AS FechaPedido_FechaConfirmacion,
		TipoEntrega AS Tipo_Entrega,
		UsuarioAceptaPedido AS Usuario_Acepta_Pedido,
		FechaAceptacionPedido AS Fecha_Aceptacion_Pedido,
		DiasAceptacionPedido AS Dias_Aceptacion_Pedido,
		NumeroAceptacionPedido AS No_Aceptacion_Pedido,
		FechaRecepcionCartaCN AS Fecha_Recepcion_CartaCN,
		DiasRecepcionCartaCN AS Dias_Recepcion_CartaCN,
		UsuarioApruebaCartaCN AS Usuario_Aprueba_CartaCN,
		FechaAprobacionCartaCN AS Fecha_Aprobacion_CartaCN,
		DiasAprobacionCartaCN AS Dias_Aprobacion_CartaCN,
		EstatusCartaCN AS Estatus_CartaCN,
		FechaRecepcionFactura AS Fecha_Recepcion_Factura,
		DiasRecepcionFactura AS Dias_Recepcion_Factura,
		FolioFactura AS Folio_Factura,
		Responsable1aAprobacion AS Responsable_1a_Aprobacion,
		Fecha1aAprobacion AS Fecha_1a_Aprobacion,
		DiasEspera1aAprobacion AS Dias_Espera_1a_Aprobacion,
		Estatus1aAprobacion AS Estatus_1a_Aprobacion,
		Responsable2aAprobacion AS Responsable_2a_Aprobacion,
		Fecha2aAprobacion AS Fecha_2a_Aprobacion,
		DiasEspera2aAprobacion AS Dias_Espera_2a_Aprobacion,
		Estatus2aAprobacion AS Estatus_2a_Aprobacion,
		DiasEnAprobacion AS Dias_En_Aprobacion,
		DiasTotal AS Dias_Total,
		EstatusAprobacionFactura AS Estatus_Aprobacion_Factura,
		NumeroPO AS No_PO,
		FechaRegistroPO AS Fecha_Registro_PO
	FROM dbo.DEA_ProcesoAceptaciones;

