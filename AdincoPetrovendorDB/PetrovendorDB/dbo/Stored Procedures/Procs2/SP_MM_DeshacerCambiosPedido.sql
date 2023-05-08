CREATE PROCEDURE SP_MM_DeshacerCambiosPedido
	@IdPedido INT
AS
BEGIN
	--Borrar el comentario del rechazo
	DELETE MM_ComentarioRecepcionPedido WHERE IdPedido = @IdPedido

	--setear a nulo 
	UPDATE MM_PedidoDetalle SET RecepcionPedido = NULL WHERE IdPedido = @IdPedido
	
END	