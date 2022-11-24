
create proc spConsultaProgramaImplementaRpt
(
	@IdContrato				int,
	@IdProgramaImplementa	int
)
as
begin
/*
	Creado por Ramón Portales 28/03/2022
	Obtiene a información del Programa de Implementación acorde a los filtros proporcionados
*/
	SELECT		Contrato											=	C.NumeroContrato,
				NombrePrograma										=	PIT.Descripcion,
				Politica											=	PIP.Descripcion, 
				Elemento											=	PIE.Descripcion, 
				ACCION												=	REPLACE(REPLACE(LTRIM(RTRIM(PIA.Descripcion)),CHAR(9),''),CHAR(13),''),
				ENTREGABLE											=	REPLACE(REPLACE(LTRIM(RTRIM(E.DocumentoEntregable)),CHAR(9),''),CHAR(13),''),
				E.Consecutivo,
				Area												=	ISNULL(AR.NombreArea,''),
				ID													=	IE.idInstanciaEntregable,
				FechaEstimadaEntregaRegulador						=	IE.FechaCalculadaEntregaReg,
				IE.CreadoEn
	FROM		CO_ProgramaImplementa								CPI
	JOIN		CO_Contrato											C		(NOLOCK)
	ON			CPI.IdContrato										=		C.IdContrato
	JOIN		CO_ProgramaImplementacionTipo						PIT
	ON			CPI.IdTipoPrograma									=		PIT.Id
	AND			CPI.Activo											=		1
	AND			CPI.IdContrato										=		PIT.IdContrato
	AND			PIT.IdContrato										=		@IdContrato				
	JOIN		CO_ProgramaImplementaPoliticas						PIP
	ON			CPI.IdProgramaImplementa							=		PIP.IdProgramaImplementa
	LEFT JOIN	CO_ProgramaImplementaElemento						PIE
	ON			PIP.IdProgramaImplementaPolitica					=		PIE.IdProgramaImplementaPolitica
	JOIN		CO_ProgramaImplementaAcciones						PIA
	ON			PIE.IdProgramaImplementaElemento					=		PIA.IdProgramaImplementaElemento
	LEFT JOIN	CO_ProgramaImplementaDepartamentos					PID
	ON			PIA.IdProgramaImplementaDepartamento				=		PID.IdProgramaImplementaDepartamento
	LEFT JOIN	EN_ContratoEntregableProgramaImplementaAcciones		ENT_ACC
	ON			PIA.IdProgramaImplementaAccion						=		ENT_ACC.IdProgramaImplementaAccion
	LEFT JOIN	EN_ContratoEntregable								CE		(NOLOCK)
	ON			ENT_ACC.IdContratoEntregable						=		CE.IdContratoEntregable
	AND			ISNULL(ENT_ACC.Activo,1)							=		1
	AND			ISNULL(CE.Activo,1)									=		1
	LEFT JOIN	EN_InstanciasEntregable								IE		(NOLOCK)
	ON			CE.IdContratoEntregable								=		IE.IdContratoEntregable
	AND			ISNULL(IE.Activo,1)									=		1
	LEFT JOIN	EN_Entregable										E		(NOLOCK)
	ON			CE.IdEntregable										=		E.IdEntregable
	AND			ISNULL(E.IsActivo,1)								=		1
	LEFT JOIN	EN_Area												AR		(NOLOCK)
	ON			CE.IdArea											=		AR.idArea
	where		PIT.IdContrato										=		@IdContrato
	and			CPI.IdProgramaImplementa							=		@IdProgramaImplementa
	ORDER BY	PIP.Descripcion, 
				PIE.Descripcion,
				Consecutivo
end
