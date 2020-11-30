CREATE PROCEDURE dbo.sp_EN_ExtraeReporteEntregablesRespaldos-- 3,10061,'2020-01-01','2020-03-31'
    @IdContrato INT,
    @idUsuario INT,
	@FechaInicio DATETIME,
	@FechaFin	DATETIME
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE Spanish; 

IF @IdContrato = 10054
BEGIN
	EXEC sp_EN_ExtraeReporteEntregablesRespaldos_ENI @IdContrato, @idUsuario
	RETURN
END
	CREATE TABLE #DocumentosInstancias(IdInstanciaEntregable INT,
									  NombreArchivo  VARCHAR(1500),
									  CantidadArchivos INT
									  );


	CREATE TABLE #Respaldos(AreaBOM VARCHAR(1500),
							Contrato VARCHAR(1500),
							NombreEntregable VARCHAR(1500),
							Funcion  VARCHAR(1500),
							Subfuncion  VARCHAR(1500),
							Usuario   VARCHAR(1500),
							CorreoUsuario   VARCHAR(1500),
							Rol    VARCHAR(1500),
							FocalPoint  VARCHAR(1500),
							FocalPointEmail  VARCHAR(1500),
							AccountableCompliance VARCHAR(1500),
							AccountableComplianceEmail  VARCHAR(1500),
							Accountable   VARCHAR(1500),
							AccountableEmail   VARCHAR(1500),
							MarcoLegal  VARCHAR(1500),
							FechaRealEntregaRegulador DATETIME,
							FechaEstimadaEntregaRegulador DATETIME,
							ID INT,
							Anio INT,
							Mes VARCHAR(1500),
							EstatusParaColor VARCHAR(1500),
							NombreArchivo  VARCHAR(1500),
							CantidadArchivos INT
						    );


	INSERT INTO #Respaldos(	AreaBOM,
							Contrato,
							NombreEntregable,
							Funcion,
							Subfuncion,
							Usuario,
							CorreoUsuario,
							Rol,
							FocalPoint,
							FocalPointEmail,
							AccountableCompliance,
							AccountableComplianceEmail,
							Accountable,
							AccountableEmail,
							MarcoLegal,
							FechaRealEntregaRegulador,
							FechaEstimadaEntregaRegulador,
							ID,
							Anio,
							Mes,
							EstatusParaColor,
							NombreArchivo,
							CantidadArchivos
						    )
	SELECT 
 		ISNULL(CA.NombreArea,'')		AS AreaBOM,
		C.NumeroContrato AS Contrato,
		E.DocumentoEntregable + '-' + LTRIM(IE.idInstanciaEntregable)  	AS [NombreEntregable],
		AR.NombreArea					AS Funcion,
		ISNULL(CE.Subfuncion,'')		AS Subfuncion,
		U.Nombre						AS Usuario,
		U.Usuario						AS CorreoUsuario,
		CASE WHEN A.EstadoID = 10000 THEN 'Elaborador'
			WHEN A.EstadoID = 10001 THEN 'Revisor'
			WHEN A.EstadoID = 10002 THEN 'Aprobador'
		END								AS Rol,
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
		ISNULL(ML.MarcoLegal,'')	AS MarcoLegal,
		IE.FechaRealEntregaRegulador,
		IE.FechaCalculadaEntregaReg	AS	FechaEstimadaEntregaRegulador,
		IE.idInstanciaEntregable	AS ID,
		YEAR(IE.FechaCalculadaEntregaReg) AS Anio,
		DATENAME(MONTH,IE.FechaCalculadaEntregaReg) AS Mes,
		CASE
			WHEN AACT.EstadoID = 10003 THEN 'Delivered' -- NEGRO 1
			WHEN DATEDIFF(DAY,IE.FechaCalculadaEntregaReg,GETDATE()) > 0 AND AACT.EstadoID <> 10003 THEN 'Delayed'	-- NEGRO 1
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0 AND 0.4 THEN '0-40% of time remaining' -- ROJO 2
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) BETWEEN 0.41 AND 0.69 THEN '40-70% of time remaining' -- AMARILLO 3
			WHEN (CONVERT(FLOAT,DATEDIFF(DAY,GETDATE(),IE.FechaCalculadaEntregaReg))/CONVERT(FLOAT,DATEDIFF(DAY, IE.FechaInicioElaboracion,IE.FechaCalculadaEntregaReg))) > 0.69 THEN 'More than 70% of time remaining' -- VERDE 4
		END		AS EstatusParaColor,
		 '' as NombreArchivo,
		 0
		 
	FROM
		EN_InstanciasEntregable	IE (NOLOCK)
	JOIN
		EN_ContratoEntregable	CE	(NOLOCK)
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	CE.IdContrato	=	@IdContrato
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
		AND E.BITJOA = 0													--JOA
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
		EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC
		ON CE.IdContratoEntregable	=	ENT_ACC.IdContratoEntregable			----	SASISOPA NULL
	WHERE
			CE.IdContrato	=	@IdContrato
	AND
			ENT_ACC.IdProgramaImplementaAccion IS NULL
	AND
			E.BitJOA	=	0													--JOA
	AND
			IE.FechaCalculadaEntregaReg BETWEEN @FechaInicio AND @FechaFin


	INSERT INTO #DocumentosInstancias(IdInstanciaEntregable ,
									  CantidadArchivos,
									  NombreArchivo
									  )
	SELECT	
			R.ID,
			COUNT(1),
			LTRIM(R.ID) + '.zip'
			
	FROM 
		#Respaldos	R
	JOIN
		EN_HistorialAprobacionesLineaTiempo	FINR	(NOLOCK)
		ON	R.ID	=	FINR.idInstanciaEntregable
		AND FINR.idTipoOperacion = 4
	JOIN
		EN_DocumentoVersion	DV	(NOLOCK)
		ON	R.ID	=	DV.idInstanciaEntregable
		AND FINR.IdLineaTiempo	=	DV.N_version
		AND DV.Activo = 1
	GROUP BY R.ID

	--Modifica la tabla principal a las instancias que contienen archivos

	UPDATE R
		SET	R.NombreArchivo =	DI.NombreArchivo,
			R.CantidadArchivos = DI.CantidadArchivos
	FROM	
		#Respaldos	R
	JOIN
		#DocumentosInstancias DI
		ON R.ID	=	DI.idInstanciaEntregable

	SELECT * FROM #Respaldos

END
