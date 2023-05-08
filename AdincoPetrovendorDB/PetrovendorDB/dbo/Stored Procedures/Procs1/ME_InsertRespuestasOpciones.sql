
CREATE procedure [dbo].[ME_InsertRespuestasOpciones]
	@IdPregunta INT,
	@Respuesta VARCHAR(max),
	@valor FLOAT
AS
BEGIN
	INSERT INTO dbo.ME_RespuestasOpciones
	(
	    IdPregunta,
	    Respuesta,
	    Valor
	)
	VALUES
	(   @IdPregunta,  -- IdPregunta - int
	    @Respuesta, -- Respuesta - varchar(max)
	    @valor -- Valor - float
	)
END
