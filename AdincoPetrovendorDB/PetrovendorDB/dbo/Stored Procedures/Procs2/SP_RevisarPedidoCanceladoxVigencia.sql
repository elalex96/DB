-- ============================================= 
-- Author:		Pedro Acu�a
-- Create date: 09/04/2018
-- Description:	se revisa si esta caducado por vigencia, si no fue ya enviado. existe para saber si se muestra o no el boton de modificar fecha
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 20/01/2021
-- Description:	Se optimiza para el detalle de pedido -- Issue 920
-- =============================================
CREATE PROCEDURE [dbo].[SP_RevisarPedidoCanceladoxVigencia] @IdPedido INT, @IdProveedor INT
AS
	BEGIN
		IF EXISTS
			(
				SELECT	 1
				FROM	 MM_Pedido AS P
				INNER JOIN MM_PedidoDetalle AS PD
					ON P.IdPedido = PD.IdPedido
				INNER JOIN MM_PeticionOferta AS PO
					ON P.IdPeticionOferta = PO.IdPeticionOferta
				INNER JOIN S_Proveedor AS PV
					ON P.IdSubcontratista = PV.IdProveedor
				INNER JOIN TA_Operacion AS O
					ON P.IdSolicitudPedido = O.IdDocumento
				LEFT JOIN TA_Prioridad AS PR
					ON O.IdPrioridad = PR.IdPrioridad
				LEFT JOIN TA_Vencimiento AS V
					ON O.IdVigencia = V.IdVencimiento
				INNER JOIN TA_TipoOperacion AS TTO
					ON O.IdTipoOperacion= TTO.IdTipoOperacion 
				INNER JOIN TA_Estatus AS E
					ON O.IdEstatusOperacion = E.IdEstatus
				LEFT JOIN MM_HorasVigenciaPedido AS HV
					ON P.IdPedido = HV.IdPedido
				LEFT JOIN PV_TipoMoneda AS TM
					ON P.IdMoneda = TM.IdMoneda
				INNER JOIN MM_Pedidos AS PG
					ON P.IdPedido = PG.IdIdentificador
					   AND PG.IdProveedorCliente = @IdProveedor
				LEFT JOIN dbo.MM_TipoPedido AS TP
					ON PG.IdTipoPedido = TP.IdTipoPedido
				WHERE
						 O.IdTipoOperacion = 9
						 AND O.IdProveedor = @IdProveedor
						 AND P.RecepcionServicio IS NULL
						 AND E.IdEstatus = 2
						 AND HV.FechaVigencia IS NOT NULL
						 AND ( DATEDIFF ( MINUTE, HV.FechaVigencia, GETDATE ())) >= 0
						 AND P.Version = O.NoVersion
						 AND P.IdPedido = @IdPedido
				GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial, +RegimenCapital ,
						 P.RecepcionServicio, E.Nombre, P.Version, TM.TipoMonedaCorto, PG.IdPedido, TP.TipoPedido ,
						 TP.IdTipoPedido, HV.FechaVigencia
		)
			SELECT 1 --Si existe muestra el boton
		ELSE 
			SELECT 0 -- si no existe oculta el boton de modificar vigencia
	END