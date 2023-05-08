
CREATE procedure CF_SP_DescargarCartaOpinionSAT
	@IdCartaOpinionSat INT

AS
BEGIN
	SELECT Carta, NombreCarta
		FROM dbo.CF_CartaOpinionSAT
		WHERE IdCartaOponionSat = @IdCartaOpinionSat
END
