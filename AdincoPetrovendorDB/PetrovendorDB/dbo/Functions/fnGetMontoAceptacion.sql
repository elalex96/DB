CREATE FUNCTION dbo.fnGetMontoAceptacion
(
	@pIdAceptacionPedido INT
)
RETURNS FLOAT
AS
BEGIN

	DECLARE @Monto FLOAT = 0

	 SELECT 
			@Monto	=	SUM(ISNULL(APD.Cantidad * PD.PrecioUnitario,0))
	 FROM
		 dbo.MM_AceptacionPedidoDetalle	APD	(NOLOCK)
	 JOIN	MM_PedidoDetalle	PD	(NOLOCK)
		ON	APD.IdPedidoDetalle	=	PD.IdPedidoDetalle
	 WHERE
		APD.IdAceptacionPedido = @pIdAceptacionPedido

	RETURN @Monto
END