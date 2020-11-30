
CREATE procedure [dbo].[ME_UpdateRespuestasRango]
	@IdRespuestasRango INT,
	@Respuesta VARCHAR(max),
	@ValorMin INT,
	@ValorMax INT,
	@Valor FLOAT
AS
BEGIN
	UPDATE dbo.ME_RespuestasRango
		SET Respuesta = @Respuesta,
			ValorMin = @ValorMin,
			ValorMax = @ValorMax,
			Valor = @Valor
		WHERE IdRespuestasRango = @IdRespuestasRango 
END
