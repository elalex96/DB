CREATE FUNCTION dbo.fnGetMontoPedido
(
	@pIdPedido INT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Monto FLOAT

	SELECT @Monto = SUM(ISNULL(Subtotal,0))
	FROM
		MM_PedidoDetalle	(NOLOCK)
	WHERE
		IdPedido	=	@pIdPedido

	RETURN @Monto
END