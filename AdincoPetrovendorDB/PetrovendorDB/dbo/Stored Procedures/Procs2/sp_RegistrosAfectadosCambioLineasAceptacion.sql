-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18-Feb-2020
-- Description:	Carga los registros que van a ser afectados
-- =============================================
--=============================================
-- Author:		Daniel AC
-- Create date: 13/07/2022
-- Description:	Se mueve relación con la tabla CO_RelacionRegistroAdinco
--=============================================
CREATE PROCEDURE [dbo].[sp_RegistrosAfectadosCambioLineasAceptacion] @IdSolicitudPedido INT
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
        JOIN MM_AceptacionPedido ap
            ON p.IdPedido = ap.IdPedido 
               AND ISNULL(ap.IdEstatusEliminado, 0) = 0
        JOIN MM_AceptacionPedidoDetalleInstalacion apdi
            ON ap.IdAceptacionPedido = apdi.IdAceptacionPedido 
        LEFT JOIN CO_Registro r
            ON apdi.IdAceptacionPedidoDetalle = r.IdAceptacionPedidoDetalle       
        LEFT JOIN Adinco..CO_Registro ar
            ON r.IdAceptacionPedidoDetalle = ar.IdAceptacionPedidoDetalle
    WHERE p.IdSolicitudPedido = @IdSolicitudPedido
          AND ISNULL(p.IdEstatusEliminado, 0) = 0

END

