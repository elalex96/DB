-- =============================================
-- Author:		Pedro Acu�a
-- Create date: 18-Feb-2020
-- Description:	Carga los registros que van a ser afectados
-- =============================================

CREATE PROCEDURE sp_RegistrosAfectadosCambioLineasAceptacion @IdSolicitudPedido INT
AS
BEGIN
    SELECT apdi.IdAceptacionPedido,
           apdi.IdAceptacionPedidoDetalle,
           apdi.IdLineaPresupuesto AS IdLineaPresupuestoAceptacion,
           r.IdRegistro AS IdRegistroPetrov,
           r.IdLineaPresupuestoMes AS IdLineaPetrov,
           ar.IdRegistro AS IdRegistroAdinco,
           ar.IdPrograma AS IdLineaAdinco,
           '' AS LineaCambiar
    FROM dbo.MM_Pedido p
        INNER JOIN dbo.MM_AceptacionPedido ap
            ON ap.IdPedido = p.IdPedido
               AND ISNULL(ap.IdEstatusEliminado, 0) = 0
        INNER JOIN dbo.MM_AceptacionPedidoDetalleInstalacion apdi
            ON apdi.IdAceptacionPedido = ap.IdAceptacionPedido
        LEFT JOIN dbo.CO_Registro r
            ON r.IdAceptacionPedidoDetalle = apdi.IdAceptacionPedidoDetalle
        LEFT JOIN dbo.CO_RelacionRegistroAdinco rel
            ON rel.IdRegistroPetrovendor = r.IdRegistro
        LEFT JOIN Adinco.dbo.CO_Registro ar
            ON rel.IdRegistroAdinco = ar.IdRegistro
    WHERE p.IdSolicitudPedido = @IdSolicitudPedido
          AND ISNULL(p.IdEstatusEliminado, 0) = 0

END

