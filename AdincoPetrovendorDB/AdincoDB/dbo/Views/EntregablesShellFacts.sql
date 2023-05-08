CREATE VIEW dbo.EntregablesShellFacts
AS
SELECT
	C.NumeroContrato	AS Contrato,
	ISNULL(CA.NombreArea,'') AS AreaBOM,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable)  	AS [NombreEntregable],
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
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) AS DiasAtraso,
	--CE.DiasElaboracion + CE.DiasRevision + CE.DiasAprobacion	AS DiasP,
	DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg)	AS DiasP,	--NVOS DIAS P PARA SHELL
	DATEDIFF(DAY,MAX(DV.CreadoEl),GETDATE())	AS DiasR,
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion) AS DiasReales,
	ISNULL(ML.MarcoLegal,'')	AS MarcoLegal,
	IE.FechaRealEntregaRegulador,
	IE.FechaCalculadaEntregaReg	AS	FechaEstimadaEntregaRegulador,
	IE.idInstanciaEntregable	AS ID,
	E.Articulo,
	ISNULL(ACT.NombreActividad,'')	AS	Actividad,
	ISNULL(PRO.Descripcion,'')	AS	Proceso,
	RE.ReceptorEntregable,
	CASE WHEN ROW_NUMBER() OVER(ORDER BY IA.idInstanciaActividad) % 2 = 0 THEN 1 ELSE -1 END	AS Orden,
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable) AS DeliverableName,
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal)	AS MarcoLegalIngles,
	ISNULL(I.NombreInstalacion,'')	AS Instalacion
FROM
	CO_Contrato	C	(NOLOCK)
JOIN
	CO_ContratoArea	CA	(NOLOCK)
	ON	C.IdContrato	=	CA.IdContrato
	AND	C.DescripcionContrato LIKE '%SHELL%'
JOIN
	EN_ContratoEntregable	CE	(NOLOCK)
	ON	C.IdContrato	=	CE.IdContrato
	AND	ISNULL(CE.Activo,1)	=	1
JOIN
	EN_InstanciasEntregable	IE (NOLOCK)
	ON	CE.IdContratoEntregable	=	IE.IdContratoEntregable
	AND	ISNULL(IE.Activo,1)	=	1
	AND IE.FechaCalculadaEntregaReg	<	DATEADD(YEAR,2,GETDATE())
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
	AND A.EstadoID = 10000
JOIN
	EN_Actividad	AACT	(NOLOCK)
	ON	IE.ActividadID	=	AACT.ActividadID
LEFT JOIN
	EN_ReceptorEntregable	RE	(NOLOCK)
	ON	E.IdReceptorEntregable	=	RE.IdReceptorEntregable
LEFT JOIN
	EN_MarcoLegal	ML	(NOLOCK)
	ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
LEFT JOIN
	EN_HistorialAprobacionesLineaTiempo	HALT	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
	AND HALT.idTipoOperacion = 2
LEFT JOIN
	AP_Usuario	U	(NOLOCK)
	ON	A.idUsuario	=	U.UsuarioID
LEFT JOIN
	AP_USUARIO FP	(NOLOCK)	-- OBTENER NOMBRE DEL FOCAL POINT
	ON	CE.FocalPoint	=	FP.Usuario
LEFT JOIN
	AP_USUARIO AC	(NOLOCK)	-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
	ON	CE.AccountableCompliance	=	AC.Usuario
LEFT JOIN
	AP_USUARIO ACC	(NOLOCK)	-- OBTENER EL NOMBRE DEL ACCOUNTABLE
	ON	CE.Accountable	=	ACC.Usuario
LEFT JOIN
	EN_DocumentoVersion	DV	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
LEFT JOIN
	EN_InstanciasEntregables_InstanciaActividad	IEIA	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
LEFT JOIN
	EN_InstanciasActividades IA	(NOLOCK)
	ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
LEFT JOIN
	EN_Actividades ACT	(NOLOCK)
	ON	IA.IdActividad	=	ACT.IdActividad
LEFT JOIN
	EN_InstanciasProcesosFecha IPF	(NOLOCK)
	ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
LEFT JOIN
	EN_Procesos PRO	(NOLOCK)
	ON	IPF.IdProceso	=	PRO.IdProceso
LEFT JOIN
	CO_Instalacion	I	(NOLOCK)
	ON	PRO.IdInstalacion	=	I.IdInstalacion
WHERE
	IE.FechaCalculadaEntregaReg	<=	'20240131'
	AND
	IE.FechaCalculadaEntregaReg	IS NOT NULL
GROUP BY
	C.NumeroContrato,
	ISNULL(CA.NombreArea,''),
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable),
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
	ACT.NombreActividad,
	PRO.Descripcion,
	RE.ReceptorEntregable,
	IA.idInstanciaActividad,
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable),
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal),
	ISNULL(I.NombreInstalacion,'')