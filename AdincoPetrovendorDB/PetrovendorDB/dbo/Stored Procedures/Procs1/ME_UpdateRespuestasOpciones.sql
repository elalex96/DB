
CREATE procedure [dbo].[ME_UpdateRespuestasOpciones]
	@IdRespuestasOpciones INT,
	@Respuesta VARCHAR(max),
	@Valor FLOAT
AS
BEGIN
	UPDATE dbo.ME_RespuestasOpciones
		SET Respuesta = @Respuesta,
			Valor = @Valor
		WHERE IdRespuestasOpciones = @IdRespuestasOpciones 
END
