
CREATE PROCEDURE [dbo].[SP_MM_guardarComentarioRecepcionPedido]
	@IdPedido INT,
	--@IdPedidoDetalle INT,
	@Comentario VARCHAR(MAX)
	--@IdUsuario INT
AS
BEGIN

	INSERT INTO dbo.MM_ComentarioRecepcionPedido
	(
	    IdPedido,
	    IdPedidoDetalle,
	    Comentario
	)
	VALUES
	(   @IdPedido, -- IdPedido - int
	    null, -- IdPedidoDetalle - int
	    @Comentario -- Comentario - varchar(max)
	)


END

