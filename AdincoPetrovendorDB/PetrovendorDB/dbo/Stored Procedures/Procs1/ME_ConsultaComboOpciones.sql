
CREATE procedure [dbo].[ME_ConsultaComboOpciones]
	@IdPregunta int 
as
begin
	SELECT Respuesta, IdRespuestasOpciones
		FROM dbo.ME_RespuestasOpciones (NOLOCK)
		WHERE IdPregunta = @IdPregunta
END
