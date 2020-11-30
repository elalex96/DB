
CREATE procedure [dbo].[ME_EliminarRespuestasRango]
	@IdRespuestasRango INT
AS
BEGIN
	DELETE dbo.ME_RespuestasRango
		WHERE IdRespuestasRango = @IdRespuestasRango
END
