CREATE VIEW dbo.JOA_MXFacts
AS
SELECT
	C.NumeroContrato	AS Contrato,
	''					 AS AreaBOM,
	CLA.NombreClasificacion AS	Category,
	COA.NombreContratista	AS COOWNER,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable)  	AS [NombreObligacion],
	AR.NombreArea AS Funcion,
	U.Nombre	AS Usuario,
	U.Usuario	AS CorreoUsuario,
	'Responsible'			AS Rol,
	CASE 
		WHEN AACT.EstadoID = 10003 THEN 'Confirmado'
		ELSE 'Por Confirmar'
	END		AS [Status],
	CASE WHEN AC.Nombre IS NULL THEN ''
		ELSE ISNULL(AC.Nombre,'')
	END		AS AccountableCompliance,
	ISNULL(CE.AccountableCompliance,'')	AS AccountableComplianceEmail,
	CASE WHEN ACC.Nombre IS NULL THEN ''
		ELSE ISNULL(ACC.Nombre,'')
	END		AS Accountable,
	ISNULL(CE.Accountable,'')	 AS	AccountableEmail,
	CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) <= 0 THEN 0
		ELSE 		DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE())
	END AS DiasAtraso,
	ISNULL(ML.MarcoLegal,'')	AS ContractName,
	IE.FechaCalculadaEntregaReg	AS	Deadline,
	HALT.CreadoEn				AS FechaConfirmacion,
	IE.idInstanciaEntregable	AS ID,
	E.Apartado AS Topic,
	E.Inciso AS Clause,
	E.Articulo,
	ISNULL(ACT.NombreActividad,'')	AS	Actividad,
	ISNULL(PRO.Descripcion,'')	AS	Proceso,
	CASE WHEN ROW_NUMBER() OVER(ORDER BY IA.idInstanciaActividad) % 2 = 0 THEN 1 ELSE -1 END	AS Orden,
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable) AS DeliverableName
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
	CO_ContratoSocio	CS
	ON CE.IdContrato	=	CS.IdContrato
JOIN 
	CO_Contratista	COA
	ON CS.IdContratistaSocio	=	COA.IdContratista
JOIN
	EN_Entregable	E	(NOLOCK)
	ON	CE.IdEntregable	=	E.IdEntregable
	AND	ISNULL(E.IsActivo,1)	=	1
	AND E.BITJOA = 1
JOIN
	EN_Area		AR	(NOLOCK)
	ON	CE.IdArea	=	AR.idArea
JOIN
	EN_Actividad	A	(NOLOCK)
	ON	CE.IdContratoEntregable	=	A.IdContratoEntregable
	AND A.EstadoID = 10000
JOIN
	AP_Usuario	U	(NOLOCK)
	ON	A.idUsuario	=	U.UsuarioID
JOIN
	EN_Actividad	AACT	(NOLOCK)
	ON	IE.ActividadID	=	AACT.ActividadID
JOIN
	En_Clasificacion	CLA
	ON E.IdClasificacion	=	CLA.IdClasificacion
LEFT JOIN
	EN_MarcoLegal	ML	(NOLOCK)
	ON	E.IdMarcoLegal	=	ML.IdMarcoLegal
LEFT JOIN
	EN_HistorialAprobacionesLineaTiempo	HALT	(NOLOCK)
	ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
	AND HALT.idTipoOperacion = 2
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
WHERE
	IE.FechaCalculadaEntregaReg	<	DATEADD(YEAR,2,GETDATE())
	AND
	IE.FechaCalculadaEntregaReg	IS NOT NULL
	AND
	C.IdContrato = 3
GROUP BY
	C.NumeroContrato,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable),
	CLA.NombreClasificacion,
	COA.NombreContratista,
	AR.NombreArea,
	U.Nombre,
	U.Usuario,
	CASE 
		WHEN AACT.EstadoID = 10003 THEN 'Confirmado'
		ELSE 'Por Confirmar'
	END,
	CASE WHEN AC.Nombre IS NULL THEN ''
		ELSE ISNULL(AC.Nombre,'')
	END,
	ISNULL(CE.AccountableCompliance,''),
	CASE WHEN ACC.Nombre IS NULL THEN ''
		ELSE ISNULL(ACC.Nombre,'')
	END,
	ISNULL(CE.Accountable,''),
	CASE WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) <= 0 THEN 0
		ELSE 	DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE())
	END,
	ISNULL(ML.MarcoLegal,''),
	IE.FechaCalculadaEntregaReg,
	HALT.CreadoEn,
	IE.idInstanciaEntregable,
	E.Articulo,
	E.Apartado ,
	E.Inciso ,
	ACT.NombreActividad,
	PRO.Descripcion,
	IA.idInstanciaActividad,
	ISNULL(E.DeliverableName,E.DocumentoEntregable) + '-' + LTRIM(IE.idInstanciaEntregable)

