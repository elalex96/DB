
CREATE VIEW [dbo].[SASISOPAFacts]
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
	ISNULL(PIA.Porcentaje,0) AS AvanceProgramado,
	CASE WHEN AACT.EstadoID = 10000 THEN 0
		WHEN AACT.EstadoID = 10001 THEN 0
		WHEN AACT.EstadoID = 10002 THEN 0
		WHEN AACT.EstadoID IS NULL THEN 0
		ELSE 1
	END AS AvanceReal, 
	IE.FechaInicioElaboracion	AS [FechaIniProg],
	IE.FechasLimiteAprobacion	AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	ISNULL(U.Nombre,'')		AS Usuario,
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END			AS Rol,
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
	CASE WHEN FP.Nombre IS NULL THEN ''
		ELSE ISNULL(FP.Nombre,'')
	END		AS FocalPoint,
	ISNULL(CE.FocalPoint,'')	AS	FocalPointEmail,
	CASE WHEN AC.Nombre IS NULL THEN ''
		ELSE ISNULL(AC.Nombre,'')
	END		AS AccountableCompliance,
	ISNULL(CE.AccountableCompliance,'')	AS AccountableComplianceEmail,
	CASE WHEN ACC.Nombre IS NULL THEN ''
		ELSE ISNULL(ACC.Nombre,'')
	END		AS Accountable,
	ISNULL(CE.Accountable,'')	 AS	AccountableEmail,
	ISNULL(U.Nombre,'')		AS Responsible,
	U.Usuario		AS	ResponsibleEmail,
	IE.idInstanciaEntregable	AS ID
FROM
	CO_ProgramaImplementa	CPI
JOIN
	CO_ProgramaImplementacionTipo	PIT
	ON	CPI.IdTipoPrograma = PIT.Id
	AND CPI.Activo	=	1
	AND CPI.IdContrato	=	PIT.IdContrato
JOIN
	CO_ProgramaImplementaPoliticas	PIP
	ON	CPI.IdProgramaImplementa	=	PIP.IdProgramaImplementa
JOIN
	CO_ProgramaImplementaElemento	PIE
	ON	PIP.IdProgramaImplementaPolitica = PIE.IdProgramaImplementaPolitica
JOIN
	CO_ProgramaImplementaAcciones	PIA
	ON	PIE.IdProgramaImplementaElemento = PIA.IdProgramaImplementaElemento
JOIN
	CO_ProgramaImplementaDepartamentos	PID
	ON	PIA.IdProgramaImplementaDepartamento = PID.IdProgramaImplementaDepartamento
JOIN
	CO_Contrato	C	(NOLOCK)
	ON	CPI.IdContrato	=	C.IdContrato
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
	AND A.EstadoID <> 10003
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
LEFT JOIN
	AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
	ON	CE.FocalPoint	=	FP.Usuario
LEFT JOIN
	AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
	ON	CE.AccountableCompliance	=	AC.Usuario
LEFT JOIN
	AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
	ON	CE.Accountable	=	ACC.Usuario
WHERE
--	PIT.IdContrato	=	3
--	AND
--	IE.FechasLimiteAprobacion	<	DATEADD(MONTH,1,GETDATE())
	--AND AACT.EstadoID NOT IN (10003)
--	AND
	IE.FechaCalculadaEntregaReg	IS NOT NULL
GROUP BY
	C.NumeroContrato,
	PIA.FechaInicioPrimeraAccion, PIA.FechaFinPrimeraAccion, PIP.Descripcion, PIE.Descripcion, 
	CASE WHEN IE.idInstanciaEntregable IS NULL THEN PIA.Descripcion
	ELSE PIA.Descripcion + '-' + LTRIM(ISNULL(IE.idInstanciaEntregable,'')) 
	END, 
	PID.Descripcion, PIA.Porcentaje,
	CASE WHEN AACT.EstadoID = 10000 THEN 0
		WHEN AACT.EstadoID = 10001 THEN 0
		WHEN AACT.EstadoID = 10002 THEN 0
		WHEN AACT.EstadoID IS NULL THEN 0
		ELSE 1
	END,
	IE.FechaInicioElaboracion,
	IE.FechasLimiteAprobacion,
	ISNULL(U.Nombre,''),
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END,
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
	CASE WHEN FP.Nombre IS NULL THEN ''
		ELSE ISNULL(FP.Nombre,'')
	END,
	ISNULL(CE.FocalPoint,''),
	CASE WHEN AC.Nombre IS NULL THEN ''
		ELSE ISNULL(AC.Nombre,'')
	END,
	ISNULL(CE.AccountableCompliance,''),
	CASE WHEN ACC.Nombre IS NULL THEN ''
		ELSE ISNULL(ACC.Nombre,'')
	END,
	ISNULL(CE.Accountable,''),
	ISNULL(U.Nombre,''),
	U.Usuario,
	IE.idInstanciaEntregable
