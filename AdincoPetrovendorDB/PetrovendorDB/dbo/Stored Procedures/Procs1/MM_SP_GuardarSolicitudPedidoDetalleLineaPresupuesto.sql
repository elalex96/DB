
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <2017>
-- Description:	<Se guarda el detalle de cada material>
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <22-11-2018>
-- Description:	<Se agrega la actualizacion del detalle de material>
-- =============================================

CREATE procedure MM_SP_GuardarSolicitudPedidoDetalleLineaPresupuesto
	@IdSolicitudPedidoDetalle INT,
	@IdCentroCosto INT,
	@IdInstalacion INT,
	@IdLineaPresupuesto INT

AS
BEGIN
	DECLARE @Existe INT

	SET	@Existe = (SELECT COUNT(IdSolicitudPedidoDetalleLineaPresupuesto) FROM dbo.MM_SolicitudPedidoDetalleLineaPresupuesto WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle)

	IF(@Existe = 0)
	BEGIN
		INSERT INTO dbo.MM_SolicitudPedidoDetalleLineaPresupuesto
		(
			IdSolicitudPedidoDetalle,
			IdCentroCosto,
			IdInstalacion,
			IdLineaPresupuesto
		)
		VALUES
		(   @IdSolicitudPedidoDetalle, -- IdSolicitudPedidoDetalle - int
			@IdCentroCosto, -- IdCentroCosto - int
			@IdInstalacion, -- IdInstalacion - int
			@IdLineaPresupuesto  -- IdLineaPresupuesto - int
		)
	END
	ELSE
    BEGIN
        UPDATE dbo.MM_SolicitudPedidoDetalleLineaPresupuesto
		SET IdCentroCosto = @IdCentroCosto,
			IdInstalacion = @IdInstalacion,
			IdLineaPresupuesto = @IdLineaPresupuesto
		WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle
    END
END
