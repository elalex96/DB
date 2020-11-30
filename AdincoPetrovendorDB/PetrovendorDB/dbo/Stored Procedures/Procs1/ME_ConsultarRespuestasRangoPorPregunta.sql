
CREATE procedure [dbo].[ME_ConsultarRespuestasRangoPorPregunta]
	@IdPregunta INT
AS
BEGIN
	SELECT IdRespuestasRango, Respuesta, ValorMin, ValorMax, Valor
		FROM dbo.ME_RespuestasRango
		WHERE IdPregunta = @IdPregunta
END
