CREATE VIEW dbo.EntregablesCarsoFacts
AS
SELECT
	C.NumeroContrato	AS Contrato,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable)  	AS [NombreEntregable],
	AR.NombreArea AS Area,
	IE.FechaInicioElaboracion	AS [FechaIniProg],
	IE.FechasLimiteAprobacion	AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	U.Nombre	AS Usuario,
	U.Usuario	AS CorreoUsuario,
	'Elaborador'	AS Rol,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END		AS [Status],
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
	ISNULL(ACT.NombreActividad,'')	AS	Actividad,
	ISNULL(PRO.Descripcion,'')	AS	Proceso,
	RE.ReceptorEntregable,
	CASE WHEN ROW_NUMBER() OVER(ORDER BY IA.idInstanciaActividad) % 2 = 0 THEN 1 ELSE -1 END	AS Orden,
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable) AS DeliverableName,
	ISNULL(ML.MarcoLegalIngles,ML.MarcoLegal)	AS MarcoLegalIngles,
	ISNULL(I.NombreInstalacion,'')	AS Instalacion,
	dbo.fnGetRevisoresEntregable(CE.IdContratoEntregable)	AS	Revisor,
	dbo.fnGetAprobadoresEntregable(CE.IdContratoEntregable)	AS	Aprobador
FROM
	EN_InstanciasEntregable	IE (NOLOCK)
JOIN
	EN_ContratoEntregable	CE	(NOLOCK)
	ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	AND	ISNULL(IE.Activo,1)	=	1
	AND	ISNULL(CE.Activo,1)	=	1
	AND	IE.FechaCalculadaEntregaReg	<	DATEADD(YEAR,2,GETDATE())
JOIN
	CO_Contrato	C	(NOLOCK)
	ON	CE.IdContrato	=	C.IdContrato
	AND	C.DescripcionContrato LIKE '%BLOQUE%'
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
	IE.FechaCalculadaEntregaReg	IS NOT NULL
GROUP BY
	C.NumeroContrato,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable),
	AR.NombreArea,
	IE.FechaInicioElaboracion,
	IE.FechasLimiteAprobacion,
	U.Nombre,
	U.Usuario,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END,
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()),
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
	ISNULL(I.NombreInstalacion,''),
	CE.IdContratoEntregable

