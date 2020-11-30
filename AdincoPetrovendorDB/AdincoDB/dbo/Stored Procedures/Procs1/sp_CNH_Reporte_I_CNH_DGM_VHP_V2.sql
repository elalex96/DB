CREATE PROCEDURE dbo.sp_CNH_Reporte_I_CNH_DGM_VHP_V2
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
-- 20190305	BAAC	Se modifica para calcular la energia con el API 14.5
-- 20190909	BAAC	Se modifica por cambios en el formato de excel de CNH
-- 20200722	BAAC	Se modifica para obtener poder calorifico de la croma cargada, se muestran agua y prod neta de petroleo de los reportes diarios
--					aunque se tengan los conciliados, se regresan solo los datos de los pozos que cuenten con produccion
-- =============================================
SET NOCOUNT ON
-- =============================================
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
-- COMPONENTES SEPARADOS DE C6+
	C6			   FLOAT,
	C7			   FLOAT,
	C8			   FLOAT,
	C9			   FLOAT,
	C10			   FLOAT,
-- COMPONENTES SEPARADOS DE C6+
	CO2MOL	FLOAT,
	H2S		FLOAT,
	N2		FLOAT,
	O2		FLOAT,
	H2O		FLOAT,
	C1MMBTU	FLOAT,
	C2MMBTU	FLOAT,
	C3MMBTU	FLOAT,
	NC4MMBTU	FLOAT,
	IC4MMBTU	FLOAT,
	NC5MMBTU	FLOAT,
	IC5MMBTU	FLOAT,
	C6MMBTU		FLOAT,
	C6MASMMBTU		FLOAT,
	C7MMBTU		FLOAT,
	C8MMBTU		FLOAT,
	C9MMBTU		FLOAT,
	C10MMBTU		FLOAT,
	PCC1		FLOAT,
	PCC2		FLOAT,
	PCC3		FLOAT,
	PCNC4		FLOAT,
	PCIC4		FLOAT,
	PCNC5		FLOAT,
	PCIC5		FLOAT,
	PCC6		FLOAT,
	PCC7		FLOAT,
	PCC8		FLOAT,
	PCC9		FLOAT,
	PCC10		FLOAT,
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
	Zmes			FLOAT,
	PresionParcial_C1	FLOAT,
	PresionParcial_C2	FLOAT,
	PresionParcial_C3	FLOAT,
	PresionParcial_nC4	FLOAT,
	PresionParcial_iC4	FLOAT,
	PresionParcial_nC5	FLOAT,
	PresionParcial_iC5	FLOAT,
	PresionParcial_C6Mas	FLOAT,
	PresionParcial_C6	FLOAT,
	PresionParcial_C7	FLOAT,
	PresionParcial_C8	FLOAT,
	PresionParcial_C9	FLOAT,
	PresionParcial_C10	FLOAT,
	PresionParcial_CO2	FLOAT,
	PresionParcial_H2S	FLOAT,
	PresionParcial_N2	FLOAT,
	-- LC Contenido de Liquido por Componente "Teorico" Gas Ideal
	LCid_C1		FLOAT,
	LCid_C2		FLOAT,
	LCid_C3		FLOAT,
	LCid_nC4		FLOAT,
	LCid_iC4		FLOAT,
	LCid_nC5		FLOAT,
	LCid_iC5		FLOAT,
	LCid_C6Mas		FLOAT,
	LCid_C6		FLOAT,
	LCid_C7		FLOAT,
	LCid_C8		FLOAT,
	LCid_C9		FLOAT,
	LCid_C10		FLOAT,
	LCid_CO2		FLOAT,
	LCid_H2S		FLOAT,
	LCid_N2		FLOAT,
-- LC Contenido de Liquido por Componente (Volumen de Gas Real)
	LCi_C1		FLOAT,
	LCi_C2		FLOAT,
	LCi_C3		FLOAT,
	LCi_nC4		FLOAT,
	LCi_iC4		FLOAT,
	LCi_nC5		FLOAT,
	LCi_iC5		FLOAT,
	LCi_C6Mas	FLOAT,
	LCi_C6		FLOAT,
	LCi_C7		FLOAT,
	LCi_C8		FLOAT,
	LCi_C9		FLOAT,
	LCi_C10		FLOAT,
	LCi_CO2		FLOAT,
	LCi_H2S		FLOAT,
	LCi_N2		FLOAT,
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
-- COMPONENTES SEPARADOS DE C6+
	C6			   FLOAT,
	C7			   FLOAT,
	C8			   FLOAT,
	C9			   FLOAT,
	C10			   FLOAT,
-- COMPONENTES SEPARADOS DE C6+
	CO2MOL	FLOAT,
	H2S		FLOAT,
	N2		FLOAT,
	O2		FLOAT,
	H2O		FLOAT,
	C1MMBTU	FLOAT,
	C2MMBTU	FLOAT,
	C3MMBTU	FLOAT,
	NC4MMBTU	FLOAT,
	IC4MMBTU	FLOAT,
	NC5MMBTU	FLOAT,
	IC5MMBTU	FLOAT,
	C6MMBTU		FLOAT,
	C6MASMMBTU		FLOAT,
	C7MMBTU		FLOAT,
	C8MMBTU		FLOAT,
	C9MMBTU		FLOAT,
	C10MMBTU		FLOAT,
	PCC1		FLOAT,
	PCC2		FLOAT,
	PCC3		FLOAT,
	PCNC4		FLOAT,
	PCIC4		FLOAT,
	PCNC5		FLOAT,
	PCIC5		FLOAT,
	PCC6		FLOAT,
	PCC7		FLOAT,
	PCC8		FLOAT,
	PCC9		FLOAT,
	PCC10		FLOAT,
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
	C6		FLOAT,
	C7		FLOAT,
	C8		FLOAT,
	C9		FLOAT,
	C10		FLOAT,
	CO2MOL	FLOAT,
	H2S		FLOAT,
	N2		FLOAT,
	O2		FLOAT,
	H2O		FLOAT,
	C1MMBTU	FLOAT,
	C2MMBTU	FLOAT,
	C3MMBTU	FLOAT,
	NC4MMBTU	FLOAT,
	IC4MMBTU	FLOAT,
	NC5MMBTU	FLOAT,
	IC5MMBTU	FLOAT,
	C6MMBTU		FLOAT,
	C6MASMMBTU		FLOAT,
	C7MMBTU		FLOAT,
	C8MMBTU		FLOAT,
	C9MMBTU		FLOAT,
	C10MMBTU	FLOAT,
	PCC1		FLOAT,
	PCC2		FLOAT,
	PCC3		FLOAT,
	PCNC4		FLOAT,
	PCIC4		FLOAT,
	PCNC5		FLOAT,
	PCIC5		FLOAT,
	PCC6		FLOAT,
	PCC7		FLOAT,
	PCC8		FLOAT,
	PCC9		FLOAT,
	PCC10		FLOAT,
	PesoMolecularGas	FLOAT,
	C5EqBl		FLOAT
)

CREATE TABLE #VolumenesTotalesHidro
(
	IdContrato	INT,
	IdPozo	INT,
	ProdCondensadoNeto	FLOAT,
	ProdAgua			FLOAT,
	ProdCondensadoNeto_15_56	FLOAT,
	NumDias	INT,
	PRIMARY KEY (IdContrato, IdPozo)
)

CREATE TABLE #VolumenesTotalesHidro_Diaria
(
	IdContrato	INT,
	IdPozo	INT,
	ProdCondensadoNeto	FLOAT,
	ProdAgua			FLOAT,
	ProdCondensadoNeto_15_56	FLOAT,
	NumDias	INT,
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

DECLARE
	@FactorConverM3_MMPC FLOAT = 0.00003531467,
	@60F_R         FLOAT = 519.678, -- 60 grados Fahrenheit a rankine
    @68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
	@Eventos	VARCHAR(2000),
	@FechaFin	DATE,
	@BitConciliada BIT = 0,
	@IdRelacionado	INT,
	@Contratos	VARCHAR(4000) = '',
	@SinPoderCalorifico VARCHAR(4000) = '',
	@ConstanteBll FLOAT = 42

SELECT @Eventos = ''

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

-- SI ES EL REPORTE MENSUAL, SE PONE EL ULTIMO DIA DEL MES A CONSULTAR
IF @BitDiario = 0
BEGIN 
	SELECT @FechaFin = DATEADD(DAY,-1,DATEADD (MONTH,1,@MesReporte))

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
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CO.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
		AND I.Activo = 1
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_ProdDiariaPozo	PDP	(NOLOCK)
		ON P.Id	=	PDP.Pozo
	WHERE
		PDP.Fecha	BETWEEN @MesReporte AND @FechaFin
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

-- VOLUMENES TOTALES DE HIDROCARBUROS DE CONTRATOS CON PRODUCCION DIARIA
INSERT INTO #VolumenesTotalesHidro
(
	IdContrato,
	IdPozo,
	ProdCondensadoNeto,
	ProdAgua,
	ProdCondensadoNeto_15_56,
	NumDias
)
SELECT
	CD.IdContrato,
	PDP.Pozo,
	SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 0
		ELSE ISNULL(PDP.ProdCondensadoNeto,0) 	END),
--		SUM(ISNULL(PDP.ProdCondensadoNeto,0)),
	SUM(ROUND(ISNULL(PDP.Agua,0),3)),
	SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN ISNULL(PDP.ProdCondensadoNeto,0)
		ELSE  0	END),
	COUNT(DISTINCT PDP.Fecha)
FROM
	#ContratosDiaria	CD
JOIN
	dbo.CO_Contrato	C
	ON	CD.IdContrato	=	C.IdContrato
JOIN
	CO_Instalacion	I	(NOLOCK)
	ON	C.IdAreaContractual	=	I.IdAreaContractual
	AND I.Activo = 1
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
	dbo.PR_ProdDiaria_Previo	PD	(NOLOCK)
	ON	PDP.ProdDiaria	=	PD.Id
	AND	PDP.Fecha		=	PD.Fecha
WHERE
	I.Activo = 1
GROUP BY
	CD.IdContrato,
	PDP.Pozo

-- SE OBTIENEN LOS DATOS DE LOS REPORTES DE PRODUCCION DIARIA PARA LOS CONTRATOS QUE CUENTAN CON PRODUCCION CONCILIADA
-- PARA OBTENER DE AQUI EL AGUA
INSERT INTO #VolumenesTotalesHidro_Diaria
(
	IdContrato,
	IdPozo,
	ProdCondensadoNeto,
	ProdAgua,
	ProdCondensadoNeto_15_56,
	NumDias
)
SELECT
	CD.IdContrato,
	PDP.Pozo,
	SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 0
		ELSE ISNULL(PDP.ProdCondensadoNeto,0) 	END),
--		SUM(ISNULL(PDP.ProdCondensadoNeto,0)),
	SUM(ROUND(ISNULL(PDP.Agua,0),3)),
	SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN ISNULL(PDP.ProdCondensadoNeto,0)
		ELSE  0	END),
	COUNT(DISTINCT PDP.Fecha)
FROM
	#ContratosConciliada	CD
JOIN
	dbo.CO_Contrato	C
	ON	CD.IdContrato	=	C.IdContrato
JOIN
	CO_Instalacion	I	(NOLOCK)
	ON	C.IdAreaContractual	=	I.IdAreaContractual
	AND I.Activo = 1
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
GROUP BY
	CD.IdContrato,
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
	IdContrato,		IdPozo,		MMPC_Gas,
	C1MOL,	C2MOL,	C3MOL,	NC4MOL,	IC4MOL,	NC5MOL,	IC5MOL,	C6MOL, C6, C7, C8, C9, C10,
	CO2MOL, N2, H2S, O2, H2O,
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
	ISNULL(CROMA.C6_plus,0), ISNULL(CROMA.C7,0), ISNULL(CROMA.C8,0), ISNULL(CROMA.C9,0), ISNULL(CROMA.C10,0),
	ISNULL(CROMA.MOL_CO2,0),
	ISNULL(CROMA.MOL_N2,0),
	ISNULL(CROMA.MOL_h2S,0),
	ISNULL(CROMA.O2,0),
	ISNULL(CROMA.H2O,0),
	CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
		ELSE 0
	END,
	ISNULL(CROMA.PoderCalorifico,0),
	ISNULL(CROMA.PoderCalorificoGas,0)
FROM
	#ContratosDiaria	CD
JOIN
	dbo.CO_Contrato	C	(NOLOCK)
	ON	CD.IdContrato	=	C.IdContrato
JOIN
	CO_Instalacion	I	(NOLOCK)
	ON	C.IdAreaContractual	=	I.IdAreaContractual
	AND I.Activo = 1
JOIN
	dbo.PR_Pozo	P	(NOLOCK)
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_ProdDiariaPozo_Previo	PDP	(NOLOCK)
	ON	P.Id	=	PDP.Pozo
	AND	ISNULL(PDP.GastoGas,0) > 0
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	C.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN
	dbo.PR_ProdDiaria_Previo	PD	(NOLOCK)
	ON	PDP.ProdDiaria	=	PD.Id
	AND	PDP.Fecha		=	PD.Fecha
LEFT JOIN	
	dbo.CO_Cromatografia	CR	(NOLOCK)
	ON C.IdContrato	=	CR.IdContrato
	AND	YEAR(@MesReporte) = CR.Anio
	AND	MONTH(@MesReporte)	=	CR.Mes
LEFT JOIN
	CO_CromatografiaValores	CROMA	(NOLOCK)
	ON	CR.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
WHERE
	PDP.Fecha	<=	@FechaFin
	AND	YEAR(@MesReporte) = YEAR(PDP.Fecha)
	AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
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
	ISNULL(CROMA.C6_plus,0), ISNULL(CROMA.C7,0), ISNULL(CROMA.C8,0), ISNULL(CROMA.C9,0), ISNULL(CROMA.C10,0),
	ISNULL(CROMA.MOL_CO2,0),
	ISNULL(CROMA.MOL_N2,0),
	ISNULL(CROMA.MOL_h2S,0),
	ISNULL(CROMA.O2,0),
	ISNULL(CROMA.H2O,0),
	CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
		ELSE 0
	END,
	ISNULL(CROMA.PoderCalorifico,0),
	ISNULL(CROMA.PoderCalorificoGas,0)


-- VOLUMENES TOTALES DE HIROCARBUROS DE CONTRATOS CON PRODUCCION CONCILIADA
INSERT INTO #VolumenesTotalesHidro
(
	IdContrato,
	IdPozo,
	ProdCondensadoNeto,
	ProdAgua,
	ProdCondensadoNeto_15_56,
	NumDias
)
SELECT
	CC.IdContrato,
	PDP.Pozo,
	SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) = 15.56 THEN 0
		ELSE ISNULL(PDP.ProduccionRealCondensado,0) 	END),
	--SUM(ISNULL(PDP.ProduccionRealCondensado,0)),
	SUM(ROUND(ISNULL(PDP.PctAguaAlocada,0),3)),
	SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) = 15.56 THEN ISNULL(PDP.ProduccionRealCondensado,0)
		ELSE 0 	END),
	COUNT(DISTINCT PDP.Fecha)
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
		IdContrato, IdPozo, MMPC_Gas,
		C1MOL,	C2MOL,	C3MOL,	NC4MOL,	IC4MOL,	NC5MOL,	IC5MOL,	C6MOL, C6, C7, C8, C9, C10,
		CO2MOL, N2, H2S, O2, H2O,
		SinCromatografia, PoderCalorifico, PoderCalorifico_Gas
	)
	SELECT
		CC.IdContrato,
		PDP.Pozo,
		SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaGas,20),2) <> 15.56 THEN ROUND((ISNULL(PDP.ProduccionRealGasM3,0) * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3)
		ELSE ISNULL(PDP.ProduccionRealGasM3,0)* @FactorConverM3_MMPC END),
		ISNULL(CROMA.C1,0),
		ISNULL(CROMA.C2,0),
		ISNULL(CROMA.C3,0),
		ISNULL(CROMA.nC4,0),
		ISNULL(CROMA.lC4,0),
		ISNULL(CROMA.nC5,0),
		ISNULL(CROMA.lC5,0),
		ISNULL(CROMA.C6_plus,0) + ISNULL(CROMA.C7,0) + ISNULL(CROMA.C8,0) + ISNULL(CROMA.C9,0) + ISNULL(CROMA.C10,0),
		ISNULL(CROMA.C6_plus,0), ISNULL(CROMA.C7,0), ISNULL(CROMA.C8,0), ISNULL(CROMA.C9,0), ISNULL(CROMA.C10,0),
		ISNULL(CROMA.MOL_CO2,0),
		ISNULL(CROMA.MOL_N2,0),
		ISNULL(CROMA.MOL_h2S,0),
		ISNULL(CROMA.O2,0),
		ISNULL(CROMA.H2O,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END,
		ISNULL(CROMA.PoderCalorifico,0),
		ISNULL(CROMA.PoderCalorificoGas,0)
	FROM
		#ContratosConciliada	CC
	JOIN
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CC.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
		AND I.Activo = 1
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_ProdDiariaPozo	PDP	(NOLOCK)
		ON	P.Id	=	PDP.Pozo
		AND	ISNULL(PDP.ProduccionRealGasM3,0) > 0
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	LEFT JOIN
		dbo.PR_ProdDiaria	PD	(NOLOCK)
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	LEFT JOIN	
		dbo.CO_Cromatografia	CR	(NOLOCK)
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	LEFT JOIN
		CO_CromatografiaValores	CROMA	(NOLOCK)
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	WHERE
		PDP.Fecha	<=	@FechaFin
		AND	YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
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
		ISNULL(CROMA.C6_plus,0), ISNULL(CROMA.C7,0), ISNULL(CROMA.C8,0), ISNULL(CROMA.C9,0), ISNULL(CROMA.C10,0),
		ISNULL(CROMA.MOL_CO2,0),
		ISNULL(CROMA.MOL_N2,0),
		ISNULL(CROMA.MOL_h2S,0),
		ISNULL(CROMA.O2,0),
		ISNULL(CROMA.H2O,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END,
		ISNULL(CROMA.PoderCalorifico,0),
		ISNULL(CROMA.PoderCalorificoGas,0)

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
		C6		=	ISNULL(CROMA.C6_plus,0),
		C7		=	ISNULL(CROMA.C7,0),
		C8		=	ISNULL(CROMA.C8,0),
		C9		=	ISNULL(CROMA.C9,0),
		C10		=	ISNULL(CROMA.C10,0),
		CO2MOL	=	ISNULL(CROMA.MOL_CO2,0),
		N2		=	ISNULL(CROMA.MOL_N2,0),
		H2S		=	ISNULL(CROMA.MOL_h2S,0),
		O2		=	ISNULL(CROMA.O2,0),
		H2O		=	ISNULL(CROMA.H2O,0),
		PoderCalorifico	=	ISNULL(CROMA.PoderCalorifico,0),
		PoderCalorifico_Gas	=	ISNULL(CROMA.PoderCalorificoGas,0)
FROM
	#ConversionGas	CG
JOIN
	dbo.PR_Pozo	P	(NOLOCK)
	ON	CG.IdPozo	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	CG.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN	
	dbo.CO_Cromatografia	CR	(NOLOCK)
	ON CG.IdContrato	=	CR.IdContrato
	AND	YEAR(DATEADD(MONTH, -1, @MesReporte)) = CR.Anio
	AND	MONTH(DATEADD(MONTH, -1, @MesReporte))	=	CR.Mes
LEFT JOIN
	CO_CromatografiaValores	CROMA	(NOLOCK)
	ON	CR.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
WHERE
	CG.SinCromatografia	=	1


/************* NUEVOS CALCULOS DE ENERGIA API 14.5 **************/
UPDATE	C
	SET
		PresionParcial_C1	= ROUND(GPA.Metano_C1 * (C.C1MOL/100),6),
		PresionParcial_C2	= ROUND(GPA.Etano_C2 * (C.C2MOL/100),6),
		PresionParcial_C3	= ROUND(GPA.Propano_C3 * (C.C3MOL/100),6),
		PresionParcial_nC4	= ROUND(GPA.Butano_nC4 * (C.NC4MOL/100),6),
		PresionParcial_iC4	= ROUND(GPA.Butano_iC4 * (C.IC4MOL/100),6),
		PresionParcial_nC5	= ROUND(GPA.Pentano_nC5 * (C.NC5MOL/100),6),
		PresionParcial_iC5	= ROUND(GPA.Pentano_iC5 * (C.IC5MOL/100),6),
		PresionParcial_C6Mas	= ROUND(GPA.Hexano_C6 * (C.C6MOL/100),6),
		PresionParcial_C6	=	ROUND(GPA.Hexano_C6 * (C.C6/100),6),
		PresionParcial_C7	= ROUND(GPA.Heptano_C7 * (C.C7/100),6),
		PresionParcial_C8	= ROUND(GPA.Octano_C8 * (C.C8/100),6),
		PresionParcial_C9	= ROUND(GPA.Nonano_C9 * (C.C9/100),6),
		PresionParcial_C10	= ROUND(GPA.Decano_C10 * (C.C10/100),6),
		PresionParcial_CO2	= ROUND(GPA.CO2 * (C.CO2MOL/100),6),
		PresionParcial_H2S	= ROUND(GPA.H2S * (C.H2S/100),6),
		PresionParcial_N2	= ROUND(GPA.Nitrogeno_N2 * (C.N2/100),6)
FROM
	#ConversionGas	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	5	-- bi Presión Base
	AND	@MesReporte	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia

UPDATE #ConversionGas
	SET Zmes = ROUND(1 - 14.696  * POWER(PresionParcial_C1 + PresionParcial_C2 + PresionParcial_C3 + PresionParcial_nC4 +
									PresionParcial_iC4 + PresionParcial_nC5 + PresionParcial_iC5 + PresionParcial_C6 +
									PresionParcial_C7 + PresionParcial_C8 + PresionParcial_C9 + PresionParcial_C10 +
									PresionParcial_CO2 + PresionParcial_H2S + PresionParcial_N2, 2),6)

UPDATE C
	SET
	LCid_C1		=	ROUND((C.C1MOL/100) * 1000 * (1/GPA.Metano_C1) * (14.696/14.696),6),
	LCid_C2		=	ROUND((C.C2MOL/100) * 1000 * (1/GPA.Etano_C2)* (14.696/14.696),6),
	LCid_C3		=	ROUND((C.C3MOL/100) * 1000 * (1/GPA.Propano_C3)* (14.696/14.696),6),
	LCid_nC4	=	ROUND((C.NC4MOL/100) * 1000 * (1/GPA.Butano_nC4)* (14.696/14.696),6),
	LCid_iC4	=	ROUND((C.IC4MOL/100) * 1000 * (1/GPA.Butano_iC4)* (14.696/14.696),6),
	LCid_nC5	=	ROUND((C.NC5MOL/100) * 1000 * (1/GPA.Pentano_nC5)* (14.696/14.696),6),
	LCid_iC5	=	ROUND((C.IC5MOL/100) * 1000 * (1/GPA.Pentano_iC5)* (14.696/14.696),6),
	LCid_C6Mas	=	ROUND((C.C6MOL/100) * 1000 * (1/GPA.Hexano_C6)* (14.696/14.696),6),
	LCid_C6		=	ROUND((C.C6/100) * 1000 * (1/GPA.Hexano_C6)* (14.696/14.696),6),
	LCid_C7		=	ROUND((C.C7/100) * 1000 * (1/GPA.Heptano_C7)* (14.696/14.696),6),
	LCid_C8		=	ROUND((C.C8/100) * 1000 * (1/GPA.Octano_C8)* (14.696/14.696),6),
	LCid_C9		=	ROUND((C.C9/100) * 1000 * (1/GPA.Nonano_C9)* (14.696/14.696),6),
	LCid_C10	=	ROUND((C.C10/100) * 1000 * (1/GPA.Decano_C10)* (14.696/14.696),6)
	--LCid_CO2	=	ROUND((C.CO2MOL/100) * 1000 * (1/GPA.CO2)* (14.696/14.696),6),
	--LCid_H2S	=	ROUND((C.H2S/100) * 1000 * (1/GPA.H2S)* (14.696/14.696),6),
	--LCid_N2		=	ROUND((C.N2/100) * 1000 * (1/GPA.Nitrogeno_N2)* (14.696/14.696),6)
FROM
	#ConversionGas	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	4	-- ft3 ideal gas/gal liquid
	AND	@MesReporte	BETWEEN IdFecIniVigencia AND FecFinVigencia

UPDATE #ConversionGas
	SET
		LCi_C1		= ROUND(LCid_C1 / Zmes,6),
		LCi_C2		= ROUND(LCid_C2 / Zmes,6),
		LCi_C3		= ROUND(LCid_C3 / Zmes,6),
		LCi_nC4		= ROUND(LCid_nC4 / Zmes,6),
		LCi_iC4		= ROUND(LCid_iC4 / Zmes,6),
		LCi_nC5		= ROUND(LCid_nC5 / Zmes,6),
		LCi_iC5		= ROUND(LCid_iC5 / Zmes,6),
		LCi_C6Mas	= ROUND(LCid_C6Mas / Zmes,6),
		LCi_C6		= ROUND(LCid_C6 / Zmes,6),
		LCi_C7		= ROUND(LCid_C7 / Zmes,6),
		LCi_C8		= ROUND(LCid_C8 / Zmes,6),
		LCi_C9		= ROUND(LCid_C9 / Zmes,6),
		LCi_C10		= ROUND(LCid_C10 / Zmes,6)
		--LCi_CO2		= ROUND(LCid_CO2 / Zmes,6),
		--LCi_H2S		= ROUND(LCid_H2S / Zmes,6),
		--LCi_N2		= ROUND(LCid_N2 / Zmes,6)


UPDATE	C
	SET
		C1MMBTU	=	ROUND((GPA.Metano_C1 * ((C.MMPC_Gas*1000000) * (C.C1MOL / 100)))/1000000,0),
		C2MMBTU	=	ROUND((GPA.Etano_C2 * ((C.MMPC_Gas*1000000) * (C.C2MOL / 100)))/1000000,0),
		C3MMBTU	=	ROUND((GPA.Propano_C3 * ((C.MMPC_Gas*1000000) * (C.C3MOL / 100)))/1000000,0),
		IC4MMBTU	=	ROUND((GPA.Butano_iC4 * ((C.MMPC_Gas*1000000) * (C.IC4MOL / 100)))/1000000,0),
		NC4MMBTU	=	ROUND((GPA.Butano_nC4 * ((C.MMPC_Gas*1000000) * (C.NC4MOL / 100)))/1000000,0),
		IC5MMBTU	=	ROUND((GPA.Pentano_iC5 * ((C.MMPC_Gas*1000000) * (C.IC5MOL / 100)))/1000000,0),
		NC5MMBTU	=	ROUND((GPA.Pentano_nC5 * ((C.MMPC_Gas*1000000) * (C.NC5MOL / 100)))/1000000,0),
		C6MASMMBTU	=	ROUND((GPA.Hexano_C6 * ((C.MMPC_Gas*1000000) * (C.C6MOL / 100)))/1000000,0),
		C6MMBTU	=	ROUND((GPA.Hexano_C6 * ((C.MMPC_Gas*1000000) * (C.C6 / 100)))/1000000,0),
		C7MMBTU	=	ROUND((GPA.Heptano_C7 * ((C.MMPC_Gas*1000000) * (C.C7 / 100)))/1000000,0),
		C8MMBTU	=	ROUND((GPA.Octano_C8 * ((C.MMPC_Gas*1000000) * (C.C8 / 100)))/1000000,0),
		C9MMBTU	=	ROUND((GPA.Nonano_C9 * ((C.MMPC_Gas*1000000) * (C.C9 / 100)))/1000000,0),
		C10MMBTU	=	ROUND((GPA.Decano_C10 * ((C.MMPC_Gas*1000000) * (C.C10 / 100)))/1000000,0),
		PCC1	=	GPA.Metano_C1 * (GPA.Metano_C1 * C.MMPC_Gas * C.C1MOL /100),
		PCC2	=	GPA.Etano_C2 * (GPA.Etano_C2 * C.MMPC_Gas * C.C2MOL /100),
		PCC3	=	GPA.Propano_C3 * (GPA.Propano_C3 * C.MMPC_Gas * C.C3MOL /100),
		PCNC4	=	GPA.Butano_nC4 * (GPA.Butano_nC4 * C.MMPC_Gas * C.NC4MOL /100),
		PCIC4	=	GPA.Butano_iC4 * (GPA.Butano_iC4 * C.MMPC_Gas * C.IC4MOL /100),
		PCNC5	=	GPA.Pentano_nC5 * (GPA.Pentano_nC5 * C.MMPC_Gas * C.NC5MOL /100),
		PCIC5	=	GPA.Pentano_iC5 * (GPA.Pentano_iC5 * C.MMPC_Gas * C.IC5MOL /100),
		PCC6	=	GPA.Hexano_C6 * (GPA.Hexano_C6 * C.MMPC_Gas * C.C6 /100),
		PCC7	=	GPA.Heptano_C7 * (GPA.Heptano_C7 * C.MMPC_Gas * C.C7 /100),
		PCC8	=	GPA.Octano_C8 * (GPA.Octano_C8 * C.MMPC_Gas * C.C8 /100),
		PCC9	=	GPA.Nonano_C9 * (GPA.Nonano_C9 * C.MMPC_Gas * C.C9 /100),
		PCC10	=	GPA.Decano_C10 * (GPA.Decano_C10 * C.MMPC_Gas * C.C10 /100)
FROM
	#ConversionGas	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	2
	AND	@MesReporte	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia

UPDATE	#ConversionGas
	SET	C5EqBl	=	ROUND((MMPC_Gas * 1000 * LCi_nC5)/@ConstanteBll,3) + ROUND((MMPC_Gas * 1000 * LCi_iC5)/@ConstanteBll,3) +
					ROUND((MMPC_Gas * 1000 * LCi_C6)/@ConstanteBll,3) + ROUND((MMPC_Gas * 1000 * LCi_C7)/@ConstanteBll,3) +
					ROUND((MMPC_Gas * 1000 * LCi_C8)/@ConstanteBll,3) + ROUND((MMPC_Gas * 1000 * LCi_C9)/@ConstanteBll,3) +
					ROUND((MMPC_Gas * 1000 * LCi_C10)/@ConstanteBll,3)


UPDATE CG
	SET	PesoMolecularGas =	(CG.C1MOL * GPA.Metano_C1/100) + (CG.C2MOL * GPA.Etano_C2/100) + (CG.C3MOL * GPA.Propano_C3/100) +
							(CG.NC4MOL * GPA.Butano_nC4/100) + (CG.IC4MOL * GPA.Butano_iC4/100) + (CG.NC5MOL * GPA.Pentano_nC5/100) +
							(CG.IC5MOL * GPA.Pentano_iC5/100) +	(CG.C6 * GPA.Hexano_C6/100) + (CG.C7 * GPA.Heptano_C7/100) +
							(CG.C8 * GPA.Octano_C8/100) + (CG.C9 * GPA.Nonano_C9/100) + (CG.C10 * GPA.Decano_C10/100) +
							(CG.CO2MOL * GPA.CO2/100) + (CG.H2S * GPA.H2S / 100) + (CG.N2 * GPA.Nitrogeno_N2 / 100)
FROM
	#ConversionGas	CG
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	1	-- PESO MOLECULAR
	AND	@MesReporte	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia

INSERT INTO #PromPonderado
(
	IdContrato,
	IdPozo,
	Condensado,
	Petroleo
)
SELECT
	CC.IdContrato,
	PDP.Pozo,
	SUM(ISNULL(PDP.ProduccionRealCondensado,0)),
	SUM(ISNULL(PDP.ProduccionReal,0))
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
	dbo.PR_ProdDiariaPozo	PDP	(NOLOCK)
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
	dbo.CO_Contrato	C	(NOLOCK)
	ON	CC.IdContrato	=	C.IdContrato
JOIN
	CO_Instalacion	I	(NOLOCK)
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P	(NOLOCK)
	ON	I.WelIID	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	C.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
JOIN
	#PromPonderado	PP
	ON	PEC.IdContrato	=	PP.IdContrato	
	AND	P.Id	=	PP.IdPozo
JOIN	
	dbo.CO_Cromatografia	CR	(NOLOCK)
	ON C.IdContrato	=	CR.IdContrato
	AND	YEAR(@MesReporte) = CR.Anio
	AND	MONTH(@MesReporte)	=	CR.Mes
JOIN
	CO_CromatografiaValores	CROMA	(NOLOCK)
	ON	CR.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
WHERE
	I.Activo = 1

INSERT INTO #PromPonderado
(
	IdContrato,
	IdPozo,
	Agua,
	Condensado,
	Petroleo
)
SELECT
	CD.IdContrato,
	PDP.Pozo,
	SUM(ISNULL(PDP.Agua,0)),
	SUM(ISNULL(PDP.ProdCondensadoNeto,0)),
	SUM(ISNULL(PDP.ProdPetroleoBruto,0))
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
	dbo.PR_ProdDiariaPozo_Previo	PDP	(NOLOCK)
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
	dbo.CO_Contrato	C	(NOLOCK)
	ON	CD.IdContrato	=	C.IdContrato
JOIN
	CO_Instalacion	I	(NOLOCK)
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P	(NOLOCK)
	ON	I.WelIID	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	C.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
JOIN	
	dbo.CO_Cromatografia	CR	(NOLOCK)
	ON C.IdContrato	=	CR.IdContrato
	AND	YEAR(@MesReporte) = CR.Anio
	AND	MONTH(@MesReporte)	=	CR.Mes
JOIN
	CO_CromatografiaValores	CROMA	(NOLOCK)
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
	dbo.PR_Pozo	P	(NOLOCK)
	ON	PP.IdPozo	=	P.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	PP.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN
	dbo.CO_Cromatografia	CRO	(NOLOCK)
	ON	PEC.IdContrato	=	CRO.IdContrato
	AND	YEAR(DATEADD(MONTH, -1, @MesReporte)) = CRO.Anio
	AND	MONTH(DATEADD(MONTH, -1, @MesReporte))	=	CRO.Mes
LEFT JOIN
	dbo.CO_CromatografiaValores	CROMA	(NOLOCK)
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
	C6,
	C7,
	C8,
	C9,
	C10,
    CO2MOL,
    H2S,
	N2,
	O2,
	H2O,
    C1MMBTU,
    C2MMBTU,
    C3MMBTU,
    NC4MMBTU,
    IC4MMBTU,
    NC5MMBTU,
    IC5MMBTU,
	C6MASMMBTU,
    C6MMBTU,
	C7MMBTU,
	C8MMBTU,
	C9MMBTU,
	C10MMBTU,
    PCC1,
    PCC2,
    PCC3,
    PCNC4,
    PCIC4,
	PCNC5,
    PCIC5,
    PCC6,
	PCC7,
	PCC8,
	PCC9,
	PCC10,
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
	SUM(C6),
	SUM(C7),
	SUM(C8),
	SUM(C9),
	SUM(C10),
    SUM(CO2MOL),
	SUM(H2S),
    SUM(N2),
	SUM(O2),
	SUM(H2O),
	SUM(C1MMBTU),
    SUM(C2MMBTU),
    SUM(C3MMBTU),
    SUM(NC4MMBTU),
    SUM(IC4MMBTU),
    SUM(NC5MMBTU),
    SUM(IC5MMBTU),
	SUM(C6MASMMBTU),
    SUM(C6MMBTU),
	SUM(C7MMBTU),
	SUM(C8MMBTU),
	SUM(C9MMBTU),
	SUM(C10MMBTU),
    SUM(PCC1),
    SUM(PCC2),
    SUM(PCC3),
    SUM(PCNC4),
    SUM(PCIC4),
    SUM(PCNC5),
    SUM(PCIC5),
    SUM(PCC6),
	SUM(PCC7),
	SUM(PCC8),
	SUM(PCC9),
	SUM(PCC10),
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
	C6,
	C7,
	C8,
	C9,
	C10,
    CO2MOL,
    H2S,
    N2,
	O2,
	H2O,
    C1MMBTU,
    C2MMBTU,
    C3MMBTU,
    NC4MMBTU,
    IC4MMBTU,
    NC5MMBTU,
    IC5MMBTU,
	C6MASMMBTU,
    C6MMBTU,
	C7MMBTU,
	C8MMBTU,
	C9MMBTU,
	C10MMBTU,
    PCC1,
    PCC2,
    PCC3,
    PCNC4,
    PCIC4,
    PCNC5,
    PCIC5,
    PCC6,
	PCC7,
	PCC8,
	PCC9,
	PCC10,
    PesoMolecularGas,
	C5EqBl
)
SELECT
	CG.IdContrato,
	ROUND(SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE CG.MMPC_Gas * (CG.MMPC_Gas/CGAC.MMPC_Gas) END),3),
	ROUND(SUM(CASE WHEN CGAC.C1MMBTU = 0 THEN 0 ELSE (CG.C1MMBTU * CG.C1MOL )/ CGAC.C1MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C2MMBTU = 0 THEN 0 ELSE  (CG.C2MMBTU * CG.C2MOL )/ CGAC.C2MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C3MMBTU = 0 THEN 0 ELSE  (CG.C3MMBTU * CG.C3MOL )/ CGAC.C3MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.NC4MMBTU = 0 THEN 0 ELSE  (CG.NC4MMBTU * CG.NC4MOL )/ CGAC.NC4MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.IC4MMBTU = 0 THEN 0 ELSE  (CG.IC4MMBTU * CG.IC4MOL )/ CGAC.IC4MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.NC5MMBTU = 0 THEN 0 ELSE  (CG.NC5MMBTU * CG.NC5MOL )/ CGAC.NC5MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.IC5MMBTU = 0 THEN 0 ELSE  (CG.IC5MMBTU * CG.IC5MOL )/ CGAC.IC5MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C6MASMMBTU = 0 THEN 0 ELSE  (CG.C6MASMMBTU * CG.C6MOL )/ CGAC.C6MASMMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C6MMBTU = 0 THEN 0 ELSE  (CG.C6MMBTU * CG.C6 )/ CGAC.C6MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C7MMBTU = 0 THEN 0 ELSE  (CG.C7MMBTU * CG.C7 )/ CGAC.C7MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C8MMBTU = 0 THEN 0 ELSE  (CG.C8MMBTU * CG.C8 )/ CGAC.C8MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C9MMBTU = 0 THEN 0 ELSE  (CG.C9MMBTU * CG.C9 )/ CGAC.C9MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C10MMBTU = 0 THEN 0 ELSE  (CG.C10MMBTU * CG.C10 )/ CGAC.C10MMBTU END),3),
    ROUND(SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.CO2MOL)/CGAC.MMPC_Gas END),3),
    ROUND(SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.H2S)/CGAC.MMPC_Gas END),3),
    ROUND(SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.N2)/CGAC.MMPC_Gas END),3),
	ROUND(SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.O2)/CGAC.MMPC_Gas END),3),
	ROUND(SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.H2O)/CGAC.MMPC_Gas END),3),
	ROUND(SUM(CASE WHEN CGAC.C1MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C1MMBTU)/CGAC.C1MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C2MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C2MMBTU)/CGAC.C2MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C3MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C3MMBTU)/CGAC.C3MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.NC4MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.NC4MMBTU)/CGAC.NC4MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.IC4MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.IC4MMBTU)/CGAC.IC4MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.NC5MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.NC5MMBTU)/CGAC.NC5MMBTU END),3),
    ROUND(SUM(CASE WHEN CGAC.IC5MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.IC5MMBTU)/CGAC.IC5MMBTU END),3),
    ROUND(SUM(CASE WHEN CGAC.C6MASMMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C6MASMMBTU)/CGAC.C6MASMMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C6MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C6MMBTU)/CGAC.C6MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C7MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C7MMBTU)/CGAC.C7MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C8MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C8MMBTU)/CGAC.C8MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C9MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C9MMBTU)/CGAC.C9MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.C10MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C10MMBTU)/CGAC.C10MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.C1MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas)/CGAC.C1MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.C2MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C2MMBTU/CG.PoderCalorifico_Gas)/CGAC.C2MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.C3MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C3MMBTU/CG.PoderCalorifico_Gas)/CGAC.C3MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.NC4MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.NC4MMBTU/CG.PoderCalorifico_Gas)/CGAC.NC4MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.IC4MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.IC4MMBTU/CG.PoderCalorifico_Gas)/CGAC.IC4MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.NC5MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.NC5MMBTU/CG.PoderCalorifico_Gas)/CGAC.NC5MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.IC5MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.IC5MMBTU/CG.PoderCalorifico_Gas)/CGAC.IC5MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.C6MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C6MMBTU/CG.PoderCalorifico_Gas)/CGAC.C6MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.C7MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C7MMBTU/CG.PoderCalorifico_Gas)/CGAC.C7MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.C8MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C8MMBTU/CG.PoderCalorifico_Gas)/CGAC.C8MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.C9MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C9MMBTU/CG.PoderCalorifico_Gas)/CGAC.C9MMBTU END),3),
	ROUND(SUM( CASE WHEN CGAC.C10MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C10MMBTU/CG.PoderCalorifico_Gas)/CGAC.C10MMBTU END),3),
	ROUND(SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PesoMolecularGas)/ CGAC.MMPC_Gas END),3),
	ROUND(SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C5EqBl)/ CGAC.MMPC_Gas END),3)
FROM
	#ConversionGas	CG
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

	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoBruto * EXP( -(341.0957 / POWER( ((141.5 / (PP.GradosAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (PP.GradosAPI + 131.5)) * 999.012), 2 )) * 8)),3)
	ELSE ROUND(P.ProdPetroleoBruto,3) END),
--	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoBruto * PP.CTL,3)
--		ELSE ROUND(P.ProdPetroleoBruto,3) END),
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoNeto * EXP( -(341.0957 / POWER( ((141.5 / (PP.GradosAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (PP.GradosAPI + 131.5)) * 999.012), 2 )) * 8)),3)
	ELSE ROUND(P.ProdPetroleoNeto,3) END)
--	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoNeto * PP.CTL,3)
--		ELSE ROUND(P.ProdPetroleoNeto,3) END)
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
		ProdCondensadoNeto_15_56	=	ProdCondensadoNeto_15_56 + ROUND(VTH.ProdCondensadoNeto * PP.CTL_Condensado,3)
FROM
	#VolumenesTotalesHidro	VTH
JOIN
	#PromPonderado	PP
	ON	VTH.IdContrato	=	PP.IdContrato
	AND	VTH.IdPozo		=	PP.IdPozo

-- SE REVISA EL DATO DEL AGUA DE LOS CONTRATOS CON PRODUCCION CONCILIADA PARA ACTUALIZAR POR EL DATO QUE SE TENGA EN LA PRODUCCION DIARIA
UPDATE	VT
SET	ProdAgua	=	PD.ProdAgua
FROM
	#VolumenesTotalesHidro_Diaria	PD
JOIN
	#VolumenesTotalesHidro	VT
	ON	PD.IdContrato	=	VT.IdContrato
	AND	PD.IdPozo	=	VT.IdPozo
WHERE
	VT.ProdAgua	=	0
	AND
	PD.ProdAgua	<> 0

--SELECT * FROM #ConversionGasAC
	---RESULTADO 1
IF @resultadoDeseado in (0,1)
BEGIN
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
		ISNULL(VTH.NumDias,0)			AS [Días de Producción],
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END 										AS [Tipo de Fluido],
		ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3)		AS [Producción de Petróleo Bruto],
		ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3)		AS [Producción de Petróleo Neto],
		ISNULL(PP.GradosAPI,0)						AS [°API],
		ISNULL(PP.ContenidoAzufre,0)				AS [% AZUFRE],
		ISNULL(PP.ContenidoSal,0)					AS [SAL],
		ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3)	AS [Producción de Condesado Neto],
		ROUND(ISNULL(VTH.ProdAgua,0),3)				AS [Producción de Agua Neto],
		CASE WHEN C.GasNoAsociado = 0
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
		ELSE	0		END							AS [Producción de Gas Asociado],
		CASE WHEN C.GasNoAsociado = 1
			THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)
		ELSE	0		END							AS [Producción de Gas No Asociado],
		ROUND(ISNULL(CG.C1MOL,0),3)					AS [C1],
		ROUND(ISNULL(CG.C2MOL,0),3)					AS [C2],
		ROUND(ISNULL(CG.C3MOL,0),3)					AS [C3],
		ROUND(ISNULL(CG.NC4MOL,0),3)				AS [C4],
		ROUND(ISNULL(CG.IC4MOL,0),3)				AS [iC4],
		ROUND(ISNULL(CG.NC5MOL,0),3)				AS [C5],
		ROUND(ISNULL(CG.IC5MOL,0),3)				AS [iC5],
		--ROUND(ISNULL(CG.C6MOL,0),3)					AS [C6+],
		ROUND(ISNULL(CG.C6,0),3)					AS [C6],
		ROUND(ISNULL(CG.C7,0),3)					AS [C7],
		ROUND(ISNULL(CG.C8,0),3)					AS [C8],
		ROUND(ISNULL(CG.C9,0),3)					AS [C9],
		ROUND(ISNULL(CG.C10,0),3)					AS [C10],
		ROUND(ISNULL(CG.CO2MOL,0),3)				AS [CO2],
		ROUND(ISNULL(CG.H2S,0),3)					AS [H2S],
		ROUND(ISNULL(CG.N2,0),3)					AS [N2],
		ROUND(ISNULL(CG.H2O,0),3)					AS [H2O],
		ROUND(ISNULL(CG.O2,0),3)					AS [O2],
		--ROUND(SUM(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+
--			ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)+ISNULL(CG.PCC7,0)+ISNULL(CG.PCC8,0)+ISNULL(CG.PCC9,0)+ISNULL(CG.PCC10,0)),3)		AS [Poder Calorífico del Gas],
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3)	AS [Poder Calorífico del Gas],
		ROUND(ISNULL(CG.PesoMolecularGas,0),3)		AS [Peso Molecular del Gas],
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+
			ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)+ISNULL(CG.C7MMBTU,0) +ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3)	AS [Energía de Gas],
		CASE WHEN APIAC.Condensado = 0 THEN 0 ELSE ROUND(VAC.MMPC_Gas/APIAC.Condensado,3) END		AS [RGA (ASIG-AC)],
		ROUND(ISNULL(APIAC.GradosAPI,0),3)			AS [API (ASIG-AC)],
		ROUND(ISNULL(APIAC.ContenidoAzufre,0),3)	AS [% S (ASIG-AC)],
		ROUND(ISNULL(APIAC.ContenidoSal,0),3)		AS [SAL (ASIG-AC)],
		ROUND(ISNULL(CG.PoderCalorifico,0),3)		AS [PODER CALORIFICO DE PETROLEO],
		ROUND(ISNULL(VAC.C1MOL,0),3)				AS [C1 (ASIG-AC)],
		ROUND(ISNULL(VAC.C2MOL,0),3)				AS [C2 (Asig - AC)],
		ROUND(ISNULL(VAC.C3MOL,0),3)				AS [C3 (Asig - AC)],
		ROUND(ISNULL(VAC.NC4MOL,0),3)				AS [C4 (Asig - AC)],
		ROUND(ISNULL(VAC.IC4MOL,0),3)				AS [IC4 (Asig - AC)],
		ROUND(ISNULL(VAC.NC5MOL,0),3)				AS [C5 (Asig - AC)],
		ROUND(ISNULL(VAC.IC5MOL,0),3)				AS [IC5 (Asig - AC)],
		--ROUND(ISNULL(VAC.C6MOL,0),3)				AS [C6+ (Asig - AC)],
		ROUND(ISNULL(VAC.C6,0),3)				AS [C6 (Asig - AC)],
		ROUND(ISNULL(VAC.C7,0),3)				AS [C7 (Asig - AC)],
		ROUND(ISNULL(VAC.C8,0),3)				AS [C8 (Asig - AC)],
		ROUND(ISNULL(VAC.C9,0),3)				AS [C9 (Asig - AC)],
		ROUND(ISNULL(VAC.C10,0),3)				AS [C10 (Asig - AC)],
		ROUND(ISNULL(VAC.CO2MOL,0),3)				AS [CO2 (Asig - AC)],
		ROUND(ISNULL(VAC.H2S,0),3)					AS [H2S (Asig - AC)],
		ROUND(ISNULL(VAC.N2,0),3)					AS [N2 (Asig - AC)],
		ROUND(ISNULL(VAC.H2O,0),3)					AS [H2O (Asig - AC)],
		ROUND(ISNULL(VAC.O2,0),3)					AS [O2 (Asig - AC)],
--		ISNULL(VAC.C1MMBTU,0)							AS [Energia C1 (Asig - AC)],
--		ISNULL(VAC.C2MMBTU,0)							AS [Energia C2 (Asig - AC)],
--		ISNULL(VAC.C3MMBTU,0)							AS [Energia C3 (Asig - AC)],
--		ISNULL(VAC.NC4MMBTU,0) + ISNULL(VAC.IC4MMBTU,0)		AS [Energia C4 (Asig - AC)],
		ISNULL(SUM_AC.C1MMBTU,0)						AS [Energia C1 (Asig - AC)],
		ISNULL(SUM_AC.C2MMBTU,0)						AS [Energia C2 (Asig - AC)],
		ISNULL(SUM_AC.C3MMBTU,0)						AS [Energia C3 (Asig - AC)],
		ISNULL(SUM_AC.NC4MMBTU,0) + ISNULL(SUM_AC.IC4MMBTU,0)	AS [Energia C4 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCC1,0),3)					AS [Poder Calorífico C1 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCC2,0),3)					AS [Poder Calorífico C2 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCC3,0),3)					AS [Poder Calorífico C3 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCNC4,0),3) 				AS [Poder Calorífico C4 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCIC4,0),3)				AS [Poder Calorífico IC4 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCNC5,0),3) 				AS [Poder Calorífico C5 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCIC5,0),3)				AS [Poder Calorífico IC5 (Asig - AC)],
		--ISNULL(VAC.PCC6,0) + ISNULL(VAC.PCC7,0) + ISNULL(VAC.PCC8,0) + ISNULL(VAC.PCC9,0) + ISNULL(VAC.PCC10,0)													AS [Poder Calorífico C6+ (Asig - AC)],
		ISNULL(VAC.PCC1,0) + ISNULL(VAC.PCC2,0) + ISNULL(VAC.PCC3,0) + ISNULL(VAC.PCNC4,0) + ISNULL(VAC.PCIC4,0) + ISNULL(VAC.PCNC5,0) +
			 ISNULL(VAC.PCIC5,0) + ISNULL(VAC.PCC6,0) + ISNULL(VAC.PCC7,0) + ISNULL(VAC.PCC8,0) + ISNULL(VAC.PCC9,0) + ISNULL(VAC.PCC10,0)						AS [Poder Calorífico de Asiganción (Asig - AC)],
		ROUND(ISNULL(VAC.C1MMBTU,0)+ISNULL(VAC.C2MMBTU,0)+ISNULL(VAC.C3MMBTU,0)+ISNULL(VAC.NC4MMBTU,0)+ISNULL(VAC.IC4MMBTU,0)+ISNULL(VAC.NC5MMBTU,0)+
			ISNULL(VAC.IC5MMBTU,0)+ISNULL(VAC.C6MMBTU,0)+ISNULL(VAC.C7MMBTU,0)+ISNULL(VAC.C8MMBTU,0)+ISNULL(VAC.C9MMBTU,0)+ISNULL(VAC.C10MMBTU,0),3)			AS [Energía de Gas (Asig - AC)],
		ROUND(ISNULL(VAC.C5EqBl,0),3)																															AS [Vol C5+ (Asig - AC)],
		ROUND(ISNULL(VAC.PCNC5 + VAC.PCIC5 + VAC.PCC6 + VAC.PCC7 + VAC.PCC8 + VAC.PCC9 + VAC.PCC10,0),3)														AS [Poder Calorífico de C5+ (Asig - AC)],
		CASE WHEN ISNULL(EC.Eventos,'') = '' THEN 'N/A'
			ELSE EC.Eventos
		END				AS [Eventos]
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
		AND	I.Activo = 1
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		PR_ProdDiariaPozo_Previo	PDPP	(NOLOCK)
		ON	P.Id	=	PDPP.Pozo
		AND PDPP.Fecha <= @FechaFin
	JOIN
		#ValoresAC		VAC
		ON	PEC.idContrato		=	VAC.IdContrato
	JOIN           
		#ValAPIAC	APIAC
		ON	PEC.idContrato	=	APIAC.IdContrato
	JOIN
		#ConversionGasAC	SUM_AC
		ON	PEC.idContrato	=	SUM_AC.IdContrato
	LEFT JOIN
		PR_EventosMensualesPozo	EC	(NOLOCK)
		ON	P.Id	=	EC.IdPozo
		AND YEAR(EC.MesReporte)	=	YEAR(@MesReporte)
		AND MONTH(EC.MesReporte)	=	MONTH(@MesReporte)	
	LEFT JOIN
		#Petroleo15_16XPozo	P15_56
		ON PEC.idContrato	=	P15_56.IdContrato
		AND	PDPP.Pozo		=	P15_56.IdPozo
	LEFT JOIN
		#PromPonderado	PP
		ON	PEC.IdContrato	=	PP.IdContrato
		AND	PDPP.Pozo	=	PP.IdPozo
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
	WHERE
		YEAR(@MesReporte) = YEAR(PDPP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDPP.Fecha)
		AND (ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3) + ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3) + ROUND(ISNULL(CG.MMPC_Gas,0),3)) > 0
	GROUP BY
		C.NumeroContrato,
		P.RegionFiscal,
		CA.Nombre,
		CASE WHEN ISNULL(P.Clave,'') = ''
			THEN 'N/A'
			ELSE P.Clave
		END,
		P.Nombre,
		ISNULL(VTH.NumDias,0),
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
		--ROUND(ISNULL(CG.C6MOL,0),3),
		ROUND(ISNULL(CG.C6,0),3),
		ROUND(ISNULL(CG.C7,0),3),
		ROUND(ISNULL(CG.C8,0),3),
		ROUND(ISNULL(CG.C9,0),3),
		ROUND(ISNULL(CG.C10,0),3),
		ROUND(ISNULL(CG.CO2MOL,0),3),
		ROUND(ISNULL(CG.H2S,0),3),
		ROUND(ISNULL(CG.N2,0),3),
		ROUND(ISNULL(CG.H2O,0),3),
		ROUND(ISNULL(CG.O2,0),3),
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3),
		ROUND(ISNULL(CG.PesoMolecularGas,0),3),
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+
			ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)+ISNULL(CG.C7MMBTU,0) +ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3),
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
		--ROUND(ISNULL(VAC.C6MOL,0),3),
		ROUND(ISNULL(VAC.C6,0),3),
		ROUND(ISNULL(VAC.C7,0),3),
		ROUND(ISNULL(VAC.C8,0),3),
		ROUND(ISNULL(VAC.C9,0),3),
		ROUND(ISNULL(VAC.C10,0),3),
		ROUND(ISNULL(VAC.CO2MOL,0),3),
		ROUND(ISNULL(VAC.H2S,0),3),
		ROUND(ISNULL(VAC.N2,0),3),
		ROUND(ISNULL(VAC.H2O,0),3),
		ROUND(ISNULL(VAC.O2,0),3),
		--ISNULL(VAC.C1MMBTU,0),
		--ISNULL(VAC.C2MMBTU,0),
		--ISNULL(VAC.C3MMBTU,0),
		--ISNULL(VAC.NC4MMBTU,0) + ISNULL(VAC.IC4MMBTU,0),
		ISNULL(SUM_AC.C1MMBTU,0),
		ISNULL(SUM_AC.C2MMBTU,0),
		ISNULL(SUM_AC.C3MMBTU,0),
		ISNULL(SUM_AC.NC4MMBTU,0) + ISNULL(SUM_AC.IC4MMBTU,0),
		--ROUND(ISNULL(VAC.PCC1,0),3),
		--ROUND(ISNULL(VAC.PCC2,0),3),
		--ROUND(ISNULL(VAC.PCC3,0),3),
		--ROUND(ISNULL(VAC.PCNC4,0),3),
		--ROUND(ISNULL(VAC.PCIC4,0),3),
		--ROUND(ISNULL(VAC.PCNC5,0),3),
		--ROUND(ISNULL(VAC.PCIC5,0),3),
		--ISNULL(VAC.PCC6,0) + ISNULL(VAC.PCC7,0) + ISNULL(VAC.PCC8,0) + ISNULL(VAC.PCC9,0) + ISNULL(VAC.PCC10,0),
		ISNULL(VAC.PCC1,0) + ISNULL(VAC.PCC2,0) + ISNULL(VAC.PCC3,0) + ISNULL(VAC.PCNC4,0) + ISNULL(VAC.PCIC4,0) + ISNULL(VAC.PCNC5,0) +
			 ISNULL(VAC.PCIC5,0) + ISNULL(VAC.PCC6,0) + ISNULL(VAC.PCC7,0) + ISNULL(VAC.PCC8,0) + ISNULL(VAC.PCC9,0) + ISNULL(VAC.PCC10,0),
		ROUND(ISNULL(VAC.C1MMBTU,0)+ISNULL(VAC.C2MMBTU,0)+ISNULL(VAC.C3MMBTU,0)+ISNULL(VAC.NC4MMBTU,0)+ISNULL(VAC.IC4MMBTU,0)+ISNULL(VAC.NC5MMBTU,0)+
			ISNULL(VAC.IC5MMBTU,0)+ISNULL(VAC.C6MMBTU,0)+ISNULL(VAC.C7MMBTU,0)+ISNULL(VAC.C8MMBTU,0)+ISNULL(VAC.C9MMBTU,0)+ISNULL(VAC.C10MMBTU,0),3),
		ROUND(ISNULL(VAC.C5EqBl,0),3),
		ROUND(ISNULL(VAC.PCNC5 + VAC.PCIC5 + VAC.PCC6 + VAC.PCC7 + VAC.PCC8 + VAC.PCC9 + VAC.PCC10,0),3),
		CASE WHEN ISNULL(EC.Eventos,'') = '' THEN 'N/A'
			ELSE EC.Eventos
		END

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
		ISNULL(VTH.NumDias,0)			AS [Días de Producción],
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END 		AS [Tipo de Fluido],
		--ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3)		AS [Producción de Petróleo Bruto],
		ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3) + ROUND(ISNULL(VTH.ProdAgua,0),3)	AS [Producción de Petróleo Bruto],
		ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3)			AS [Producción de Petróleo Neto],
		ISNULL(PP.GradosAPI,0)			AS [°API],
		ISNULL(PP.ContenidoAzufre,0)	AS [% AZUFRE],
		ISNULL(PP.ContenidoSal,0)		AS [SAL],
		ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3)	AS [Producción de Condesado Neto],
		ROUND(ISNULL(VTH.ProdAgua,0),3)	AS [Producción de Agua Neto],
		CASE WHEN C.GasNoAsociado = 0 THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)	ELSE 0	END						AS [Producción de Gas Asociado],
		CASE WHEN C.GasNoAsociado = 1 THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)	ELSE 0	END						AS [Producción de Gas No Asociado],
		ROUND(ISNULL(CG.C1MOL,0),3)					AS [C1],
		ROUND(ISNULL(CG.C2MOL,0),3)					AS [C2],
		ROUND(ISNULL(CG.C3MOL,0),3)					AS [C3],
		ROUND(ISNULL(CG.IC4MOL,0),3)				AS [C4],
		ROUND(ISNULL(CG.IC4MOL,0),3)				AS [iC4],
		ROUND(ISNULL(CG.IC5MOL,0),3)				AS [C5],
		ROUND(ISNULL(CG.IC5MOL,0),3)				AS [iC5],
		--ROUND(ISNULL(CG.C6MOL,0),3)					AS [C6+],
		ROUND(ISNULL(CG.C6,0),3)				AS [C6],
		ROUND(ISNULL(CG.C7,0),3)				AS [C7],
		ROUND(ISNULL(CG.C8,0),3)				AS [C8],
		ROUND(ISNULL(CG.C9,0),3)				AS [C9],
		ROUND(ISNULL(CG.C10,0),3)				AS [C10],
		ROUND(ISNULL(CG.CO2MOL,0),3)				AS [CO2],
		ROUND(ISNULL(CG.H2S,0),3)					AS [H2S],
		ROUND(ISNULL(CG.N2,0),3)					AS [N2],
		ROUND(ISNULL(CG.H2O,0),3)					AS [H2O],
		ROUND(ISNULL(CG.O2,0),3)					AS [O2],
		--ROUND(SUM(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+
--			ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)+ISNULL(CG.PCC7,0)+ISNULL(CG.PCC8,0)+ISNULL(CG.PCC9,0)+ISNULL(CG.PCC10,0)),3)						AS [Poder Calorífico del Gas],
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3)		AS [Poder Calorífico del Gas],
		ROUND(ISNULL(CG.PesoMolecularGas,0),3)		AS [Peso Molecular del Gas],
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+
			ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)+ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3)		AS [Energía de Gas],
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
		--ROUND(ISNULL(VAC.C6MOL,0),3)				AS [C6+ (Asig - AC)],
		ROUND(ISNULL(VAC.C6,0),3)				AS [C6 (Asig - AC)],
		ROUND(ISNULL(VAC.C7,0),3)				AS [C7 (Asig - AC)],
		ROUND(ISNULL(VAC.C8,0),3)				AS [C8 (Asig - AC)],
		ROUND(ISNULL(VAC.C9,0),3)				AS [C9 (Asig - AC)],
		ROUND(ISNULL(VAC.C10,0),3)				AS [C10 (Asig - AC)],
		ROUND(ISNULL(VAC.CO2MOL,0),3)				AS [CO2 (Asig - AC)],
		ROUND(ISNULL(VAC.H2S,0),3)					AS [H2S (Asig - AC)],
		ROUND(ISNULL(VAC.N2,0),3)					AS [N2 (Asig - AC)],
		ROUND(ISNULL(VAC.H2O,0),3)			AS [H2O (Asig - AC)],
		ROUND(ISNULL(VAC.O2,0),3)			AS [O2 (Asig - AC)],
		--ISNULL(VAC.C1MMBTU,0)							AS [Energia C1 (Asig - AC)],
		--ISNULL(VAC.C2MMBTU,0)							AS [Energia C2 (Asig - AC)],
		--ISNULL(VAC.C3MMBTU,0)							AS [Energia C3 (Asig - AC)],
		--ISNULL(VAC.NC4MMBTU,0) + ISNULL(VAC.IC4MMBTU,0)		AS [Energia C4 (Asig - AC)],
		ISNULL(SUM_AC.C1MMBTU,0)						AS [Energia C1 (Asig - AC)],
		ISNULL(SUM_AC.C2MMBTU,0)						AS [Energia C2 (Asig - AC)],
		ISNULL(SUM_AC.C3MMBTU,0)						AS [Energia C3 (Asig - AC)],
		ISNULL(SUM_AC.NC4MMBTU,0) + ISNULL(SUM_AC.IC4MMBTU,0)	AS [Energia C4 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCC2,0),3)				AS [Poder Calorífico C2 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCC3,0),3)				AS [Poder Calorífico C3 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCNC4,0),3) 	AS [Poder Calorífico C4 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCIC4,0),3)				AS [Poder Calorífico IC4 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCNC5,0),3) 	AS [Poder Calorífico C5 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCIC5,0),3)				AS [Poder Calorífico IC5 (Asig - AC)],
		--ROUND(ISNULL(VAC.PCC6,0)+ISNULL(VAC.PCC7,0)+ISNULL(VAC.PCC8,0)+ISNULL(VAC.PCC9,0)+ISNULL(VAC.PCC10,0),3)										AS [Poder Calorífico C6+ (Asig - AC)],
		ROUND(ISNULL(VAC.PCC1,0)+ISNULL(VAC.PCC2,0)+ISNULL(VAC.PCC3,0)+ISNULL(VAC.PCNC4,0)+ISNULL(VAC.PCIC4,0)+ISNULL(VAC.PCNC5,0)+ISNULL(VAC.PCIC5,0)+
			ISNULL(VAC.PCC6,0)+ISNULL(VAC.PCC7,0)+ISNULL(VAC.PCC8,0)+ISNULL(VAC.PCC9,0)+ISNULL(VAC.PCC10,0),3)											AS [Poder Calorífico de Asiganción (Asig - AC)],
		ROUND(ISNULL(VAC.C1MMBTU,0)+ISNULL(VAC.C2MMBTU,0)+ISNULL(VAC.C3MMBTU,0)+ISNULL(VAC.NC4MMBTU,0)+ISNULL(VAC.IC4MMBTU,0)+ISNULL(VAC.NC5MMBTU,0)+
			ISNULL(VAC.IC5MMBTU,0)+ISNULL(VAC.C6MMBTU,0)+ISNULL(VAC.C7MMBTU,0)+ISNULL(VAC.C8MMBTU,0)+ISNULL(VAC.C9MMBTU,0)+ISNULL(VAC.C10MMBTU,0),3)		AS [Energía de Gas (Asig - AC)],
		ROUND(ISNULL(VAC.C5EqBl,0),3)			AS [Vol C5+ (Asig - AC)],
		ROUND(ISNULL(VAC.PCNC5 + VAC.PCIC5 + VAC.PCC6 + VAC.PCC7 + VAC.PCC8 + VAC.PCC9 + VAC.PCC10,0),3)				AS [Poder Calorífico de C5+ (Asig - AC)],
		CASE WHEN ISNULL(EC.Eventos,'') = '' THEN 'N/A'
			ELSE EC.Eventos
		END				AS [Eventos]
	FROM
		#ContratosConciliada	CO
	JOIN
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CO.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I	(NOLOCK)
		ON	C.IdAreaContractual	=	I.IdAreaContractual
		AND		I.Activo = 1
	JOIN
		dbo.PR_Pozo	P	(NOLOCK)
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
		ON	C.IdContrato	=	PEC.idContrato
		AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo	PDP	(NOLOCK)
		ON	P.Id	=	PDP.Pozo
		AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	JOIN
		#PromPonderado	PP
		ON	PEC.idContrato	=	PP.IdContrato
		AND	PDP.Pozo	=	PP.IdPozo
	JOIN
		#VolumenesTotalesHidro	VTH
		ON	PEC.idContrato	=	VTH.IdContrato
		AND	PDP.Pozo	=	VTH.IdPozo
	JOIN
		#ValoresAC		VAC
		ON	PEC.idContrato	=	VAC.IdContrato
	JOIN
		#ValAPIAC	APIAC
		ON	PEC.idContrato	=	APIAC.IdContrato
	JOIN
		#ConversionGasAC	SUM_AC
		ON	PEC.idContrato	=	SUM_AC.IdContrato
	LEFT JOIN
		PR_EventosMensualesPozo	EC	(NOLOCK)
		ON	P.Id	=	EC.IdPozo
		AND YEAR(EC.MesReporte)	=	YEAR(@MesReporte)
		AND MONTH(EC.MesReporte)	=	MONTH(@MesReporte)	
	LEFT JOIN
		dbo.PR_Campo	CA	(NOLOCK)
		ON	P.Campo	=	CA.Id
	LEFT JOIN
		#ConversionGas	CG
		ON	PEC.idContrato	=	CG.IdContrato
		AND	P.Id	=	CG.IdPozo
	LEFT JOIN
		#Petroleo15_16XPozo	P15_56
		ON PEC.idContrato	=	P15_56.IdContrato
		AND	PDP.Pozo		=	P15_56.IdPozo
	WHERE
		YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
		AND (ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3) + ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3) + ROUND(ISNULL(CG.MMPC_Gas,0),3)) > 0
	GROUP BY
		C.NumeroContrato,
		P.RegionFiscal,
		CA.Nombre,
		CASE WHEN ISNULL(P.Clave,'') = ''
			THEN 'N/A'
			ELSE P.Clave
		END,
		P.Nombre,
		ISNULL(VTH.NumDias,0),
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END,
		ISNULL(PP.GradosAPI,0),
		ISNULL(PP.ContenidoAzufre,0),
		ISNULL(PP.ContenidoSal,0),
		--ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3),
		ROUND(ISNULL(P15_56.ProdPetroleoNeto,0),3),
		ROUND(ISNULL(VTH.ProdCondensadoNeto_15_56,0),3),
		ROUND(ISNULL(VTH.ProdAgua,0),3),
		CASE WHEN C.GasNoAsociado = 0 THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3)	ELSE 0	END,
		CASE WHEN C.GasNoAsociado = 1 THEN	ROUND(ISNULL(CG.MMPC_Gas,0),3) ELSE	0 END,
		ROUND(ISNULL(CG.C1MOL,0),3),
		ROUND(ISNULL(CG.C2MOL,0),3),
		ROUND(ISNULL(CG.C3MOL,0),3),
		ROUND(ISNULL(CG.IC4MOL,0),3),
		ROUND(ISNULL(CG.IC4MOL,0),3),
		ROUND(ISNULL(CG.IC5MOL,0),3),
		ROUND(ISNULL(CG.IC5MOL,0),3),
		--ROUND(ISNULL(CG.C6MOL,0),3),
		ROUND(ISNULL(CG.C6,0),3),
		ROUND(ISNULL(CG.C7,0),3),
		ROUND(ISNULL(CG.C8,0),3),
		ROUND(ISNULL(CG.C9,0),3),
		ROUND(ISNULL(CG.C10,0),3),
		ROUND(ISNULL(CG.CO2MOL,0),3),
		ROUND(ISNULL(CG.H2S,0),3),
		ROUND(ISNULL(CG.N2,0),3),
		ROUND(ISNULL(CG.H2O,0),3),
		ROUND(ISNULL(CG.O2,0),3),
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3),
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+
			ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)+ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3),
		ROUND(ISNULL(CG.PesoMolecularGas,0),3),
		ROUND(ISNULL(CG.PoderCalorifico,0),3),
		CASE WHEN APIAC.Condensado = 0 THEN 0 ELSE ROUND(VAC.MMPC_Gas/APIAC.Condensado,3) END,
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
		--ROUND(ISNULL(VAC.C6MOL,0),3),
		ROUND(ISNULL(VAC.C6,0),3),
		ROUND(ISNULL(VAC.C7,0),3),
		ROUND(ISNULL(VAC.C8,0),3),
		ROUND(ISNULL(VAC.C9,0),3),
		ROUND(ISNULL(VAC.C10,0),3),
		ROUND(ISNULL(VAC.CO2MOL,0),3),
		ROUND(ISNULL(VAC.H2S,0),3),
		ROUND(ISNULL(VAC.N2,0),3),
		ROUND(ISNULL(VAC.H2O,0),3),
		ROUND(ISNULL(VAC.O2,0),3),
		--ISNULL(VAC.C1MMBTU,0),
		--ISNULL(VAC.C2MMBTU,0),
		--ISNULL(VAC.C3MMBTU,0),
		--ISNULL(VAC.NC4MMBTU,0) + ISNULL(VAC.IC4MMBTU,0),
		ISNULL(SUM_AC.C1MMBTU,0),
		ISNULL(SUM_AC.C2MMBTU,0),
		ISNULL(SUM_AC.C3MMBTU,0),
		ISNULL(SUM_AC.NC4MMBTU,0) + ISNULL(SUM_AC.IC4MMBTU,0),
		--ROUND(ISNULL(VAC.PCC1,0),3),
		--ROUND(ISNULL(VAC.PCC2,0),3),
		--ROUND(ISNULL(VAC.PCC3,0),3),
		--ROUND(ISNULL(VAC.PCNC4,0),3),
		--ROUND(ISNULL(VAC.PCIC4,0),3),
		--ROUND(ISNULL(VAC.PCNC5,0),3),
		--ROUND(ISNULL(VAC.PCIC5,0),3),
		--ROUND(ISNULL(VAC.PCC6,0)+ISNULL(VAC.PCC7,0)+ISNULL(VAC.PCC8,0)+ISNULL(VAC.PCC9,0)+ISNULL(VAC.PCC10,0),3),
		ROUND(ISNULL(VAC.PCC1,0)+ISNULL(VAC.PCC2,0)+ISNULL(VAC.PCC3,0)+ISNULL(VAC.PCNC4,0)+ISNULL(VAC.PCIC4,0)+ISNULL(VAC.PCNC5,0)+ISNULL(VAC.PCIC5,0)+
			ISNULL(VAC.PCC6,0)+ISNULL(VAC.PCC7,0)+ISNULL(VAC.PCC8,0)+ISNULL(VAC.PCC9,0)+ISNULL(VAC.PCC10,0),3),
		ROUND(ISNULL(VAC.C1MMBTU,0)+ISNULL(VAC.C2MMBTU,0)+ISNULL(VAC.C3MMBTU,0)+ISNULL(VAC.NC4MMBTU,0)+ISNULL(VAC.IC4MMBTU,0)+ISNULL(VAC.NC5MMBTU,0)+
			ISNULL(VAC.IC5MMBTU,0)+ISNULL(VAC.C6MMBTU,0)+ISNULL(VAC.C7MMBTU,0)+ISNULL(VAC.C8MMBTU,0)+ISNULL(VAC.C9MMBTU,0)+ISNULL(VAC.C10MMBTU,0),3),
		ROUND(ISNULL(VAC.C5EqBl,0),3),
		ROUND(ISNULL(VAC.PCNC5 + VAC.PCIC5 + VAC.PCC6 + VAC.PCC7 + VAC.PCC8 + VAC.PCC9 + VAC.PCC10,0),3),
		CASE WHEN ISNULL(EC.Eventos,'') = '' THEN 'N/A'
			ELSE EC.Eventos
		END
	ORDER BY
		C.NumeroContrato,
		P.Nombre
END

IF @resultadoDeseado in (0,2)
BEGIN
	---RESULTADO 2
	/************************* AFOROS DE POZO ****************************/

	-- SE BUSCA SI EXISTEN AFOROS REGISTRADOS EN ADINCO
	IF 0 < (SELECT COUNT(1)
			FROM	#Contratos	C
			JOIN	PR_Aforo	A
			ON	C.IdContrato	=	A.IdContrato
			WHERE	A.Fecha	BETWEEN @MesReporte AND @FechaFin
	)
	BEGIN

		SELECT
			CO.NumeroContrato	AS [ID Contrato o Asignación],
			P.RegionFiscal		AS [Región Fiscal],		--DATO POR CONTRATO
			CA.Nombre			AS [Nombre del Campo],
			CASE WHEN ISNULL(P.Clave,'') = ''
				THEN 'N/A'
				ELSE P.Clave
			END					AS [ID de Pozo SEGUN ANEXO 3 POZOS],
			P.Nombre			AS [Nombre del Pozo SEGUN ANEXO 3 POZOS],
			A.Fecha,
			ROUND(A.PresionCabeza,3)		AS [Presión de Cabeza],
			ROUND(A.Estrangulador,3)		AS [Estrangulador],
			ROUND(A.PresionLinea,3)			AS [Presión de Línea],
			ROUND(A.Temperatura,3)			AS [Temperatura],
			CASE WHEN ROUND(ISNULL(A.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(A.ProduccionPetroleo,0) * ISNULL(PP.CTL,1),3)
				ELSE ROUND(ISNULL(A.ProduccionPetroleo,0),3) END		AS [Producción de Petróleo],
			CASE WHEN ROUND(ISNULL(A.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(A.ProduccionGas,0) * (@60F_R/@68F_R),3)
				ELSE ROUND(ISNULL(A.ProduccionGas,0),3) END					AS [Producción de Gas],
			ROUND(A.ProduccionAgua,3)			AS [Producción de Agua],
			ROUND(A.RGA,3)					AS [RGA],
			ISNULL(A.Observaciones,'')		AS [OBSERVACIONES]
		FROM
			#Contratos	C
		JOIN
			dbo.CO_Contrato	CO	(NOLOCK)
			ON	C.IdContrato	=	CO.IdContrato
		JOIN
			PR_Aforo	A	(NOLOCK)
			ON	C.IdContrato	=	A.IdContrato
		JOIN
			dbo.PR_Pozo	P	(NOLOCK)
			ON	A.IdPozo	=	P.Id
		LEFT JOIN
			dbo.PR_Campo	CA	(NOLOCK)
			ON	P.Campo	=	CA.Id
		LEFT JOIN
			#PromPonderado	PP	-- SE OBTIENEN LOS VALORES PARA LA CONVERSION DE TEMPERATURA
			ON	C.IdContrato	=	PP.IdContrato
			AND	A.IdPozo	=	PP.IdPozo
		WHERE
			A.Fecha	BETWEEN @MesReporte AND @FechaFin
	END
	ELSE
	BEGIN
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
			ROUND(ISNULL(PD.Temperatura,0),3)		AS [Temperatura],
			CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProdPetroleoBruto,0) * ISNULL(PP.CTL,1),3)
				ELSE ROUND(ISNULL(PDP.ProdPetroleoBruto,0),3) END		AS [Producción de Petróleo],
			CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.GastoGas,0) * (@60F_R/@68F_R),3)
				ELSE ROUND(ISNULL(PDP.GastoGas,0),3) END					AS [Producción de Gas],
			ROUND(PDP.Agua,3)			AS [Producción de Agua],
			CASE WHEN PDP.ProdAceiteNeto = 0 THEN 0 ELSE ROUND(PDP.GastoGas/PDP.ProdAceiteNeto,3) END	AS [RGA],
			CASE WHEN ISNULL(PDP.Comentarios,'') = ''
				THEN 'N/A'
				ELSE PDP.Comentarios
			END		AS [OBSERVACIONES]
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
			AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
			AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
			AND ( (@BitDiario = 1 AND PDP.Fecha = @FechaFin) OR (@BitDiario = 0 AND PDP.Fecha BETWEEN @MesReporte AND @FechaFin) )
		LEFT JOIN
			#PromPonderado	PP	-- SE OBTIENEN LOS VALORES PARA LA CONVERSION DE TEMPERATURA
			ON	C.IdContrato	=	PP.IdContrato
			AND	PDP.Pozo	=	PP.IdPozo
		LEFT JOIN
			dbo.PR_Campo	CA	(NOLOCK)
			ON	P.Campo	=	CA.Id
		LEFT JOIN
			dbo.PR_ProdDiaria_Previo	PD	(NOLOCK)
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
			ROUND(ISNULL(PD.TemperaturaPetroleo,PD.TemperaturaGas),3)		AS [Temperatura],
			CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProduccionReal,0) * ISNULL(PP.CTL,1),3)
				ELSE ROUND(ISNULL(PDP.ProduccionReal,0),3) END		AS [Producción de Petróleo],
			CASE WHEN ROUND(ISNULL(PD.TemperaturaGas,20),2) <> 15.56 THEN ROUND( (PDP.ProduccionRealGasM3 * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3)
				ELSE ROUND(ISNULL(PDP.ProduccionRealGasM3,0) * @FactorConverM3_MMPC,3) END		AS [Producción de Gas],
			ROUND(ISNULL(DIARIA.Agua,0),3)			AS [Producción de Agua],
			CASE WHEN PDP.ProduccionReal = 0 THEN 0 ELSE ROUND(PDP.ProduccionRealGasM3/PDP.ProduccionReal,3) END	AS [RGA],
			CASE WHEN ISNULL(DIARIA.Comentarios,'') = ''
				THEN 'N/A'
				ELSE DIARIA.Comentarios
			END		AS [OBSERVACIONES]
		FROM
			#ContratosConciliada	CO
		JOIN
			dbo.CO_Contrato	C	(NOLOCK)
			ON	CO.IdContrato	=	C.IdContrato
		JOIN
			CO_AreaContractual	AC	(NOLOCK)
			ON	C.IdAreaContractual	=	AC.IdAreaContractual
		JOIN
			CO_Instalacion	I	(NOLOCK)
			ON	AC.IdAreaContractual	=	I.IdAreaContractual
		JOIN
			dbo.PR_Pozo	P	(NOLOCK)
			ON	I.WelIID	=	P.Id
		JOIN
			PR_ProdDiariaPozo	PDP	(NOLOCK)
			ON	P.Id	=	PDP.Pozo
			AND YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
			AND	MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
		LEFT JOIN
			#PromPonderado	PP	-- SE OBTIENEN LOS VALORES PARA LA CONVERSION DE TEMPERATURA
			ON	C.IdContrato	=	PP.IdContrato
			AND	PDP.Pozo	=	PP.IdPozo
		LEFT JOIN
			dbo.PR_ProdDiariaPozo_Previo	DIARIA	(NOLOCK)
			ON	PDP.Pozo	=	DIARIA.Pozo
			AND PDP.Fecha	=	DIARIA.Fecha
		LEFT JOIN
			dbo.PR_Campo	CA	(NOLOCK)
			ON	P.Campo	=	CA.Id
		LEFT JOIN
			dbo.PR_ProdDiaria	PD	(NOLOCK)
			ON	PDP.ProdDiaria	=	PD.Id
			AND	PDP.Fecha		=	PD.Fecha
		WHERE
			I.Activo = 1
		 ORDER BY
			C.NumeroContrato,
			P.Nombre,
			PDP.Fecha
	END
END

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
IF @resultadoDeseado in (0,3)
BEGIN
	IF @BitDiario = 0 AND 0 < (SELECT COUNT(1) FROM #ContratosDiaria)
	BEGIN
		SELECT  CASE WHEN @SinPoderCalorifico = ''
					THEN 'Sin produccion Conciliada en los contratos: ' + @Contratos
				ELSE 'Sin produccion Conciliada en los contratos: ' + @Contratos + 'Sin Poder Calorífico de Gas en los contratos: ' + @SinPoderCalorifico
				END
	END
END
END