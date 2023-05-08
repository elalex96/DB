-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19/11/2019>
-- Description:	<agregado de los detalles de la solped de la plantilla>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Guardar_Plantilla_SolicitudPedido_Detalles]
	-- Add the parameters for the stored procedure here
      @IdSolicitudPedido int,
	  @IdMaterial int,
	  @Cantidad FLOAT,
	  @observaciones nvarchar(MAX),
	  @CreadoPor int, 
	  @IdUnidad int,
	  @IdDomicilioEntrega int,
	  @IdCentroCosto INT,
	  @IdLineaPresupuesto INT,
	  @IdInstalacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDSOLICITUDPEDIDO_DETALLE INT;
    -- Insert statements for procedure here
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

	SET @IDSOLICITUDPEDIDO_DETALLE = (SCOPE_IDENTITY());

	SELECT @IDSOLICITUDPEDIDO_DETALLE;
END
