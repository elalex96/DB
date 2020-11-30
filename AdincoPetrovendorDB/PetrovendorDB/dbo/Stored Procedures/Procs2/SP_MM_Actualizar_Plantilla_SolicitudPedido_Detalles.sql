-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/11/2019>
-- Description:	<Actualizar los datos de una plantilla de solicitud de pedido en las partidas>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Actualizar_Plantilla_SolicitudPedido_Detalles]
	-- Add the parameters for the stored procedure here
	  @IdSolicitudPedidoDetalle int,
	  @IdSolicitudPedido INT,
	  @IdMaterial int,
	  @Cantidad FLOAT,
	  @observaciones nvarchar(MAX),
	  @IdUnidad int,
	  @IdDomicilioEntrega int,
	  @IdCentroCosto INT,
	  @IdLineaPresupuesto INT,
	  @IdInstalacion INT,
	  @CreadoPor INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IDSOLICITUDPEDIDODETALLEB INT = (SELECT
												IdPlantillaSolicitudPedidoDetalle
											FROM dbo.MM_Plantilla_SolicitudPedidoDetalle 
											WHERE IdPlantillaSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle);

	IF ISNULL(@IDSOLICITUDPEDIDODETALLEB,0) > 0
	BEGIN
			UPDATE dbo.MM_Plantilla_SolicitudPedidoDetalle
				SET IdMaterial = @IdMaterial,
					Cantidad = @Cantidad,
					Observaciones = @observaciones,
					IdUnidad = @IdUnidad,
					IdCentroCosto = @IdCentroCosto,
					IdDomicilioEntrega = @IdDomicilioEntrega,
					IdInstalacion = @IdInstalacion,
					IdLineaPresupuesto = @IdLineaPresupuesto,
					Activo = 1
			WHERE IdPlantillaSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle;
	END
	ELSE
	BEGIN
	    INSERT INTO dbo.MM_Plantilla_SolicitudPedidoDetalle
		(
			IdPlantillaSolicitudPedido,
			IdMaterial,
			Fecha,
			Cantidad,
			Observaciones,
			CreadoPor,
			IdUnidad,
			IdCentroCosto,
			IdDomicilioEntrega,
			CreadoEl,
			IdInstalacion,
			IdLineaPresupuesto,
			Activo
		)
		VALUES
		(   @IdSolicitudPedido,         -- IdPlantillaSolicitudPedido - int
			@IdMaterial,         -- IdMaterial - int
			GETDATE(), -- Fecha - datetime
			@Cantidad,       -- Cantidad - float
			@observaciones,       -- Observaciones - nvarchar(max)
			@CreadoPor,         -- CreadoPor - int
			@IdUnidad,         -- IdUnidad - int
			@IdCentroCosto,         -- IdCentroCosto - int
			@IdDomicilioEntrega,         -- IdDomicilioEntrega - int
			GETDATE(),  -- CreadoEl - datetime
			@IdInstalacion,
			@IdLineaPresupuesto,
			1
			);
	END

END
