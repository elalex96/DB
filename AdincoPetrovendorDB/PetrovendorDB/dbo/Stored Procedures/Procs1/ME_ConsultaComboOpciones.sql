
CREATE procedure ME_ConsultaComboOpciones
	@IdPregunta int 
as
begin
	SELECT Respuesta, IdRespuestasOpciones
		FROM dbo.ME_RespuestasOpciones
		WHERE IdPregunta = @IdPregunta
END

