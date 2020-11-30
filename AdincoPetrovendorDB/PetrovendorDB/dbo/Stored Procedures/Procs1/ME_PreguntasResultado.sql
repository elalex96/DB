create PROCEDURE ME_PreguntasResultado
	@IdSeccion INT,
	@IdPedido int
AS
BEGIN
	SELECT r.IdRespuestas, 
	p.Pregunta, 
		(CASE  
			WHEN p.IdTipoRespuesta = 1 THEN (CASE WHEN r.Respuesta = 1 THEN 'Si' ELSE 'No' END)
			WHEN p.IdTipoRespuesta = 2 THEN (SELECT Respuesta FROM dbo.ME_RespuestasOpciones AS o WHERE o.IdPregunta = r.IdPregunta AND o.IdRespuestasOpciones = r.Respuesta)
			WHEN p.IdTipoRespuesta = 3 THEN (r.Respuesta)
		end) AS Respuesta, 
		r.ValorRespuesta, 
		p.RequiereDocumento, 
		p.Ponderacion AS PonderacionMaxima, 
		r.ValorAutorizado	 
	FROM dbo.ME_Respuestas AS r
		INNER JOIN dbo.ME_Preguntas AS p ON p.IdPregunta = r.IdPregunta
		INNER JOIN dbo.ME_Seccion AS s ON s.IdSeccion = r.IdSeccion
		INNER JOIN dbo.ME_MatrizEvaluacion AS m ON m.IdMatrizEvaluacion = r.IdMatrizEvaluacion
	WHERE r.IdSeccion = @IdSeccion AND r.IdPedido = @IdPedido
END