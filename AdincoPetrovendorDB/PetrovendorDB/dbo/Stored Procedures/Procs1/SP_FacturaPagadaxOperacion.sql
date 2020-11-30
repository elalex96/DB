-- =============================================
-- Author:	Pedro Acuña
-- Create date: 04-07-2018
-- Description:	SP la operacion ya fue pagada las factura
-- =============================================

CREATE PROCEDURE SP_FacturaPagadaxOperacion @IdProveedor INT, @IdContrato INT, @IdOperacion INT, @Version INT
AS
	BEGIN
		DECLARE @tablaAux TABLE
			( FechaAprobacionFactura DATETIME )

		DECLARE @cuentaRegistros INT

		INSERT INTO @tablaAux
			( FechaAprobacionFactura )
		SELECT		dbo.Fn_ObtenerFechaAprobacionFactura ( AP.IdAceptacionPedido, PO.IdPeticionOferta, AP.IdProveedor ) AS AprobacionFactura
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
		LEFT JOIN	dbo.MM_Pedido ped
			ON ped.IdSolicitudPedido = TAO.IdDocumento
		LEFT JOIN	dbo.MM_Pedidos pedidos
			ON pedidos.IdIdentificador = ped.IdPedido
			   AND	pedidos.IdProveedorCliente = ped.IdProveedorCompras
		LEFT JOIN	MM_AceptacionPedido AP
			ON AP.IdPedido = ped.IdPedido
		WHERE
					SP.IdProveedor = @IdProveedor
					AND TAO.IdTipoOperacion = 2
					AND ISNULL ( SP.Visible, 1 ) = 1
					AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 -- no este eliminada
					AND C.IdContrato = @IdContrato
					AND pedido.IdOperacion = @IdOperacion
					AND ped.Version = @Version

		SELECT @cuentaRegistros	 = COUNT ( * ) FROM @tablaAux

		IF ( @cuentaRegistros > 0 ) --si no existen registros significa que todavia no se ah aprobado ningun registro
			BEGIN
				IF EXISTS ( SELECT 1  FROM @tablaAux  WHERE FechaAprobacionFactura IS NULL ) --si existe un valor entonces faltan aprobaciones por realizar
					BEGIN
						SELECT 0
					END
				ELSE BEGIN
						 SELECT 1
					END
			END
		ELSE 
			BEGIN
				 SELECT 0
			END
	END