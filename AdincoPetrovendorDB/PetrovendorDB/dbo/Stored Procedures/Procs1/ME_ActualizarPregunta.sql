
CREATE procedure ME_ActualizarPregunta
	@IdPregunta INT,
	@IdTipoRespuesta INT,
	@Pregunta VARCHAR(max),
	@Ponderacion FLOAT,
	@AplicaPersonaMoral BIT,
	@RequiereDocumento bit

AS
BEGIN
	UPDATE dbo.ME_Preguntas
		SET IdTipoRespuesta = @IdTipoRespuesta,
			Pregunta = @Pregunta,
			Ponderacion = @Ponderacion,
			AplicaPersonaMoral = @AplicaPersonaMoral,
			RequiereDocumento = @RequiereDocumento
		WHERE IdPregunta = @IdPregunta
END