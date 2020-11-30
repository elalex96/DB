-- =============================================
-- Author:	Daniel A Cruz
-- Create date: 11-04-17
-- Description:	SP que agrega Detalle de Solicitud de Pedido
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <22-11-2017>
-- Description:	<Se agrega la opcion de actualizacion del detalle>
-- =============================================
CREATE PROCEDURE SP_MM_AgregarSolicitudPedidoDetalle
	  @IdSolicitudPedidoDetalle INT,
      @IdSolicitudPedido int,
	  @IdMaterial int,
	  @Cantidad FLOAT,
	  @observaciones nvarchar(MAX),
	  @CreadoPor int, 
	  @IdUnidad int,
	  @IdDomicilioEntrega int,
	  @IdCentroCosto INT,
	  @IsReciclado BIT
	 
AS     
BEGIN
	DECLARE @ExisteDetalle INT
	
	IF(@IsReciclado = 0)
	BEGIN
		SET @ExisteDetalle = (SELECT COUNT(IdSolicitudPedidoDetalle) FROM dbo.MM_SolicitudPedidoDetalle WHERE IdSolicitudPedidoDetalle = @IdSolicitudPedidoDetalle)
	END
	ELSE
	BEGIN
		SET @ExisteDetalle = 0
	END

	IF(@ExisteDetalle = 0)
	BEGIN
		INSERT INTO [dbo].[MM_SolicitudPedidoDetalle]
			   ([IdSolicitudPedido]
				,[IdMaterial]
				,[Fecha]
			   ,[Cantidad]
			   ,[observaciones]
			   ,[CreadoPor]
			   ,[IdUnidad]
			   ,[IdCentroCosto]
			   ,[IdDomicilioEntrega]
			   )          
		 VALUES
			   ( @IdSolicitudPedido,
				@IdMaterial,
				GETDATE(),
				@Cantidad, 
				@observaciones,
				@CreadoPor,
				@IdUnidad,
				@IdCentroCosto,
				@IdDomicilioEntrega
				)
	
		SELECT @IdSolicitudPedidoDetalle = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SELECT @IdSolicitudPedidoDetalle
	END

	SELECT @IdSolicitudPedidoDetalle
END





