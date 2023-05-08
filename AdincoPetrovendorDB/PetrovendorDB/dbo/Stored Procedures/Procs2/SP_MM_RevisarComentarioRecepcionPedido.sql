CREATE PROCEDURE SP_MM_RevisarComentarioRecepcionPedido
	@IdPedido INT
AS
BEGIN
	SELECT Comentario FROM MM_ComentarioRecepcionPedido WHERE IdPedido = @IdPedido
END
