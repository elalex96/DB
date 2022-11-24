-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE procedure [dbo].[ME_ValidarEvaluacionRespondida]
	@IdProveedorEvaluado INT,
	@IdMatrizEvaluacion INT,
	@IdPedido int
AS
BEGIN
	SELECT COUNT(IdRespuestas) 
		FROM dbo.ME_Respuestas  (NOLOCK)
		WHERE IdMatrizEvaluacion = @IdMatrizEvaluacion
			AND IdProveedorEvaluado = @IdProveedorEvaluado
			AND IdPedido = @IdPedido
END


