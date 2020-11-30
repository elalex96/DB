-- =============================================
-- Author:		<Jose Roman>
-- Create date: <26-06-2018>
-- Description:	<Se consultan las cantidades registradas en la aceptacion de pedido y la factura para su validacion>
-- =============================================
-- Author:		DANIEL AC
-- Create date: 16/07/2018
-- Description:	<Se consultan las cantidades registradas en la aceptacion de pedido y la factura para su validacion, SE CAMBIO DE ORDEN >
-- =============================================
-- Author:		Jose Roman
-- Create date: 24/08/2018
-- Description:	<Se homologan los tipos de monedas al que se encuentra registrado en la aceptacion>
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19/07/2019
-- Description:	<Se redondeo las cantidades para la validacion>
-- =============================================

CREATE PROCEDURE [dbo].[MM_ValidarCantitadesAP] --10317, 258
    @IdFactura INT,
    @IdAceptacionPedido INT,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    DECLARE @TotalAceptacion MONEY,
			@TotalFactura MONEY,
			@TipoMonedaAceptacion INT,
			@TipoMonedaFactura INT

	SELECT @TipoMonedaAceptacion = pd.IdMoneda
	FROM dbo.MM_AceptacionPedidoDetalle ap
        INNER JOIN dbo.MM_PedidoDetalle pd
            ON pd.IdPedidoDetalle = ap.IdPedidoDetalle
    WHERE IdAceptacionPedido = @IdAceptacionPedido
	GROUP BY pd.IdMoneda

	SELECT @TipoMonedaFactura = IdMoneda
	FROM dbo.FI_Factura
	WHERE IdFactura = @IdFactura

	IF(@TipoMonedaAceptacion = @TipoMonedaFactura)
	BEGIN
		SELECT @TotalFactura = SubTotal
		FROM dbo.FI_Factura
		WHERE IdFactura = @IdFactura;
	END
    ELSE
    BEGIN
		IF(@TipoMonedaAceptacion = 1) --Si el tipo de moneda de la aceptacion es Pesos
		BEGIN
			SELECT @TotalFactura = SubTotal * CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
			FROM dbo.FI_Factura
			WHERE IdFactura = @IdFactura;
		END
		ELSE --Si el tipo de moneda de la aceptacion son dolares
		BEGIN
			SELECT @TotalFactura = SubTotal / CAST(dbo.GetTipoCambioActualScalar(1, CAST(FechaTimbrado AS DATETIME)) AS MONEY)
			FROM dbo.FI_Factura
			WHERE IdFactura = @IdFactura;
		END
	END
		
	SELECT @TotalAceptacion = SUM(ap.Cantidad * pd.PrecioUnitario)
	FROM dbo.MM_AceptacionPedidoDetalle ap
		INNER JOIN dbo.MM_PedidoDetalle pd
			ON pd.IdPedidoDetalle = ap.IdPedidoDetalle
	WHERE IdAceptacionPedido = @IdAceptacionPedido;

	SELECT ROUND(@TotalFactura,2), 
			ROUND(@TotalAceptacion,2),
			ISNULL(TipoMonedaCorto, TipoMoneda)
	FROM dbo.PV_TipoMoneda
	WHERE IdMoneda = @TipoMonedaAceptacion
END;


