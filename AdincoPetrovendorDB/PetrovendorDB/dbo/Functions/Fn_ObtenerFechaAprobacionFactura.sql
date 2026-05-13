-- =============================================
-- Author: Pedro Acuña
-- Create date: 11/06/2018
-- Description: obtener la fecha de la aprobacion de factura por el id de aceptacion de pedido
-- Encaso de tener mas de un aprobador se valida que el estatus de la operacion este como aprobada para tomar la ultima fecha 
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaAprobacionFactura
	( @IdAceptacionPedido INT ,
	  @IdPeticionOferta INT ,
	  @IdProveedorCliente INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaAprobacionFactura DATETIME, @IdEstatusOperacion INT

		SELECT		@FechaAprobacionFactura = MAX ( t.FechaCambioEstatus ) ,
					@IdEstatusOperacion = MAX ( O.IdEstatusOperacion )
		FROM		MM_AceptacionFactura AS AF
		INNER JOIN	FI_Factura AS F
			ON F.IdFactura = AF.IdFactura
		INNER JOIN	TA_Operacion AS O
			ON O.IdDocumento = AF.IdAceptacionFactura
		INNER JOIN	TA_Tarea AS T
			ON T.IdOperacion = O.IdOperacion
		INNER JOIN	TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN	MM_AceptacionPedido AS AP
			ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		INNER JOIN	MM_Pedido AS PE
			ON PE.IdPedido = AP.IdPedido
		INNER JOIN	MM_Pedidos AS PG
			ON PE.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = @IdProveedorCliente
		INNER JOIN	S_Proveedor AS PR
			ON PR.IdProveedor = PE.IdSubcontratista
		LEFT JOIN	dbo.MM_TipoPedido AS TP
			ON TP.IdTipoPedido = PG.IdTipoPedido
		WHERE
					O.IdTipoOperacion = 10 --aprobacion de factura
					AND PE.IdProveedorCompras = @IdProveedorCliente
					AND AF.IdAceptacionPedido = @IdAceptacionPedido
					AND PE.IdPeticionOferta = @IdPeticionOferta

		IF ( @IdEstatusOperacion != 2 ) 
			SELECT @FechaAprobacionFactura =  NULL

		RETURN @FechaAprobacionFactura
	END