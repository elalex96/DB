CREATE PROCEDURE dbo.sp_CNH_Reporte_I_CNH_DGM_VHP
	@Contrato		INT,
	@MesReporte		DATE,	
	@IdUsuario		INT,
	@BitDiario		BIT = 0,
	@resultadoDeseado		tinyint=0 --0 trae todos los resultados, 1 solo producción, 2 trae resultado 2, 3 trae resultado 3
AS
BEGIN
-- =============================================
-- Description:	Reporte de CNH I_CNH_DGM_VHP (Producción Mensual por Pozo / Aforos de Pozo)
-- -------------------------------------------------
-- FECHA	MODIFICÓ	COMENTARIO
-- -------------------------------------------------
-- 20180503	BAAC		Creación de sp
-- 20180503	MGR		Quitar en NC4 y NC5 la suma de NC + IC
-- 20180709	BAAC	Se modifica para agregar parametro indicando si se trata de reporte diario o mensual
-- 20180824	BAAC	Se modifica para buscar la cromatografia del mes anterior, si no hay en el mes a consultar
-- 20180924	BAAC	Se modifica para usar el poder calorifico del gas registrado en la cromatografia
-- 20190129	BAAC	Se modifica para buscar la calidad del petroleo del mes anterior, si no hay en el mes a consultar
-- 20190304	BAAC	Se modifica para tomar la temperatura de los hidrocarburos de acuerdo a lo indicado en los formatos de producción diaria
-- =============================================
SET NOCOUNT ON
-- =============================================
-- SE CAMBIA A VERSION 2 POR CAMBIO EN CALCULO DE ENERGIA A API 14.5
EXEC sp_CNH_Reporte_I_CNH_DGM_VHP_V2 @Contrato, @MesReporte, @IdUsuario, @BitDiario, @resultadoDeseado
RETURN

CREATE TABLE #Contratos
(
	IdContrato	INT PRIMARY KEY
)

CREATE TABLE #ContratosDiaria
(
	IdContrato	INT PRIMARY KEY
)

CREATE TABLE #ContratosConciliada
(
	IdContrato	INT PRIMARY KEY
)

CREATE TABLE #ConversionGas
(
	IdContrato	INT,
	IdPozo		INT,
	MMPC_Gas	DECIMAL(24,8),
	C1MOL	FLOAT,
	C2MOL	FLOAT,
	C3MOL	FLOAT,
	NC4MOL	FLOAT,
	IC4MOL	FLOAT,
	NC5MOL	FLOAT,
	IC5MOL	FLOAT,
	C6MOL	FLOAT,
	CO2MOL	FLOAT,
	H2S		FLOAT,
	N2		FLOAT,
	C1MMBTU	FLOAT,
	C2MMBTU	FLOAT,
	C3MMBTU	FLOAT,
	NC4MMBTU	FLOAT,
	IC4MMBTU	FLOAT,
	NC5MMBTU	FLOAT,
	IC5MMBTU	FLOAT,
	C6MMBTU		FLOAT,
	PCC1		FLOAT,
	PCC2		FLOAT,
	PCC3		FLOAT,
	PCNC4		FLOAT,
	PCIC4		FLOAT,
	PCNC5		FLOAT,
	PCIC5		FLOAT,
	PCC6		FLOAT,
	PesoMolecularGas	FLOAT,
	C5EqBl		FLOAT,
	SinCromatografia	BIT,
	PoderCalorifico	FLOAT,
	GradosAPI	FLOAT,
	KgM3		FLOAT,
	Alfa		FLOAT,
	CTL			FLOAT,
	KgM3_Condensado	FLOAT,
	Alfa_Condensado	FLOAT,
	CTL_Condensado	FLOAT,
	PoderCalorifico_Gas	FLOAT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #ConversionGasAC
(
	IdContrato	INT,
	MMPC_Gas	DECIMAL(24,8),
	C1MOL	FLOAT,
	C2MOL	FLOAT,
	C3MOL	FLOAT,
	NC4MOL	FLOAT,
	IC4MOL	FLOAT,
	NC5MOL	FLOAT,
	IC5MOL	FLOAT,
	C6MOL	FLOAT,
	CO2MOL	FLOAT,
	H2S		FLOAT,
	N2		FLOAT,
	C1MMBTU	FLOAT,
	C2MMBTU	FLOAT,
	C3MMBTU	FLOAT,
	NC4MMBTU	FLOAT,
	IC4MMBTU	FLOAT,
	NC5MMBTU	FLOAT,
	IC5MMBTU	FLOAT,
	C6MMBTU		FLOAT,
	PCC1		FLOAT,
	PCC2		FLOAT,
	PCC3		FLOAT,
	PCNC4		FLOAT,
	PCIC4		FLOAT,
	PCNC5		FLOAT,
	PCIC5		FLOAT,
	PCC6		FLOAT,
	PesoMolecularGas	FLOAT,
	C5EqBl		FLOAT
)

CREATE TABLE #PromPonderado
(
	IdContrato	INT,
	IdPozo		INT,
	GradosAPI	FLOAT,
	ContenidoAzufre	FLOAT,
	ContenidoSal	FLOAT,
	Agua		FLOAT,
	Condensado	FLOAT,
	Petroleo		FLOAT,
	KgM3		FLOAT,
	Alfa		FLOAT,
	CTL			FLOAT,
	KgM3_Condensado	FLOAT,
	Alfa_Condensado	FLOAT,
	CTL_Condensado	FLOAT,
	SinCalidad		BIT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #PromPonderadoAC
(
	IdContrato	INT,
	GradosAPI	FLOAT,
	ContenidoAzufre	FLOAT,
	ContenidoSal	FLOAT,
	Condensado	FLOAT,
	Petroleo		FLOAT
)

CREATE TABLE #ValAPIAC
(
	IdContrato	INT,
	GradosAPI	FLOAT,
	ContenidoAzufre	FLOAT,
	ContenidoSal	FLOAT,
	Condensado	FLOAT
)

CREATE TABLE #ValoresAC
(
	IdContrato	INT,
	MMPC_Gas	DECIMAL(24,8),
	C1MOL	FLOAT,
	C2MOL	FLOAT,
	C3MOL	FLOAT,
	NC4MOL	FLOAT,
	IC4MOL	FLOAT,
	NC5MOL	FLOAT,
	IC5MOL	FLOAT,
	C6MOL	FLOAT,
	CO2MOL	FLOAT,
	H2S		FLOAT,
	N2		FLOAT,
	C1MMBTU	FLOAT,
	C2MMBTU	FLOAT,
	C3MMBTU	FLOAT,
	NC4MMBTU	FLOAT,
	IC4MMBTU	FLOAT,
	NC5MMBTU	FLOAT,
	IC5MMBTU	FLOAT,
	C6MMBTU		FLOAT,
	PCC1		FLOAT,
	PCC2		FLOAT,
	PCC3		FLOAT,
	PCNC4		FLOAT,
	PCIC4		FLOAT,
	PCNC5		FLOAT,
	PCIC5		FLOAT,
	PCC6		FLOAT,
	PesoMolecularGas	FLOAT,
	C5EqBl		FLOAT
)

CREATE TABLE #Calculo_Yi_PMi
(
	IdContrato	INT,
	IdPozo		INT,
	MMPC_Gas	DECIMAL(24,8),
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #Mezcla
(
	IdContrato	INT,
	IdPozo INT,
	MMPC_Gas	DECIMAL(24,8),
	Mezcla FLOAT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #MezclaAire
(
	IdContrato	INT,
	IdPozo	INT,
	PMMezcla	FLOAT,
	DensRel		FLOAT,
	DensMezcla	FLOAT,
	MtGas		FLOAT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #CalculoXi
(
	IdContrato	INT,
	IdPozo	INT,
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT,
	PRIMARY KEY ( IdContrato, IdPozo)
)

CREATE TABLE #CalculoMasa
(
	IdContrato	INT,
	IdPozo	INT,
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #CalculoVolumen
(
	IdContrato	INT,
	IdPozo	INT,
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #VolumenesComponente
(
	IdContrato	INT,
	C1	FLOAT,
	C2	FLOAT,
	C3	FLOAT,
	nC4	FLOAT,
	iC4	FLOAT,
	nC5	FLOAT,
	IC5	FLOAT,
	C6	FLOAT,
	CO2	FLOAT,
	H2S	FLOAT,
	N2	FLOAT
)

CREATE TABLE #DiasOperacion
(
	IdContrato	INT,
	IdPozo	INT,
	NumDias	INT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #VolumenesTotalesHidro
(
	IdContrato	INT,
	IdPozo	INT,
	--ProdPetroleoBruto	FLOAT,
	--ProdPetroleoNeto	FLOAT,
	ProdCondensadoNeto	FLOAT,
	ProdAgua			FLOAT,
	--ProdPetroleoBruto_15_56	FLOAT,
	--ProdPetroleoNeto_15_56	FLOAT,
	ProdCondensadoNeto_15_56	FLOAT,
	--Temperatura			FLOAT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #Petroleo15_16
(
	IdContrato	INT,
	IdPozo	INT,
	Fecha	DATE,
	ProdPetroleoBruto	FLOAT,
	ProdPetroleoNeto	FLOAT,
	Temperatura		FLOAT,
	PRIMARY KEY (IdContrato, IdPozo, Fecha)
)

CREATE TABLE #Petroleo15_16XPozo
(
	IdContrato	INT,
	IdPozo	INT,
	ProdPetroleoBruto	FLOAT,
	ProdPetroleoNeto	FLOAT
	PRIMARY KEY (IdContrato, IdPozo)
)

--CREATE TABLE #Eventos
--(
--	IdContrato	INT,
--	IdPozo		INT,
--	Eventos		VARCHAR(2000)
--)

--CREATE TABLE #EventosXContrato
--(
--	IdContrato	INT,
--	IdPozo		INT,
--	Eventos		VARCHAR(6000)
--)

DECLARE
	@FactorConverM3_MMPC FLOAT = 0.00003531467,
	@60F_R         FLOAT = 519.67, -- 60 grados Fahrenheit a rankine
    @68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
	@Eventos	VARCHAR(2000),
	@FechaFin	DATE,
	@BitConciliada BIT = 0,
	@IdRelacionado	INT,
	@Contratos	VARCHAR(4000) = '',
	@SinPoderCalorifico VARCHAR(4000) = ''

SELECT @Eventos = ''

--SELECT
--	@IdRelacionado	=	REL.IdRelacionado
--FROM
--	dbo.CO_Contrato	C
--JOIN
--	CO_ContratistaRelacionado	REL
--	ON	C.IdContratista	=	REL.IdContratista
--WHERE
--	C.IdContrato = @Contrato

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

-- SI ES EL REPORTE MENSUAL, SE PONE EL ULTIMO DIA DEL MES A CONSULTAR
IF @BitDiario = 0
BEGIN 
	SELECT @FechaFin = DATEADD(DAY,-1,DATEADD (MONTH,1,@MesReporte))

	-- SE VALIDA SI EXISTE PRODUCCION CONCILIADA
	--IF 0 < (
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
		PDP.Fecha	BETWEEN @MesReporte AND @FechaFin
		AND I.Activo = 1
	GROUP BY
		CO.IdContrato
	HAVING
		COUNT(PDP.Fecha) >= DAY(@FechaFin)

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
END
ELSE
BEGIN
	SELECT @FechaFin = @MesReporte

	INSERT INTO #ContratosDiaria
	(
	    IdContrato
	)
	SELECT
		IdContrato
	FROM
		#Contratos
END

--INSERT INTO #Eventos
--(
--	IdContrato,
--	IdPozo,
--	Eventos
--)
--SELECT
--	CO.IdContrato,
--	EP.IdPozo,
--	EP.Eventos
--FROM
--	#Contratos	CO
--JOIN
--	dbo.CO_Contrato	C
--	ON	CO.IdContrato	=	C.IdContrato
--JOIN
--	CO_Instalacion	I
--	ON	C.IdAreaContractual	=	I.IdAreaContractual
--JOIN
--	dbo.PR_Pozo	P
--	ON	I.WelIID	=	P.Id
--JOIN
--	PR_EventosMensualesPozo	EP
--	ON	P.Id		=	EP.IdPozo
--	AND YEAR(EP.MesReporte)	=	YEAR(@MesReporte)
--	AND MONTH(EP.MesReporte) = MONTH(@MesReporte)
----WHERE
----	C.IdContrato	=	@Contrato
--GROUP BY
--	CO.IdContrato,
--	EP.IdPozo,
--	EP.Eventos

--INSERT INTO #EventosXContrato
--(
--    IdContrato,
--    Eventos
--)
--SELECT
--	B.IdContrato , 
--	STUFF(( SELECT  ', '+ Eventos FROM #Eventos A
--			WHERE B.IdContrato = A.IdContrato AND B.IdPozo = A.IdPozo  FOR XML PATH('')),1 ,1, '')  Members
--FROM
--	#Eventos B
--GROUP BY
--	B.IdContrato

--IF @BitConciliada = 0
--BEGIN
-- DIAS OPERANDO DE CONTRATOS CON PRODUCCION DIARIA
	INSERT INTO #DiasOperacion
	(
		IdContrato,
		IdPozo,
		NumDias
	)
	SELECT
		CD.IdContrato,
		PDP.Pozo,
		COUNT(DISTINCT PDP.Fecha)
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		PR_ProdDiariaPozo_Previo	PDP	(NOLOCK)
		ON	P.Id	=	PDP.Pozo
		AND PDP.Fecha	<=	@FechaFin
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	WHERE
		--C.IdContrato	=	@Contrato
		--AND
		--PDP.Comentarios NOT LIKE '%CERRADO%'
		PDP.Operando	=	1
		AND I.Activo = 1
	GROUP BY
		CD.IdContrato,
		PDP.Pozo

-- VOLUMENES TOTALES DE HIDROCARBUROS DE CONTRATOS CON PRODUCCION DIARIA
	INSERT INTO #VolumenesTotalesHidro
	(
		IdContrato,
		IdPozo,
		--ProdPetroleoBruto,
		--ProdPetroleoNeto,
		ProdCondensadoNeto,
		ProdAgua,
		ProdCondensadoNeto_15_56
	)
	SELECT
		CD.IdContrato,
		PDP.Pozo,
		--SUM(ISNULL(PDP.ProdPetroleoBruto,0)),
		--SUM(ISNULL(PDP.ProdAceiteNeto,0)),
		SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 0
			ELSE ISNULL(PDP.ProdCondensadoNeto,0) 	END),
--		SUM(ISNULL(PDP.ProdCondensadoNeto,0)),
		SUM(ROUND(ISNULL(PDP.Agua,0),3)),
		SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN ISNULL(PDP.ProdCondensadoNeto,0)
			ELSE  0	END)
		--CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 15.56
		--	ELSE 20
		--END
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		PR_ProdDiariaPozo_Previo	PDP	(NOLOCK)
		ON	P.Id	=	PDP.Pozo
		AND PDP.Fecha	<=	@FechaFin
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	--	C.IdContrato	=	@Contrato
	GROUP BY
		CD.IdContrato,
		PDP.Pozo
		--CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 15.56
		--	ELSE 20
		--END

	INSERT INTO #Petroleo15_16
	(
		IdContrato,
		IdPozo,
		Fecha,
		ProdPetroleoBruto,
		ProdPetroleoNeto,
		Temperatura
	)
	SELECT
		CD.IdContrato,
		PDP.Pozo,
		PDP.Fecha,
		ROUND(ISNULL(PDP.ProdPetroleoBruto,0),3),
		ROUND(ISNULL(PDP.ProdAceiteNeto,0),3),
		CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 15.56
			ELSE 20
		END
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		PR_ProdDiariaPozo_Previo	PDP	(NOLOCK)
		ON	P.Id	=	PDP.Pozo
		AND PDP.Fecha	<=	@FechaFin
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	GROUP BY
		CD.IdContrato,
		PDP.Pozo,
		PDP.Fecha,
		ROUND(ISNULL(PDP.ProdPetroleoBruto,0),3),
		ROUND(ISNULL(PDP.ProdAceiteNeto,0),3),
		CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 15.56
			ELSE 20
		END

	-- SE VALIDA SI EXISTE GAS EN ALGUNO DE LOS POZOS PARA REALIZAR EL CALCULO DE % MOLAR
-- DE LOS CONTRATOS CON PRODUCCION DIARIA
	INSERT INTO #ConversionGas
	(
		IdContrato,
		IdPozo,
		MMPC_Gas,
		C1MOL,	C2MOL,	C3MOL,	NC4MOL,	IC4MOL,	NC5MOL,	IC5MOL,	C6MOL, CO2MOL, H2S, N2,
		SinCromatografia, PoderCalorifico, PoderCalorifico_Gas
	)
	SELECT
		CD.IdContrato,
		PDP.Pozo,
		--SUM(PDP.GastoGas * (@60F_R/@68F_R)),-- * @FactorConverM3_MMPC) * (@60F_R/@68F_R),	-- VA DIRECTO YA QUE EN EL FORMATO YA ESTA EN MMPC, SOLO SE CONVIERTE LA TEMPERATURA
		SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.GastoGas,0) * (@60F_R/@68F_R),3)
		ELSE ISNULL(PDP.GastoGas,0) END),
--		SUM(ROUND(PDP.GastoGas * (@60F_R/@68F_R),3)),
		ISNULL(CROMA.C1,0),
		ISNULL(CROMA.C2,0),
		ISNULL(CROMA.C3,0),
		ISNULL(CROMA.nC4,0),
		ISNULL(CROMA.lC4,0),
		ISNULL(CROMA.nC5,0),
		ISNULL(CROMA.lC5,0),
		ISNULL(CROMA.C6_plus,0) + ISNULL(CROMA.C7,0) + ISNULL(CROMA.C8,0) + ISNULL(CROMA.C9,0) + ISNULL(CROMA.C10,0),
		ISNULL(CROMA.MOL_CO2,0),
		ISNULL(CROMA.MOL_N2,0),
		ISNULL(CROMA.MOL_h2S,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END,
		ISNULL(CROMA.PoderCalorifico,0),
		ISNULL(CROMA.PoderCalorificoGas,0)
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_ProdDiariaPozo_Previo	PDP
		ON	P.Id	=	PDP.Pozo
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	LEFT JOIN	
		dbo.CO_Cromatografia	CR
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	LEFT JOIN
		CO_CromatografiaValores	CROMA
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	WHERE
		--C.IdContrato	=	@Contrato
		--AND
		PDP.Fecha	<=	@FechaFin
		AND	YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
		AND	ISNULL(PDP.GastoGas,0) > 0
		AND I.Activo = 1
	GROUP BY
		CD.IdContrato,
		PDP.Pozo,
		ISNULL(CROMA.C1,0),
		ISNULL(CROMA.C2,0),
		ISNULL(CROMA.C3,0),
		ISNULL(CROMA.nC4,0),
		ISNULL(CROMA.lC4,0),
		ISNULL(CROMA.nC5,0),
		ISNULL(CROMA.lC5,0),
		ISNULL(CROMA.C6_plus,0) + ISNULL(CROMA.C7,0) + ISNULL(CROMA.C8,0) + ISNULL(CROMA.C9,0) + ISNULL(CROMA.C10,0),
		ISNULL(CROMA.MOL_CO2,0),
		ISNULL(CROMA.MOL_N2,0),
		ISNULL(CROMA.MOL_h2S,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END,
		ISNULL(CROMA.PoderCalorifico,0),
		ISNULL(CROMA.PoderCalorificoGas,0)
--END
--ELSE
--BEGIN

-- DIAS DE OPERACION DE LOS CONTRATOS CON PRODUCCION CONCILIADA
	INSERT INTO #DiasOperacion
	(
		IdContrato,
		IdPozo,
		NumDias
	)
	SELECT
		CC.IdContrato,
		PDP.Pozo,
		COUNT(DISTINCT PDP.Fecha)
	FROM
		#ContratosConciliada	CC
	JOIN
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CC.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		PR_ProdDiariaPozo	PDP	(NOLOCK)
		ON	P.Id	=	PDP.Pozo
		AND PDP.Fecha	<=	@FechaFin
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	WHERE
		I.Activo = 1
	--	C.IdContrato	=	@Contrato
	GROUP BY
		CC.IdContrato,
		PDP.Pozo

-- VOLUMENES TOTALES DE HIROCARBUROS DE CONTRATOS CON PRODUCCION CONCILIADA
	INSERT INTO #VolumenesTotalesHidro
	(
		IdContrato,
		IdPozo,
		--ProdPetroleoBruto,
		--ProdPetroleoNeto,
		ProdCondensadoNeto,
		ProdAgua,
		ProdCondensadoNeto_15_56
	)
	SELECT
		CC.IdContrato,
		PDP.Pozo,
		--SUM(ISNULL(PDP.ProduccionReal,0)),
		--SUM(ISNULL(PDP.ProduccionReal,0)),
		SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) = 15.56 THEN 0
			ELSE ISNULL(PDP.ProduccionRealCondensado,0) 	END),
		--SUM(ISNULL(PDP.ProduccionRealCondensado,0)),
		SUM(ROUND(ISNULL(PDP.PctAguaAlocada,0),3)),
		SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) = 15.56 THEN ISNULL(PDP.ProduccionRealCondensado,0)
			ELSE 0 	END)
	FROM
		#ContratosConciliada	CC
	JOIN
		dbo.CO_Contrato	C
		ON	CC.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		PR_ProdDiariaPozo	PDP	(NOLOCK)
		ON	P.Id	=	PDP.Pozo
		AND PDP.Fecha	<=	@FechaFin
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	--	C.IdContrato	=	@Contrato
	GROUP BY
		CC.IdContrato,
		PDP.Pozo

	INSERT INTO #Petroleo15_16
	(
		IdContrato,
		IdPozo,
		Fecha,
		ProdPetroleoBruto,
		ProdPetroleoNeto,
		Temperatura
	)
	SELECT
		CC.IdContrato,
		PDP.Pozo,
		PDP.Fecha,
		ISNULL(PDP.ProduccionReal,0),
		ISNULL(PDP.ProduccionReal,0),
		CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) = 15.56 THEN 15.56
			ELSE 20
		END
	FROM
		#ContratosConciliada	CC
	JOIN
		dbo.CO_Contrato	C
		ON	CC.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		PR_ProdDiariaPozo	PDP	(NOLOCK)
		ON	P.Id	=	PDP.Pozo
		AND PDP.Fecha	<=	@FechaFin
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha	=	PD.Fecha
	WHERE
		I.Activo = 1
	GROUP BY
		CC.IdContrato,
		PDP.Pozo,
		PDP.Fecha,
		ISNULL(PDP.ProduccionReal,0),
		ISNULL(PDP.ProduccionReal,0),
		CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) = 15.56 THEN 15.56
			ELSE 20
		END

	-- SE VALIDA SI EXISTE GAS EN ALGUNO DE LOS POZOS PARA REALIZAR EL CALCULO DE % MOLAR
-- PARA LOS CONTRATOS QUE CUENTAN CON PRODUCCION CONCILIADA
	INSERT INTO #ConversionGas
	(
		IdContrato,
		IdPozo,
		MMPC_Gas,
		C1MOL,	C2MOL,	C3MOL,	NC4MOL,	IC4MOL,	NC5MOL,	IC5MOL,	C6MOL, CO2MOL, H2S, N2,
		SinCromatografia, PoderCalorifico, PoderCalorifico_Gas
	)
	SELECT
		CC.IdContrato,
		PDP.Pozo,
		SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaGas,20),2) <> 15.56 THEN ROUND((ISNULL(PDP.ProduccionRealGasM3,0) * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3)
		ELSE ISNULL(PDP.ProduccionRealGasM3,0)* @FactorConverM3_MMPC END),
--		SUM( ROUND((PDP.ProduccionRealGasM3 * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3)),
		ISNULL(CROMA.C1,0),
		ISNULL(CROMA.C2,0),
		ISNULL(CROMA.C3,0),
		ISNULL(CROMA.nC4,0),
		ISNULL(CROMA.lC4,0),
		ISNULL(CROMA.nC5,0),
		ISNULL(CROMA.lC5,0),
		ISNULL(CROMA.C6_plus,0) + ISNULL(CROMA.C7,0) + ISNULL(CROMA.C8,0) + ISNULL(CROMA.C9,0) + ISNULL(CROMA.C10,0),
		ISNULL(CROMA.MOL_CO2,0),
		ISNULL(CROMA.MOL_N2,0),
		ISNULL(CROMA.MOL_h2S,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END,
		ISNULL(CROMA.PoderCalorifico,0),
		ISNULL(CROMA.PoderCalorificoGas,0)
	FROM
		#ContratosConciliada	CC
	JOIN
		dbo.CO_Contrato	C
		ON	CC.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_ProdDiariaPozo	PDP
		ON	P.Id	=	PDP.Pozo
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	LEFT JOIN
		dbo.PR_ProdDiaria	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	LEFT JOIN	
		dbo.CO_Cromatografia	CR
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	LEFT JOIN
		CO_CromatografiaValores	CROMA
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	WHERE
		--C.IdContrato	=	@Contrato
		--AND
		PDP.Fecha	<=	@FechaFin
		AND	YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
		AND	ISNULL(PDP.ProduccionRealGasM3,0) > 0
		AND I.Activo = 1
	GROUP BY
		CC.IdContrato,
		PDP.Pozo,
		ISNULL(CROMA.C1,0),
		ISNULL(CROMA.C2,0),
		ISNULL(CROMA.C3,0),
		ISNULL(CROMA.nC4,0),
		ISNULL(CROMA.lC4,0),
		ISNULL(CROMA.nC5,0),
		ISNULL(CROMA.lC5,0),
		ISNULL(CROMA.C6_plus,0) + ISNULL(CROMA.C7,0) + ISNULL(CROMA.C8,0) + ISNULL(CROMA.C9,0) + ISNULL(CROMA.C10,0),
		ISNULL(CROMA.MOL_CO2,0),
		ISNULL(CROMA.MOL_N2,0),
		ISNULL(CROMA.MOL_h2S,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END,
		ISNULL(CROMA.PoderCalorifico,0),
		ISNULL(CROMA.PoderCalorificoGas,0)
--END 

UPDATE #ConversionGas
	SET SinCromatografia = 0
WHERE
	SinCromatografia IS NULL

-- SE BUSCA LA CROMATOGRAFIA DEL MES ANTERIOR, PARA LOS CONTRATOS-PUNTOS DE ENTREGA QUE NO SE ENCONTRO
UPDATE	CG
	SET
		C1MOL	=	ISNULL(CROMA.C1,0),
		C2MOL	=	ISNULL(CROMA.C2,0),
		C3MOL	=	ISNULL(CROMA.C3,0),
		NC4MOL	=	ISNULL(CROMA.nC4,0),
		IC4MOL	=	ISNULL(CROMA.lC4,0),
		NC5MOL	=	ISNULL(CROMA.nC5,0),
		IC5MOL	=	ISNULL(CROMA.lC5,0),
		C6MOL	=	ISNULL(CROMA.C6_plus,0) + ISNULL(CROMA.C7,0) + ISNULL(CROMA.C8,0) + ISNULL(CROMA.C9,0) + ISNULL(CROMA.C10,0),
		CO2MOL	=	ISNULL(CROMA.MOL_CO2,0),
		H2S		=	ISNULL(CROMA.MOL_N2,0),
		N2		=	ISNULL(CROMA.MOL_h2S,0),
		PoderCalorifico	=	ISNULL(CROMA.PoderCalorifico,0),
		PoderCalorifico_Gas	=	ISNULL(CROMA.PoderCalorificoGas,0)
FROM
	#ConversionGas	CG
JOIN
	dbo.PR_Pozo	P
	ON	CG.IdPozo	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	CG.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN	
	dbo.CO_Cromatografia	CR
	ON CG.IdContrato	=	CR.IdContrato
	AND	YEAR(DATEADD(MONTH, -1, @MesReporte)) = CR.Anio
	AND	MONTH(DATEADD(MONTH, -1, @MesReporte))	=	CR.Mes
LEFT JOIN
	CO_CromatografiaValores	CROMA
	ON	CR.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
WHERE
	CG.SinCromatografia	=	1


UPDATE	CG
 SET
    C1MMBTU = PC.C1 * CG.MMPC_Gas * CG.C1MOL / 100,
	C2MMBTU = PC.C2 * CG.MMPC_Gas * CG.C2MOL / 100,
	C3MMBTU = PC.C3 * CG.MMPC_Gas * CG.C3MOL / 100,
	NC4MMBTU = PC.C4 * CG.MMPC_Gas * CG.NC4MOL / 100,
	IC4MMBTU = PC.IC4 * CG.MMPC_Gas * CG.IC4MOL / 100,
-- QUEDARIA IGUAL QUE EL ARCHIVO DE IHSA? O CALCULO NORMAL?
	NC5MMBTU = PC.C5 * CG.MMPC_Gas * ( CG.NC5MOL +CG.IC5MOL +CG.C6MOL) / 100,
	IC5MMBTU = PC.IC5 * CG.MMPC_Gas * CG.IC5MOL / 100,
	C6MMBTU = PC.C6 * CG.MMPC_Gas * CG.C6MOL / 100,
	PCC1	=	PC.C1 * (PC.C1 * CG.MMPC_Gas * CG.C1MOL /100),
	PCC2	=	PC.C2 * (PC.C2 * CG.MMPC_Gas * CG.C2MOL /100),
	PCC3	=	PC.C3 * (PC.C3 * CG.MMPC_Gas * CG.C3MOL /100),
	PCNC4	=	PC.C4 * (PC.C4 * CG.MMPC_Gas * CG.NC4MOL /100),
	PCIC4	=	PC.IC4 * (PC.IC4 * CG.MMPC_Gas * CG.IC4MOL /100),
	PCNC5	=	PC.C5 * (PC.C5 * CG.MMPC_Gas * ( CG.NC5MOL +CG.IC5MOL +CG.C6MOL) /100),
	PCIC5	=	PC.IC5 * (PC.IC5 * CG.MMPC_Gas * CG.IC5MOL /100),
	PCC6	=	PC.C6 * (PC.C6 * CG.MMPC_Gas * CG.C6MOL /100)
FROM
    CO_PoderCaloríficoBrutoGPA2145	PC
CROSS JOIN
	#ConversionGas	CG

INSERT INTO #Calculo_Yi_PMi
(
	IdContrato,
	IdPozo,
	MMPC_Gas,
	C1,
	C2,
	C3,
	nC4,
	iC4,
	nC5,
	IC5,
	C6,
	CO2,
	H2S,
	N2
)
SELECT
	CG.IdContrato,
    CG.IdPozo,
	CG.MMPC_Gas,
    CG.C1MOL * PM.C1 / 100   AS C1,
    CG.C2MOL * PM.C2 / 100   AS C2,
    CG.C3MOL * PM.C3 / 100   AS C3,
    CG.NC4MOL * PM.nC4 / 100 AS nC4,
    CG.IC4MOL * PM.IC4 / 100 AS iC4,
    CG.NC5MOL * PM.nC5 / 100 AS nC5,
    CG.IC5MOL * PM.IC5 / 100 AS IC5,
    CG.C6MOL * PM.C6 / 100   AS C6,
    CG.CO2MOL * PM.CO2 / 100 AS CO2,
    CG.H2S * PM.H2S / 100  AS H2S,
    CG.N2 * PM.N2 / 100   AS N2
FROM
    CO_PesoMolecularGPA2145	PM
CROSS JOIN
	#ConversionGas	CG

INSERT INTO #Mezcla
(
	IdContrato,
	IdPozo,
	MMPC_Gas,
	Mezcla
)
SELECT
	IdContrato,
    IdPozo,
	MMPC_Gas,
	C1 + C2 + C3 + nC4 + iC4 + nC5 + IC5 + C6 + CO2 + H2S + N2
FROM
    #Calculo_Yi_PMi


INSERT INTO #MezclaAire
(
	IdContrato,
	IdPozo,
	PMMezcla,
	DensRel,
	DensMezcla,
	MtGas
)
SELECT
	M.IdContrato,
    M.IdPozo,
    M.Mezcla      AS PMMezcla,
	M.Mezcla / DA.PMaire           AS DensRel,
    (M.Mezcla / DA.PMaire) * DA.Densaire    AS DensMezcla,
    M.MMPC_Gas * ((M.Mezcla / PMaire) * DA.Densaire) * 1000 AS MtGas
FROM
    CO_DatosAire	DA
CROSS JOIN
	#Mezcla	M

INSERT INTO #CalculoXi
(
	IdContrato,
	IdPozo,
	C1,
	C2,
	C3,
	nC4,
	iC4,
	nC5,
	IC5,
	C6,
	CO2,
	H2S,
	N2
)
SELECT
	PM.IdContrato,
	PM.IdPozo,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.C1 / M.Mezcla END  AS C1,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.C2 /M.Mezcla END AS C2,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.C3 /  M.Mezcla END AS C3,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.nC4 / M.Mezcla END AS nC4,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.iC4 / M.Mezcla END AS iC4,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.nC5 /M.Mezcla END AS nC5,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.IC5 / M.Mezcla END AS iC5,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.C6 / M.Mezcla END AS C6,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.CO2 /  M.Mezcla END AS CO2,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.H2S / M.Mezcla END AS H2S,
	CASE WHEN M.Mezcla = 0 THEN 0 ELSE PM.N2 / M.Mezcla END AS N2
FROM
    #Calculo_Yi_PMi	PM
JOIN
	#Mezcla	M
	ON	PM.IdContrato	=	M.IdContrato
	AND	PM.IdPozo	=	M.IdPozo

INSERT INTO #CalculoMasa
(
	IdContrato,
	IdPozo,
	C1,
	C2,
	C3,
	nC4,
	iC4,
	nC5,
	IC5,
	C6,
	CO2,
	H2S,
	N2
)
SELECT
	Ma.IdContrato,
    Ma.IdPozo,
    C1 * MtGas  AS C1,
    C2 * MtGas AS C2,
    C3 * MtGas  AS C3,
    nC4 * MtGas AS nC4,
    iC4 * MtGas AS iC4,
    nC5 * MtGas AS nC5,
    iC5 * MtGas AS iC5,
    C6 * MtGas  AS C6,
    CO2 * MtGas AS CO2,
    H2S * MtGas AS H2S,
    N2 * MtGas  AS N2
FROM
    #CalculoXi  xi
JOIN
    #MezclaAire Ma
    ON	Ma.IdContrato	=	xi.IdContrato
	AND	Ma.IdPozo = xi.IdPozo

INSERT INTO #CalculoVolumen
(
	IdContrato,
	IdPozo,
	C1,
	C2,
	C3,
	nC4,
	iC4,
	nC5,
	IC5,
	C6,
	CO2,
	H2S,
	N2
)
SELECT
	CM.IdContrato,
    CM.IdPozo,
    (CM.C1 / D.C1) / 42   AS C1,
    (CM.C2 / D.C2) / 42   AS C2,
    (CM.C3 / D.C3) / 42   AS C3,
    (CM.nC4 / D.nC4) / 42 AS nC4,
    (CM.iC4 / D.IC4) / 42 AS iC4,
    (CM.nC5 / D.nC5) / 42 AS nC5,
    (CM.iC5 / D.IC5) / 42 AS iC5,
    (CM.C6 / D.C6) / 42   AS C6,
    (CM.CO2 / D.CO2) / 42 AS CO2,
    (CM.H2S / D.H2S) / 42 AS H2S,
    (CM.N2 / D.N2) / 42   AS N2
FROM
   #CalculoMasa CM
CROSS JOIN 
	CO_DensidadGPA2145	D

UPDATE	CG
    SET	C5EqBl = ISNULL(CV.nC5 + CV.iC5 + CV.C6,0)
FROM
    #CalculoVolumen	CV
JOIN
	#ConversionGas	CG
	ON	CV.IdContrato	=	CG.IdContrato
	AND	CV.IdPozo	=	CG.IdPozo

UPDATE CG
SET	PesoMolecularGas = 	(CG.C1MOL * PM.C1/100) + (CG.C2MOL * PM.C2/100) + (CG.C3MOL * PM.C3/100) +
    (CG.NC4MOL * PM.nC4/100) + (CG.IC4MOL * PM.IC4/100) + (CG.NC5MOL * PM.nC5/100) + (CG.IC5MOL * PM.IC5/100) +
    (CG.C6MOL * PM.C6/100) + (CG.CO2MOL * PM.CO2/100) + (CG.H2S * PM.H2S / 100) + (CG.N2 * PM.N2 / 100)
FROM
    CO_PesoMolecularGPA2145	PM
CROSS JOIN
	#ConversionGas	CG

--IF @BitConciliada = 1
--BEGIN
-- SE INSERTAN LOS VALORES DE LOS CONTRATOS CON PRODUCCION CONCILIADA
	INSERT INTO #PromPonderado
	(
		IdContrato,
		IdPozo,
		--GradosAPI,
		--ContenidoAzufre,
		--ContenidoSal,
		--Agua,
		Condensado,
		Petroleo
	)
	SELECT
		CC.IdContrato,
		PDP.Pozo,
		--SUM(ISNULL(PDP.GradosAPI,0)),
		--SUM(ISNULL(PDP.ContenidoAzufre,0)),
		--SUM(ISNULL(PDP.ContenidoSal,0)),
		--SUM(ISNULL(PDP.PctAguaControl,0)),
		SUM(ISNULL(PDP.ProduccionRealCondensado,0)),
		SUM(ISNULL(PDP.ProduccionReal,0))
	FROM
		#ContratosConciliada	CC
	JOIN
		dbo.CO_Contrato	C
		ON	CC.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_ProdDiariaPozo	PDP
		ON	P.Id	=	PDP.Pozo
		AND	YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
	WHERE
		I.Activo = 1
	GROUP BY
		CC.IdContrato,
		PDP.Pozo


	UPDATE	pp
		SET	
			GradosAPI	=	CROMA.GradosAPI,
			ContenidoAzufre	=	CROMA.Azufre,
			ContenidoSal	=	CROMA.SalLBS_1000BLS,
			Agua	=	CROMA.AguaSedimento,
			SinCalidad	= 0
	FROM
		#ContratosConciliada	CC
	JOIN
		dbo.CO_Contrato	C
		ON	CC.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN	
		dbo.CO_Cromatografia	CR
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	JOIN
		CO_CromatografiaValores	CROMA
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	JOIN
		#PromPonderado	PP
		ON	PEC.IdContrato	=	PP.IdContrato	
		AND	P.Id	=	PP.IdPozo
	WHERE
		I.Activo = 1

	INSERT INTO #PromPonderado
	(
		IdContrato,
		IdPozo,
		--GradosAPI,
		--ContenidoAzufre,
		--ContenidoSal,
		Agua,
		Condensado,
		Petroleo
	)
	SELECT
		CD.IdContrato,
		PDP.Pozo,
		--SUM(ISNULL(PDP.GradosAPI,0)),
		--SUM(ISNULL(PDP.ContenidoAzufre,0)),
		--SUM(ISNULL(PDP.ContenidoSal,0)),
		SUM(ISNULL(PDP.Agua,0)),
		SUM(ISNULL(PDP.ProdCondensadoNeto,0)),
		SUM(ISNULL(PDP.ProdPetroleoBruto,0))
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_ProdDiariaPozo_Previo	PDP
		ON	P.Id	=	PDP.Pozo
		AND	YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
		AND PDP.Fecha	<=	@FechaFin
	WHERE
		I.Activo = 1
	GROUP BY
		CD.IdContrato,
		PDP.Pozo

	UPDATE	pp
		SET	
			GradosAPI	=	CROMA.GradosAPI,
			ContenidoAzufre	=	CROMA.Azufre,
			ContenidoSal	=	CROMA.SalLBS_1000BLS,
			SinCalidad	=	0
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN	
		dbo.CO_Cromatografia	CR
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	JOIN
		CO_CromatografiaValores	CROMA
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	JOIN
		#PromPonderado	PP
		ON	PEC.IdContrato	=	PP.IdContrato
		AND	P.Id	=	PP.IdPozo
	WHERE
		I.Activo = 1

UPDATE #PromPonderado
	SET SinCalidad = 1
WHERE
	SinCalidad IS NULL

-- SE BUSCA LA CALIDAD DEL MES ANTERIOR
UPDATE PP
	SET
		GradosAPI	=	ISNULL(CROMA.GradosAPI,0),
		ContenidoSal	=ISNULL(CROMA.SalLBS_1000BLS,0),
		ContenidoAzufre	=	ISNULL(CROMA.Azufre,0)
FROM
	#PromPonderado	PP
JOIN
	dbo.PR_Pozo	P
	ON	PP.IdPozo	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	PP.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN
	dbo.CO_Cromatografia	CRO
	ON	PEC.IdContrato	=	CRO.IdContrato
	AND	YEAR(DATEADD(MONTH, -1, @MesReporte)) = CRO.Anio
	AND	MONTH(DATEADD(MONTH, -1, @MesReporte))	=	CRO.Mes
LEFT JOIN
	dbo.CO_CromatografiaValores	CROMA
	ON	CRO.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
WHERE
	PP.SinCalidad	=	1

INSERT INTO #PromPonderadoAC
(
	IdContrato,
	GradosAPI,
	ContenidoAzufre,
	ContenidoSal,
	Condensado,
	Petroleo
)
SELECT
	P.IdContrato,
	SUM(P.GradosAPI),
	SUM(P.ContenidoAzufre),
	SUM(P.ContenidoSal),
	SUM(P.Condensado),
	SUM(P.Petroleo)
FROM
	#PromPonderado	P
GROUP BY
	P.IdContrato

INSERT INTO #ValAPIAC
(
	IdContrato,
    GradosAPI,
    ContenidoAzufre,
    ContenidoSal,
	Condensado
)
SELECT
	PP.IdContrato,
	SUM(CASE WHEN PPAC.Petroleo = 0 THEN 0 ELSE (PP.GradosAPI * PP.Petroleo)/PPAC.Petroleo END),
	SUM(CASE WHEN PPAC.Petroleo = 0 THEN 0 ELSE (PP.ContenidoAzufre * PP.Petroleo)/PPAC.Petroleo END),
	SUM(CASE WHEN PPAC.Petroleo = 0 THEN 0 ELSE (PP.ContenidoSal * PP.Petroleo)/PPAC.Petroleo END),
	SUM(CASE WHEN PPAC.Condensado = 0 THEN 0 ELSE PP.Condensado * (PP.Condensado/PPAC.Condensado) END)
FROM
	#PromPonderado	PP
JOIN
	#PromPonderadoAC	PPAC
	ON	PP.IdContrato	=	PPAC.IdContrato
GROUP BY
	PP.IdContrato


INSERT INTO #ConversionGasAC
(
	IdContrato,
    MMPC_Gas,
    C1MOL,
    C2MOL,
    C3MOL,
    NC4MOL,
    IC4MOL,
    NC5MOL,
    IC5MOL,
    C6MOL,
    CO2MOL,
    H2S,
	N2,
    C1MMBTU,
    C2MMBTU,
    C3MMBTU,
    NC4MMBTU,
    IC4MMBTU,
    NC5MMBTU,
    IC5MMBTU,
    C6MMBTU,
    PCC1,
    PCC2,
    PCC3,
    PCNC4,
    PCIC4,
  PCNC5,
    PCIC5,
    PCC6,
    PesoMolecularGas,
	C5EqBl
)
SELECT
	IdContrato,
	SUM(MMPC_Gas),
    SUM(C1MOL),
    SUM(C2MOL),
    SUM(C3MOL),
    SUM(NC4MOL),
    SUM(IC4MOL),
    SUM(NC5MOL),
    SUM(IC5MOL),
    SUM(C6MOL),
    SUM(CO2MOL),
   SUM(H2S),
    SUM(N2),
  SUM(C1MMBTU),
    SUM(C2MMBTU),
    SUM(C3MMBTU),
    SUM(NC4MMBTU),
    SUM(IC4MMBTU),
    SUM(NC5MMBTU),
    SUM(IC5MMBTU),
    SUM(C6MMBTU),
    SUM(PCC1),
    SUM(PCC2),
    SUM(PCC3),
    SUM(PCNC4),
    SUM(PCIC4),
    SUM(PCNC5),
    SUM(PCIC5),
    SUM(PCC6),
    SUM(PesoMolecularGas),
	SUM(C5EqBl)
FROM
	#ConversionGas
GROUP BY
	IdContrato

-- CALCULAR LOS PORCENTAJES MOLARES POR AREA CONTRACTUAL
INSERT INTO #ValoresAC
(
	IdContrato,
    MMPC_Gas,
    C1MOL,
    C2MOL,
    C3MOL,
    NC4MOL,
    IC4MOL,
    NC5MOL,
    IC5MOL,
    C6MOL,
    CO2MOL,
    H2S,
    N2,
    C1MMBTU,
    C2MMBTU,
    C3MMBTU,
    NC4MMBTU,
    IC4MMBTU,
    NC5MMBTU,
    IC5MMBTU,
    C6MMBTU,
    PCC1,
    PCC2,
    PCC3,
    PCNC4,
    PCIC4,
    PCNC5,
    PCIC5,
    PCC6,
    PesoMolecularGas,
	C5EqBl
)
SELECT
	CG.IdContrato,
	SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE CG.MMPC_Gas * (CG.MMPC_Gas/CGAC.MMPC_Gas) END),
	SUM(CASE WHEN CGAC.C1MMBTU = 0 THEN 0 ELSE (CG.C1MMBTU * CG.C1MOL )/ CGAC.C1MMBTU END),
	SUM(CASE WHEN CGAC.C2MMBTU = 0 THEN 0 ELSE  (CG.C2MMBTU * CG.C2MOL )/ CGAC.C2MMBTU END),
	SUM(CASE WHEN CGAC.C3MMBTU = 0 THEN 0 ELSE  (CG.C3MMBTU * CG.C3MOL )/ CGAC.C3MMBTU END),
	SUM(CASE WHEN CGAC.NC4MMBTU = 0 THEN 0 ELSE  (CG.NC4MMBTU * CG.NC4MOL )/ CGAC.NC4MMBTU END),
	SUM(CASE WHEN CGAC.IC4MMBTU = 0 THEN 0 ELSE  (CG.IC4MMBTU * CG.IC4MOL )/ CGAC.IC4MMBTU END),
	SUM(CASE WHEN CGAC.NC5MMBTU = 0 THEN 0 ELSE  (CG.NC5MMBTU * CG.NC5MOL )/ CGAC.NC5MMBTU END),
	SUM(CASE WHEN CGAC.IC5MMBTU = 0 THEN 0 ELSE  (CG.IC5MMBTU * CG.IC5MOL )/ CGAC.IC5MMBTU END),
	SUM(CASE WHEN CGAC.C6MMBTU = 0 THEN 0 ELSE  (CG.C6MMBTU * CG.C6MOL )/ CGAC.C6MMBTU END),
    SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.CO2MOL)/CGAC.MMPC_Gas END),
    SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.H2S)/CGAC.MMPC_Gas END),
    SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.N2)/CGAC.MMPC_Gas END),
	SUM(CASE WHEN CGAC.C1MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C1MMBTU)/CGAC.C1MMBTU END),
	SUM(CASE WHEN CGAC.C2MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C2MMBTU)/CGAC.C2MMBTU END),
	SUM(CASE WHEN CGAC.C3MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C3MMBTU)/CGAC.C3MMBTU END),
	SUM(CASE WHEN CGAC.NC4MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.NC4MMBTU)/CGAC.NC4MMBTU END),
	SUM(CASE WHEN CGAC.IC4MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.IC4MMBTU)/CGAC.IC4MMBTU END),
	SUM(CASE WHEN CGAC.NC5MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.NC5MMBTU)/CGAC.NC5MMBTU END),
    SUM(CASE WHEN CGAC.IC5MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.IC5MMBTU)/CGAC.IC5MMBTU END),
    SUM(CASE WHEN CGAC.C6MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C6MMBTU)/CGAC.C6MMBTU END),
	SUM( CASE WHEN CGAC.C1MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas)/CGAC.C1MMBTU END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCC1)/ CGAC.MMPC_Gas END),
	SUM( CASE WHEN CGAC.C2MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C2MMBTU/CG.PoderCalorifico_Gas)/CGAC.C2MMBTU END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCC2)/ CGAC.MMPC_Gas END),
	SUM( CASE WHEN CGAC.C3MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C3MMBTU/CG.PoderCalorifico_Gas)/CGAC.C3MMBTU END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCC3)/ CGAC.MMPC_Gas END),
	SUM( CASE WHEN CGAC.NC4MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.NC4MMBTU/CG.PoderCalorifico_Gas)/CGAC.NC4MMBTU END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCNC4)/ CGAC.MMPC_Gas END),
	SUM( CASE WHEN CGAC.IC4MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.IC4MMBTU/CG.PoderCalorifico_Gas)/CGAC.IC4MMBTU END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCIC4)/ CGAC.MMPC_Gas END),
	SUM( CASE WHEN CGAC.NC5MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.NC5MMBTU/CG.PoderCalorifico_Gas)/CGAC.NC5MMBTU END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCNC5)/ CGAC.MMPC_Gas END),
	SUM( CASE WHEN CGAC.IC5MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.IC5MMBTU/CG.PoderCalorifico_Gas)/CGAC.IC5MMBTU END),
    --SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCIC5)/ CGAC.MMPC_Gas END),
	SUM( CASE WHEN CGAC.C6MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C6MMBTU/CG.PoderCalorifico_Gas)/CGAC.C6MMBTU END),
    --SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCC6)/ CGAC.MMPC_Gas END),
	SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PesoMolecularGas)/ CGAC.MMPC_Gas END),
	SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C5EqBl)/ CGAC.MMPC_Gas END)
FROM
	#ConversionGas	CG
--CROSS JOIN #VolumenesComponente VC
JOIN
	#ConversionGasAC	CGAC
	ON	CG.IdContrato	=	CGAC.IdContrato
GROUP BY
	CG.IdContrato


-- SE GENERAN LOS VALORES PARA LA CONVERSION DE TEMPERATURA
UPDATE #PromPonderado
	SET KgM3 = (141.5 / (GradosAPI + 131.5)) * 999.012,
		KgM3_Condensado	=	(141.5 / (0 + 131.5)) * 999.012	-- 0 --> Grados API del Condensado

UPDATE #PromPonderado
	SET Alfa	=	(341.0957 / POWER( KgM3, 2 )),
		Alfa_Condensado	=	(341.0957 / POWER( KgM3_Condensado, 2 ))

UPDATE #PromPonderado
	SET	CTL	=	EXP( -Alfa * 8 * (1 + 0.8 * Alfa * 8)),
		CTL_Condensado	=	EXP( -Alfa_Condensado * 8 * (1 + 0.8 * Alfa_Condensado * 8))


INSERT INTO #Petroleo15_16XPozo
(
	IdContrato,
	IdPozo,
	ProdPetroleoBruto,
	ProdPetroleoNeto
)
SELECT
	P.IdContrato,
	P.IdPozo,
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoBruto * PP.CTL,3)
		ELSE ROUND(P.ProdPetroleoBruto,3) END),
--	SUM(ROUND(P.ProdPetroleoBruto * PP.CTL,3)),
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoNeto * PP.CTL,3)
		ELSE ROUND(P.ProdPetroleoNeto,3) END)
	--SUM(ROUND(P.ProdPetroleoNeto * PP.CTL,3))
FROM
	#Petroleo15_16	P
JOIN
	#PromPonderado	PP
	ON	P.IdContrato	=	PP.IdContrato
	AND	P.IdPozo		=	PP.IdPozo
GROUP BY
	P.IdContrato,
	P.IdPozo

UPDATE	VTH
	SET
		--ProdPetroleoBruto_15_56	=	ROUND(VTH.ProdPetroleoBruto * PP.CTL,3),
		--ProdPetroleoNeto_15_56	=	ROUND(VTH.ProdPetroleoNeto * PP.CTL,3),
		ProdCondensadoNeto_15_56	=	ProdCondensadoNeto_15_56 + ROUND(VTH.ProdCondensadoNeto * PP.CTL_Condensado,3)
FROM
	#VolumenesTotalesHidro	VTH
JOIN
	#PromPonderado	PP
	ON	VTH.IdContrato	=	PP.IdContrato
	AND	VTH.IdPozo		=	PP.IdPozo

-- SI ES REPORTE DIARIO, SOLO SE MOSTRARAN LOS DATOS DEL DIA A CONSULTAR
--IF @BitDiario = 1 OR (@BitDiario = 0 AND @BitConciliada = 0)
--BEGIN



	---RESULTADO 1
	if @resultadoDeseado in (0,1)
	begin
	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		P.RegionFiscal		AS [Región Fiscal],
		CA.Nombre			AS [Nombre del Campo],
		CASE WHEN ISNULL(P.Clave,'') = ''
			THEN 'N/A'
			ELSE P.Clave
		END					AS [ID de Pozo SEGUN ANEXO 3 POZOS],
		P.Nombre			AS [Nombre del Pozo SEGUN ANEXO 3 POZOS],
		@MesReporte			AS [Fecha],
		ISNULL(DO.NumDias,0)			AS [Días de Producción],
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END 		AS [Tipo de Fluido],
		ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3)		AS [Producción de Petróleo Bruto],
		ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3)		AS [Producción de Petróleo Neto],
		--SUM(CASE WHEN ISNULL(PP.GradosAPI,0) = 0 THEN 0 ELSE ISNULL(PDP.GradosAPI,0)/PP.GradosAPI END)			AS [°API],
		ISNULL(PP.GradosAPI,0)			AS [°API],
		ISNULL(PP.ContenidoAzufre,0)	AS [% AZUFRE],
		--SUM(CASE WHEN ISNULL(PP.ContenidoAzufre,0) = 0  THEN 0 ELSE ROUND(ISNULL(PDP.ContenidoAzufre,0)/PP.ContenidoAzufre,3) END)				AS [% AZUFRE],
		ISNULL(PP.ContenidoSal,0)		AS [SAL],
		--SUM(CASE WHEN ISNULL(PP.ContenidoSal,0) = 0 THEN 0 ELSE ROUND(ISNULL(PDP.ContenidoSal,0)/PP.ContenidoSal,3) END)					AS [SAL],
		ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3)	AS [Producción de Condesado Neto],
		--SUM(CASE WHEN PP.Agua = 0 THEN 0 ELSE PDP.PctAguaControl/PP.Agua END)		AS [Producción de Agua Neto],
		ROUND(ISNULL(VTH.ProdAgua,0),3)		AS [Producción de Agua Neto],
		--SUM(
		CASE WHEN C.GasNoAsociado = 0
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
			ELSE	0
		END						AS [Producción de Gas Asociado],
		--SUM(
		CASE WHEN C.GasNoAsociado = 1
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
			ELSE	0
		END						AS [Producción de Gas No Asociado],
		ROUND(ISNULL(CG.C1MOL,0),3)					AS [C1],
		ROUND(ISNULL(CG.C2MOL,0),3)					AS [C2],
		ROUND(ISNULL(CG.C3MOL,0),3)					AS [C3],
		ROUND(ISNULL(CG.NC4MOL,0),3)				AS [C4],
		ROUND(ISNULL(CG.IC4MOL,0),3)				AS [iC4],
		ROUND(ISNULL(CG.NC5MOL,0),3)				AS [C5],
		ROUND(ISNULL(CG.IC5MOL,0),3)				AS [iC5],
		ROUND(ISNULL(CG.C6MOL,0),3)					AS [C6],
		ROUND(ISNULL(CG.CO2MOL,0),3)				AS [CO2],
		ROUND(ISNULL(CG.H2S,0),3)					AS [H2S],
		ROUND(ISNULL(CG.N2,0),3)					AS [N2],
		ROUND(SUM(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)),3) AS [Poder Calorífico del Gas],
		ROUND(SUM(ISNULL(CG.PesoMolecularGas,0)),3)		AS [Peso Molecular del Gas],
		ROUND(SUM(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)),3) AS [Energía de Gas],
		CASE WHEN APIAC.Condensado = 0 THEN 0 ELSE ROUND(VAC.MMPC_Gas/APIAC.Condensado,3) END		AS [RGA (ASIG-AC)],
		ROUND(ISNULL(APIAC.GradosAPI,0),3)			AS [API (ASIG-AC)],
		ROUND(ISNULL(APIAC.ContenidoAzufre,0),3)		AS [% S (ASIG-AC)],
		ROUND(ISNULL(APIAC.ContenidoSal,0),3)		AS [SAL (ASIG-AC)],
		ROUND(ISNULL(CG.PoderCalorifico,0),3)		AS [PODER CALORIFICO DE PETROLEO],
		ROUND(ISNULL(VAC.C1MOL,0),3)				AS [C1 (ASIG-AC)],
		ROUND(ISNULL(VAC.C2MOL,0),3)				AS [C2 (Asig - AC)],
		ROUND(ISNULL(VAC.C3MOL,0),3)				AS [C3 (Asig - AC)],
		ROUND(ISNULL(VAC.NC4MOL,0),3)				AS [C4 (Asig - AC)],
		ROUND(ISNULL(VAC.IC4MOL,0),3)				AS [IC4 (Asig - AC)],
		ROUND(ISNULL(VAC.NC5MOL,0),3)				AS [C5 (Asig - AC)],
		ROUND(ISNULL(VAC.IC5MOL,0),3)				AS [IC5 (Asig - AC)],
		ROUND(ISNULL(VAC.C6MOL,0),3)				AS [C6+ (Asig - AC)],
		ROUND(ISNULL(VAC.CO2MOL,0),3)				AS [CO2 (Asig - AC)],
		ROUND(ISNULL(VAC.H2S,0),3)					AS [H2S (Asig - AC)],
		ROUND(ISNULL(VAC.N2,0),3)					AS [N2 (Asig - AC)],
		ROUND(ISNULL(VAC.PCC1,0),3)					AS [Poder Calorífico C1 (Asig - AC)],
		ROUND(ISNULL(VAC.PCC2,0),3)					AS [Poder Calorífico C2 (Asig - AC)],
		ROUND(ISNULL(VAC.PCC3,0),3)					AS [Poder Calorífico C3 (Asig - AC)],
		--VAC.PCNC4 + VAC.PCIC4	AS [Poder Calorífico C4 (Asig - AC)],
		ROUND(ISNULL(VAC.PCNC4,0),3) 				AS [Poder Calorífico C4 (Asig - AC)],
		ROUND(ISNULL(VAC.PCIC4,0),3)				AS [Poder Calorífico IC4 (Asig - AC)],
		--VAC.PCNC5 + VAC.PCIC5	AS [Poder Calorífico C5 (Asig - AC)],
		ROUND(ISNULL(VAC.PCNC5,0),3) 				AS [Poder Calorífico C5 (Asig - AC)],
		ROUND(ISNULL(VAC.PCIC5,0),3)				AS [Poder Calorífico IC5 (Asig - AC)],
		ROUND(ISNULL(VAC.PCC6,0),3)					AS [Poder Calorífico C6+ (Asig - AC)],
		ROUND(ISNULL(VAC.PCC1,0)+ISNULL(VAC.PCC2,0)+ISNULL(VAC.PCC3,0)+ISNULL(VAC.PCNC4,0)+ISNULL(VAC.PCIC4,0)+ISNULL(VAC.PCNC5,0)+ISNULL(VAC.PCIC5,0)+ISNULL(VAC.PCC6,0),3)	AS [Poder Calorífico de Asiganción (Asig - AC)],
		ROUND(ISNULL(VAC.C1MMBTU,0)+ISNULL(VAC.C2MMBTU,0)+ISNULL(VAC.C3MMBTU,0)+ISNULL(VAC.NC4MMBTU,0)+ISNULL(VAC.IC4MMBTU,0)+ISNULL(VAC.NC5MMBTU,0)+ISNULL(VAC.IC5MMBTU,0)+ISNULL(VAC.C6MMBTU,0),3)	AS [Energía de Gas (Asig - AC)],
		ROUND(ISNULL(VAC.C5EqBl,0),3)			AS [Vol C5+ (Asig - AC)],
		ROUND(ISNULL(VAC.PCNC5 + VAC.PCIC5 + VAC.PCC6,0),3)	AS [Poder Calorífico de C5+ (Asig - AC)],
		CASE WHEN ISNULL(EC.Eventos,'') = '' THEN 'N/A'
			ELSE EC.Eventos
		END				AS [Eventos]
	
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		PR_ProdDiariaPozo_Previo	PDPP
		ON	P.Id	=	PDPP.Pozo
		AND PDPP.Fecha <= @FechaFin
		--AND YEAR(PDPP.Fecha)	=	YEAR(@MesReporte)
		--AND MONTH(PDPP.Fecha)	=	MONTH(@MesReporte)
	LEFT JOIN
		PR_EventosMensualesPozo	EC
		ON	P.Id	=	EC.IdPozo
		AND YEAR(EC.MesReporte)	=	YEAR(@MesReporte)
		AND MONTH(EC.MesReporte)	=	MONTH(@MesReporte)	
		--#EventosXContrato	EC
		--ON	PEC.idContrato	=	EC.IdContrato
	LEFT JOIN
		#Petroleo15_16XPozo	P15_56
		ON PEC.idContrato	=	P15_56.IdContrato
		AND	PDPP.Pozo		=	P15_56.IdPozo
	LEFT JOIN
		#PromPonderado	PP
		ON	PEC.IdContrato	=	PP.IdContrato
		AND	PDPP.Pozo	=	PP.IdPozo
	LEFT JOIN
		#DiasOperacion	DO
		ON	PEC.IdContratO	=	DO.IdContrato
		AND	PDPP.Pozo	=	DO.IdPozo
	LEFT JOIN
		#VolumenesTotalesHidro	VTH
		ON	PEC.IdContrato	=	VTH.IdContrato
		AND PDPP.Pozo	=	VTH.IdPozo
	LEFT JOIN
		dbo.PR_Campo	CA
		ON	P.Campo	=	CA.Id
	LEFT JOIN
		#ConversionGas	CG
		ON	PEC.idContrato	=	CG.IdContrato
		AND	P.Id	=	CG.IdPozo
	LEFT JOIN
		dbo.PR_ProdDiariaPozo	PDP
		ON	P.Id	=	PDP.Pozo
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	--CROSS JOIN
	--	#PromPonderadoAC	PPAC
	JOIN
		#ValoresAC		VAC
		ON	PEC.idContrato		=	VAC.IdContrato
	JOIN           
		#ValAPIAC	APIAC
		ON	PEC.idContrato	=	APIAC.IdContrato
	WHERE
		--C.IdContrato	=	@Contrato
		--AND
		YEAR(@MesReporte) = YEAR(PDPP.Fecha)
		AND
		MONTH(@MesReporte) = MONTH(PDPP.Fecha)
		AND
		I.Activo = 1
	GROUP BY
		C.NumeroContrato,
		P.RegionFiscal,
		CA.Nombre,
		CASE WHEN ISNULL(P.Clave,'') = ''
			THEN 'N/A'
			ELSE P.Clave
		END,
		P.Nombre,
		ISNULL(DO.NumDias,0),
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END,

		ISNULL(PP.GradosAPI,0),
		ISNULL(PP.ContenidoAzufre,0),
		ISNULL(PP.ContenidoSal,0),

		ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3),
		ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3),
		ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3),
		ROUND(ISNULL(VTH.ProdAgua,0),3),
		CASE WHEN C.GasNoAsociado = 0
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
			ELSE	0
		END,
		CASE WHEN C.GasNoAsociado = 1
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
			ELSE	0
		END,
		ROUND(ISNULL(CG.C1MOL,0),3),
		ROUND(ISNULL(CG.C2MOL,0),3),
		ROUND(ISNULL(CG.C3MOL,0),3),
		ROUND(ISNULL(CG.NC4MOL,0),3),
		ROUND(ISNULL(CG.IC4MOL,0),3),
		ROUND(ISNULL(CG.NC5MOL,0),3),
		ROUND(ISNULL(CG.IC5MOL,0),3),
		ROUND(ISNULL(CG.C6MOL,0),3),
		ROUND(ISNULL(CG.CO2MOL,0),3),
		ROUND(ISNULL(CG.H2S,0),3),
		ROUND(ISNULL(CG.N2,0),3),
		ROUND(ISNULL(CG.PoderCalorifico,0),3),
		CASE WHEN APIAC.Condensado = 0 
			THEN 0 ELSE ROUND(VAC.MMPC_Gas/APIAC.Condensado,3) 
		END,
		ROUND(ISNULL(APIAC.GradosAPI,0),3),
		ROUND(ISNULL(APIAC.ContenidoAzufre,0),3),
		ROUND(ISNULL(APIAC.ContenidoSal,0),3),
		ROUND(ISNULL(VAC.C1MOL,0),3),
		ROUND(ISNULL(VAC.C2MOL,0),3),
		ROUND(ISNULL(VAC.C3MOL,0),3),
		ROUND(ISNULL(VAC.NC4MOL,0),3),
		ROUND(ISNULL(VAC.IC4MOL,0),3),
		ROUND(ISNULL(VAC.NC5MOL,0),3),
		ROUND(ISNULL(VAC.IC5MOL,0),3),
		ROUND(ISNULL(VAC.C6MOL,0),3),
		ROUND(ISNULL(VAC.CO2MOL,0),3),
		ROUND(ISNULL(VAC.H2S,0),3),
		ROUND(ISNULL(VAC.N2,0),3),
		ROUND(ISNULL(VAC.PCC1,0),3),
		ROUND(ISNULL(VAC.PCC2,0),3),
		ROUND(ISNULL(VAC.PCC3,0),3),
		ROUND(ISNULL(VAC.PCNC4,0),3),
		ROUND(ISNULL(VAC.PCIC4,0),3),
		ROUND(ISNULL(VAC.PCNC5,0),3),
		ROUND(ISNULL(VAC.PCIC5,0),3),
		ROUND(ISNULL(VAC.PCC6,0),3),
		ROUND(ISNULL(VAC.PCC1,0)+ISNULL(VAC.PCC2,0)+ISNULL(VAC.PCC3,0)+ISNULL(VAC.PCNC4,0)+ISNULL(VAC.PCIC4,0)+ISNULL(VAC.PCNC5,0)+ISNULL(VAC.PCIC5,0)+ISNULL(VAC.PCC6,0),3),
		ROUND(ISNULL(VAC.C1MMBTU,0)+ISNULL(VAC.C2MMBTU,0)+ISNULL(VAC.C3MMBTU,0)+ISNULL(VAC.NC4MMBTU,0)+ISNULL(VAC.IC4MMBTU,0)+ISNULL(VAC.NC5MMBTU,0)+ISNULL(VAC.IC5MMBTU,0)+ISNULL(VAC.C6MMBTU,0),3),
		ROUND(ISNULL(VAC.C5EqBl,0),3),
		ROUND(ISNULL(VAC.PCNC5 + VAC.PCIC5 + VAC.PCC6,0),3),
		CASE WHEN ISNULL(EC.Eventos,'') = '' THEN 'N/A'
			ELSE EC.Eventos
		END
	--ORDER BY
	--	P.Nombre

	UNION

	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		P.RegionFiscal		AS [Región Fiscal],
		CA.Nombre			AS [Nombre del Campo],
		CASE WHEN ISNULL(P.Clave,'') = ''
			THEN 'N/A'
			ELSE P.Clave
		END					AS [ID de Pozo SEGUN ANEXO 3 POZOS],
		P.Nombre			AS [Nombre del Pozo SEGUN ANEXO 3 POZOS],
		@MesReporte			AS [Fecha],
		ISNULL(DO.NumDias,0)			AS [Días de Producción],
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END 		AS [Tipo de Fluido],
		--ROUND(VTH.ProdPetroleoBruto,3)		AS [Producción de Petróleo Bruto],
		ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3)		AS [Producción de Petróleo Bruto],
		--ROUND(VTH.ProdPetroleoNeto,3)			AS [Producción de Petróleo Neto],
		ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3)			AS [Producción de Petróleo Neto],
		ISNULL(PP.GradosAPI,0)			AS [°API],
		ISNULL(PP.ContenidoAzufre,0)	AS [% AZUFRE],
		ISNULL(PP.ContenidoSal,0)		AS [SAL],
		--SUM(CASE WHEN ISNULL(PP.GradosAPI,0) = 0 THEN 0 ELSE ROUND(ISNULL(PDP.GradosAPI,0)/PP.GradosAPI,3) END)			AS [°API],
		--SUM(CASE WHEN ISNULL(PP.ContenidoAzufre,0) = 0  THEN 0 ELSE ROUND(ISNULL(PDP.ContenidoAzufre,0)/PP.ContenidoAzufre,3) END)				AS [% AZUFRE],
		--SUM(CASE WHEN ISNULL(PP.ContenidoSal,0) = 0 THEN 0 ELSE ROUND(ISNULL(PDP.ContenidoSal,0)/PP.ContenidoSal,3) END)					AS [SAL],
		--ROUND(VTH.ProdCondensadoNeto,3)	AS [Producción de Condesado Neto],
		ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3)	AS [Producción de Condesado Neto],
		--SUM(CASE WHEN PP.Agua = 0 THEN 0 ELSE PDP.PctAguaControl/PP.Agua END)		AS [Producción de Agua Neto],
		ROUND(ISNULL(VTH.ProdAgua,0),3)	AS [Producción de Agua Neto],
		--SUM(
		CASE WHEN C.GasNoAsociado = 0
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
			ELSE	0
		END						AS [Producción de Gas Asociado],
		--SUM(
		CASE WHEN C.GasNoAsociado = 1
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
			ELSE	0
		END						AS [Producción de Gas No Asociado],
		ROUND(ISNULL(CG.C1MOL,0),3)					AS [C1],
		ROUND(ISNULL(CG.C2MOL,0),3)					AS [C2],
		ROUND(ISNULL(CG.C3MOL,0),3)					AS [C3],
		ROUND(ISNULL(CG.IC4MOL,0),3)				AS [C4],
		ROUND(ISNULL(CG.IC4MOL,0),3)				AS [iC4],
		ROUND(ISNULL(CG.IC5MOL,0),3)				AS [C5],
		ROUND(ISNULL(CG.IC5MOL,0),3)				AS [iC5],
		ROUND(ISNULL(CG.C6MOL,0),3)					AS [C6],
		ROUND(ISNULL(CG.CO2MOL,0),3)				AS [CO2],
		ROUND(ISNULL(CG.H2S,0),3)					AS [H2S],
		ROUND(ISNULL(CG.N2,0),3)					AS [N2],
		ROUND(SUM(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)),3) AS [Poder Calorífico del Gas],
		ROUND(SUM(ISNULL(CG.PesoMolecularGas,0)),3)		AS [Peso Molecular del Gas],
		ROUND(SUM(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)),3) AS [Energía de Gas],
		CASE WHEN APIAC.Condensado = 0 THEN 0 ELSE ROUND(VAC.MMPC_Gas/APIAC.Condensado,3) END		AS [RGA (ASIG-AC)],
		ROUND(ISNULL(APIAC.GradosAPI,0),3)		AS [API (ASIG-AC)],
		ROUND(ISNULL(APIAC.ContenidoAzufre,0),3)		AS [% S (ASIG-AC)],
		ROUND(ISNULL(APIAC.ContenidoSal,0),3)		AS [SAL (ASIG-AC)],
		ROUND(ISNULL(CG.PoderCalorifico,0),3)		AS [PODER CALORIFICO DE PETROLEO],
		ROUND(ISNULL(VAC.C1MOL,0),3)				AS [C1 (ASIG-AC)],
		ROUND(ISNULL(VAC.C2MOL,0),3)				AS [C2 (Asig - AC)],
		ROUND(ISNULL(VAC.C3MOL,0),3)				AS [C3 (Asig - AC)],
		ROUND(ISNULL(VAC.NC4MOL,0),3)				AS [C4 (Asig - AC)],
		ROUND(ISNULL(VAC.IC4MOL,0),3)				AS [IC4 (Asig - AC)],
		ROUND(ISNULL(VAC.NC5MOL,0),3)				AS [C5 (Asig - AC)],
		ROUND(ISNULL(VAC.IC5MOL,0),3)				AS [IC5 (Asig - AC)],
		ROUND(ISNULL(VAC.C6MOL,0),3)				AS [C6+ (Asig - AC)],
		ROUND(ISNULL(VAC.CO2MOL,0),3)				AS [CO2 (Asig - AC)],
		ROUND(ISNULL(VAC.H2S,0),3)					AS [H2S (Asig - AC)],
		ROUND(ISNULL(VAC.N2,0),3)					AS [N2 (Asig - AC)],
		ROUND(ISNULL(VAC.PCC1,0),3)				AS [Poder Calorífico C1 (Asig - AC)],
		ROUND(ISNULL(VAC.PCC2,0),3)				AS [Poder Calorífico C2 (Asig - AC)],
		ROUND(ISNULL(VAC.PCC3,0),3)				AS [Poder Calorífico C3 (Asig - AC)],
		--VAC.PCNC4 + VAC.PCIC4	AS [Poder Calorífico C4 (Asig - AC)],
		ROUND(ISNULL(VAC.PCNC4,0),3) 	AS [Poder Calorífico C4 (Asig - AC)],
		ROUND(ISNULL(VAC.PCIC4,0),3)				AS [Poder Calorífico IC4 (Asig - AC)],
		--VAC.PCNC5 + VAC.PCIC5	AS [Poder Calorífico C5 (Asig - AC)],
		ROUND(ISNULL(VAC.PCNC5,0),3) 	AS [Poder Calorífico C5 (Asig - AC)],
		ROUND(ISNULL(VAC.PCIC5,0),3)				AS [Poder Calorífico IC5 (Asig - AC)],
		ROUND(ISNULL(VAC.PCC6,0),3)				AS [Poder Calorífico C6+ (Asig - AC)],
		ROUND(ISNULL(VAC.PCC1,0)+ISNULL(VAC.PCC2,0)+ISNULL(VAC.PCC3,0)+ISNULL(VAC.PCNC4,0)+ISNULL(VAC.PCIC4,0)+ISNULL(VAC.PCNC5,0)+ISNULL(VAC.PCIC5,0)+ISNULL(VAC.PCC6,0),3)	AS [Poder Calorífico de Asiganción (Asig - AC)],
		ROUND(ISNULL(VAC.C1MMBTU,0)+ISNULL(VAC.C2MMBTU,0)+ISNULL(VAC.C3MMBTU,0)+ISNULL(VAC.NC4MMBTU,0)+ISNULL(VAC.IC4MMBTU,0)+ISNULL(VAC.NC5MMBTU,0)+ISNULL(VAC.IC5MMBTU,0)+ISNULL(VAC.C6MMBTU,0),3)	AS [Energía de Gas (Asig - AC)],
		ROUND(ISNULL(VAC.C5EqBl,0),3)			AS [Vol C5+ (Asig - AC)],
		ROUND(ISNULL(VAC.PCNC5 + VAC.PCIC5 + VAC.PCC6,0),3)	AS [Poder Calorífico de C5+ (Asig - AC)],
		CASE WHEN ISNULL(EC.Eventos,'') = '' THEN 'N/A'
			ELSE EC.Eventos
		END				AS [Eventos]
	FROM
		#ContratosConciliada	CO
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
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo	PDP
		ON	P.Id	=	PDP.Pozo
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	JOIN
		#PromPonderado	PP
		ON	PEC.idContrato	=	PP.IdContrato
		AND	PDP.Pozo	=	PP.IdPozo
	JOIN
		#DiasOperacion	DO
		ON	PEC.idContrato	=	DO.IdContrato
		AND	PDP.Pozo	=	DO.IdPozo
	JOIN
		#VolumenesTotalesHidro	VTH
		ON	PEC.idContrato	=	VTH.IdContrato
		AND	PDP.Pozo	=	VTH.IdPozo
	LEFT JOIN
		PR_EventosMensualesPozo	EC
		ON	P.Id	=	EC.IdPozo
		AND YEAR(EC.MesReporte)	=	YEAR(@MesReporte)
		AND MONTH(EC.MesReporte)	=	MONTH(@MesReporte)	
	LEFT JOIN
		dbo.PR_Campo	CA
		ON	P.Campo	=	CA.Id
	LEFT JOIN
		#ConversionGas	CG
		ON	PEC.idContrato	=	CG.IdContrato
		AND	P.Id	=	CG.IdPozo
	LEFT JOIN
		#ValoresAC		VAC
		ON	PEC.idContrato	=	VAC.IdContrato
	LEFT JOIN
		#ValAPIAC	APIAC
		ON	PEC.idContrato	=	APIAC.IdContrato
	LEFT JOIN
		#Petroleo15_16XPozo	P15_56
		ON PEC.idContrato	=	P15_56.IdContrato
		AND	PDP.Pozo		=	P15_56.IdPozo
	WHERE
		--C.IdContrato	=	@Contrato
		--AND
		YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND
		MONTH(@MesReporte) = MONTH(PDP.Fecha)
		AND
		I.Activo = 1
	GROUP BY
		C.NumeroContrato,
		P.RegionFiscal,
		CA.Nombre,
		CASE WHEN ISNULL(P.Clave,'') = ''
			THEN 'N/A'
			ELSE P.Clave
		END,
		P.Nombre,
		ISNULL(DO.NumDias,0),
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END,
		ISNULL(PP.GradosAPI,0),
		ISNULL(PP.ContenidoAzufre,0),
		ISNULL(PP.ContenidoSal,0),
		ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3),
		ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3),
		ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3),
		ROUND(ISNULL(VTH.ProdAgua,0),3),
		CASE WHEN C.GasNoAsociado = 0
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
			ELSE	0
		END,
		CASE WHEN C.GasNoAsociado = 1
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
			ELSE	0
		END,
		ROUND(ISNULL(CG.C1MOL,0),3),
		ROUND(ISNULL(CG.C2MOL,0),3),
		ROUND(ISNULL(CG.C3MOL,0),3),
		ROUND(ISNULL(CG.IC4MOL,0),3),
		ROUND(ISNULL(CG.IC4MOL,0),3),
		ROUND(ISNULL(CG.IC5MOL,0),3),
		ROUND(ISNULL(CG.IC5MOL,0),3),
		ROUND(ISNULL(CG.C6MOL,0),3),
		ROUND(ISNULL(CG.CO2MOL,0),3),
		ROUND(ISNULL(CG.H2S,0),3),
		ROUND(ISNULL(CG.N2,0),3),
		ROUND(ISNULL(CG.PoderCalorifico,0),3),
		CASE WHEN APIAC.Condensado = 0 THEN 0 
			ELSE ROUND(VAC.MMPC_Gas/APIAC.Condensado,3) 
		END,
		ROUND(ISNULL(APIAC.GradosAPI,0),3),
		ROUND(ISNULL(APIAC.ContenidoAzufre,0),3),
		ROUND(ISNULL(APIAC.ContenidoSal,0),3),
		ROUND(ISNULL(VAC.C1MOL,0),3),
		ROUND(ISNULL(VAC.C2MOL,0),3),
		ROUND(ISNULL(VAC.C3MOL,0),3),
		ROUND(ISNULL(VAC.NC4MOL,0),3),
		ROUND(ISNULL(VAC.IC4MOL,0),3),
		ROUND(ISNULL(VAC.NC5MOL,0),3),
		ROUND(ISNULL(VAC.IC5MOL,0),3),
		ROUND(ISNULL(VAC.C6MOL,0),3),
		ROUND(ISNULL(VAC.CO2MOL,0),3),
		ROUND(ISNULL(VAC.H2S,0),3),
		ROUND(ISNULL(VAC.N2,0),3),
		ROUND(ISNULL(VAC.PCC1,0),3),
		ROUND(ISNULL(VAC.PCC2,0),3),
		ROUND(ISNULL(VAC.PCC3,0),3),
		ROUND(ISNULL(VAC.PCNC4,0),3),
		ROUND(ISNULL(VAC.PCIC4,0),3),
		ROUND(ISNULL(VAC.PCNC5,0),3),
		ROUND(ISNULL(VAC.PCIC5,0),3),
		ROUND(ISNULL(VAC.PCC6,0),3),
		ROUND(ISNULL(VAC.PCC1,0)+ISNULL(VAC.PCC2,0)+ISNULL(VAC.PCC3,0)+ISNULL(VAC.PCNC4,0)+ISNULL(VAC.PCIC4,0)+ISNULL(VAC.PCNC5,0)+ISNULL(VAC.PCIC5,0)+ISNULL(VAC.PCC6,0),3),
		ROUND(ISNULL(VAC.C1MMBTU,0)+ISNULL(VAC.C2MMBTU,0)+ISNULL(VAC.C3MMBTU,0)+ISNULL(VAC.NC4MMBTU,0)+ISNULL(VAC.IC4MMBTU,0)+ISNULL(VAC.NC5MMBTU,0)+ISNULL(VAC.IC5MMBTU,0)+ISNULL(VAC.C6MMBTU,0),3),
		ROUND(ISNULL(VAC.C5EqBl,0),3),
		ROUND(ISNULL(VAC.PCNC5 + VAC.PCIC5 + VAC.PCC6,0),3),
		CASE WHEN ISNULL(EC.Eventos,'') = '' THEN 'N/A'
			ELSE EC.Eventos
		END
	ORDER BY
		C.NumeroContrato,
		P.Nombre
	end

	if @resultadoDeseado in (0,2)
	begin
	---RESULTADO 2
	/************************* AFOROS DE POZO ****************************/
	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		P.RegionFiscal		AS [Región Fiscal],		--DATO POR CONTRATO
		CA.Nombre			AS [Nombre del Campo],
		CASE WHEN ISNULL(P.Clave,'') = ''
			THEN 'N/A'
			ELSE P.Clave
		END					AS [ID de Pozo SEGUN ANEXO 3 POZOS],
		P.Nombre			AS [Nombre del Pozo SEGUN ANEXO 3 POZOS],
		PDP.Fecha,
		ROUND(PDP.Cabeza,3)			AS [Presión de Cabeza],
		ROUND(PDP.Est_64Plg,3)		AS [Estrangulador],
		ROUND(PDP.Linea,3)			AS [Presión de Línea],
		ROUND(PDP.Temperatura,3)		AS [Temperatura],
		CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProdPetroleoBruto,0) * ISNULL(PP.CTL,1),3)
			ELSE ROUND(ISNULL(PDP.ProdPetroleoBruto,0),3) END		AS [Producción de Petróleo],
--		ROUND(PDP.ProdPetroleoBruto * ISNULL(PP.CTL,1),3)	AS [Producción de Petróleo],
		CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.GastoGas,0) * (@60F_R/@68F_R),3)
			ELSE ROUND(ISNULL(PDP.GastoGas,0),3) END					AS [Producción de Gas],
--		ROUND(PDP.GastoGas * (@60F_R/@68F_R),3)		AS [Producción de Gas],-- * @FactorConverM3_MMPC) * (@60F_R/@68F_R)	AS [Producción de Gas],
		ROUND(PDP.Agua,3)			AS [Producción de Agua],
		CASE WHEN PDP.ProdAceiteNeto = 0 THEN 0 ELSE ROUND(PDP.GastoGas/PDP.ProdAceiteNeto,3) END	AS [RGA],
		CASE WHEN ISNULL(PDP.Comentarios,'') = ''
			THEN 'N/A'
			ELSE PDP.Comentarios
		END		AS [OBSERVACIONES]
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		PR_ProdDiariaPozo_Previo	PDP
		ON	P.Id	=	PDP.Pozo
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
		AND ( (@BitDiario = 1 AND PDP.Fecha = @FechaFin) OR (@BitDiario = 0 AND PDP.Fecha BETWEEN @MesReporte AND @FechaFin) )
	LEFT JOIN
		#PromPonderado	PP	-- SE OBTIENEN LOS VALORES PARA LA CONVERSION DE TEMPERATURA
		ON	C.IdContrato	=	PP.IdContrato
		AND	PDP.Pozo	=	PP.IdPozo
	LEFT JOIN
		dbo.PR_Campo	CA
		ON	P.Campo	=	CA.Id
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1

UNION

	/************************* AFOROS DE POZO ****************************/
	SELECT
		C.NumeroContrato			AS [ID Contrato o Asignación],
		P.RegionFiscal				AS [Región Fiscal],		--DATO POR CONTRATO
		CA.Nombre					AS [Nombre del Campo],
		CASE WHEN ISNULL(P.Clave,'') = '' 	THEN 'N/A'
			ELSE P.Clave	END					AS [ID de Pozo SEGUN ANEXO 3 POZOS],
		P.Nombre					AS [Nombre del Pozo SEGUN ANEXO 3 POZOS],
		PDP.Fecha,
		ROUND(ISNULL(DIARIA.Cabeza,0),3)			AS [Presión de Cabeza],
		ROUND(ISNULL(DIARIA.Est_64Plg,0),3)		AS [Estrangulador],
		ROUND(ISNULL(DIARIA.Linea,0),3)			AS [Presión de Línea],
		--ROUND(ISNULL(DIARIA.Temperatura,0),3)		AS [Temperatura],
		ROUND(ISNULL(PD.TemperaturaPetroleo,0),3)		AS [Temperatura],
		CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProduccionReal,0) * ISNULL(PP.CTL,1),3)
			ELSE ROUND(ISNULL(PDP.ProduccionReal,0),3) END		AS [Producción de Petróleo],
		--ROUND(PDP.ProduccionAlocadaBruta * PP.CTL,3)	AS [Producción de Petróleo],
		--ROUND((PDP.GastoGas),3)		AS [Producción de Gas],	-- * @FactorConverM3_MMPC) * (@60F_R/@68F_R)	
		CASE WHEN ROUND(ISNULL(PD.TemperaturaGas,20),2) <> 15.56 THEN ROUND( (PDP.ProduccionRealGasM3 * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3)
			ELSE ROUND(ISNULL(PDP.ProduccionRealGasM3,0) * @FactorConverM3_MMPC,3) END		AS [Producción de Gas],
--		ROUND( (PDP.ProduccionRealGasM3 * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3)		AS [Producción de Gas],			
		ROUND(ISNULL(DIARIA.Agua,0),3)			AS [Producción de Agua],
		CASE WHEN PDP.ProduccionReal = 0 THEN 0 ELSE ROUND(PDP.ProduccionRealGasM3/PDP.ProduccionReal,3) END	AS [RGA],
		CASE WHEN ISNULL(DIARIA.Comentarios,'') = ''
			THEN 'N/A'
			ELSE DIARIA.Comentarios
		END		AS [OBSERVACIONES]
	FROM
		#ContratosConciliada	CO
	JOIN
		dbo.CO_Contrato	C
		ON	CO.IdContrato	=	C.IdContrato
	JOIN
		CO_AreaContractual	AC
		ON	C.IdAreaContractual	=	AC.IdAreaContractual
	JOIN
		CO_Instalacion	I
		ON	AC.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		PR_ProdDiariaPozo	PDP
		ON	P.Id	=	PDP.Pozo
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	LEFT JOIN
		#PromPonderado	PP	-- SE OBTIENEN LOS VALORES PARA LA CONVERSION DE TEMPERATURA
		ON	C.IdContrato	=	PP.IdContrato
		AND	PDP.Pozo	=	PP.IdPozo
	LEFT JOIN
		dbo.PR_ProdDiariaPozo_Previo	DIARIA
		ON	PDP.Pozo	=	DIARIA.Pozo
		AND PDP.Fecha	=	DIARIA.Fecha
	LEFT JOIN
		dbo.PR_Campo	CA
		ON	P.Campo	=	CA.Id
	LEFT JOIN
		dbo.PR_ProdDiaria	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	 ORDER BY
		C.NumeroContrato,
		P.Nombre,
		PDP.Fecha

	end

	SELECT @Contratos = @Contratos + C.NumeroContrato + ', '
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato

	SELECT @SinPoderCalorifico = @SinPoderCalorifico + C.NumeroContrato + ', '
	FROM
		dbo.CO_Contrato	C
	JOIN
		#ConversionGas	CG
		ON	C.IdContrato	=	CG.IdContrato
	WHERE
		CG.PoderCalorifico_Gas	=	0
	GROUP BY
		C.NumeroContrato


	---RESULTADO 3
	if @resultadoDeseado in (0,3)
	begin
		IF @BitDiario = 0 AND 0 < (SELECT COUNT(1) FROM #ContratosDiaria)
			BEGIN
				SELECT  CASE WHEN @SinPoderCalorifico = ''
							THEN 'Sin produccion Conciliada en los contratos: ' + @Contratos
						ELSE 'Sin produccion Conciliada en los contratos: ' + @Contratos + 'Sin Poder Calorífico de Gas en los contratos: ' + @SinPoderCalorifico
						END
			END
	end
--END 
END