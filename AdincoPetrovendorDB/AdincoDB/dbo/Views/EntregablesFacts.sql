CREATE VIEW dbo.EntregablesFacts
AS
SELECT
	C.NumeroContrato	AS Contrato,
	--ROW_NUMBER() OVER(PARTITION BY IE.idInstanciaEntregable ORDER BY IE.idInstanciaEntregable,A.EstadoID) AS RowNo, 
	--DATEFROMPARTS(YEAR(IE.FechaCalculadaEntregaReg),MONTH(IE.FechaCalculadaEntregaReg),1) AS Mes,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable)  	AS [NombreEntregable],
	AR.NombreArea,
	IE.FechaInicioElaboracion	AS [FechaIniProg],
	IE.FechasLimiteAprobacion	AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	--CE.IdContratoEntregable,
	--IE.FechasLimiteElaboracion,
	--IE.FechasLimiteRevision,
	--IE.FechaEnvioMensajeAtrasoRevision,
	--IE.FechaCalculadaEntregaReg,
	--IE.FechaRealEntregaRegulador,
	--A.ActividadID,
	--A.idUsuario AS Usuario,
	U.Nombre	AS Usuario,
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END			AS Rol,
	--dbo.fnGetAprobadoresEntregable(CE.IdContratoEntregable)	AS Aprobador,
	--dbo.fnGetElaboradoresEntregable(CE.IdContratoEntregable)	AS Elaborador,
	--dbo.fnGetRevisoresEntregable(CE.IdContratoEntregable)	AS Revisor,
--	CE.IdEntregable,
	--AACT.EstadoID AS Estatus,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
	END		AS [Status],
	--CE.IdArea	AS idArea,
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) AS DiasAtraso,
	--DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechasLimiteAprobacion)		AS DiasP,
	CE.DiasElaboracion + CE.DiasRevision + CE.DiasAprobacion	AS DiasP,
	--CASE WHEN IE.FechaInicioElaboracion > GETDATE() THEN 0
	--	ELSE DATEDIFF(DAY, IE.FechaInicioElaboracion, ISNULL(MAX(HALT.CreadoEn),GETDATE()))
	--END		AS DiasAtraso,

	--CASE WHEN AACT.EstadoID = 10002
		--THEN 
	DATEDIFF(DAY,MAX(DV.CreadoEl),GETDATE())	AS DiasR,
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion) AS DiasReales
		--ELSE	DATEDIFF(DAY,MAX(DV.CreadoEl),ISNULL(MAX(HALTR.CreadoEn),MAX(HALT.CreadoEn)))
	--END		AS DiasR
	--CASE WHEN A.EstadoID = 10000 THEN 1 ELSE 0 END AS CANTIDAD
	--CONVERT(BIT,CASE WHEN AACT.EstadoID > 10000 THEN 1 ELSE 0 END)	AS Elaborado,
	--CONVERT(BIT,CASE WHEN AACT.EstadoID > 10001 THEN 1 ELSE 0 END)	AS Revisado,
	--CONVERT(BIT,CASE WHEN AACT.EstadoID > 10002 THEN 1 ELSE 0 END)	AS Aprobado
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
--LEFT JOIN
--	EN_HistorialAprobacionesLineaTiempo	HALTR	(NOLOCK)
--	ON	IE.idInstanciaEntregable	=	HALTR.idInstanciaEntregable
--	AND HALTR.idTipoOperacion = 3
LEFT JOIN
	EN_DocumentoVersion	DV
	ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
WHERE
	IE.FechasLimiteAprobacion	<	DATEADD(YEAR,2,GETDATE())
	AND
	AACT.EstadoID NOT IN (10003)
	AND
	IE.FechaCalculadaEntregaReg	IS NOT NULL
GROUP BY
	C.NumeroContrato,
	--DATEFROMPARTS(YEAR(IE.FechaCalculadaEntregaReg),MONTH(IE.FechaCalculadaEntregaReg),1),
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable),
	AR.NombreArea,
	--IE.idInstanciaEntregable,
	--CE.IdContratoEntregable,
	--IE.FechasLimiteElaboracion,
	--IE.FechasLimiteRevision,
	IE.FechasLimiteAprobacion,
	--IE.FechaEnvioMensajeAtrasoRevision,
	--IE.FechaCalculadaEntregaReg,
	IE.FechaInicioElaboracion,
	--IE.FechaRealEntregaRegulador,
	--A.ActividadID,
	A.EstadoID,
	--A.idUsuario,
	U.Nombre,
	--CE.IdEntregable,
	AACT.EstadoID,
	--CE.IdArea,
	CE.DiasElaboracion,
	CE.DiasRevision,
	CE.DiasAprobacion,
	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion)
	--CASE WHEN A.EstadoID = 10000 THEN 1 ELSE 0 END
