CREATE VIEW dbo.EntregablesFacts
AS
SELECT
	C.NumeroContrato	AS Contrato,
	IE.idInstanciaEntregable AS ID,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable)  	AS [NombreEntregable],
	AR.NombreArea,
	IE.FechaInicioElaboracion	AS [FechaIniProg],
	IE.FechasLimiteAprobacion	AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	U.Nombre	AS Usuario,
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
	ISNULL(ACT.NombreActividad,'')	AS	Actividad,
	ISNULL(PRO.Descripcion,'')	AS	Proceso
FROM
	EN_InstanciasEntregable	IE (NOLOCK)
JOIN
	EN_ContratoEntregable	CE	(NOLOCK)
	ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
	AND	ISNULL(IE.Activo,1)	=	1
	AND	ISNULL(CE.Activo,1)	=	1
JOIN
	CO_Contrato	C	(NOLOCK)
	ON	CE.IdContrato	=	C.IdContrato
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
LEFT JOIN
	EN_HistorialAprobacionesLineaTiempo	HALT	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
	AND HALT.idTipoOperacion = 2
LEFT JOIN
	AP_Usuario	U
	ON	A.idUsuario	=	U.UsuarioID
LEFT JOIN
	EN_DocumentoVersion	DV
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
WHERE
	IE.FechasLimiteAprobacion	<	DATEADD(YEAR,2,GETDATE())
--	AND 	AACT.EstadoID NOT IN (10003)
	AND
	IE.FechaCalculadaEntregaReg	IS NOT NULL
GROUP BY
	C.NumeroContrato,
	IE.idInstanciaEntregable,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable),
	AR.NombreArea,
	IE.FechasLimiteAprobacion,
	IE.FechaInicioElaboracion,
	A.EstadoID,
	U.Nombre,
	AACT.EstadoID,
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	ISNULL(ACT.NombreActividad,''),
	ISNULL(PRO.Descripcion,'')

