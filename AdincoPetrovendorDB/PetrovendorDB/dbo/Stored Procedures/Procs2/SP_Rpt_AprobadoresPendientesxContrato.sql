-- =============================================
-- Author:		Pedro Acuña
-- Create date: 11-12-18
-- Description:	llena el reporte de los aprobadores pendientes por aprobar
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 11-12-18
-- Description:	se quito el filtro por contrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_Rpt_AprobadoresPendientesxContrato] @IdProveedor INT, @IdContrato INT
AS
	BEGIN
		SET LANGUAGE Español

		SELECT		ps.IdPedido, P.IdSolicitudPedido, O.FechaRegistro, SUM ( pd.Subtotal ) AS subtotal, tm.TipoMonedaCorto ,
					ISNULL ( prov.RazonSocial, '' ) + ' ' + ISNULL ( prov.RegimenCapital, '' ) AS Proveedor, tp.TipoPedido ,
					O.Descripcion, dbo.FN_AprobadoresDePedidoPorOperacion ( O.IdOperacion ) AS aprobadores ,
					DATEDIFF ( DAY, O.FechaRegistro, GETDATE ()) diasAprobacion, P.Version, O.IdOperacion
		FROM		TA_Operacion AS O
		LEFT JOIN	MM_Pedido AS P
			ON P.IdSolicitudPedido = O.IdDocumento
			   AND	P.Version = O.NoVersion
		LEFT JOIN	dbo.MM_PedidoDetalle pd
			ON pd.IdPedido = P.IdPedido
		LEFT JOIN	dbo.MM_PeticionOferta po
			ON po.IdPeticionOferta = P.IdPeticionOferta
		LEFT JOIN	TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		LEFT JOIN	dbo.S_Proveedor prov
			ON prov.IdProveedor = P.IdSubcontratista
		LEFT JOIN	dbo.MM_Pedidos ps
			ON ps.IdIdentificador = P.IdPedido
			   AND	P.IdProveedorCompras = ps.IdProveedorCliente
		LEFT JOIN	dbo.MM_TipoPedido tp
			ON tp.IdTipoPedido = ps.IdTipoPedido
		LEFT JOIN	dbo.PV_TipoMoneda tm
			ON tm.IdMoneda = pd.IdMoneda
		WHERE
					O.IdProveedor = @IdProveedor
					AND O.IdTipoOperacion = 9
					AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
					AND ISNULL ( P.IdEstatusEliminado, 0 ) <> 1 -->Pedido NO ESTE ELIMINADO
					AND E.IdEstatus = 1 -- En aprobacion
					AND ps.IdPedido IS NOT NULL
					--AND P.IdContrato = @IdContrato
		GROUP BY	ps.IdPedido, P.IdSolicitudPedido, O.FechaRegistro, tm.TipoMonedaCorto, prov.RazonSocial ,
					prov.RegimenCapital, tp.TipoPedido, O.Descripcion, P.Version, O.IdOperacion
		ORDER BY	ps.IdPedido
	END
