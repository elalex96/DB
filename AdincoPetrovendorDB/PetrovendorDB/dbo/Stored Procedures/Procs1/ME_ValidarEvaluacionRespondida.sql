
CREATE procedure [dbo].[ME_ValidarEvaluacionRespondida]
	@IdProveedorEvaluado INT,
	@IdMatrizEvaluacion INT,
	@IdPedido int
AS
BEGIN
	SELECT COUNT(IdRespuestas) 
		FROM dbo.ME_Respuestas
		WHERE IdMatrizEvaluacion = @IdMatrizEvaluacion
			AND IdProveedorEvaluado = @IdProveedorEvaluado
			AND IdPedido = @IdPedido
END


