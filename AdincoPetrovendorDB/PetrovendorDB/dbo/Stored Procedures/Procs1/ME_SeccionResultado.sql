
create PROCEDURE [dbo].[ME_SeccionResultado]
	@IdEvaluacion INT,
	@IdProveedorEvaluado INT,
	@IdPedido int
AS
BEGIN
	SELECT s.IdSeccion, s.Nombre, (CAST((SUM(CASE WHEN r.ValorAutorizado is NULL THEN r.ValorRespuesta ELSE r.ValorAutorizado end)*s.Ponderacion)AS FLOAT) / 100) AS Resultado		 		 
	FROM dbo.ME_Respuestas AS r
		INNER JOIN dbo.ME_Preguntas AS p ON p.IdPregunta = r.IdPregunta
		INNER JOIN dbo.ME_Seccion AS s ON s.IdSeccion = r.IdSeccion
	WHERE r.IdMatrizEvaluacion = @IdEvaluacion AND r.IdProveedorEvaluado = @IdProveedorEvaluado AND r.IdPedido = @IdPedido
	GROUP BY r.IdSeccion, s.Nombre, s.Ponderacion, s.IdSeccion
END

