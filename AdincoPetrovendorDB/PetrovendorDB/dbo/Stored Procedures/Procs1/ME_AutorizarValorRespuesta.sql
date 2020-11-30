
create PROCEDURE [dbo].[ME_AutorizarValorRespuesta]
	@IdRespuestas INT,
	@ValorAutorizado int
AS
BEGIN
	UPDATE dbo.ME_Respuestas
		SET ValorAutorizado = @ValorAutorizado
		WHERE IdRespuestas = @IdRespuestas

	DECLARE @IdEvaluado INT,
			@IdMatriz INT,
			@IdPedido INT

	SET @IdEvaluado = (SELECT IdProveedorEvaluado FROM dbo.ME_Respuestas WHERE IdRespuestas = @IdRespuestas)
	SET @IdMatriz = (SELECT IdMatrizEvaluacion FROM dbo.ME_Respuestas WHERE IdRespuestas = @IdRespuestas)
	SET @IdPedido = (SELECT IdPedido FROM dbo.ME_Respuestas WHERE IdRespuestas = @IdRespuestas)

	EXEC dbo.ME_CalcularResultadoEvaluacion @IdProveedorEvaluado = @IdEvaluado, -- int
	                                        @IdMatrizEvaluacion = @IdMatriz,  -- int
	                                        @IdPedido = @IdPedido             -- int
	
END

