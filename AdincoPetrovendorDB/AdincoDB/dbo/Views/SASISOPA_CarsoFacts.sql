CREATE VIEW dbo.SASISOPA_CarsoFacts
AS

SELECT
	C.NumeroContrato	AS Contrato,
	PIA.FechaInicioPrimeraAccion, 
	PIA.FechaFinPrimeraAccion, 
	PIP.Descripcion AS Politica, 
	PIE.Descripcion AS Elemento, 
	CASE WHEN IE.idInstanciaEntregable IS NULL THEN PIA.Descripcion
		ELSE PIA.Descripcion + '-' + LTRIM(ISNULL(IE.idInstanciaEntregable,'')) 
	END		AS Accion,
	PID.Descripcion AS Responsables,
	ISNULL(PIA.Porcentaje,0)/dbo.fnGetCantidadInstancias(CE.IdContratoEntregable) AS AvanceProgramado,
	CASE WHEN AACT.EstadoID = 10000 THEN 0
		WHEN AACT.EstadoID = 10001 THEN 0
		WHEN AACT.EstadoID = 10002 THEN 0
		WHEN AACT.EstadoID IS NULL THEN 0
		ELSE ISNULL(PIA.Porcentaje,0)/dbo.fnGetCantidadInstancias(CE.IdContratoEntregable)
	END AS AvanceReal, 
	IE.FechaInicioElaboracion	AS [FechaIniProg],
	IE.FechasLimiteAprobacion	AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	ISNULL(U.Nombre,'')		AS Usuario,
	'Elaborador'			AS Rol,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END		AS [Status],
	ISNULL(CE.DiasElaboracion,0) AS DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) AS DiasAtraso,
	CE.DiasElaboracion + CE.DiasRevision + CE.DiasAprobacion	AS DiasP,
	DATEDIFF(DAY,MAX(DV.CreadoEl),GETDATE())	AS DiasR,
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion) AS DiasReales,
	ISNULL(AR.NombreArea,'') As Area,
	PIT.Descripcion	AS NombrePrograma,
	IE.FechaRealEntregaRegulador,
	IE.FechaCalculadaEntregaReg	AS	FechaEstimadaEntregaRegulador,
	CASE WHEN AACT.EstadoID = 10003 AND MAX(FINR.CreadoEn) <= IE.FechaCalculadaEntregaReg THEN 'Delivered'
	WHEN AACT.EstadoID = 10003 AND MAX(FINR.CreadoEn) > IE.FechaCalculadaEntregaReg THEN 'Delayed'
	WHEN IE.FechaCalculadaEntregaReg < GETDATE() AND AACT.EstadoID <> 10003 THEN 'Delayed'
	ELSE 'To Deliver'
	END	AS EstatusColor,
	ISNULL(U.Nombre,'')		AS Elaborador,
	U.Usuario		AS	ElaboradorEmail,
	IE.idInstanciaEntregable	AS ID,
	dbo.fnGetRevisoresEntregable(CE.IdContratoEntregable)	AS	Revisor,
	dbo.fnGetAprobadoresEntregable(CE.IdContratoEntregable)	AS Aprobador
FROM
	CO_ProgramaImplementa	CPI	(NOLOCK)
JOIN
	CO_ProgramaImplementacionTipo	PIT	(NOLOCK)
	ON	CPI.IdTipoPrograma = PIT.Id
	AND CPI.Activo	=	1
	AND CPI.IdContrato	=	PIT.IdContrato
JOIN
	CO_Contrato	C	(NOLOCK)
	ON	CPI.IdContrato	=	C.IdContrato
JOIN
	CO_Contratista	COA	(NOLOCK)
	ON	C.IdContratista	=	COA.IdContratista
	AND COA.NombreContratista	LIKE '%BLOQUE%'
JOIN
	CO_ProgramaImplementaPoliticas	PIP	(NOLOCK)
	ON	CPI.IdProgramaImplementa	=	PIP.IdProgramaImplementa
JOIN
	CO_ProgramaImplementaElemento	PIE	(NOLOCK)
	ON	PIP.IdProgramaImplementaPolitica = PIE.IdProgramaImplementaPolitica
JOIN
	CO_ProgramaImplementaAcciones	PIA	(NOLOCK)
	ON	PIE.IdProgramaImplementaElemento = PIA.IdProgramaImplementaElemento
JOIN
	CO_ProgramaImplementaDepartamentos	PID	(NOLOCK)
	ON	PIA.IdProgramaImplementaDepartamento = PID.IdProgramaImplementaDepartamento
JOIN
	EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC	(NOLOCK)
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
LEFT JOIN
	EN_InstanciasEntregable	IE (NOLOCK)
	ON	CE.IdContratoEntregable = IE.IdContratoEntregable
	AND	ISNULL(IE.Activo,1)	=	1
LEFT JOIN
	EN_Area		AR	(NOLOCK)
	ON	CE.IdArea	=	AR.idArea
LEFT JOIN
	EN_Actividad	A	(NOLOCK)
	ON	CE.IdContratoEntregable	=	A.IdContratoEntregable
	AND A.EstadoID = 10000
LEFT JOIN
	EN_Actividad	AACT	(NOLOCK)
	ON	IE.ActividadID	=	AACT.ActividadID
	AND AACT.Activo = 1
LEFT JOIN
	EN_HistorialAprobacionesLineaTiempo	HALT	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
	AND HALT.idTipoOperacion = 2
LEFT JOIN
	EN_HistorialAprobacionesLineaTiempo	FINR	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	FINR.idInstanciaEntregable
	AND FINR.idTipoOperacion = 4
LEFT JOIN
	AP_Usuario	U
	ON	A.idUsuario	=	U.UsuarioID
LEFT JOIN
	EN_DocumentoVersion	DV
	ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
WHERE
	IE.FechaCalculadaEntregaReg	IS NOT NULL
GROUP BY
	C.NumeroContrato,
	PIA.FechaInicioPrimeraAccion, PIA.FechaFinPrimeraAccion, PIP.Descripcion, PIE.Descripcion, 
	CASE WHEN IE.idInstanciaEntregable IS NULL THEN PIA.Descripcion
	ELSE PIA.Descripcion + '-' + LTRIM(ISNULL(IE.idInstanciaEntregable,'')) 
	END, 
	PID.Descripcion, 
	ISNULL(PIA.Porcentaje,0)/dbo.fnGetCantidadInstancias(CE.IdContratoEntregable),
	CASE WHEN AACT.EstadoID = 10000 THEN 0
		WHEN AACT.EstadoID = 10001 THEN 0
		WHEN AACT.EstadoID = 10002 THEN 0
		WHEN AACT.EstadoID IS NULL THEN 0
		ELSE ISNULL(PIA.Porcentaje,0)/dbo.fnGetCantidadInstancias(CE.IdContratoEntregable)
	END, 
	IE.FechaInicioElaboracion,
	IE.FechasLimiteAprobacion,
	ISNULL(U.Nombre,''),
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END,
	ISNULL(CE.DiasElaboracion,0),
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()),
	CE.DiasElaboracion + CE.DiasRevision + CE.DiasAprobacion,
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	ISNULL(AR.NombreArea,''),
	PIT.Descripcion,
	IE.FechaRealEntregaRegulador,
	IE.FechaCalculadaEntregaReg,
	AACT.EstadoID,
	ISNULL(U.Nombre,''),
	U.Usuario,
	IE.idInstanciaEntregable,
	CE.IdContratoEntregable