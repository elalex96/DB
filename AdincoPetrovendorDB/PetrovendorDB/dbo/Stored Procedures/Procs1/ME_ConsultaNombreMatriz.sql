
CREATE procedure [dbo].[ME_ConsultaNombreMatriz]
	@IdMatrizEvaluacion int 
as
begin
	SELECT Nombre FROM dbo.ME_MatrizEvaluacion WHERE IdMatrizEvaluacion = @IdMatrizEvaluacion
END
