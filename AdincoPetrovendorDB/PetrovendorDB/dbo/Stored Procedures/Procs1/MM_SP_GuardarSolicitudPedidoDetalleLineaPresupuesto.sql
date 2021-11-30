USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[MM_SP_GuardarSolicitudPedidoDetalleLineaPresupuesto]    Script Date: 26/11/2021 01:59:57 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

ALTER procedure [dbo].[MM_SP_GuardarSolicitudPedidoDetalleLineaPresupuesto]
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
