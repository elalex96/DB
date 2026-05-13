-- =============================================
-- Author: Alexander Gomez
-- Create date: 12/03/2019
-- Description: Calcular por el idpedido el total del pedido apartir de los detalles del mismo
-- =============================================

CREATE FUNCTION Fn_CalcularTotalPedido
	( @IDPEDIDO INT)
RETURNS MONEY
AS
	BEGIN
		DECLARE @TOTALPEDIDO MONEY

		SELECT
			@TOTALPEDIDO = SUM(PD.Cantidad * PD.PrecioUnitario)
		FROM dbo.MM_PedidoDetalle AS PD
		WHERE PD.IdPedido = @IDPEDIDO

		RETURN @TOTALPEDIDO
	END;




