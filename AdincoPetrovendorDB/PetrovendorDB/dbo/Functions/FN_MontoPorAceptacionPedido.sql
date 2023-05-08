
-- =============================
-- Author:		Jose Roman
-- Create date: 08-11-2018
-- Description: Funcion para obtener el total de una aceptacion
-- =============================================
CREATE FUNCTION FN_MontoPorAceptacionPedido
(
	@IdAceptacion INT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Monto FLOAT

	SELECT @Monto = SUM(pd.PrecioUnitario * apd.Cantidad)
	FROM dbo.MM_AceptacionPedido ap
	INNER JOIN dbo.MM_AceptacionPedidoDetalle apd ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
	INNER JOIN dbo.MM_PedidoDetalle pd ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
	WHERE ap.IdAceptacionPedido = @IdAceptacion
	
	RETURN @Monto
END
