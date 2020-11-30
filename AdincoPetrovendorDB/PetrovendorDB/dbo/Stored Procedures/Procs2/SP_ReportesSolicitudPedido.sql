-- =============================================
-- Author:		Pedro Acuña
-- Create date: 27/02/2019
-- Description:	obtener todas las solicitudes de pedido por el mes requerido
-- =============================================

CREATE PROCEDURE SP_ReportesSolicitudPedido @IdProveedor INT, @MesAnio DATETIME
AS
	BEGIN
		DECLARE @DiaAnterior DATETIME, @MesSiguiente DATETIME

		SELECT @DiaAnterior	 = DATEADD ( MINUTE, -1, @MesAnio )

		SELECT @MesSiguiente  = DATEADD ( MONTH, 1, @MesAnio )

		SELECT	sp.IdProveedor, sp.IdUsuarioSolicitante, sp.IdSolicitudPedido, u.IdTipoUsuario
		  FROM	MM_SolicitudPedido AS SP
				INNER JOIN MM_TipoSolicitudPedido AS TSP
						   ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
				INNER JOIN TA_Operacion AS TAO
						   ON TAO.IdDocumento = SP.IdSolicitudPedido
				INNER JOIN TA_Estatus AS TE
						   ON TE.IdEstatus = TAO.IdEstatusOperacion
				LEFT JOIN CC_CentroCosto AS CC
						  ON SP.IdCentroCosto = CC.IdCentroCosto
				INNER JOIN S_Usuario AS U
						   ON SP.IdUsuarioSolicitante = U.IdUsuario
		 WHERE
				ISNULL ( sp.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE ELIMINADO 
				AND sp.IdProveedor = @IdProveedor
				AND sp.FechaAlta BETWEEN @DiaAnterior
								 AND	 @MesSiguiente
				GROUP BY SP.IdProveedor, SP.IdUsuarioSolicitante, SP.IdSolicitudPedido, U.IdTipoUsuario
				ORDER BY SP.IdSolicitudPedido
	END
