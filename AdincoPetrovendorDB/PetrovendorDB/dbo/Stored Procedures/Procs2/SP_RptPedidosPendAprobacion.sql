-- =============================================
-- Author:	Pedro Acuña
-- Create date: 16-07-2018
-- Description:	SP que obtiene Pedidos pendientes de aprobación.
-- =============================================

CREATE PROCEDURE SP_RptPedidosPendAprobacion @IdProveedor INT, @IdContrato INT
AS
	BEGIN
		SELECT		O.IdOperacion, O.IdDocumento, O.FechaRegistro, O.Descripcion, E.Nombre, P.Version, prov.RazonSocial ,
					O.IdFlujoTarea
		FROM		TA_Operacion AS O
		LEFT JOIN	MM_Pedido AS P
			ON P.IdSolicitudPedido = O.IdDocumento
		LEFT JOIN	dbo.MM_SolicitudPedido SP
			ON SP.IdSolicitudPedido = P.IdSolicitudPedido
		LEFT JOIN	TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		LEFT JOIN	TA_Tarea AS T
			ON T.IdOperacion = O.IdOperacion
		LEFT JOIN	dbo.S_Usuario U
			ON u.IdUsuario = T.IdAprobador
		LEFT JOIN	dbo.S_UsuarioProveedor UP
			ON UP.IdUsuario = U.IdUsuario
			   AND	UP.IdProveedor = O.IdProveedor
		LEFT JOIN	dbo.S_Proveedor prov
			ON prov.IdProveedor = P.IdSubcontratista
		WHERE
					O.IdProveedor = @IdProveedor
					AND O.IdTipoOperacion = 9
					AND P.Version = O.NoVersion
					AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
					AND E.IdEstatus = 1 -- En aprobacion
		GROUP BY	O.IdOperacion, O.IdDocumento, O.FechaRegistro, O.Descripcion, E.Nombre, O.IdTipoOperacion, P.Version ,
					O.IdEstatusEliminado, prov.RazonSocial, O.IdFlujoTarea
		ORDER BY	O.FechaRegistro DESC
	END