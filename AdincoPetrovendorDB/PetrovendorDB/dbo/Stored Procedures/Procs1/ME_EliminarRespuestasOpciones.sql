
CREATE procedure [dbo].[ME_EliminarRespuestasOpciones]
	@IdRespuestasOpciones INT
AS
BEGIN
	DELETE dbo.ME_RespuestasOpciones
		WHERE IdRespuestasOpciones = @IdRespuestasOpciones
END
