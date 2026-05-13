CREATE  PROCEDURE [dbo].[sp_EN_TableroEntregables]--3,10061
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 
-- Description:	
-- =============================================
SET NOCOUNT ON

CREATE TABLE #Detalle
(
	Contrato		VARCHAR(70),
	AreaBOM			VARCHAR(70),
	NombreEntregable	VARCHAR(1500),
	Funcion			VARCHAR(70),
	Subfuncion		VARCHAR(70),
	FechaIniProg	DATE,
	FechaFinProg	DATE,
	FechaIniReal	DATE,
	Usuario			VARCHAR(250),
	CorreoUsuario	VARCHAR(250),
	Rol				VARCHAR(70),
	Status			VARCHAR(70),
	FocalPoint		VARCHAR(250),
	FocalPointEmail	VARCHAR(250),
	AccountableCompliance	VARCHAR(250),
	AccountableComplianceEmail	VARCHAR(250),
	Accountable		VARCHAR(250),
	AccountableEmail	VARCHAR(250),
	DiasElaboracion		INT,
	DiasRevision		INT,
	DiasAprobacion		INT,
	DiasAtraso			INT,
	DiasP				INT,
	DiasR				INT,
	DiasReales			INT,
	MarcoLegal			VARCHAR(1000),
	FechaRealEntregaRegulador	DATE,
	FechaEstimadaEntregaRegulador	DATE,
	ID					INT,
	Articulo			VARCHAR(6000),
	Anio				INT,
	Mes					VARCHAR(70),
	EstatusParaColor	VARCHAR(150),
	Color				INT,
	PRIMARY KEY (ID)
);
DECLARE @IsAdmin	INT	=	0,
	@IdContratista	INT

	SELECT	@IdContratista = IdContratista
	FROM CO_Contrato
	WHERE IdContrato	=	@idContrato

    SELECT @IsAdmin = COUNT(1)
    FROM dbo.AP_PerfilUsuario PU
    JOIN 
		dbo.AP_Perfil P 
		ON PU.PerfilID = P.IdPerfil
    JOIN 
		dbo.AP_Rol R 
		ON P.IdRol	=	R.IdRol
    WHERE UsuarioID	=	@idUsuario
          AND P.IdContrato	=	@idContrato
          AND (R.Rol LIKE '%Admin%' or R.Rol Like '%Upper Managment Shell%');

IF(@IsAdmin	=	1)
BEGIN
	SET	@idUsuario	=	NULL;
END

INSERT INTO #Detalle
(
	Contrato,
	AreaBOM,
	NombreEntregable,
	Funcion,
	Subfuncion,
	FechaIniProg,
	FechaFinProg,
	FechaIniReal,
	Usuario,
	CorreoUsuario,
	Rol,
	Status,
	FocalPoint,
	FocalPointEmail,
	AccountableCompliance,
	AccountableComplianceEmail,
	Accountable,
	AccountableEmail,
	DiasElaboracion,
	DiasRevision,
	DiasAprobacion,
	DiasAtraso,
	DiasP,
	DiasR,
	DiasReales,
	MarcoLegal,
	FechaRealEntregaRegulador,
	FechaEstimadaEntregaRegulador,
	ID,
	Articulo,
	Anio,
	Mes,
	EstatusParaColor,
	Color
)
SELECT
	C.NumeroContrato				AS Contrato,
	ISNULL(CA.NombreArea,'')		AS AreaBOM,
	E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable)  	AS [NombreEntregable],
	AR.NombreArea					AS Funcion,
	ISNULL(CE.Subfuncion,'')		AS Subfuncion,
	IE.FechaInicioElaboracion		AS [FechaIniProg],
	IE.FechasLimiteAprobacion		AS [FechaFinProg],
	MAX(HALT.CreadoEn)				AS [FechaIniReal],
	U.Nombre						AS Usuario,
	U.Usuario						AS CorreoUsuario,
	CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
		WHEN A.EstadoID = 10001 THEN 'Revisor'
		WHEN A.EstadoID = 10002 THEN 'Aprobador'
	END								AS Rol,
	CASE WHEN AACT.EstadoID = 10000 THEN 'En Elaboración'
		WHEN AACT.EstadoID = 10001 THEN 'En Revisión'
		WHEN AACT.EstadoID = 10002 THEN 'En Aprobación'
		WHEN AACT.EstadoID = 10003 THEN 'Aprobado'
	END								AS [Status],
	CASE WHEN FP.Nombre IS NULL THEN ''
		ELSE ISNULL(FP.Nombre,'')
	END								AS FocalPoint,
	ISNULL(CE.FocalPoint,'')		AS	FocalPointEmail,
	CASE WHEN AC.Nombre IS NULL THEN ''
		ELSE ISNULL(AC.Nombre,'')
	END								AS AccountableCompliance,
	ISNULL(CE.AccountableCompliance,'')	AS AccountableComplianceEmail,
	CASE WHEN ACC.Nombre IS NULL THEN ''
		ELSE ISNULL(ACC.Nombre,'')
	END								AS Accountable,
	ISNULL(CE.Accountable,'')		AS	AccountableEmail,
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
	YEAR(IE.FechaCalculadaEntregaReg) AS Anio,
	DATENAME(MONTH,IE.FechaCalculadaEntregaReg) AS Mes,
	CASE
		WHEN AACT.EstadoID = 10003 THEN 'Delivered' -- NEGRO 1
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 AND AACT.EstadoID <> 10003 THEN 'Delayed'	-- NEGRO 1
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN '0-40% of time remaining' -- ROJO 2
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN '40-70% of time remaining' -- AMARILLO 3
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN 'More than 70% of time remaining' -- VERDE 4
	END		AS EstatusParaColor,
	CASE
		WHEN AACT.EstadoID = 10003 THEN 1
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 AND AACT.EstadoID <> 10003 THEN 1
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN 2
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN 3
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN 4
	END		AS Color
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
	CO_ContratoArea	CA
	ON	C.IdContrato	=	CA.IdContrato
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
	AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
	ON	CE.FocalPoint	=	FP.Usuario
LEFT JOIN
	AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
	ON	CE.AccountableCompliance	=	AC.Usuario
LEFT JOIN
	AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
	ON	CE.Accountable	=	ACC.Usuario
LEFT JOIN
	EN_DocumentoVersion	DV
	ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
WHERE
	IE.FechasLimiteElaboracion 	<	DATEADD(YEAR,2,GETDATE())
	AND
	IE.FechaCalculadaEntregaReg	IS NOT NULL
	AND
	--C.IdContrato	=	@IdContrato
	C.IdContratista	= @IdContratista
	AND 
	IE.Activo	=	1
	 AND ( A.idUsuario = ISNULL(@IdUsuario,A.idUsuario) 
            OR FP.UsuarioID    =    ISNULL(@IdUsuario,	FP.UsuarioID )
            OR AC.UsuarioID    =    ISNULL(@IdUsuario,	AC.UsuarioID)
            OR ACC.UsuarioID    =    ISNULL(@IdUsuario,	ACC.UsuarioID)
         )
		
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
	DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg),
	DATEDIFF(DAY, IE.FechaInicioElaboracion, IE.FechasLimiteAprobacion),
	ISNULL(ML.MarcoLegal,''),
	IE.FechaRealEntregaRegulador,
	IE.FechaCalculadaEntregaReg,
	IE.idInstanciaEntregable,
	E.Articulo,
	YEAR(IE.FechaCalculadaEntregaReg),
	DATENAME(MONTH,IE.FechaCalculadaEntregaReg),
	CASE
		WHEN AACT.EstadoID = 10003 THEN 'Delivered'
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 AND AACT.EstadoID <> 10003 THEN 'Delayed'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN '0-40% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN '40-70% of time remaining'
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN 'More than 70% of time remaining'
	END,
	CASE
		WHEN AACT.EstadoID = 10003 THEN 1
		WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 AND AACT.EstadoID <> 10003 THEN 1
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN 2
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN 3
		WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN 4
	END

SELECT
	Funcion,
	Subfuncion,
	COUNT(ID)	AS Cantidad
FROM
	#Detalle
GROUP BY
	Funcion,
	Subfuncion
ORDER BY
	Funcion,
	Subfuncion


SELECT
	Anio	as	[AñoEntrega],
	REPLICATE('0',2-LEN(LTRIM(MONTH(FechaEstimadaEntregaRegulador)))) + LTRIM(MONTH(FechaEstimadaEntregaRegulador)) + '-' + Mes		AS	[MesEntrega],
	Funcion,
	COUNT(ID)	AS Cantidad
FROM
	#Detalle
GROUP BY
	Anio,
	REPLICATE('0',2-LEN(LTRIM(MONTH(FechaEstimadaEntregaRegulador)))) + LTRIM(MONTH(FechaEstimadaEntregaRegulador)) + '-' + Mes,
	Funcion
ORDER BY
	Anio,
	REPLICATE('0',2-LEN(LTRIM(MONTH(FechaEstimadaEntregaRegulador)))) + LTRIM(MONTH(FechaEstimadaEntregaRegulador)) + '-' + Mes,
	Funcion

SELECT
	EstatusParaColor,
	COUNT(ID)	AS Cantidad
FROM
	#Detalle
GROUP BY
	EstatusParaColor
ORDER BY
	EstatusParaColor

SELECT 
	Contrato,
	AreaBOM,
	NombreEntregable,
	Funcion,
	Subfuncion,
	FechaIniProg,
	FechaFinProg,
	FechaIniReal,
	Usuario,
	CorreoUsuario,
	Rol,
	Status,
	FocalPoint,
	FocalPointEmail,
	AccountableCompliance,
	AccountableComplianceEmail,
	Accountable,
	AccountableEmail,
	DiasElaboracion,
	DiasRevision,
	DiasAprobacion,
	DiasAtraso,
	DiasP,
	DiasR,
	DiasReales,
	MarcoLegal,
	FechaRealEntregaRegulador,
	FechaEstimadaEntregaRegulador,
	ID,
	Articulo,
	Anio,
	Mes,
	EstatusParaColor,
	Color,
	'https://shell.adinco.mx/2/Entregables/SubeEntregables.aspx?inst='+LTRIM(ID)+'' GoToObligation,
	'mailto: '+AccountableEmail+'?cc='+ CorreoUsuario +';'+AccountableComplianceEmail+'&subject=Compliance System &body='+SUBSTRING(NombreEntregable,1,100)+'' as Mail
FROM
	#Detalle
ORDER BY
	FechaEstimadaEntregaRegulador

END
