CREATE PROCEDURE spConsultaProgramaImplementaRpt
	@IdContrato				int,
	@IdProgramaImplementa	int
AS
BEGIN
/*
	Creado por Ramón Portales 28/03/2022
	Obtiene a información del Programa de Implementación acorde a los filtros proporcionados
*/
	SELECT	DISTINCT	Contrato											=	C.NumeroContrato,
				NombrePrograma										=	PIT.Descripcion,
				Politica											=	PIP.Descripcion, 
				Elemento											=	PIE.Descripcion, 
				ACCION												=	REPLACE(REPLACE(LTRIM(RTRIM(PIA.Descripcion)),CHAR(9),''),CHAR(13),''),
				ENTREGABLE											=	REPLACE(REPLACE(LTRIM(RTRIM(E.DocumentoEntregable)),CHAR(9),''),CHAR(13),''),
				E.Consecutivo,
				Area												=	ISNULL(AR.NombreArea,''),
				ID													=	IE.idInstanciaEntregable,
				FechaEstimadaEntregaRegulador						=	IE.FechaCalculadaEntregaReg,
				IE.CreadoEn,
				EST.NombreEstado,
				U.Nombre
	FROM
		CO_ProgramaImplementa								CPI	(NOLOCK)
	JOIN
		CO_Contrato											C		(NOLOCK)
		ON		CPI.IdContrato						=		C.IdContrato
		AND		C.IdContrato	=	@IdContrato
		and			CPI.IdProgramaImplementa		=		@IdProgramaImplementa
	JOIN
		CO_ProgramaImplementacionTipo						PIT	(NOLOCK)
		ON			CPI.IdTipoPrograma				=		PIT.Id
		AND			CPI.Activo						=		1
		AND			CPI.IdContrato					=		PIT.IdContrato
		AND			PIT.IdContrato					=		@IdContrato				
	JOIN
		CO_ProgramaImplementaPoliticas						PIP	(NOLOCK)
		ON			CPI.IdProgramaImplementa	=		PIP.IdProgramaImplementa
	JOIN
		CO_ProgramaImplementaElemento						PIE	(NOLOCK)
		ON			PIP.IdProgramaImplementaPolitica=		PIE.IdProgramaImplementaPolitica
	JOIN
		CO_ProgramaImplementaAcciones						PIA	(NOLOCK)
		ON			PIE.IdProgramaImplementaElemento	=		PIA.IdProgramaImplementaElemento
	LEFT JOIN
		CO_ProgramaImplementaDepartamentos					PID	(NOLOCK)
		ON			PIA.IdProgramaImplementaDepartamento	=		PID.IdProgramaImplementaDepartamento
	LEFT JOIN
		EN_ContratoEntregableProgramaImplementaAcciones		ENT_ACC	(NOLOCK)
		ON			PIA.IdProgramaImplementaAccion		=		ENT_ACC.IdProgramaImplementaAccion
		AND			ISNULL(ENT_ACC.Activo,1)			=		1
	LEFT JOIN
		EN_ContratoEntregable								CE		(NOLOCK)
		ON			ENT_ACC.IdContratoEntregable		=		CE.IdContratoEntregable
		AND			ISNULL(CE.Activo,1)					=		1
	LEFT JOIN	EN_InstanciasEntregable								IE		(NOLOCK)
		ON			CE.IdContratoEntregable				=		IE.IdContratoEntregable
		AND			ISNULL(IE.Activo,1)					=		1
	LEFT JOIN	EN_Entregable										E		(NOLOCK)
		ON			CE.IdEntregable						=		E.IdEntregable
		AND			ISNULL(E.IsActivo,1)				=		1
	LEFT JOIN	EN_Area												AR		(NOLOCK)
		ON			CE.IdArea							=		AR.idArea
	LEFT JOIN
		EN_Actividad	A
		ON	IE.ActividadID	=	A.ActividadID
	LEFT JOIN
		EN_Estado	EST
		ON	A.EstadoID	=	EST.EstadoID
	LEFT JOIN EN_HistorialAprobacionesLineaTiempo HALT
		ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
		AND HALT.idTipoOperacion	= 2
	LEFT JOIN
		AP_Usuario	U
		ON HALT.CreadoPor = U.UsuarioID
	where		PIT.IdContrato							=		@IdContrato
		and			CPI.IdProgramaImplementa			=		@IdProgramaImplementa
	ORDER BY	PIP.Descripcion, 
				PIE.Descripcion,
				Consecutivo
end

