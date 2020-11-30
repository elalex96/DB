

-- =============================================
-- Author:		<Jose Roman>
-- Create date: <09-07-2018>
-- Description:	<Se cierra el pedido>
-- =============================================

CREATE procedure MM_SP_CierrePedido
	@IdPedido INT,
	@MotivoInterno NVARCHAR(1500),
	@MotivoExterno NVARCHAR(1500),
	@TipoRegistro INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	DECLARE @UltimoCierre BIT = 0,
			@IdHistorialCierrePedido INT

	--Si el tipo de registro es un cierre de pedido
	IF(@TipoRegistro = 1)
	BEGIN
		UPDATE dbo.MM_Pedido	
			SET Cerrado = 1
		WHERE IdPedido = @IdPedido

		UPDATE dbo.MM_HistorialCierrePedido
		SET UltimoCierre = 0
		WHERE IdPedido = @IdPedido
		
		SET @UltimoCierre = 1		
	END
	ELSE IF (@TipoRegistro = 2)		--Si el tipo de registro es una reapertura de cierre
    BEGIN
		UPDATE dbo.MM_Pedido
			SET Cerrado = 0
		WHERE IdPedido = @IdPedido
	END

	INSERT INTO dbo.MM_HistorialCierrePedido
	(
	    IdPedido,
	    MotivoExterno,
	    MotivoInterno,
	    CambiadoPor,
	    CambiadoEl,
	    TipoRegistro,
		UltimoCierre
	)
	VALUES
	(   @IdPedido,                     -- IdPedido - int
	    @MotivoExterno,                   -- MotivoExterno - nvarchar(1500)
	    @MotivoInterno,                   -- MotivoInterno - nvarchar(1500)
	    @IdUsuario,                     -- CambiadoPor - int
	    GETDATE(), -- CambiadoEl - smalldatetime
	    @TipoRegistro,                  -- IsCierre - bit
		@UltimoCierre
	)

	--Si es un cierre de pedido se guardan las cantidades faltantes de cada material solicitado
	IF(@TipoRegistro = 1)
	BEGIN
		SET @IdHistorialCierrePedido = @@IDENTITY

		INSERT INTO dbo.MM_HistorialCierrePedidoDetalle
		(
			IdHistorialCierrePedido,
			IdPedidoDetalle,
			CantidadFaltanteAlCierre
		)
		SELECT 
			@IdHistorialCierrePedido,
			pd.IdPedidoDetalle,
			(pd.Cantidad - SUM(ISNULL(apd.Cantidad, 0))) AS CantidadFaltanteAlCierre
		FROM dbo.MM_Pedido p
		INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedido = p.IdPedido
		LEFT JOIN dbo.MM_AceptacionPedidoDetalle apd ON apd.IdPedidoDetalle = pd.IdPedidoDetalle
		WHERE p.idpedido = @IdPedido
			AND ISNULL(apd.IdEstatusEliminado, 0) = 0
		GROUP BY pd.IdPedidoDetalle, apd.Cantidad, pd.Cantidad
	end

END
