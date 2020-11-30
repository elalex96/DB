
-- =============================
-- Author:		Jose Roman
-- Create date: 08-11-2018
-- Description: Funcion para obtener el total de una aceptacion
-- =============================================
CREATE FUNCTION FN_MontoPorPedido
(
	@IdPedido INT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Monto FLOAT

	SELECT @Monto = SUM(pd.Subtotal)
	FROM dbo.MM_Pedido p
	INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedido = p.IdPedido
	WHERE p.IdPedido = @IdPedido	
	
	RETURN @Monto
END
