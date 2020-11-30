CREATE FUNCTION [dbo].[fnGetAvanceXPolitica]
(
	@IdProgramaImplementaPolitica INT
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @Cantidad FLOAT

	SELECT
		@Cantidad	=	SUM(100.00/dbo.fnGetCantidadAccionesXPolitica(PIE.IdProgramaImplementaPolitica))
	FROM
		CO_ProgramaImplementaElemento	PIE	(NOLOCK)
	JOIN
		CO_ProgramaImplementaAcciones	PIA	(NOLOCK)
		ON	PIE.IdProgramaImplementaElemento = PIA.IdProgramaImplementaElemento
	JOIN
		EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC
		ON	PIA.IdProgramaImplementaAccion = ENT_ACC.IdProgramaImplementaAccion
	JOIN
		EN_ContratoEntregable	CE	(NOLOCK)
		ON	ENT_ACC.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	ISNULL(ENT_ACC.Activo,1)	=	1
		AND	ISNULL(CE.Activo,0)	=	1
	JOIN
		EN_Entregable	E	(NOLOCK)
		ON	CE.IdEntregable	=	E.IdEntregable
		AND	ISNULL(E.IsActivo,1)	=	1
	JOIN
		EN_InstanciasEntregable	IE (NOLOCK)
		ON	CE.IdContratoEntregable = IE.IdContratoEntregable
		AND	ISNULL(IE.Activo,1)	=	1
	JOIN
		EN_Actividad	AACT	(NOLOCK)
		ON	IE.ActividadID	=	AACT.ActividadID
		AND AACT.Activo = 1
		AND AACT.EstadoID = 10003
	WHERE
		PIE.IdProgramaImplementaPolitica	=	@IdProgramaImplementaPolitica

	RETURN @Cantidad
END