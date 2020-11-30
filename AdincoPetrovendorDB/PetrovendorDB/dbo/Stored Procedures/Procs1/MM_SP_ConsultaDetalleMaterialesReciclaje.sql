
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10-01-2018>
-- Description:	<Consulta de detalle de materiales en el reciclaje de una solicitud de pedido>
-- =============================================

CREATE procedure [dbo].[MM_SP_ConsultaDetalleMaterialesReciclaje]
	@IdSolicitudPedidoDetalle INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
  /*---------------------------------------------------------------*/
AS
BEGIN
	SELECT IdSolicitudPedidoDetalleLineaPresupuesto, IdCentroCosto, IdInstalacion, IdLineaPresupuesto
	FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto 
	WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
END
