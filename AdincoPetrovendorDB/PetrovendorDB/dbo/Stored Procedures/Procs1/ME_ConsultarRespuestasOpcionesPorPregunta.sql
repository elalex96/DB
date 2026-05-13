
CREATE procedure [dbo].[ME_ConsultarRespuestasOpcionesPorPregunta]
	@IdPregunta INT
AS
BEGIN
	SELECT IdRespuestasOpciones, Respuesta, Valor
		FROM dbo.ME_RespuestasOpciones
		WHERE IdPregunta = @IdPregunta
END
