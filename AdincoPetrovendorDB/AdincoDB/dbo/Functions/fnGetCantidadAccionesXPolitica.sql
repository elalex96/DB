CREATE FUNCTION [dbo].[fnGetCantidadAccionesXPolitica]
(
	@IdProgramaImplementaPolitica INT
)
RETURNS INT
AS
BEGIN
	DECLARE @Cantidad INT

	SELECT	@Cantidad = COUNT(1)
	FROM
		CO_ProgramaImplementaElemento	PIE	(NOLOCK)
	JOIN
		CO_ProgramaImplementaAcciones	PIA	(NOLOCK)
		ON	PIE.IdProgramaImplementaElemento = PIA.IdProgramaImplementaElemento
	WHERE
		PIE.IdProgramaImplementaPolitica	=	@IdProgramaImplementaPolitica

	RETURN @Cantidad
END