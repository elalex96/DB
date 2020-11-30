CREATE VIEW [dbo].[Entregables_BP_Facts]
AS
SELECT
	C.NumeroContrato	AS Contrato,
	ISNULL(CA.NombreArea,'') AS AreaBOM,
	E.DocumentoEntregable + '-' + LTRIM(ISNULL(IE.idInstanciaEntregable,0))  	AS [NombreEntregable],
	AR.NombreArea AS Funcion,
	ISNULL(CE.Subfuncion,'') AS Subfuncion,
	IE.FechaInicioElaboracion	AS [FechaIniProg],
	IE.FechasLimiteAprobacion	AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	U.Nombre	AS Usuario,
	U.Usuario	AS CorreoUsuario,
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END			AS Rol,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END		AS [Status],
	CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
		ELSE ISNULL(FP.Nombre,'')
	END		AS FocalPoint,
	ISNULL(CE.FocalPoint,'')	AS	FocalPointEmail,	-- ELABORADOR INTERNO
	CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
		ELSE ISNULL(AC.Nombre,'')
	END		AS AccountableCompliance,
	ISNULL(CE.AccountableCompliance,'')	AS AccountableComplianceEmail,
	CASE WHEN ACC.Nombre IS NULL THEN ''
		ELSE ISNULL(ACC.Nombre,'')
	END		AS Accountable,
	ISNULL(CE.Accountable,'')	 AS	AccountableEmail,
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) AS DiasAtraso,
	DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg)	AS DiasP,	--NVOS DIAS P PARA SHELL
	DATEDIFF(DAY,MAX(DV.CreadoEl),GETDATE())	AS DiasR,
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion) AS DiasReales,
	ISNULL(ML.MarcoLegal,'')	AS MarcoLegal,
	IE.FechaRealEntregaRegulador,
	IE.FechaCalculadaEntregaReg	AS	FechaEstimadaEntregaRegulador,
	IE.idInstanciaEntregable	AS ID,
	E.Articulo,
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable) AS DeliverableName,
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal)	AS MarcoLegalIngles
FROM
	EN_InstanciasEntregable	IE (NOLOCK)
JOIN
	EN_ContratoEntregable	CE	(NOLOCK)
	ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	AND	ISNULL(IE.Activo,1)	=	1
	AND	ISNULL(CE.Activo,1)	=	1
	AND IE.FechasLimiteAprobacion	<	DATEADD(YEAR,2,GETDATE())
	AND	IE.FechaCalculadaEntregaReg	IS NOT NULL
JOIN
	CO_Contrato	C	(NOLOCK)
	ON	CE.IdContrato	=	C.IdContrato
JOIN
	CO_Contratista	CO
	ON	C.IdContratista	=	CO.IdContratista
	AND CO.NombreContratista LIKE '%BP%'
JOIN
	EN_Entregable	E	(NOLOCK)
	ON	CE.IdEntregable	=	E.IdEntregable
	AND	ISNULL(E.IsActivo,1)	=	1
	AND E.BITJOA = 0
LEFT JOIN
	CO_ContratoArea	CA
	ON	C.IdContrato	=	CA.IdContrato
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
LEFT JOIN
	EN_MarcoLegal	ML
	ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
LEFT JOIN
	EN_HistorialAprobacionesLineaTiempo	HALT	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
	AND HALT.idTipoOperacion = 2
LEFT JOIN
	AP_Usuario	U
	ON	A.idUsuario	=	U.UsuarioID
LEFT JOIN
	AP_USUARIO FP		-- OBTENER NOMBRE DEL ELABORADOR INTERNO
	ON	CE.FocalPoint	=	FP.Usuario
LEFT JOIN
	AP_USUARIO AC		-- OBTENER EL NOMBRE DEL Lider del área
	ON	CE.AccountableCompliance	=	AC.Usuario
LEFT JOIN
	AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
	ON	CE.Accountable	=	ACC.Usuario
LEFT JOIN
	EN_DocumentoVersion	DV
	ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
WHERE
	IE.Activo =  1
GROUP BY
	C.NumeroContrato,
	ISNULL(CA.NombreArea,''),
	E.DocumentoEntregable + '-' + LTRIM(ISNULL(IE.idInstanciaEntregable,0)),
	AR.NombreArea,
	ISNULL(CE.Subfuncion,''),
	IE.FechaInicioElaboracion,
	IE.FechasLimiteAprobacion,
	U.Nombre,
	U.Usuario,
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END,
	CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
		ELSE ISNULL(FP.Nombre,'')
	END,
	ISNULL(CE.FocalPoint,''),
	CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
		ELSE ISNULL(AC.Nombre,'')
	END,
	ISNULL(CE.AccountableCompliance,''),
	CASE WHEN ACC.Nombre IS NULL THEN ''
		ELSE ISNULL(ACC.Nombre,'')
	END,
	ISNULL(CE.Accountable,''),
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()),
	--CE.DiasElaboracion + CE.DiasRevision + CE.DiasAprobacion,
	DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	ISNULL(ML.MarcoLegal,''),
	IE.FechaRealEntregaRegulador,
	IE.FechaCalculadaEntregaReg,
	IE.idInstanciaEntregable,
	E.Articulo,
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable),
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal)
