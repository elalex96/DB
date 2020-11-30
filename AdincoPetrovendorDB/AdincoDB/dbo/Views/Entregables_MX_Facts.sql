CREATE VIEW dbo.Entregables_MX_Facts
AS
SELECT
	C.NumeroContrato	AS Contrato,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable)  	AS [NombreEntregable],
	AR.NombreArea,
	IE.FechaInicioElaboracion	AS [FechaIniProg],
	IE.FechasLimiteAprobacion	AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	U.Nombre	AS Usuario,
	U.Usuario	AS Correo,
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END			AS Rol,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
	END		AS [Status],
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) AS DiasAtraso,
	CE.DiasElaboracion + CE.DiasRevision + CE.DiasAprobacion	AS DiasP,
	DATEDIFF(DAY,MAX(DV.CreadoEl),GETDATE())	AS DiasR,
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion) AS DiasReales,
	ISNULL(IE.FechaCalculadaEntregaReg,'')	AS FechaCalculadaEntregaReg,
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
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable) AS DeliverableName,
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal)	AS MarcoLegalIngles
FROM
	EN_InstanciasEntregable	IE (NOLOCK)
JOIN
	EN_ContratoEntregable	CE	(NOLOCK)
	ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	AND	ISNULL(IE.Activo,1)	=	1
	AND	ISNULL(CE.Activo,1)	=	1
	AND	IE.FechaCalculadaEntregaReg	IS NOT NULL
JOIN
	CO_Contrato	C	(NOLOCK)
	ON	CE.IdContrato	=	C.IdContrato
	AND	C.IdContrato = 3
JOIN
	CO_Contratista	CA
	ON	C.IdContratista	=	CA.IdContratista
JOIN
	EN_Entregable	E	(NOLOCK)
	ON	CE.IdEntregable	=	E.IdEntregable
	AND	ISNULL(E.IsActivo,1)	=	1
	AND E.BITJOA = 0
JOIN
	EN_Area		AR	(NOLOCK)
	ON	CE.IdArea	=	AR.idArea
JOIN
	EN_Actividad	A	(NOLOCK)
	ON	CE.IdContratoEntregable	=	A.IdContratoEntregable
	AND A.EstadoID <> 10003
JOIN
	EN_Actividad	AACT	(NOLOCK)
	ON	IE.ActividadID	=	AACT.ActividadID
	AND	AACT.EstadoID NOT IN (10003)
LEFT JOIN
	EN_MarcoLegal	ML	(NOLOCK)
	ON	E.IdMarcoLegal = ML.IdMarcoLegal
LEFT JOIN
	EN_HistorialAprobacionesLineaTiempo	HALT	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
	AND HALT.idTipoOperacion = 2
LEFT JOIN
	AP_Usuario	U	(NOLOCK)
	ON	A.idUsuario	=	U.UsuarioID
LEFT JOIN
	EN_DocumentoVersion	DV	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
LEFT JOIN
	AP_USUARIO FP		(NOLOCK)-- OBTENER NOMBRE DEL FOCAL POINT
	ON	CE.FocalPoint	=	FP.Usuario
LEFT JOIN
	AP_USUARIO AC		(NOLOCK)-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
	ON	CE.AccountableCompliance	=	AC.Usuario
LEFT JOIN
	AP_USUARIO ACC		(NOLOCK)-- OBTENER EL NOMBRE DEL ACCOUNTABLE
	ON	CE.Accountable	=	ACC.Usuario
WHERE
	IE.FechasLimiteAprobacion	<	DATEADD(YEAR,2,GETDATE())
GROUP BY
	C.NumeroContrato,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable),
	AR.NombreArea,
	IE.FechasLimiteAprobacion,
	IE.FechaInicioElaboracion,
	A.EstadoID,
	U.Nombre,
	U.Usuario,
	AACT.EstadoID,
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	ISNULL(IE.FechaCalculadaEntregaReg,''),
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
		ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable),
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal)
