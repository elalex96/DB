CREATE PROCEDURE dbo.sp_EN_ExtraeReporteEntregablesRespaldos_ENI-- 3,10061,'2020-01-01','2020-03-31'
    @IdContrato INT,
    @idUsuario INT
--	@FechaInicio DATETIME,
--	@FechaFin	DATETIME
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE Spanish; 

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


	INSERT INTO #Respaldos(	--AreaBOM,
							Contrato,
							NombreEntregable,
							Funcion,
							Subfuncion,
							Usuario,
							CorreoUsuario,
							Rol,
							--FocalPoint,
							--FocalPointEmail,
							--AccountableCompliance,
							--AccountableComplianceEmail,
							--Accountable,
							--AccountableEmail,
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
-- 		ISNULL(CA.NombreArea,'')		AS AreaBOM,
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
		--CASE WHEN FP.Nombre IS NULL THEN ''
		--	ELSE ISNULL(FP.Nombre,'')
		--END								AS FocalPoint,
		--ISNULL(CE.FocalPoint,'')		AS	FocalPointEmail,
		--CASE WHEN AC.Nombre IS NULL THEN ''
		--	ELSE ISNULL(AC.Nombre,'')
		--END								AS AccountableCompliance,
		--ISNULL(CE.AccountableCompliance,'')	AS AccountableComplianceEmail,
		--CASE WHEN ACC.Nombre IS NULL THEN ''
		--	ELSE ISNULL(ACC.Nombre,'')
		--END								AS Accountable,
		--ISNULL(CE.Accountable,'')		AS	AccountableEmail,
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
		AND IE.FechaCalculadaEntregaReg BETWEEN '20180701' AND '20191231'
		AND ie.idinstanciaentregable not in (35737	,35738	,35739	,35740	,35741	,35742	,35743	,35744	,
35745	,35746	,35747	,35748	,35749	,35750	,35751	,35752	,35753	,35754	,35478	,35479	,35480	,35481	,35482	,35483	,
35484	,35485	,35486	,35487	,35488	,35489	,35490	,35491	,35492	,35493	,35494	,35495	,40356	,34961	,34962	,34963	,
34964	,34965	,34966	,34967	,34968	,34969	,34970	,34971	,34972	,34973	,34974	,34975	,34976	,34977	,39103	,39104	,
39105	,39106	,39107	,510770	,510772	,510774	,509142	,509143	,509913	,507517	,508692	,510817	,510819	,510821	,131117	,510575	,
39619	,39620	,39621	,39622	,39623	,527856	,527857	,527858	,507433	,38069	,38070	,38071	,38072	,38073	,38074	,38327	,
38328	,140362	,140363	,140364	,40657	,40548	,40549	,527478	,527479	,553841	,523698	,523700	,523703	,523706	,523707	,523708	,
523709	,523710	,523711	,556262	,110465	,110466	,110467	,110468	,110469	,110470	,110471	,110472	,110473	,110474	,110475	,110476	,
110477	,110478	,110479	,110480	,559508	,559509	,559510	,559511	,559512	,559513	,559514	,
-- 7 nov
40440,559773,559774,559775,562064,562046,562050,562047,562051,562055,38075,140365,140366,39447,40526)

	JOIN
		CO_Contrato	C	(NOLOCK)
		ON	CE.IdContrato	=	C.IdContrato
	--JOIN
	--	CO_ContratoArea	CA
	--	ON	C.IdContrato	=	CA.IdContrato
	JOIN
		EN_Entregable	E	(NOLOCK)
		ON	CE.IdEntregable	=	E.IdEntregable
		AND	ISNULL(E.IsActivo,1)	=	1
		AND E.BITJOA = 0													--JOA
		AND E.CONSECUTIVO IN ('ADINCO-CN005','ADINCO-GAS005','ADINCO-GENR005','ADINCO-GENR021',
'ADINCO-MEDI006','ADINCO-MEDI007','ADINCO-MEDI009','ADINCO-MEDI010',
'ADINCO-MIA008','ADINCO-PERFO008','ADINCO-PERFO015','ADINCO-PERFO107',
'ADINCO-PERFO503','ADINCO-PERFO505','ADINCO-PLANES110','ADINCO-PLANES174',
'ADINCO-PLANES175','ADINCO-PLANES182','ADINCO-R1L2036','ADINCO-R1L2099',
'ADINCO-R1L2106','ADINCO-R1L2107','ADINCO-R1L2108','ADINCO-RESER002',
'ADINCO-RESER006','ADINCO-SAR0015','ENI-0091','ENI-0122' ,
-- LOS QUE ME FALTARON 9-NOV
'ADINCO-MIA001','ADINCO-MIA002','ADINCO-MIA003','ADINCO-MIA005','ADINCO-MIA009','ADINCO-PERFO507','ADINCO-R1L2052','ADINCO-R1L2159','ADINCO-RESER013')
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
		EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC
		ON CE.IdContratoEntregable	=	ENT_ACC.IdContratoEntregable			----	SASISOPA NULL
	WHERE
			CE.IdContrato	=	@IdContrato
	AND
			ENT_ACC.IdProgramaImplementaAccion IS NULL
	AND
			E.BitJOA	=	0													--JOA


	INSERT INTO #DocumentosInstancias(IdInstanciaEntregable ,
									  CantidadArchivos,
									  NombreArchivo
									  )
	SELECT	
			R.ID,
			COUNT(DISTINCT DocumentoEntregableId),
			LTRIM(R.ID) + '.zip'
			
	FROM 
		#Respaldos	R
	JOIN
		EN_HistorialAprobacionesLineaTiempo	FINR	(NOLOCK)
		ON	R.ID	=	FINR.idInstanciaEntregable
		AND FINR.idTipoOperacion in (2, 3, 4)
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
