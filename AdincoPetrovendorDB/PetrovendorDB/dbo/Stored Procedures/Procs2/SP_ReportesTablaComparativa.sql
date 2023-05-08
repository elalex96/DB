-- =============================================
-- Author:		Pedro Acuña
-- Create date: 27/02/2019
-- Description:	obtener las solicitudes que tienen una oferta para que se cargue el reporte mensual de la tabla comparativa
-- =============================================

CREATE PROCEDURE SP_ReportesTablaComparativa @IdProveedor INT, @MesAnio DATETIME
AS
	BEGIN
		DECLARE @DiaAnterior DATETIME, @MesSiguiente DATETIME

		SELECT @DiaAnterior	 = DATEADD ( MINUTE, -1, @MesAnio )

		SELECT @MesSiguiente  = DATEADD ( MONTH, 1, @MesAnio )

		SELECT	SP.IdSolicitudPedido, SP.IdUsuarioSolicitante, O.IdProveedor, O.FechaRegistro
		  FROM	MM_SolicitudPedido AS SP
				INNER JOIN MM_TipoSolicitudPedido AS TSP
						   ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
				INNER JOIN TA_Operacion AS O
						   ON O.IdDocumento = SP.IdSolicitudPedido
							  AND	O.IdTipoOperacion = 6
				INNER JOIN TA_Vencimiento AS V
						   ON V.IdVencimiento = O.IdVigencia
				INNER JOIN TA_Estatus AS E
						   ON E.IdEstatus = O.IdEstatusOperacion
				LEFT JOIN MM_PeticionOferta AS PO
						  ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		 WHERE
				SP.IdProveedor = @IdProveedor
				AND O.FechaFinalizacion IS NOT NULL
				AND SP.IdTipoProceso = 2 -- Mercadeo
				AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 --> DIFERENTE DE ESTATUS ELIMINADO
				AND o.FechaRegistro BETWEEN @DiaAnterior
									AND		@MesSiguiente
		 GROUP BY SP.IdSolicitudPedido, SP.IdUsuarioSolicitante, O.IdProveedor, O.FechaRegistro
		 ORDER BY SP.IdSolicitudPedido
	END
