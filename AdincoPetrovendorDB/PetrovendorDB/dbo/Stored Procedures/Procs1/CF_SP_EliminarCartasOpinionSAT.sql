
CREATE procedure CF_SP_EliminarCartasOpinionSAT
	@IdCartaOpinionSat INT

AS
BEGIN
	UPDATE dbo.CF_CartaOpinionSAT
		SET Eliminado = 1, FechaEliminacion = GETDATE(), vigente = 0
		WHERE IdCartaOponionSat = @IdCartaOpinionSat
END
