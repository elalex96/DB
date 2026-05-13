-- =============================================
-- Author: Pedro Acu�a
-- Create date: 22/06/2018
-- Description: obtener la fecha de registro de la factura
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaRegistroFactura
	( @IdProveedor INT ,
	  @IdAceptacionPedido INT ,
	  @IdPeticionOferta INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaRetorno DATETIME

		SELECT		@FechaRetorno = O.FechaRegistro
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
			   AND	PG.IdProveedorCliente = @IdProveedor
		INNER JOIN	S_Proveedor AS PR
			ON PR.IdProveedor = PE.IdSubcontratista
		LEFT JOIN	dbo.MM_TipoPedido AS TP
			ON TP.IdTipoPedido = PG.IdTipoPedido
		WHERE
					O.IdTipoOperacion = 10
					AND PE.IdProveedorCompras = @IdProveedor
					AND AF.IdAceptacionPedido = @IdAceptacionPedido
					AND PE.IdPeticionOferta = @IdPeticionOferta

		RETURN @FechaRetorno
	END