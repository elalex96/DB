
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <27-04-2018>
-- Description:	<Cambia la cantidad recibida y guarda el Historial de cambios>
-- Author:		<Abel Rivera>
-- Create date: <08-10-2019>
-- Description:	<Se agrego funcionalidad para validar que la cantidad agregada no exeda la cantidad restante>
-- =============================================

CREATE procedure [dbo].[MM_SP_CambiarCantidadRecibidaAP]
	@IdAceptacionPedido INT,
	@IdAceptacionPedidoDetalle INT,
	@Motivo VARCHAR(1500),
	@CantidadNueva FLOAT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	DECLARE @CantidadAnterior FLOAT,
			@PrecioUnitario FLOAT,
			@FechaAceptacionPedido DATE,
			@PrecioDolares FLOAT,
			@IdMoneda INT,
			@IdPedidoDetalle INT,
			@CantidadSolicitada FLOAT,
			@CantidadAceptada FLOAT


	SELECT @CantidadAnterior = APD.Cantidad, @PrecioUnitario = pd.PrecioUnitario, @FechaAceptacionPedido = APD.Creado, @IdPedidoDetalle = APD.IdPedidoDetalle
	FROM dbo.MM_AceptacionPedidoDetalle APD INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedidoDetalle = APD.IdPedidoDetalle 
	WHERE APD.IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle

	SET @CantidadSolicitada = ( SELECT Cantidad FROM dbo.MM_PedidoDetalle WHERE IdPedidoDetalle = @IdPedidoDetalle )

    SET @CantidadAceptada = (	SELECT SUM(ISNULL(APD.Cantidad,0)) AS CantidadYaAceptada
								FROM MM_AceptacionPedidoDetalle AS APD
								INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido= APD.IdAceptacionPedido
								INNER JOIN MM_Pedido AS P ON P.IdPedido = AP.IdPedido
								INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
								WHERE  PD.IdPedidoDetalle= @IdPedidoDetalle AND ISNULL(AP.IdEstatusEliminado,0)<>1)

    DECLARE @CantidadRestante FLOAT = ( @CantidadSolicitada - @CantidadAceptada )
	DECLARE @CantidadMaximaAgregar FLOAT = ( @CantidadAnterior + @CantidadRestante )
	DECLARE @CantidadTotal FLOAT = (@CantidadAceptada + @CantidadNueva)

	IF( @CantidadNueva <= @CantidadMaximaAgregar )
	BEGIN
	    	UPDATE dbo.MM_AceptacionPedidoDetalle
			SET Cantidad = @CantidadNueva
			WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle

			UPDATE dbo.MM_PCN_ValoresPesos
			SET ValorFactura = (@CantidadNueva * @PrecioUnitario) 
			WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle

			SELECT @IdMoneda = IdMoneda 
			FROM dbo.MM_PedidoDetalle WHERE IdPedidoDetalle = @IdPedidoDetalle

			IF(@IdMoneda = 2)
			BEGIN	
			SELECT @PrecioDolares = dbo.FN_DolaresPesosTipoCambio(@CantidadNueva * @PrecioUnitario, @FechaAceptacionPedido)
	
			UPDATE dbo.MM_PCN_ValoresPesos
			SET ValorFactura = @PrecioDolares
			WHERE IdAceptacionPedidoDetalle = @IdAceptacionPedidoDetalle

			END	
			INSERT INTO dbo.MM_HistorialCorreccionCantidadAP
			(
				IdAceptacionPedido,
				IdAeptacionPedidoDetalle,
				CantidadAnterior,
				CantidadNueva,
				Motivo,
				ModificadoPor,
				ModificadoEl
			)
			VALUES
			(   @IdAceptacionPedido,                    -- IdAceptacionPedido - int
				@IdAceptacionPedidoDetalle,                    -- IdAeptacionPedidoDetalle - int
				@CantidadAnterior,                  -- CantidadAnterior - float
				@CantidadNueva,                  -- CantidadNueva - float
				@Motivo,                   -- Motivo - varchar(1500)
				@IdUsuario,                    -- ModificadoPor - int
				GETDATE()	 -- ModificadoEl - smalldatetime
			)
	END
	ELSE
    BEGIN
        SELECT 'Solo puedes aceptar una cantidad máxima de ' + CAST(@CantidadMaximaAgregar AS NVARCHAR(15)) + ' para este material/servicio' AS mensaje
    END

END

