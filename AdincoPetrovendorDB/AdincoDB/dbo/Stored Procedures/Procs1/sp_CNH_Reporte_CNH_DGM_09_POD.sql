CREATE PROCEDURE dbo.sp_CNH_Reporte_CNH_DGM_09_POD
	 @Contrato  INT,  
	 @DiaReporte  DATE,   
	 @IdUsuario  INT ,
	 @verProdNeta bit=0-- Defina si se verá la prod. de petroleo Neta
AS
BEGIN
-- ==============================================================================================
-- Description:	Reporte de CNH CNH_DGM_09_POD (Producción Operativa Diaria)
--				Muestra todos los contratos relacionados
-- ----------------------------------------------------------------------------------------------
-- FECHA	MODIFICÓ	COMENTARIO
-- ----------------------------------------------------------------------------------------------
-- 20180726	BAAC		Creación de sp
-- 20180830	BAAC		Se modifica para convertir los hidrocarburos de 20° a 15.56°
-- 20190304	BAAC		Se modifica para tomar la temperatura de los hidrocarburos de acuerdo a lo indicado en los formatos de producción diaria
-- 20190417	BAAC		Se agrega CASE en la produccion de petroleo, para que cuando se trate de PCM O DEA o Jaguar o IHSA o GS muestre la produccion neta
-- ==============================================================================================
SET NOCOUNT ON
-- ==============================================================================================

CREATE TABLE #Contratos
(
	IdContrato	INT PRIMARY KEY
)

CREATE TABLE #ContratosDiaria
(
	IdContrato	INT PRIMARY KEY
	--Temperatura	FLOAT
)

CREATE TABLE #ContratosConciliada
(
	IdContrato	INT PRIMARY KEY
	--Tempratura_Gas	FLOAT,
	--Temperatura_Petroloe	FLOAT
)

CREATE TABLE #EventosPozo
(
--	IdCampo	INT,	SE CAMBIA POR EL NOMBRE PORQUE ESTAN REPETIDOS POR EL BLOQUE
	Fecha	DATE,
	Campo	VARCHAR(250),
	IdPozo	INT,
	Eventos	VARCHAR(2000),
	PRIMARY KEY (Fecha, Campo, IdPozo)
)

CREATE TABLE #EventosCampo
(
--	IdCampo	INT,	SE CAMBIA POR EL NOMBRE PORQUE ESTAN REPETIDOS POR EL BLOQUE
	Fecha	DATE,
	Campo	VARCHAR(250),
	Eventos	VARCHAR(6000),
	PRIMARY KEY (Fecha, Campo)
)

CREATE TABLE #GradosAPI
(
	IdCampo	INT,
	GradosAPI	FLOAT,
	KgM3		FLOAT,
	Alfa		FLOAT,
	CTL			FLOAT,
	KgM3_Condensado	FLOAT,
	Alfa_Condensado	FLOAT,
	CTL_Condensado	FLOAT,
	SinCromatografia	BIT
)

DECLARE
	@IdRelacionado	INT,
	@60F_R         FLOAT = 519.67, -- 60 grados Fahrenheit a rankine
	@68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
	@FactorConverM3_MMPC FLOAT = 0.00003531467,
	@BitProdNeta	BIT = 0

--SELECT
--	@IdRelacionado	=	REL.IdRelacionado
--FROM
--	dbo.CO_Contrato	C
--JOIN
--	CO_ContratistaRelacionado	REL
--	ON	C.IdContratista	=	REL.IdContratista
--WHERE
--	C.IdContrato = @Contrato

IF 0 < (SELECT COUNT(1) 
	FROM	CO_Contrato	C
	JOIN	CO_Contratista	CC
		ON	C.IdContratista	=	CC.IdContratista
	WHERE
		CC.NombreContratista IN ('Jaguar', 'Pantera', 'Petrolera Cárdenas Mora', 'Deutsche Erdoel México')
		AND		C.IdContrato = @Contrato
	)
	SELECT @BitProdNeta = 1

---- SI NO HAY CONTRATISTAS RELACIONADOS, SE INSERTAN TODOS LOS CONTRATOS DEL MISMO SUBCONTRATISTA	
--IF ISNULL(@IdRelacionado,0) = 0
--BEGIN
	INSERT INTO #Contratos
	(
	    IdContrato
	)
	SELECT
		C2.IdContrato
	FROM
		dbo.CO_Contrato	C
	JOIN
		dbo.CO_Contrato	C2
		ON	C.IdContratista	=	C2.IdContratista
	WHERE
		C.IdContrato	=	@Contrato
	GROUP BY
		C2.IdContrato
--END
--ELSE
--BEGIN
--	INSERT INTO #Contratos
--	(
--	    IdContrato
--	)
--	SELECT
--		C.IdContrato
--	FROM
--		dbo.CO_Contrato	C
--	JOIN
--		CO_ContratistaRelacionado	REL
--		ON	C.IdContratista	=	REL.IdContratista
--	WHERE
--		REL.IdRelacionado	=	@IdRelacionado

--END

-- SE INSERTAN LOS CONTRATOS QUE CUENTAN CON PRODUCCION CONCILIADA
INSERT INTO #ContratosConciliada
(
	IdContrato
)
SELECT
	CO.IdContrato
FROM
	#Contratos	CO
JOIN 
	dbo.CO_Contrato	C
	ON	CO.IdContrato	=	C.IdContrato
JOIN
	CO_Instalacion	I
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_ProdDiariaPozo	PDP
	ON P.Id	=	PDP.Pozo
WHERE
	YEAR(PDP.Fecha)	=	YEAR(@DiaReporte)
	AND MONTH(PDP.Fecha)	=	MONTH(@DiaReporte)
	AND I.Activo = 1
GROUP BY
	CO.IdContrato
HAVING
	COUNT(PDP.Fecha) >= DAY(EOMONTH(@DiaReporte))

-- SE INSERTA EL COMPLEMENTO DE CONTRATOS QUE NO TUVIERON PROD CONCILIADA, PARA OBTENER LA INFORMACION DE LA PRODUCCION DIARIA
INSERT INTO #ContratosDiaria
(
	IdContrato
)
SELECT
	C.IdContrato
FROM
	#Contratos	C
LEFT JOIN
	#ContratosConciliada	CC
	ON	C.IdContrato	=	CC.IdContrato
WHERE
	CC.IdContrato	IS NULL


-- GRADOS API POR CAMPO PARA CONVERSION DE TEMPERATURA
INSERT INTO #GradosAPI
(
	IdCampo,
	GradosAPI,
	SinCromatografia
)
SELECT
	CPO.Id,
	ISNULL(CROMA.GradosAPI,0),
	CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
	END
FROM
	#Contratos	T
JOIN
	dbo.CO_Contrato	C
	ON	T.IdContrato	=	C.IdContrato
JOIN
	dbo.CO_Instalacion	I
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_Campo	CPO
	ON	P.Campo	=	CPO.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	C.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN	
	dbo.CO_Cromatografia	CR
	ON PEC.IdContrato	=	CR.IdContrato
	AND	YEAR(@DiaReporte) = CR.Anio
	AND	MONTH(@DiaReporte)	=	CR.Mes
LEFT JOIN
	CO_CromatografiaValores	CROMA
	ON	CR.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
WHERE
	I.Activo = 1
GROUP BY
	CPO.Id,
	ISNULL(CROMA.GradosAPI,0),
	CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
	END

UPDATE #GradosAPI
	SET SinCromatografia = 0
WHERE
	SinCromatografia IS NULL

-- SE BUSCA LA CROMATOGRAFIA DEL MES ANTERIOR, PARA LOS CONTRATOS-PUNTOS DE ENTREGA QUE NO SE ENCONTRO
UPDATE	API
	SET	API.GradosAPI	=	ISNULL(CROMA.GradosAPI,0)
FROM
	#Contratos	T
JOIN
	dbo.CO_Contrato	C
	ON	T.IdContrato	=	C.IdContrato
JOIN
	dbo.CO_Instalacion	I
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_Campo	CPO
	ON	P.Campo	=	CPO.Id
JOIN
	#GradosAPI		API
	ON	CPO.Id	=	API.IdCampo
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	C.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN	
	dbo.CO_Cromatografia	CR
	ON PEC.IdContrato	=	CR.IdContrato
	AND	YEAR(DATEADD(MONTH, -1,@DiaReporte)) = CR.Anio
	AND	MONTH(DATEADD(MONTH, -1,@DiaReporte))	=	CR.Mes
LEFT JOIN
	CO_CromatografiaValores	CROMA
	ON	CR.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
WHERE
	API.SinCromatografia	=	1
	AND
	I.Activo = 1


UPDATE #GradosAPI
	SET KgM3 = (141.5 / (GradosAPI + 131.5)) * 999.012,
		KgM3_Condensado	=	(141.5 / (0 + 131.5)) * 999.012	-- 0 --> Grados API del Condensado

UPDATE #GradosAPI
	SET Alfa	=	(341.0957 / POWER( KgM3, 2 )),
		Alfa_Condensado	=	(341.0957 / POWER( KgM3_Condensado, 2 ))

UPDATE #GradosAPI
	SET	CTL	=	EXP( -Alfa * 8 * (1 + 0.8 * Alfa * 8)),
		CTL_Condensado	=	EXP( -Alfa_Condensado * 8 * (1 + 0.8 * Alfa_Condensado * 8))


INSERT INTO #EventosPozo
(
	Fecha,
	Campo,
	IdPozo,
	Eventos
)
SELECT
	PDP.Fecha,
	CPO.Nombre,
	P.Id,
	P.Nombre + ': ' + PDP.Comentarios
FROM
	#Contratos	T
JOIN
	dbo.CO_Contrato	C
	ON	T.IdContrato	=	C.IdContrato
JOIN
	dbo.CO_Instalacion	I
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_ProdDiariaPozo_Previo	PDP
	ON	P.Id	=	PDP.Pozo
JOIN
	dbo.PR_Campo	CPO
	ON	P.Campo	=	CPO.Id
WHERE
	YEAR(PDP.Fecha)	=	YEAR(@DiaReporte)
	AND
	MONTH(PDP.Fecha)	=	MONTH(@DiaReporte)
	AND
	PDP.Fecha	<=	@DiaReporte
	AND
	ISNULL(PDP.Comentarios,'') <> ''
	AND
	I.Activo = 1
GROUP BY
	PDP.Fecha,
	CPO.Nombre,
	P.Id,
	P.Nombre + ': ' + PDP.Comentarios

INSERT INTO #EventosCampo
(
	Fecha,
	Campo,
	Eventos
)
SELECT
	Fecha,
	Campo , 
	STUFF(( SELECT  ', '+ Eventos FROM #EventosPozo A
			WHERE B.Campo = A.Campo AND B.Fecha = A.Fecha FOR XML PATH('')),1 ,1, '')  Members
FROM
	#EventosPozo B
GROUP BY
	Fecha,
	Campo


SELECT
	CPO.Nombre	AS [Normbre del Campo],
	C.NumeroContrato AS [ID del Contrato o Asignación],
	PDP.Fecha,
	SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProdPetroleoBruto,0) * API.CTL,3)
		ELSE ISNULL(PDP.ProdPetroleoBruto,0) END)			AS [Producción de Petróleo bls],
--	SUM(ROUND(ISNULL(PDP.ProdPetroleoBruto,0) * API.CTL,3))	AS [Producción de Petróleo bls],
	SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProdCondensadoNeto,0) * API.CTL_Condensado,3)
		ELSE ISNULL(PDP.ProdCondensadoNeto,0) END)			AS [Producción de Condensado bls],
--	SUM(ROUND(ISNULL(PDP.ProdCondensadoNeto,0) * API.CTL_Condensado,3))	AS [Producción de Condensado bls],
	SUM(ROUND(ISNULL(PDP.Agua,0),3))				AS [Producción de Agua Neto bls],
	SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.GastoGas,0) * (@60F_R/@68F_R),3)
		ELSE ISNULL(PDP.GastoGas,0) END)			AS [Producción de Gas  MMPC],
--	SUM(ROUND(ISNULL(PDP.GastoGas,0) * (@60F_R/@68F_R),3))			AS [Producción de Gas  MMPC],
	--COUNT(PDP.Pozo)				AS [Número de Pozos Operando],
	SUM(CASE WHEN PDP.Operando = 1 THEN 1 ELSE 0 END) AS [Número de Pozos Operando],
	ISNULL(E.Eventos,'')		AS [Eventos],
	SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProdAceiteNeto,0) * API.CTL,3)
		ELSE ISNULL(PDP.ProdAceiteNeto,0) END)		AS [Producción de Petróleo Neto]
--	SUM(ROUND(ISNULL(PDP.ProdAceiteNeto,0) * API.CTL,3))	AS [Producción de Petróleo Neto]
	into #tmpResultFinal
FROM
	#ContratosDiaria	T
JOIN
	dbo.CO_Contrato	C
	ON	T.IdContrato	=	C.IdContrato
JOIN
	dbo.CO_Instalacion	I
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_ProdDiariaPozo_Previo	PDP
	ON	P.Id	=	PDP.Pozo
JOIN
	dbo.PR_Campo	CPO
	ON	P.Campo	=	CPO.Id
LEFT JOIN
	#GradosAPI	API
	ON	CPO.Id	=	API.IdCampo
LEFT JOIN
	#EventosCampo	E
	ON	PDP.Fecha	=	E.Fecha
	AND	CPO.Nombre	=	E.Campo
LEFT JOIN
	dbo.PR_ProdDiaria_Previo	PD
	ON	PDP.ProdDiaria	=	PD.Id
	AND PDP.Fecha		=	PD.Fecha
WHERE
	YEAR(PDP.Fecha)	=	YEAR(@DiaReporte)
	AND
	MONTH(PDP.Fecha)	=	MONTH(@DiaReporte)
	AND
	PDP.Fecha	<=	@DiaReporte
	AND
	I.Activo = 1
GROUP BY
	CPO.Nombre,
	C.NumeroContrato,
	PDP.Fecha,
	ISNULL(E.Eventos,'')


UNION

SELECT
	CPO.Nombre	AS [Normbre del Campo],
	C.NumeroContrato AS [ID del Contrato o Asignación],
	PDP.Fecha,
	SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProduccionReal,0) * API.CTL,3)
		ELSE ISNULL(PDP.ProduccionReal,0) END)				AS [Producción de Petróleo bls],
--	SUM(ROUND(ISNULL(PDP.ProduccionReal,0) * API.CTL,3))	AS [Producción de Petróleo bls],
	SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProduccionRealCondensado,0) * API.CTL_Condensado,3)
		ELSE ISNULL(PDP.ProduccionRealCondensado,0) END)	AS [Producción de Condensado bls],
--	SUM(ROUND(ISNULL(PDP.ProduccionRealCondensado,0) * API.CTL_Condensado,3))	AS [Producción de Condensado bls],
	SUM(ROUND(ISNULL(PDP.PctAguaAlocada,0),3))				AS [Producción de Agua Neto bls],
	SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaGas,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProduccionRealGasM3,0)  * @FactorConverM3_MMPC * (@60F_R/@68F_R),3)
		ELSE ISNULL(PDP.ProduccionRealGasM3,0) * @FactorConverM3_MMPC END)		AS [Producción de Gas  MMPC],
--	SUM(ROUND(ISNULL(PDP.ProduccionRealGasM3,0) * @FactorConverM3_MMPC * (@60F_R/@68F_R),3))			AS [Producción de Gas  MMPC],
	COUNT(PDP.Pozo)				AS [Número de Pozos Operando],
	--SUM(CASE WHEN PDP.Operando = 1 THEN 1 ELSE 0 END) AS [Número de Pozos Operando],
	ISNULL(E.Eventos,'')		AS [Eventos],
	--0	AS [Producción de Petróleo Neto]
	SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProduccionReal,0) * API.CTL,3)
		ELSE ISNULL(PDP.ProduccionReal,0) END)		AS [Producción de Petróleo Neto]
FROM
	#ContratosConciliada	T
JOIN
	dbo.CO_Contrato	C
	ON	T.IdContrato	=	C.IdContrato
JOIN
	dbo.CO_Instalacion	I
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_ProdDiariaPozo	PDP
	ON	P.Id	=	PDP.Pozo
JOIN
	dbo.PR_Campo	CPO
	ON	P.Campo	=	CPO.Id
LEFT JOIN
	#GradosAPI	API
	ON	CPO.Id	=	API.IdCampo
LEFT JOIN
	#EventosCampo	E
	ON	PDP.Fecha	=	E.Fecha
	AND	CPO.Nombre	=	E.Campo
LEFT JOIN
	dbo.PR_ProdDiaria	PD
	ON	PDP.ProdDiaria	=	PD.Id
	AND PDP.Fecha		=	PD.Fecha
WHERE
	YEAR(PDP.Fecha)	=	YEAR(@DiaReporte)
	AND
	MONTH(PDP.Fecha)	=	MONTH(@DiaReporte)
	AND
	PDP.Fecha	<=	@DiaReporte
	AND
	I.Activo = 1
GROUP BY
	CPO.Nombre,
	C.NumeroContrato,
	PDP.Fecha,
	ISNULL(E.Eventos,'')
ORDER BY
	PDP.Fecha,
	C.NumeroContrato,
	CPO.Nombre


	if @verProdNeta = 1
	begin

		select  
			[Normbre del Campo],
			[ID del Contrato o Asignación],
			Fecha,
			[Producción de Petróleo bls],
			[Producción de Condensado bls],
			[Producción de Agua Neto bls],
			[Producción de Gas  MMPC],	
			[Número de Pozos Operando],
			[Eventos],
			[Producción de Petróleo Neto]
		from #tmpResultFinal

	End
	Else
	Begin
		select  
			[Normbre del Campo],
			[ID del Contrato o Asignación],
			--Fecha,
			LTRIM(YEAR(Fecha)) + '-' + REPLICATE('0',2-LEN(LTRIM(MONTH(FECHA)))) + ltrim(month(fecha)) + '-' + REPLICATE('0',2-LEN(LTRIM(day(FECHA)))) + ltrim(day(fecha)) as Fecha,
			--CASE WHEN @BitProdNeta = 1 --@Contrato IN (10036, 10038)  SE PONE EL CAMBIO A PRODUCCION NETA PARA TODOS 20190515
				 [Producción de Petróleo Neto]
			--	ELSE [Producción de Petróleo bls]
			--END
			AS [Producción de Petróleo bls],
			[Producción de Condensado bls],
			[Producción de Agua Neto bls],
			[Producción de Gas  MMPC],	
			[Número de Pozos Operando],
			[Eventos]
		from #tmpResultFinal
	End

END

