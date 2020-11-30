
CREATE procedure [dbo].[ME_InsertRespuestasRango]
	@IdPregunta INT,
	@Respuesta VARCHAR(max),
	@ValorMin INT,
	@ValorMax INT,
	@Valor FLOAT
AS
BEGIN
	INSERT INTO dbo.ME_RespuestasRango
	(
	    IdPregunta,
	    ValorMin,
	    ValorMax,
	    Valor,
	    Respuesta
	)
	VALUES
	(   @IdPregunta,   -- IdPregunta - int
	    @ValorMin,   -- ValorMin - int
	    @ValorMax,   -- ValorMax - int
	    @Valor, -- Valor - float
	    @Respuesta   -- Respuesta - varchar(max)
	)
END
