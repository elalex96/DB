CREATE PROCEDURE SP_ObtenerMMPedidos @IdPedido INT
AS
BEGIN
	DECLARE @mmPedidoId INT
	SELECT @mmPedidoId = IdPedido FROM dbo.MM_Pedidos WHERE IdIdentificador = @IdPedido

	SELECT @mmPedidoId, Version FROM dbo.MM_Pedido WHERE IdPedido = @IdPedido
	
END	