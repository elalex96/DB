
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10-01-2019>
-- Description:	<Se valida que el monto de una factura no supere el monto de la aceptacion, si la operadora asi lo configuro>
-- =============================================

CREATE PROCEDURE FI_SP_ValidacionRestriccionDeFactura	
	@MontoFactura FLOAT,
	@IdMonedaFactura INT,
	@IdAceptacionPedido INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN

	DECLARE @RestriccionActiva BIT,
			@MontoAceptacion FLOAT,
			@Diferencia FLOAT,
			@IdProveedor INT

	SET @IdProveedor = (SELECT IdProveedor FROM dbo.MM_AceptacionPedido WHERE IdAceptacionPedido = @IdAceptacionPedido)
	SET @RestriccionActiva = (SELECT ISNULL(Activo, 0) FROM dbo.FI_RestriccionFactura WHERE IdProveedor = @IdProveedor)

	IF(@RestriccionActiva = 1)
	BEGIN
	    SET @MontoAceptacion = (
								SELECT SUM(apd.Cantidad * CASE WHEN pd.IdMoneda = 1 THEN dbo.FN_PesosDolaresTipoCambio(pd.PrecioUnitario, GETDATE()) ELSE pd.PrecioUnitario END)
								FROM dbo.MM_AceptacionPedido ap 
								INNER JOIN dbo.MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
								INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
								INNER JOIN dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido
								WHERE ap.IdAceptacionPedido = @IdAceptacionPedido
								)
		IF(@IdMonedaFactura = 1)
		BEGIN
		    SET @MontoFactura = (SELECT dbo.FN_PesosDolaresTipoCambio(@MontoFactura, GETDATE()))
		END

		SET @Diferencia = @MontoFactura - @MontoAceptacion

		SELECT CASE 
					WHEN @Diferencia > Excedente THEN 0
					ELSE 1
				END,
				Excedente
		FROM dbo.FI_RestriccionFactura
		WHERE IdProveedor = @IdProveedor

	END
	ELSE
	BEGIN
	    SELECT 1, 0
	END

END

