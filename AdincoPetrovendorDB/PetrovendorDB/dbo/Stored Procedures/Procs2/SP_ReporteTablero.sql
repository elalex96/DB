-- =============================================
-- Author:		Pedro Acu�a
-- Create date: 05-Jun-18
-- Description:	se agrega el filtro por giro empresarial y por materiales
-- =============================================

CREATE PROCEDURE SP_ReporteTablero @IdProveedor INT, @IdContrato INT, @IdUsuario INT, @IdTipoUsuario INT
AS
	BEGIN
		SELECT		SP.IdSolicitudPedido AS IdRequisicion, SP.MotivoUrgencia AS Descripcion, SP.FechaAlta AS FechaRegistro ,
					CASE WHEN dbo.Fn_ObtenerEstatusSolPed ( TAO.IdOperacion ) = 3 THEN
							 dbo.Fn_ObtenerUltimaFechaTareaModificacion ( TAo.IdOperacion )
					END AS FechaRechazado, CASE WHEN dbo.Fn_ObtenerEstatusSolPed ( TAO.IdOperacion ) = 2 THEN
													dbo.Fn_ObtenerUltimaFechaTareaModificacion ( TAo.IdOperacion )
										   END AS FechaAprobado, PO.IdPeticionOferta, PO.CreadoEl AS FechaPeticionOferta ,
					P.RazonSocial, p.IdProveedor ,
					dbo.Fn_ObtenerUltimaFechaPeticionOfertaDetalle ( PO.IdPeticionOferta ) AS FechaCotizacionOC ,
					ped.CreadoEl AS FechaPedido, pedidos.IdPedido AS NumPedido ,
					dbo.Fn_ObtenerFechaAprobacionPedido ( pedido.IdOperacion ) AS AprobacionPedido ,
					dbo.Fn_RetornarNombreEstatus ( pedido.IdEstatusOperacion ) AS EstatusPedido, pedido.Subtotal AS Costo ,
					dbo.Fn_RetornarMonedaNombreCorto ( pedido.Moneda ) AS Moneda, tarea.IdAprobador ,
					uTarea.Nombre AS NombreAprobadorPedido ,
					dbo.Fn_RetornarNombreEstatus ( tarea.IdEstatus ) AS EstatusAprobador ,
					dbo.Fn_ObtenerFechaAceptacionProveedor(AP.IdProveedor, ped.IdPedido, PO.IdPeticionOferta ) AS OrdenCompra, 
					dbo.Fn_ObtenerFechaEntregaRecepcion ( AP.IdProveedor, AP.IdAceptacionPedido, PO.IdPeticionOferta ) AS EntregaRecepcion ,
					dbo.Fn_ObtenerFechaRegistroACPCN ( AP.IdAceptacionPedido, PO.IdSubcontratista, PO.IdPeticionOferta ) AS RegistroPCN ,
					dbo.Fn_ObtenerFechaAprobacionACPCN ( AP.IdProveedor, AP.IdAceptacionPedido, PO.IdPeticionOferta ) AS AprobacionPCN ,
					dbo.Fn_ObtenerFechaRegistroFactura ( AP.IdProveedor, AP.IdAceptacionPedido, PO.IdPeticionOferta ) AS RecepcionFactura ,
					dbo.Fn_ObtenerFechaAprobacionFactura ( pedidos.IdPedido, AP.IdAceptacionPedido, PO.IdPeticionOferta ) AS AprobacionFactura,
					AP.IdAceptacionPedido, AP.IdProveedor, PO.IdSubcontratista, pedidos.IdPedido
		FROM		MM_SolicitudPedido AS SP
		LEFT JOIN	TA_Operacion AS TAO
			ON TAO.IdDocumento = SP.IdSolicitudPedido
		LEFT JOIN	TA_Estatus AS TE
			ON TE.IdEstatus = TAO.IdEstatusOperacion
		LEFT JOIN	Adinco.dbo.CO_Contrato AS C
			ON SP.IdContrato = C.IdContrato
		LEFT JOIN	dbo.MM_PeticionOferta PO
			ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		LEFT JOIN	dbo.S_Proveedor P
			ON P.IdProveedor = PO.IdSubcontratista
		LEFT JOIN	dbo.Fn_ObtenerFechaAprobacionPedidoCosto ( @IdContrato, @IdProveedor ) pedido
			ON pedido.IdSolicitudPedido = SP.IdSolicitudPedido
			   AND	PO.IdPeticionOferta = pedido.IdPeticionOferta
		LEFT JOIN	dbo.TA_Tarea tarea
			ON tarea.IdOperacion = pedido.IdOperacion
		LEFT JOIN	s_usuario uTarea
			ON uTarea.IdUsuario = tarea.IdAprobador
		LEFT JOIN	dbo.MM_Pedido ped
			ON ped.IdSolicitudPedido = TAO.IdDocumento
			   AND	ped.IdPeticionOferta = PO.IdPeticionOferta
		LEFT JOIN	dbo.MM_Pedidos pedidos
			ON pedidos.IdIdentificador = ped.IdPedido
			   AND	pedidos.IdProveedorCliente = ped.IdProveedorCompras
		LEFT JOIN	MM_AceptacionPedido AP
			ON AP.IdPedido = ped.IdPedido
		WHERE
					(	SP.IdUsuarioSolicitante = @IdUsuario
						OR		@IdTipoUsuario NOT IN ( 5 ))
					AND SP.IdProveedor = @IdProveedor
					AND TAO.IdTipoOperacion = 2
					AND ISNULL ( SP.Visible, 1 ) = 1
					AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 -- no este eliminada
					AND C.IdContrato = @IdContrato
		ORDER BY	SP.IdSolicitudPedido
	END