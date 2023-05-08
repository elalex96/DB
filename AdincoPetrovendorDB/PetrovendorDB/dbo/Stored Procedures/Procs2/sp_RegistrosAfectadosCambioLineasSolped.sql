-- =============================================
-- Author:		Pedro Acuña
-- Create date: 14-08-2019
-- Description:	Carga los registros que van a ser afectados
-- =============================================

CREATE PROCEDURE sp_RegistrosAfectadosCambioLineasSolped @IdSolicitudPedido INT
AS
BEGIN 
    SELECT sp.IdSolicitudPedido,
           spd.IdSolicitudPedidoDetalle,
           spdl.IdSolicitudPedidoDetalleLineaPresupuesto,
           spdl.IdLineaPresupuesto,
		   '' AS LineaCambiar
    FROM dbo.MM_SolicitudPedido sp
        INNER JOIN dbo.MM_SolicitudPedidoDetalle spd
            ON spd.IdSolicitudPedido = sp.IdSolicitudPedido
        INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
            ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
    WHERE sp.IdSolicitudPedido = @IdSolicitudPedido

END
