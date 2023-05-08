
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <2017>
-- Description:	<Se guarda el detalle de cada material>
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <22-11-2018>
-- Description:	<Se agrega la actualizacion del detalle de material>
-- =============================================
-- Author:		<Alexander Gomez>
-- Update date: <26/11/2021>
-- Description:	<optimizacion>
-- =============================================

CREATE procedure [dbo].[MM_SP_GuardarSolicitudPedidoDetalleLineaPresupuesto]
	@IdSolicitudPedidoDetalle INT,
	@IdCentroCosto INT,
	@IdInstalacion INT,
	@IdLineaPresupuesto INT

AS
BEGIN

	UPDATE dbo.MM_SolicitudPedidoDetalleLineaPresupuesto
	SET IdCentroCosto = @IdCentroCosto,
			IdInstalacion = @IdInstalacion,
			IdLineaPresupuesto = @IdLineaPresupuesto
	WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle

	IF @@ROWCOUNT = 0
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

END