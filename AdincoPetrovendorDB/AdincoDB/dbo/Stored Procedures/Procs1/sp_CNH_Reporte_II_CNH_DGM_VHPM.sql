CREATE PROCEDURE dbo.sp_CNH_Reporte_II_CNH_DGM_VHPM
	@Contrato		INT,
	@MesReporte		DATE,	
	@IdUsuario		INT,
	@pPuntoEntregaId int=0, --Se utiliza para la pantalla RegistroBalenceMensual.aspx
	@pEsConciliado bit=0 out --Se utiliza para la pantalla RegistroBalenceMensual.aspx
AS
BEGIN
-- =============================================
-- Description:	Reporte de CNH II_CNH_DGM_VHPM (Producción Diaria y Mensual por Instalación)
-- -------------------------------------------------
-- FECHA	MODIFICÓ	COMENTARIO
-- -------------------------------------------------
-- 20180503	BAAC		Creación de sp
-- 20180824	BAAC	Se modifica para buscar la cromatografia del mes anterior, si no hay en el mes a consultar
-- 20190129	BAAC	Se modifica para buscar la calidad del petrole del mes anterior, si no hay en el mes a consultar
-- 20190304	BAAC	Se modifica para tomar la temperatura de los hidrocarburos de acuerdo a lo indicado en los formatos de producción diaria
-- =============================================
SET NOCOUNT ON
-- =============================================
-- SE CAMBIA A VERSION 2 POR CAMBIO EN CALCULO DE ENERGIA A API 14.5
EXEC dbo.sp_CNH_Reporte_II_CNH_DGM_VHPM_V2 @Contrato, @MesReporte, @IdUsuario, @pPuntoEntregaId, @pEsConciliado OUTPUT
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
	PuntoEntregaID		INT,
	Fecha	DATE,
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
	SinCromatografia	BIT,
	PoderCalorifico	FLOAT,
	PoderCalorifico_Gas	FLOAT,
	PRIMARY KEY (IdContrato, PuntoEntregaID, Fecha)
)

CREATE TABLE #ConversionGasInstalacion
(
	IdContrato	INT,
	PuntoEntregaID		INT,
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
	PesoMolecularGas	FLOAT
)

CREATE TABLE #ValoresInstalacion
(
	IdContrato	INT,
	PuntoEntregaID		INT,
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
	PesoMolecularGas	FLOAT
)

CREATE TABLE #PromPonderado
(
	IdContrato	INT,
	PuntoEntregaID	INT,
	Fecha			DATETIME,
	Presion			FLOAT,
	Temperatura		FLOAT,
	DensidadAPI		FLOAT,
	Salinidad		FLOAT,
	PorcentajeAguaSedimentos		FLOAT,
	Azufre			DECIMAL(12,4),
	KgM3		FLOAT,
	Alfa		FLOAT,
	CTL			FLOAT,
	KgM3_Condensado	FLOAT,
	Alfa_Condensado	FLOAT,
	CTL_Condensado	FLOAT,
	SinCalidad	BIT,
	PRIMARY KEY (IdContrato, PuntoEntregaID, Fecha)
)

CREATE TABLE #ValMensualInstalacion
(
	IdContrato	INT,
	PuntoEntregaID		INT,
	Presion			FLOAT,
	Temperatura		FLOAT,
	DensidadAPI		FLOAT,
	Salinidad		FLOAT,
	PorcentajeAguaSedimentos		FLOAT,
	Azufre			DECIMAL(12,4)
)

CREATE TABLE #Pozos
(
	IdContrato	INT,
	PuntoEntregaID INT,
	IdPozo	INT,
	Cant	INT
)

CREATE TABLE #VolumenesTotalesHidro
(
	IdContrato	INT,
	PuntoEntregaID	INT,
	ProdPetroleo	FLOAT,
	MMPC_Gas	FLOAT,
	Condensado	FLOAT,
	ProdPetroleo_15_56	FLOAT,
	Condensado_15_56	FLOAT,
	VolumenAgua	FLOAT,
	VolumenAgua_SR	FLOAT,
	PRIMARY KEY (IdContrato, PuntoEntregaID)
)

CREATE TABLE #VolumenXPtoEntrega
(
	IdContrato	INT,
	PuntoEntregaID	INT,
	Fecha	DATE,
	VolumenPetroleo	FLOAT,
	VolumenGas	FLOAT,
	VolumenCondensado	FLOAT,
	RegionFiscal	VARCHAR(1000),
	TipoFluido		VARCHAR(2000),
	VolumenPetroleo_15_56	FLOAT,
	VolumenCondensado_15_56	FLOAT,
	VolumenAgua	FLOAT,
	VolumenAgua_SR	FLOAT,
	PRIMARY KEY (IdContrato, PuntoEntregaID, Fecha)
)

CREATE TABLE #TotalesXContrato
(
	IdContrato	INT,
	Petroleo	FLOAT,
	Gas			FLOAT
)

CREATE TABLE #Petroleo15_16
(
	IdContrato	INT,
	PuntoEntregaID	INT,
	IdPozo	INT,
	Fecha	DATE,
	ProdPetroleoBruto	FLOAT,
	ProdPetroleoBruto_SR	FLOAT,
	ProdAceiteNeto		FLOAT,
	ProdAceiteNeto_SR		FLOAT,
	Temperatura			FLOAT,
	PRIMARY KEY (IdContrato, PuntoEntregaID, IdPozo, Fecha)
)

CREATE TABLE #Petroleo15_56XPtoEntrega
(
	IdContrato	INT,
	PuntoEntregaID	INT,
	Fecha	DATE,
	ProdPetroleoBruto	FLOAT,
	ProdPetroleoBruto_SR	FLOAT,
	ProdAceiteNeto		FLOAT,
	ProdAceiteNeto_SR		FLOAT,
	PRIMARY KEY (IdContrato, PuntoEntregaID, Fecha)
)

CREATE TABLE #Petroleo15_56XPtoEntregaTotal
(
	IdContrato	INT,
	PuntoEntregaID	INT,
	ProdPetroleoBruto	FLOAT,
	ProdPetroleoBruto_SR	FLOAT,
	ProdAceiteNeto		FLOAT,
	ProdAceiteNeto_SR		FLOAT,
	PRIMARY KEY (IdContrato, PuntoEntregaID)
)

DECLARE
	@FactorConverM3_MMPC FLOAT = 0.00003531467,
	@60F_R         FLOAT = 519.67, -- 60 grados Fahrenheit a rankine
    @68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
	@BitConciliada	BIT = 1,
	@TotalPetroleo	FLOAT,
	@TotalGas		FLOAT,
	@IdRelacionado	INT,
	@Contratos		VARCHAR(800) = '',
	@SinPoderCalorifico VARCHAR(4000) = ''

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

INSERT INTO #Pozos
(
	IdContrato,
	PuntoEntregaID,
	IdPozo,
	Cant
)
SELECT
	C.IdContrato,
	PEC.PuntoEntregaID,
	P.Id,
	COUNT(PDP.Id)
FROM
	#Contratos	CO
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
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	C.IdContrato	=	PEC.idContrato
	AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
JOIN
	dbo.CO_PuntosdeEntrega	PE
	ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	AND P.PuntoEntregaID	=	PE.PuntoEntregaID
LEFT JOIN
	dbo.PR_ProdDiariaPozo	PDP
	ON P.Id	=	PDP.Pozo
	AND
	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
	AND
	MONTH(PDP.Fecha) = MONTH(@MesReporte)
WHERE
	I.Activo = 1
GROUP BY
	C.IdContrato,
	PEC.PuntoEntregaID,
	P.Id

---- SE VALIDA SI EXISTE PRODUCCION CONCILIADA
IF 0 < (SELECT	COUNT(1)
		FROM 	#Pozos
		WHERE Cant = 0 and
		PuntoEntregaID = @pPuntoEntregaID
		OR(
			@pPuntoEntregaID = 0 and
			IdContrato = @Contrato
		)
		)
BEGIN
	SELECT @BitConciliada = 0
			
END 

set @pEsConciliado = @BitConciliada 

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
	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
	AND MONTH(PDP.Fecha)	=	MONTH(@MesReporte)
	AND	I.Activo = 1
GROUP BY
	CO.IdContrato
HAVING
	COUNT(PDP.Fecha) >= DAY(EOMONTH(@MesReporte))

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

--IF @BitConciliada = 1
--BEGIN
	-- SE VALIDA SI EXISTE GAS EN ALGUNO DE LOS POZOS PARA REALIZAR EL CALCULO DE % MOLAR
	INSERT INTO #ConversionGas
	(	IdContrato,
		PuntoEntregaID, Fecha,
		MMPC_Gas,
		C1MOL,	C2MOL,	C3MOL,	NC4MOL,	IC4MOL,	NC5MOL,	IC5MOL,	C6MOL, CO2MOL, H2S, N2,
		SinCromatografia, PoderCalorifico, PoderCalorifico_Gas
	)
	SELECT
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Fecha,
		--SUM( ROUND( (PDP.ProduccionRealGasM3 * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3) ),
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
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	LEFT JOIN	
		dbo.CO_Cromatografia	CR
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	LEFT JOIN
		CO_CromatografiaValores	CROMA
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	LEFT JOIN
		dbo.PR_ProdDiaria	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		--C.IdContrato	=	@Contrato
		--AND
		YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
		AND	ISNULL(PDP.ProduccionRealGasM3,0) > 0
		AND I.Activo = 1
	GROUP BY
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Fecha,
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


	INSERT INTO #VolumenXPtoEntrega
	(
		IdContrato,
		PuntoEntregaID,
		Fecha,
		VolumenPetroleo,
		VolumenGas,
		VolumenCondensado,
		RegionFiscal,
		TipoFluido,
		VolumenAgua,
		VolumenAgua_SR
	)
	SELECT
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Fecha,
		SUM(ROUND(ISNULL(PDP.ProduccionReal,0),3)),
		--SUM(ROUND((ISNULL(PDP.ProduccionRealGasM3,0) * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3)),
		SUM(CASE WHEN ROUND(ISNULL(PD.TemperaturaGas,20),2) <> 15.56 THEN ROUND((ISNULL(PDP.ProduccionRealGasM3,0) * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3)
			ELSE ISNULL(PDP.ProduccionRealGasM3,0)* @FactorConverM3_MMPC END),
		SUM(ROUND(ISNULL(PDP.ProduccionRealCondensado,0),3)),
		ISNULL(P.RegionFiscal,''),
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END,
		SUM(ROUND(ISNULL(PDP.PctAguaAlocada,0),3)),
		SUM(ISNULL(PDP.PctAguaAlocada,0))
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
		AND	p.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo	PDP
		ON P.Id	=	PDP.Pozo
		AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	--	C.IdContrato	=	@Contrato
	GROUP BY
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Fecha,
		ISNULL(P.RegionFiscal,''),
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END

	INSERT INTO #Petroleo15_16
	(
		IdContrato,
		PuntoEntregaID,
		IdPozo,
		Fecha,
		ProdPetroleoBruto,
		ProdPetroleoBruto_SR,
		ProdAceiteNeto,
		ProdAceiteNeto_SR,
		Temperatura
	)
	SELECT
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Id,
		PDP.Fecha,
		ISNULL(PDP.ProduccionReal,0),
		ISNULL(PDP.ProduccionReal,0),
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
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo	PDP
		ON P.Id	=	PDP.Pozo
		AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	GROUP BY
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Id,
		PDP.Fecha,
		ISNULL(PDP.ProduccionReal,0),
		CASE WHEN ROUND(ISNULL(PD.TemperaturaPetroleo,20),2) = 15.56 THEN 15.56
			ELSE 20
		END

--END
--ELSE
--BEGIN
	-- SE VALIDA SI EXISTE GAS EN ALGUNO DE LOS POZOS PARA REALIZAR EL CALCULO DE % MOLAR
	INSERT INTO #ConversionGas
	(	IdContrato,
		PuntoEntregaID, Fecha,
		MMPC_Gas,
		C1MOL,	C2MOL,	C3MOL,	NC4MOL,	IC4MOL,	NC5MOL,	IC5MOL,	C6MOL, CO2MOL, H2S, N2,
		SinCromatografia, PoderCalorifico, PoderCalorifico_Gas
	)
	SELECT
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Fecha,
		SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.GastoGas,0) * (@60F_R/@68F_R),3)
			ELSE ISNULL(PDP.GastoGas,0) END),
		--SUM(ROUND(PDP.GastoGas * (@60F_R/@68F_R),3)),	-- * @FactorConverM3_MMPC) * (@60F_R/@68F_R),
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
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	LEFT JOIN	
		dbo.CO_Cromatografia	CR
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	LEFT JOIN
		CO_CromatografiaValores	CROMA
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
		AND	ISNULL(PDP.GastoGas,0) > 0
		AND I.Activo = 1
	GROUP BY
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Fecha,
		ISNULL(CROMA.C1,0),
		ISNULL(CROMA.C2,0),
		ISNULL(CROMA.C3,0),
		ISNULL(CROMA.nC4,0),
		ISNULL(CROMA.lC4,0),
		ISNULL(CROMA.nC5,0),
		ISNULL(CROMA.lC5,0),
		ISNULL(CROMA.C6_plus,0)  + ISNULL(CROMA.C7,0) + ISNULL(CROMA.C8,0) + ISNULL(CROMA.C9,0) + ISNULL(CROMA.C10,0),
		ISNULL(CROMA.MOL_CO2,0),
		ISNULL(CROMA.MOL_N2,0),
		ISNULL(CROMA.MOL_h2S,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END,
		ISNULL(CROMA.PoderCalorifico,0),
		ISNULL(CROMA.PoderCalorificoGas,0)

	INSERT INTO #VolumenXPtoEntrega
	(
		IdContrato,
		PuntoEntregaID,
		Fecha,
		VolumenPetroleo,
		VolumenGas,
		VolumenCondensado,
		RegionFiscal,
		TipoFluido,
		VolumenAgua,
		VolumenAgua_SR,
		VolumenCondensado_15_56
	)
	SELECT
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Fecha,
		SUM(ROUND(ISNULL(PDP.ProdPetroleoBruto,0),3)),
		SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.GastoGas,0) * (@60F_R/@68F_R),3)
			ELSE ISNULL(PDP.GastoGas,0) END),
		--SUM(ROUND(ISNULL(PDP.GastoGas * (@60F_R/@68F_R),0),3)),
		SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProdCondensadoNeto,0),3)
			ELSE 0 END),
		--SUM(ROUND(ISNULL(PDP.ProdCondensadoNeto,0),3)),
		ISNULL(P.RegionFiscal,''),
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END,
		SUM(ROUND(ISNULL(PDP.Agua,0),3)),
		SUM(ISNULL(PDP.Agua,0)),
		SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN 0
			ELSE ROUND(ISNULL(PDP.ProdCondensadoNeto,0),3) END)
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
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo_Previo	PDP
		ON P.Id	=	PDP.Pozo
		AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	--	C.IdContrato	=	@Contrato
	GROUP BY
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Fecha,
		ISNULL(P.RegionFiscal,''),
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END

	INSERT INTO #Petroleo15_16
	(
		IdContrato,
		PuntoEntregaID,
		IdPozo,
		Fecha,
		ProdPetroleoBruto,
		ProdPetroleoBruto_SR,
		ProdAceiteNeto,
		ProdAceiteNeto_SR,
		Temperatura
	)
	SELECT
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Id,
		PDP.Fecha,
		ISNULL(PDP.ProdPetroleoBruto,0),
		ISNULL(PDP.ProdPetroleoBruto,0),
		ISNULL(PDP.ProdAceiteNeto,0),
		ISNULL(PDP.ProdAceiteNeto,0),
		CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 15.56
			ELSE 20
		END
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
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo_Previo	PDP
		ON P.Id	=	PDP.Pozo
		AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	GROUP BY
		C.IdContrato,
		PEC.PuntoEntregaID,
		PDP.Id,
		PDP.Fecha,
		ISNULL(PDP.ProdPetroleoBruto,0),
		ISNULL(PDP.ProdAceiteNeto,0),
		CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) = 15.56 THEN 15.56
			ELSE 20
		END

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
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	CG.IdContrato	=	PEC.idContrato
	AND CG.PuntoEntregaID	=	PEC.PuntoEntregaID
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

UPDATE CG
SET	PesoMolecularGas = 	(CG.C1MOL * PM.C1/100) + (CG.C2MOL * PM.C2/100) + (CG.C3MOL * PM.C3/100) +
    (CG.NC4MOL * PM.nC4/100) + (CG.IC4MOL * PM.IC4/100) + (CG.NC5MOL * PM.nC5/100) + (CG.IC5MOL * PM.IC5/100) +
    (CG.C6MOL * PM.C6/100) + (CG.CO2MOL * PM.CO2/100) + (CG.H2S * PM.H2S / 100) + (CG.N2 * PM.N2 / 100)
FROM
    CO_PesoMolecularGPA2145	PM
CROSS JOIN
	#ConversionGas	CG

INSERT INTO #ConversionGasInstalacion
(
	IdContrato,
	PuntoEntregaID,
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
    PesoMolecularGas
)
SELECT
	IdContrato,
	PuntoEntregaID,
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
    SUM(ROUND(C1MMBTU,3)),
    SUM(ROUND(C2MMBTU,3)),
    SUM(ROUND(C3MMBTU,3)),
    SUM(ROUND(NC4MMBTU,3)),
    SUM(ROUND(IC4MMBTU,3)),
    SUM(ROUND(NC5MMBTU,3)),
    SUM(ROUND(IC5MMBTU,3)),
    SUM(ROUND(C6MMBTU,3)),
    SUM(ROUND(PCC1,3)),
    SUM(ROUND(PCC2,3)),
    SUM(ROUND(PCC3,3)),
    SUM(ROUND(PCNC4,3)),
    SUM(ROUND(PCIC4,3)),
    SUM(ROUND(PCNC5,3)),
    SUM(ROUND(PCIC5,3)),
    SUM(ROUND(PCC6,3)),
    SUM(ROUND(PesoMolecularGas,3))
FROM
	#ConversionGas
GROUP BY
	IdContrato,
	PuntoEntregaID

-- CALCULAR LOS PORCENTAJES MOLARES POR AREA CONTRACTUAL
INSERT INTO #ValoresInstalacion
(
	IdContrato,
	PuntoEntregaID,
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
    PesoMolecularGas
)
SELECT
	CG.IdContrato,
	CG.PuntoEntregaID,
	SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE CG.MMPC_Gas * (CG.MMPC_Gas/CGAC.MMPC_Gas) END),
	SUM(CASE WHEN CGAC.C1MMBTU = 0 THEN 0 ELSE (CG.C1MMBTU * CG.C1MOL )/ CGAC.C1MMBTU END),
	SUM(CASE WHEN CGAC.C2MMBTU = 0 THEN 0 ELSE (CG.C2MMBTU * CG.C2MOL )/ CGAC.C2MMBTU END),
	SUM(CASE WHEN CGAC.C3MMBTU = 0 THEN 0 ELSE (CG.C3MMBTU * CG.C3MOL )/ CGAC.C3MMBTU END),
	SUM(CASE WHEN CGAC.NC4MMBTU = 0 THEN 0 ELSE (CG.NC4MMBTU * CG.NC4MOL )/ CGAC.NC4MMBTU END),
	SUM(CASE WHEN CGAC.IC4MMBTU = 0 THEN 0 ELSE (CG.IC4MMBTU * CG.IC4MOL )/ CGAC.IC4MMBTU END),
	SUM(CASE WHEN CGAC.NC5MMBTU = 0 THEN 0 ELSE (CG.NC5MMBTU * CG.NC5MOL )/ CGAC.NC5MMBTU END),
	SUM(CASE WHEN CGAC.IC5MMBTU = 0 THEN 0 ELSE (CG.IC5MMBTU * CG.IC5MOL )/ CGAC.IC5MMBTU END),
	SUM(CASE WHEN CGAC.C6MMBTU = 0 THEN 0 ELSE (CG.C6MMBTU * CG.C6MOL )/ CGAC.C6MMBTU END),
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
	SUM( CASE WHEN CGAC.C2MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C2MMBTU/CG.PoderCalorifico_Gas)/CGAC.C2MMBTU END),
	SUM( CASE WHEN CGAC.C3MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C3MMBTU/CG.PoderCalorifico_Gas)/CGAC.C3MMBTU END),
	SUM( CASE WHEN CGAC.NC4MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.NC4MMBTU/CG.PoderCalorifico_Gas)/CGAC.NC4MMBTU END),
	SUM( CASE WHEN CGAC.IC4MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.IC4MMBTU/CG.PoderCalorifico_Gas)/CGAC.IC4MMBTU END),
	SUM( CASE WHEN CGAC.NC5MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.NC5MMBTU/CG.PoderCalorifico_Gas)/CGAC.NC5MMBTU END),
	SUM( CASE WHEN CGAC.IC5MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.IC5MMBTU/CG.PoderCalorifico_Gas)/CGAC.IC5MMBTU END),
	SUM( CASE WHEN CGAC.C6MMBTU = 0 THEN 0
		WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C6MMBTU/CG.PoderCalorifico_Gas)/CGAC.C6MMBTU END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCC1)/ CGAC.MMPC_Gas END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCC2)/ CGAC.MMPC_Gas END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCC3)/ CGAC.MMPC_Gas END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCNC4)/ CGAC.MMPC_Gas END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCIC4)/ CGAC.MMPC_Gas END),
	--SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCNC5)/ CGAC.MMPC_Gas END),
 --   SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCIC5)/ CGAC.MMPC_Gas END),
 --   SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PCC6)/ CGAC.MMPC_Gas END),
	SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.PesoMolecularGas)/ CGAC.MMPC_Gas END)
FROM
	#ConversionGas	CG
JOIN
	#ConversionGasInstalacion	CGAC
	ON	CG.IdContrato	=	CGAC.IdContrato
	AND	CG.PuntoEntregaID	=	CGAC.PuntoEntregaID
GROUP BY
	CG.IdContrato,
	CG.PuntoEntregaID


--IF @BitConciliada = 1
--BEGIN
	INSERT INTO #PromPonderado
	(
		IdContrato,
		PuntoEntregaID,
		Fecha,
		Presion,
		Temperatura,
		DensidadAPI,
		Salinidad,
		PorcentajeAguaSedimentos,
		Azufre,
		SinCalidad
	)
	SELECT
		PEC.IdContrato,
		PEC.PuntoEntregaID,
		PDPP.Fecha,
		ISNULL(PED.Presion,0),
		ISNULL(PED.Temperatura,PD.TemperaturaPetroleo),
		ISNULL(CROMA.GradosAPI,0),
		ISNULL(CROMA.SalLBS_1000BLS,0),
		ISNULL(CROMA.AguaSedimento,0),
		ISNULL(CROMA.Azufre,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END
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
		PR_ProdDiariaPozo	PDPP
		ON P.Id		=	PDPP.Pozo
		AND YEAR(PDPP.Fecha)	=	YEAR(@MesReporte)
		AND MONTH(PDPP.Fecha)	=	MONTH(@MesReporte)
	LEFT JOIN
		dbo.CO_Cromatografia	CRO
		ON	PEC.IdContrato	=	CRO.IdContrato
		AND CRO.Anio		=	YEAR(@MesReporte)
		AND CRO.Mes			=	MONTH(@MesReporte)
	LEFT JOIN
		dbo.CO_CromatografiaValores	CROMA
		ON	CRO.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	LEFT JOIN
		PR_PuntoEntregaDiario	PED
		ON	PEC.PuntoEntregaID	=	PED.PuntoEntregaID
		AND PDPP.Fecha			=	PED.Fecha
	LEFT JOIN
		dbo.PR_ProdDiaria	PD
		ON	PDPP.ProdDiaria	=	PD.Id
		AND PDPP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	--	C.IdContrato	=	@Contrato
	GROUP BY
		PEC.IdContrato,
		PEC.PuntoEntregaID,
		PDPP.Fecha,
		ISNULL(PED.Presion,0),
		ISNULL(PED.Temperatura,PD.TemperaturaPetroleo),
		ISNULL(CROMA.GradosAPI,0),
		ISNULL(CROMA.SalLBS_1000BLS,0),
		ISNULL(CROMA.AguaSedimento,0),
		ISNULL(CROMA.Azufre,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END

--END
--ELSE
--BEGIN
	INSERT INTO #PromPonderado
	(
		IdContrato,
		PuntoEntregaID,
		Fecha,
		Presion,
		Temperatura,
		DensidadAPI,
		Salinidad,
		PorcentajeAguaSedimentos,
		Azufre,
		SinCalidad
	)
	SELECT
		PEC.IdContrato,
		PEC.PuntoEntregaID,
		PDPP.Fecha,
		ISNULL(PED.Presion,0),
		ISNULL(PED.Temperatura,PD.Temperatura),
		ISNULL(CROMA.GradosAPI,0),
		ISNULL(CROMA.SalLBS_1000BLS,0),
		ISNULL(CROMA.AguaSedimento,0),
		ISNULL(CROMA.Azufre,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END
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
		ON P.Id		=	PDPP.Pozo
		AND YEAR(PDPP.Fecha)	=	YEAR(@MesReporte)
		AND MONTH(PDPP.Fecha)	=	MONTH(@MesReporte)
	LEFT JOIN
		dbo.CO_Cromatografia	CRO
		ON	PEC.IdContrato	=	CRO.IdContrato
		AND CRO.Anio		=	YEAR(@MesReporte)
		AND CRO.Mes			=	MONTH(@MesReporte)
	LEFT JOIN
		dbo.CO_CromatografiaValores	CROMA
		ON	CRO.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	LEFT JOIN
		PR_PuntoEntregaDiario	PED
		ON	PEC.PuntoEntregaID	=	PED.PuntoEntregaID
		AND PDPP.Fecha			=	PED.Fecha
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD
		ON	PDPP.ProdDiaria	=	PD.Id
		AND	PDPP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
	--	C.IdContrato	=	@Contrato
	GROUP BY
		PEC.IdContrato,
		PEC.PuntoEntregaID,
		PDPP.Fecha,
		ISNULL(PED.Presion,0),
		ISNULL(PED.Temperatura,PD.Temperatura),
		ISNULL(CROMA.GradosAPI,0),
		ISNULL(CROMA.SalLBS_1000BLS,0),
		ISNULL(CROMA.AguaSedimento,0),
		ISNULL(CROMA.Azufre,0),
		CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
		END
--END

UPDATE #PromPonderado
	SET SinCalidad = 0
WHERE
	SinCalidad IS NULL

-- SE BUSCA LA CALIDAD DEL MES ANTERIOR
UPDATE PP
	SET
		DensidadAPI	=	ISNULL(CROMA.GradosAPI,0),
		Salinidad	=ISNULL(CROMA.SalLBS_1000BLS,0),
		PorcentajeAguaSedimentos	=ISNULL(CROMA.AguaSedimento,0),
		Azufre	=	ISNULL(CROMA.Azufre,0)
FROM
	#PromPonderado	PP
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	PP.IdContrato	=	PEC.idContrato
	AND PP.PuntoEntregaID	=	PEC.PuntoEntregaID
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


INSERT INTO #TotalesXContrato
(
	IdContrato,
	Petroleo,
	Gas
)
SELECT
	IdContrato,
	SUM(ISNULL(VolumenPetroleo,0)),
	SUM(ISNULL(VolumenGas,0))
FROM 
	#VolumenXPtoEntrega
GROUP BY
	IdContrato


INSERT INTO #ValMensualInstalacion
(
	IdContrato,
	PuntoEntregaID,
    Presion,
    Temperatura,
    DensidadAPI,
    Salinidad,
    PorcentajeAguaSedimentos,
	Azufre
)
SELECT
	PP.IdContrato,
	PP.PuntoEntregaID,
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Presion * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.Presion * VPE.VolumenPetroleo)/TC.Petroleo END),
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Temperatura * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.Temperatura * VPE.VolumenPetroleo)/TC.Petroleo END),
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.DensidadAPI * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.DensidadAPI * VPE.VolumenPetroleo)/TC.Petroleo END),
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Salinidad * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.Salinidad * VPE.VolumenPetroleo)/TC.Petroleo END),
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.PorcentajeAguaSedimentos * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.PorcentajeAguaSedimentos * VPE.VolumenPetroleo)/TC.Petroleo END),
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Azufre * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.Azufre * VPE.VolumenPetroleo)/TC.Petroleo END)
FROM
	#PromPonderado	PP
JOIN
	#VolumenXPtoEntrega	VPE
	ON	PP.IdContrato		=	VPE.IdContrato
	AND	PP.PuntoEntregaID	=	VPE.PuntoEntregaID
	AND	PP.Fecha			=	VPE.Fecha
JOIN
	#TotalesXContrato	TC
	ON	PP.IdContrato	=	TC.IdContrato
GROUP BY
	PP.IdContrato,
	PP.PuntoEntregaID


-- SE GENERAN LOS VALORES PARA LA CONVERSION DE TEMPERATURA
UPDATE #PromPonderado
	SET KgM3 = (141.5 / (DensidadAPI + 131.5)) * 999.012,
		KgM3_Condensado	=	(141.5 / (0 + 131.5)) * 999.012	-- 0 --> Grados API del Condensado

UPDATE #PromPonderado
	SET Alfa	=	(341.0957 / POWER( KgM3, 2 )),
		Alfa_Condensado	=	(341.0957 / POWER( KgM3_Condensado, 2 ))

UPDATE #PromPonderado
	SET	CTL	=	EXP( -Alfa * 8 * (1 + 0.8 * Alfa * 8)),
		CTL_Condensado	=	EXP( -Alfa_Condensado * 8 * (1 + 0.8 * Alfa_Condensado * 8))


INSERT INTO #Petroleo15_56XPtoEntrega
(
	IdContrato,
	PuntoEntregaID,
	Fecha,
	ProdPetroleoBruto,
	ProdPetroleoBruto_SR,
	ProdAceiteNeto,
	ProdAceiteNeto_SR
)
SELECT
	P.IdContrato,
	P.PuntoEntregaID,
	P.Fecha,
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoBruto * PP.CTL,3)
		ELSE ROUND(P.ProdPetroleoBruto,3) END),
--	SUM(ROUND(P.ProdPetroleoBruto * PP.CTL,3)),
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN P.ProdPetroleoBruto * PP.CTL
		ELSE P.ProdPetroleoBruto END),
	--SUM(P.ProdPetroleoBruto * PP.CTL),
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdAceiteNeto * PP.CTL,3)
		ELSE ROUND(P.ProdAceiteNeto,3) END),
	--SUM(ROUND(P.ProdAceiteNeto * PP.CTL,3)),
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN P.ProdAceiteNeto * PP.CTL
		ELSE P.ProdAceiteNeto END)
	--SUM(P.ProdAceiteNeto * PP.CTL)
FROM
	#Petroleo15_16	P
JOIN
	#PromPonderado	PP
	ON	P.IdContrato		=	PP.IdContrato
	AND	P.PuntoEntregaID	=	PP.PuntoEntregaID
	AND	P.Fecha				=	PP.Fecha
GROUP BY
	P.IdContrato,
	P.PuntoEntregaID,
	P.Fecha

INSERT INTO #Petroleo15_56XPtoEntregaTotal
(
	IdContrato,
	PuntoEntregaID,
	ProdPetroleoBruto,
	ProdPetroleoBruto_SR,
	ProdAceiteNeto,
	ProdAceiteNeto_SR
)
SELECT
	IdContrato,
	PuntoEntregaID,
	SUM(ProdPetroleoBruto),
	SUM(ProdPetroleoBruto_SR),
	SUM(ProdAceiteNeto),
	SUM(ProdAceiteNeto_SR)
FROM
	#Petroleo15_56XPtoEntrega
GROUP BY
	IdContrato,
	PuntoEntregaID


UPDATE	VPE
	SET
		--VolumenPetroleo_15_56	=	VPE.VolumenPetroleo * ROUND(PP.CTL,6),
		VolumenCondensado_15_56	=	VPE.VolumenCondensado_15_56 + (VPE.VolumenCondensado * PP.CTL_Condensado)
FROM
	#PromPonderado	PP
JOIN
	#VolumenXPtoEntrega	VPE
	ON	PP.IdContrato		=	VPE.IdContrato
	AND	PP.PuntoEntregaID	=	VPE.PuntoEntregaID
	AND	PP.Fecha			=	VPE.Fecha

INSERT INTO #VolumenesTotalesHidro
(
    IdContrato,
    PuntoEntregaID,
    ProdPetroleo,
    MMPC_Gas,
    Condensado,
    ProdPetroleo_15_56,
    Condensado_15_56,
	VolumenAgua,
	VolumenAgua_SR
)
SELECT
	IdContrato,
	PuntoEntregaID,
	SUM(VolumenPetroleo),
	SUM(ROUND(VolumenGas,3)),
	SUM(VolumenCondensado),
	SUM(ROUND(VolumenPetroleo_15_56,3)),
	SUM(ROUND(VolumenCondensado_15_56,3)),
	SUM(ROUND(VolumenAgua,3)),
	SUM(VolumenAgua_SR)
FROM
	#VolumenXPtoEntrega
GROUP BY
	IdContrato,
	PuntoEntregaID

	
--IF @BitConciliada = 1
--BEGIN
SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		--P.RegionFiscal		AS [Región Fiscal],
		ISNULL(VPE.RegionFiscal,'N/A')	AS [Región Fiscal],
		PE.Nombre			AS [Ubicación del Punto de Medición],
		ISNULL(PE.TagPatinMedicion,'N/A')	AS [Tag del Patín de Medición],
		ISNULL(PE.TipoMedidor,'N/A')		AS [Tipo de Medidor],
		ISNULL(PE.TagMedidor,'N/A')			AS [Tag del Medidor],
		ISNULL(PE.Clasificacion,'N/A')		AS [Clasificación del Sistema de Medición],
		ISNULL(VPE.TipoFluido,'N/A')		AS [Tipo de Hidrocarburo],
		--PED.Fecha			AS [Fecha],
		--PDPP.Fecha				AS [Fecha],
		VPE.Fecha				AS [Fecha],
		ROUND(ISNULL(PED.Presion,0),3)			AS [Presion],
		ROUND(ISNULL(PED.Temperatura,0),3)		AS [Temperatura],
		--ROUND(VPE.VolumenPetroleo,3)	AS [Producción de Petroleo Medido Neto bbl/dia],
		--ROUND(ISNULL(VPE.VolumenPetroleo_15_56,0),3)	AS [Producción de Petroleo Medido Neto bbl/dia],
		--ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(PP.DensidadAPI,0),3)		AS [°API],
		ROUND(ISNULL(PP.Azufre,0),3)			AS [% S],
		ROUND(ISNULL(PP.Salinidad,0),3)		AS [Sal],
		--CASE WHEN ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3) = 0 THEN 0
		--	ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3),3)
		--END									AS [% H2O],
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END									AS [% H2O],
		--ROUND(VPE.VolumenCondensado,3)		AS [Producción de Condensado Medido Neto],
		ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3)		AS [Producción de Condensado Medido Neto],
		ROUND(ISNULL(PP.DensidadAPI,0),3)		AS [°API],
		ROUND(ISNULL(PP.Azufre,0),3)			AS [% S],
		--ROUND(ISNULL(PP.PorcentajeAguaSedimentos,0),3)	AS [% H2O],
		CASE WHEN ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3),3)
		END										AS [% H2O],
		ROUND(ISNULL(VPE.VolumenGas,0),3)					AS [Producción de Gas Medido],
		--ROUND(ISNULL(CG.MMPC_Gas,0),3)			AS [Producción de Gas Medido],
		CASE WHEN CG.PoderCalorifico_Gas = 0 THEN 0
			ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas) + (CG.C2MMBTU/CG.PoderCalorifico_Gas) + (CG.C3MMBTU/CG.PoderCalorifico_Gas) + (CG.NC4MMBTU/CG.PoderCalorifico_Gas) + 
				(CG.IC4MMBTU/CG.PoderCalorifico_Gas) + (CG.NC5MMBTU/CG.PoderCalorifico_Gas) + (CG.IC5MMBTU/CG.PoderCalorifico_Gas) + (CG.C6MMBTU/CG.PoderCalorifico_Gas)
		END																		AS [Poder Calorífico de Gas],
		--ROUND(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0),3)	AS [Poder Calorífico de Gas],
		--ROUND(ISNULL(VA.PCC1,0)+ISNULL(VA.PCC2,0)+ISNULL(VA.PCC3,0)+ISNULL(VA.PCNC4,0)+ISNULL(VA.PCIC4,0)+ISNULL(VA.PCNC5,0)+ISNULL(VA.PCIC5,0)+ISNULL(VA.PCC6,0),3)	AS [Poder Calorífico de Gas],
		ROUND(ISNULL(CG.PesoMolecularGas,0),3)	AS [Peso Molecular de Gas],
		--ROUND(ISNULL(VA.PesoMolecularGas,0),3)	AS [Peso Molecular de Gas],
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0),3)	AS [Energia de Gas],
		--ROUND(ISNULL(VA.C1MMBTU,0)+ISNULL(VA.C2MMBTU,0)+ISNULL(VA.C3MMBTU,0)+ISNULL(VA.NC4MMBTU,0)+ISNULL(VA.IC4MMBTU,0)+ISNULL(VA.NC5MMBTU,0)+ISNULL(VA.IC5MMBTU,0)+ISNULL(VA.C6MMBTU,0),3)	AS [Energia de Gas],
		ISNULL(PED.Eventos,'N/A')			AS [Eventos]
	FROM
		#ContratosConciliada	CC
	JOIN
		dbo.CO_Contrato	C
		ON	CC.IdContrato	=	C.IdContrato
	JOIN
		#VolumenXPtoEntrega	VPE
		ON	C.IdContrato	=	VPE.IdContrato
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	VPE.IdContrato	=	PEC.idContrato
		AND VPE.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND VPE.PuntoEntregaID	=	PE.PuntoEntregaID
	LEFT JOIN
		dbo.PR_PuntoEntregaDiario	PED
		ON	VPE.PuntoEntregaID	=	PED.PuntoEntregaID
		AND	VPE.Fecha			=	PED.Fecha
	LEFT JOIN
		#ConversionGas	CG
		ON	VPE.IdContrato	=	CG.IdContrato
		AND	PE.PuntoEntregaID	=	CG.PuntoEntregaID
		AND VPE.Fecha			=	CG.Fecha
	LEFT JOIN
		#PromPonderado	PP
		ON VPE.IdContrato	=	PP.IdContrato
		AND	PE.PuntoEntregaID	=	PP.PuntoEntregaID
		AND VPE.Fecha		=	PP.Fecha
	LEFT JOIN
		#Petroleo15_56XPtoEntrega	P15_56
		ON	VPE.IdContrato	=	P15_56.IdContrato
		AND	PE.PuntoEntregaID	=	P15_56.PuntoEntregaID
		AND	VPE.Fecha		=	P15_56.Fecha
	GROUP BY
		C.NumeroContrato,
		ISNULL(VPE.RegionFiscal,'N/A'),
		--P.RegionFiscal,
		PE.Nombre,
		ISNULL(PE.TagPatinMedicion,'N/A'),
		ISNULL(PE.TipoMedidor,'N/A'),
		ISNULL(PE.TagMedidor,'N/A'),
		ISNULL(PE.Clasificacion,'N/A'),
		ISNULL(VPE.TipoFluido,'N/A'),
		--PED.Fecha,
		--PDPP.Fecha,
		VPE.Fecha,
		ROUND(ISNULL(PED.Presion,0),3),
		ROUND(ISNULL(PED.Temperatura,0),3),
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),
		ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3),
		ROUND(ISNULL(VPE.VolumenGas,0),3),
		ROUND(ISNULL(PP.DensidadAPI,0),3),
		ROUND(ISNULL(PP.Azufre,0),3),
		ROUND(ISNULL(PP.Salinidad,0),3),
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END,
		CASE WHEN ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3),3)
		END,
		--ROUND(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0),3),
		CASE WHEN CG.PoderCalorifico_Gas = 0 THEN 0
			ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas) + (CG.C2MMBTU/CG.PoderCalorifico_Gas) + (CG.C3MMBTU/CG.PoderCalorifico_Gas) + (CG.NC4MMBTU/CG.PoderCalorifico_Gas) + 
				(CG.IC4MMBTU/CG.PoderCalorifico_Gas) + (CG.NC5MMBTU/CG.PoderCalorifico_Gas) + (CG.IC5MMBTU/CG.PoderCalorifico_Gas) + (CG.C6MMBTU/CG.PoderCalorifico_Gas)
		END,
		--ROUND(ISNULL(VA.PCC1,0)+ISNULL(VA.PCC2,0)+ISNULL(VA.PCC3,0)+ISNULL(VA.PCNC4,0)+ISNULL(VA.PCIC4,0)+ISNULL(VA.PCNC5,0)+ISNULL(VA.PCIC5,0)+ISNULL(VA.PCC6,0),3),
		ROUND(ISNULL(CG.PesoMolecularGas,0),3),
		--ROUND(ISNULL(VA.PesoMolecularGas,0),3),
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0),3),
		--ROUND(ISNULL(VA.C1MMBTU,0)+ISNULL(VA.C2MMBTU,0)+ISNULL(VA.C3MMBTU,0)+ISNULL(VA.NC4MMBTU,0)+ISNULL(VA.IC4MMBTU,0)+ISNULL(VA.NC5MMBTU,0)+ISNULL(VA.IC5MMBTU,0)+ISNULL(VA.C6MMBTU,0),3),
		ISNULL(PED.Eventos,'N/A')


UNION
-- DIARIA

	SELECT
		C.NumeroContrato				AS [ID Contrato o Asignación],
		--P.RegionFiscal					AS [Región Fiscal],
		ISNULL(VPE.RegionFiscal,'N/A')		AS [Región Fiscal],
		PE.Nombre						AS [Ubicación del Punto de Medición],
		ISNULL(PE.TagPatinMedicion,'N/A')	AS [Tag del Patín de Medición],
		ISNULL(PE.TipoMedidor,'N/A')		AS [Tipo de Medidor],
		ISNULL(PE.TagMedidor,'N/A')			AS [Tag del Medidor],
		ISNULL(PE.Clasificacion,'N/A')			AS [Clasificación del Sistema de Medición],
		ISNULL(VPE.TipoFluido,'N/A')			AS [Tipo de Hidrocarburo],
		VPE.Fecha,
		ROUND(ISNULL(PED.Presion,0),3)			AS [Presion],
		ROUND(ISNULL(PED.Temperatura,0),3)		AS [Temperatura],
		--ROUND(ISNULL(VPE.VolumenPetroleo,0),3)			AS [Producción de Petroleo Medido Neto bbl/dia],
		--ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3)			AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3)			AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(PP.DensidadAPI,0),3)		AS [°API],
		ROUND(ISNULL(PP.Azufre,0),3)			AS [% S],
		ROUND(ISNULL(PP.Salinidad,0),3)			AS [Sal],
		--ROUND(ISNULL(PP.PorcentajeAguaSedimentos,0),3)	AS [% H2O],
		--CASE WHEN ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3) = 0 THEN 0
		--	ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3),3)
		--END										AS [% H2O],
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END										AS [% H2O],
		--ROUND(VPE.VolumenCondensado,3)			AS [Producción de Condensado Medido Neto],
		ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3)			AS [Producción de Condensado Medido Neto],
		ROUND(ISNULL(PP.DensidadAPI,0),3)		AS [°API],
		ROUND(ISNULL(PP.Azufre,0),3)			AS [% S],
		CASE WHEN ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3),3)
		END	AS [% H2O],
		--ROUND(SUM(PDPP.GastoGas),3)						AS [Producción de Gas Medido],
		ROUND(ISNULL(VPE.VolumenGas,0),3)					AS [Producción de Gas Medido],
		--ROUND(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0),3)	AS [Poder Calorífico de Gas],
		CASE WHEN CG.PoderCalorifico_Gas = 0 THEN 0
			ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas) + (CG.C2MMBTU/CG.PoderCalorifico_Gas) + (CG.C3MMBTU/CG.PoderCalorifico_Gas) + (CG.NC4MMBTU/CG.PoderCalorifico_Gas) + 
				(CG.IC4MMBTU/CG.PoderCalorifico_Gas) + (CG.NC5MMBTU/CG.PoderCalorifico_Gas) + (CG.IC5MMBTU/CG.PoderCalorifico_Gas) + (CG.C6MMBTU/CG.PoderCalorifico_Gas)
		END									AS [Poder Calorífico de Gas],
		ROUND(ISNULL(CG.PesoMolecularGas,0),3)	AS [Peso Molecular de Gas],
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0),3)	AS [Energia de Gas],
		ISNULL(PED.Eventos,'N/A')			AS [Eventos]
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		#VolumenXPtoEntrega	VPE
		ON	C.IdContrato	=	VPE.IdContrato
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	VPE.IdContrato	=	PEC.idContrato
		AND	VPE.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND VPE.PuntoEntregaID	=	PE.PuntoEntregaID
	LEFT JOIN
		dbo.PR_PuntoEntregaDiario	PED
		ON	VPE.PuntoEntregaID	=	PED.PuntoEntregaID
		AND VPE.Fecha		=	PED.Fecha
	LEFT JOIN
		#ConversionGas	CG
		ON	PEC.IdContrato		=	CG.IdContrato
		AND	PED.PuntoEntregaID	=	CG.PuntoEntregaID
		AND	VPE.Fecha			=	CG.Fecha
	LEFT JOIN
		#PromPonderado	PP
		ON PEC.IdContrato		=	PP.IdContrato
		AND	PED.PuntoEntregaID	=	PP.PuntoEntregaID
		AND	VPE.Fecha		=	PP.Fecha
	LEFT JOIN
		#Petroleo15_56XPtoEntrega	P15_56
		ON	PEC.IdContrato	=	P15_56.IdContrato
		AND	PED.PuntoEntregaID	=	P15_56.PuntoEntregaID
		AND	VPE.Fecha		=	P15_56.Fecha
	WHERE
		YEAR(@MesReporte) = YEAR(PED.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PED.Fecha)
	GROUP BY
		C.NumeroContrato,
		--P.RegionFiscal,
		ISNULL(VPE.RegionFiscal,'N/A'),
		PE.Nombre,
		ISNULL(PE.TagPatinMedicion,'N/A'),
		ISNULL(PE.TipoMedidor,'N/A'),
		ISNULL(PE.TagMedidor,'N/A'),
		ISNULL(PE.Clasificacion,'N/A'),
		ISNULL(VPE.TipoFluido,'N/A'),
		VPE.Fecha,
		ROUND(ISNULL(PED.Presion,0),3),
		ROUND(ISNULL(PED.Temperatura,0),3),
		ROUND(ISNULL(PP.DensidadAPI,0),3),
		ROUND(ISNULL(PP.Azufre,0),3),
		ROUND(ISNULL(PP.Salinidad,0),3),
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),
		ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3),
		ROUND(ISNULL(VPE.VolumenGas,0),3),
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END,
		CASE WHEN ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3),3)
		END,
		--ROUND(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0),3),
		CASE WHEN CG.PoderCalorifico_Gas = 0 THEN 0
			ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas) + (CG.C2MMBTU/CG.PoderCalorifico_Gas) + (CG.C3MMBTU/CG.PoderCalorifico_Gas) + (CG.NC4MMBTU/CG.PoderCalorifico_Gas) + 
				(CG.IC4MMBTU/CG.PoderCalorifico_Gas) + (CG.NC5MMBTU/CG.PoderCalorifico_Gas) + (CG.IC5MMBTU/CG.PoderCalorifico_Gas) + (CG.C6MMBTU/CG.PoderCalorifico_Gas)
		END,
		ROUND(ISNULL(CG.PesoMolecularGas,0),3),
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0),3),
		ISNULL(PED.Eventos,'N/A')
	ORDER BY
		C.NumeroContrato,
		ISNULL(VPE.RegionFiscal,'N/A'),
		PE.Nombre


/* ********************************** REPORTE 2 HOJA 2 *********************************/

	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		P.RegionFiscal		AS [Región Fiscal],
		PE.Nombre			AS [Ubicación del Punto de Medición],
		--I.NombreInstalacion	AS [Ubicación del Punto de Medición],
		ISNULL(PE.TagPatinMedicion,'N/A')	AS [Tag del Patín de Medición],
		ISNULL(PE.TipoMedidor,'N/A')		AS [Tipo de Medidor],
		ISNULL(PE.TagMedidor,'N/A')		AS [Tag del Medidor],
		ISNULL(PE.Clasificacion,'N/A')	AS [Clasificación del Sistema de Medición],
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END 		AS [Tipo de Hidrocarburo],
		@MesReporte				AS [Fecha],
		ROUND(ISNULL(VMI.Presion,0),3)			AS [Presion],
		ROUND(ISNULL(VMI.Temperatura,0),3)		AS [Temperatura],
		--ROUND(ISNULL(VTH.ProdPetroleo,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		--ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(VMI.DensidadAPI,0),3)		AS [API],
		ROUND(ISNULL(VMI.Azufre,0),3)			AS [% S],
		ROUND(ISNULL(VMI.Salinidad,0),3)		AS [Sal],
		--CASE WHEN ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3) = 0 THEN 0
		--	ELSE ROUND(ROUND((ISNULL(VTH.VolumenAgua,0) * 100),3) / ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3),3)
		--END										AS [% H2O],
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND(ROUND((ISNULL(VTH.VolumenAgua,0) * 100),3) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END										AS [% H2O],
		--ROUND(SUM(ISNULL(PDPP.ProduccionRealCondensado,0)),3)	AS [Producción de Condensado Medido Neto],
		--ROUND(ISNULL(VTH.Condensado,0),3)		AS [Producción de Condensado Medido Neto],
		ROUND(ISNULL(VTH.Condensado_15_56,0),3)		AS [Producción de Condensado Medido Neto],
		ROUND(ISNULL(VMI.DensidadAPI,0),3)		AS [°API],
		ROUND(ISNULL(VMI.Azufre,0),3)			AS [% S],
		CASE WHEN ROUND(ISNULL(VTH.Condensado_15_56,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VTH.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VTH.Condensado_15_56,0),3),3)
		END										AS [% H2O],
		--SUM(ROUND((PDPP.ProduccionRealGasM3 * @FactorConverM3_MMPC) * (@60F_R/@68F_R),3))	AS [Producción de Gas Medido],
		ROUND(ISNULL(VTH.MMPC_Gas,0),3)			AS [Producción de Gas Medido],
		ROUND(ISNULL(VI.C1MOL,0),3)			AS [C1],
		ROUND(ISNULL(VI.C2MOL,0),3)			AS [C2],
		ROUND(ISNULL(VI.C3MOL,0),3)			AS [C3],
		ROUND(ISNULL(VI.NC4MOL,0),3)			AS [C4],
		ROUND(ISNULL(VI.IC4MOL,0),3)				AS [IC4],
		ROUND(ISNULL(VI.NC5MOL,0),3)			AS [C5],
		ROUND(ISNULL(VI.IC5MOL,0),3)				AS [IC5],
		ROUND(ISNULL(VI.C6MOL,0),3)				AS [C6+],
		ROUND(ISNULL(VI.CO2MOL,0),3)				AS [CO2],
		ROUND(ISNULL(VI.H2S,0),3)					AS [H2S],
		ROUND(ISNULL(VI.N2,0),3)					AS [N2],
		--ROUND(SUM(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)),3)	AS [Poder calorifico de GAs],
		--ROUND((ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)),3)	AS [Poder calorifico de GAs],
		ROUND((ISNULL(VI.PCC1,0)+ISNULL(VI.PCC2,0)+ISNULL(VI.PCC3,0)+ISNULL(VI.PCNC4,0)+ISNULL(VI.PCIC4,0)+ISNULL(VI.PCNC5,0)+ISNULL(VI.PCIC5,0)+ISNULL(VI.PCC6,0)),3)	AS [Poder Calorifico de Gas],
		--ROUND(SUM(ISNULL(CG.PesoMolecularGas,0)),3)		AS [Peso Molecular de Gas],
		ROUND((ISNULL(CG.PesoMolecularGas,0)),3)		AS [Peso Molecular de Gas],
		--ROUND(SUM(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)),3)	AS [Energia de Gas],
		ROUND((ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)),3)	AS [Energia de Gas],
		ISNULL(FPE.Eventos,'N/A')
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
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		#VolumenesTotalesHidro	VTH
		ON	PEC.idContrato	=	VTH.IdContrato
		AND	PE.PuntoEntregaID	=	VTH.PuntoEntregaID
	LEFT JOIN
		PR_FactorPuntoEntrega	FPE
		ON	PE.PuntoEntregaID	=	FPE.PuntoEntregaID
		AND FPE.Mes		=	@MesReporte
	LEFT JOIN
		#ConversionGasInstalacion	CG
		ON	PEC.idContrato	=	CG.IdContrato
		AND	PE.PuntoEntregaID	=	CG.PuntoEntregaID
	LEFT JOIN
		#ValoresInstalacion	VI
		ON	PEC.IdContrato	=	VI.IdContrato
		AND	PE.PuntoEntregaID	=	VI.PuntoEntregaID
	LEFT JOIN
		#ValMensualInstalacion	VMI
		ON	PEC.IdContrato	=	VMI.IdContrato
		AND	PE.PuntoEntregaID	=	VMI.PuntoEntregaID
	LEFT JOIN
		#Petroleo15_56XPtoEntregaTotal	P15_56
		ON	PEC.IdContrato	=	P15_56.IdContrato
		AND	PE.PuntoEntregaID	=	P15_56.PuntoEntregaID
	WHERE
		I.Activo = 1
	GROUP BY
		C.NumeroContrato,
		P.RegionFiscal,
		PE.Nombre,
		--I.NombreInstalacion,
		PE.TagPatinMedicion,
		PE.TipoMedidor,
		PE.TagMedidor,
		PE.Clasificacion,
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END,
		ROUND(ISNULL(VMI.Presion,0),3),
		ROUND(ISNULL(VMI.Temperatura,0),3),
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),
		ROUND(ISNULL(VMI.DensidadAPI,0),3),
		ROUND(ISNULL(VMI.Azufre,0),3),
		ROUND(ISNULL(VMI.Salinidad,0),3),
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND(ROUND((ISNULL(VTH.VolumenAgua,0) * 100),3) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END,
		CASE WHEN ROUND(ISNULL(VTH.Condensado_15_56,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VTH.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VTH.Condensado_15_56,0),3),3)
		END,
		ROUND(ISNULL(VTH.Condensado_15_56,0),3),
		ROUND(ISNULL(VTH.MMPC_Gas,0),3),
		ROUND(ISNULL(VI.C1MOL,0),3),
		ROUND(ISNULL(VI.C2MOL,0),3),
		ROUND(ISNULL(VI.C3MOL,0),3),
		ROUND(ISNULL(VI.NC4MOL,0),3),
		ROUND(ISNULL(VI.IC4MOL,0),3),
		ROUND(ISNULL(VI.NC5MOL,0),3),
		ROUND(ISNULL(VI.IC5MOL,0),3),
		ROUND(ISNULL(VI.C6MOL,0),3),
		ROUND(ISNULL(VI.CO2MOL,0),3),
		ROUND(ISNULL(VI.H2S,0),3),
		ROUND(ISNULL(VI.N2,0),3),
		--ROUND((ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)),3),
		ROUND((ISNULL(VI.PCC1,0)+ISNULL(VI.PCC2,0)+ISNULL(VI.PCC3,0)+ISNULL(VI.PCNC4,0)+ISNULL(VI.PCIC4,0)+ISNULL(VI.PCNC5,0)+ISNULL(VI.PCIC5,0)+ISNULL(VI.PCC6,0)),3),
		ROUND((ISNULL(CG.PesoMolecularGas,0)),3),
		ROUND((ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)),3),
		ISNULL(FPE.Eventos,'N/A')
--END
--ELSE
--BEGIN
UNION
	/* ********************************** REPORTE 2 HOJA 2 *********************************/

	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		P.RegionFiscal		AS [Región Fiscal],
		PE.Nombre			AS [Ubicación del Punto de Medición],
		--I.NombreInstalacion	AS [Ubicación del Punto de Medición],
		ISNULL(PE.TagPatinMedicion,'N/A')	AS [Tag del Patín de Medición],
		ISNULL(PE.TipoMedidor,'N/A')		AS [Tipo de Medidor],
		ISNULL(PE.TagMedidor,'N/A')		AS [Tag del Medidor],
		ISNULL(PE.Clasificacion,'N/A')	AS [Clasificación del Sistema de Medición],
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END 		AS [Tipo de Hidrocarburo],
		@MesReporte				AS [Fecha],
		ROUND(ISNULL(VMI.Presion,0),3)			AS [Presion],
		ROUND(ISNULL(VMI.Temperatura,0),3)		AS [Temperatura],
		--ROUND(ISNULL(VTH.ProdPetroleo,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		--ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(VMI.DensidadAPI,0),3)		AS [API],
		ROUND(ISNULL(VMI.Azufre,0),3)			AS [% S],
		ROUND(ISNULL(VMI.Salinidad,0),3)		AS [Sal],
		--CASE WHEN ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3) = 0 THEN 0
		--	ELSE ROUND(ROUND((ISNULL(VTH.VolumenAgua,0) * 100),3) / ROUND(ISNULL(P15_56.ProdPetroleoBruto,0),3),3)
		--END										AS [% H2O],
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND(ROUND((ISNULL(VTH.VolumenAgua,0) * 100),3) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END										AS [% H2O],
		--ROUND(ISNULL(VTH.Condensado,0),3)		AS [Producción de Condensado Medido Neto],
		ROUND(ISNULL(VTH.Condensado_15_56,0),3)		AS [Producción de Condensado Medido Neto],
		ROUND(ISNULL(VMI.DensidadAPI,0),3)		AS [°API],
		ROUND(ISNULL(VMI.Azufre,0),3)			AS [% S],
		CASE WHEN ROUND(ISNULL(VTH.Condensado_15_56,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VTH.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VTH.Condensado_15_56,0),3),4)
		END										AS [% H2O],
		ROUND(ISNULL(VTH.MMPC_Gas,0),3)			AS [Producción de Gas Medido],
		--ROUND(SUM(PDPP.GastoGas),3)	AS [Producción de Gas Medido],
		ROUND(ISNULL(VI.C1MOL,0),3)			AS [C1],
		ROUND(ISNULL(VI.C2MOL,0),3)			AS [C2],
		ROUND(ISNULL(VI.C3MOL,0),3)			AS [C3],
		ROUND(ISNULL(VI.NC4MOL,0),3)			AS [C4],
		ROUND(ISNULL(VI.IC4MOL,0),3)				AS [IC4],
		ROUND(ISNULL(VI.NC5MOL,0),3)			AS [C5],
		ROUND(ISNULL(VI.IC5MOL,0),3)				AS [IC5],
		ROUND(ISNULL(VI.C6MOL,0),3)				AS [C6+],
		ROUND(ISNULL(VI.CO2MOL,0),3)				AS [CO2],
		ROUND(ISNULL(VI.H2S,0),3)					AS [H2S],
		ROUND(ISNULL(VI.N2,0),3)					AS [N2],
--		ROUND(SUM(ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)),3)	AS [Poder calorifico de GAs],
		--ROUND((ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)),3)	AS [Poder calorifico de GAs],
		ROUND((ISNULL(VI.PCC1,0)+ISNULL(VI.PCC2,0)+ISNULL(VI.PCC3,0)+ISNULL(VI.PCNC4,0)+ISNULL(VI.PCIC4,0)+ISNULL(VI.PCNC5,0)+ISNULL(VI.PCIC5,0)+ISNULL(VI.PCC6,0)),3)	AS [Poder calorifico de GAs],
--		ROUND(SUM(ISNULL(CG.PesoMolecularGas,0)),3)		AS [Peso Molecular de Gas],
		ROUND((ISNULL(CG.PesoMolecularGas,0)),3)		AS [Peso Molecular de Gas],
--		ROUND(SUM(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)),3)	AS [Energia de Gas],
		ROUND((ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)),3)	AS [Energia de Gas],
		ISNULL(FPE.Eventos,'N/A')		AS [Eventos]
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
		AND	P.PuntoEntregaID	=PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		#VolumenesTotalesHidro	VTH
		ON	PEC.idContrato	=	VTH.IdContrato
		AND	PE.PuntoEntregaID	=	VTH.PuntoEntregaID
	LEFT JOIN
		PR_FactorPuntoEntrega	FPE
		ON	PE.PuntoEntregaID	=	FPE.PuntoEntregaID
		AND FPE.Mes		=	@MesReporte
	LEFT JOIN
		#ConversionGasInstalacion	CG
		ON	PEC.idContrato	=	CG.IdContrato
		AND	PE.PuntoEntregaID	=	CG.PuntoEntregaID
	LEFT JOIN
		#ValoresInstalacion	VI
		ON	PEC.IdContrato		=	VI.IdContrato
		AND	PE.PuntoEntregaID	=	VI.PuntoEntregaID
	LEFT JOIN
		#ValMensualInstalacion	VMI
		ON	PEC.IdContrato		=	VMI.IdContrato
		AND	PE.PuntoEntregaID	=	VMI.PuntoEntregaID
	LEFT JOIN
		#Petroleo15_56XPtoEntregaTotal	P15_56
		ON	PEC.IdContrato	=	P15_56.IdContrato
		AND	PE.PuntoEntregaID	=	P15_56.PuntoEntregaID
	WHERE
		I.Activo = 1
	GROUP BY
		C.NumeroContrato,
		P.RegionFiscal,
		PE.Nombre,
		ISNULL(PE.TagPatinMedicion,'N/A'),
		ISNULL(PE.TipoMedidor,'N/A'),
		ISNULL(PE.TagMedidor,'N/A'),
		ISNULL(PE.Clasificacion,'N/A'),
		CASE WHEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),1,1) = ','
			THEN SUBSTRING(LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas)),2,250)
			ELSE LTRIM(CONCAT(P.TipoFluidoPetroleo,' ,',P.TipoFluidoGas))
		END,
		ROUND(ISNULL(VMI.Presion,0),3),
		ROUND(ISNULL(VMI.Temperatura,0),3),
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),
		ROUND(ISNULL(VMI.DensidadAPI,0),3),
		ROUND(ISNULL(VMI.Azufre,0),3),
		ROUND(ISNULL(VMI.Salinidad,0),3),
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND(ROUND((ISNULL(VTH.VolumenAgua,0) * 100),3) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END,
		CASE WHEN ROUND(ISNULL(VTH.Condensado_15_56,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VTH.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VTH.Condensado_15_56,0),3),4)
		END,
		ROUND(ISNULL(VTH.Condensado_15_56,0),3),
		ROUND(ISNULL(VTH.MMPC_Gas,0),3),
		ROUND(ISNULL(VI.C1MOL,0),3),
		ROUND(ISNULL(VI.C2MOL,0),3),
		ROUND(ISNULL(VI.C3MOL,0),3),
		ROUND(ISNULL(VI.NC4MOL,0),3),
		ROUND(ISNULL(VI.IC4MOL,0),3),
		ROUND(ISNULL(VI.NC5MOL,0),3),
		ROUND(ISNULL(VI.IC5MOL,0),3),
		ROUND(ISNULL(VI.C6MOL,0),3),
		ROUND(ISNULL(VI.CO2MOL,0),3),
		ROUND(ISNULL(VI.H2S,0),3),
		ROUND(ISNULL(VI.N2,0),3),
		--ROUND((ISNULL(CG.PCC1,0)+ISNULL(CG.PCC2,0)+ISNULL(CG.PCC3,0)+ISNULL(CG.PCNC4,0)+ISNULL(CG.PCIC4,0)+ISNULL(CG.PCNC5,0)+ISNULL(CG.PCIC5,0)+ISNULL(CG.PCC6,0)),3),
		ROUND((ISNULL(VI.PCC1,0)+ISNULL(VI.PCC2,0)+ISNULL(VI.PCC3,0)+ISNULL(VI.PCNC4,0)+ISNULL(VI.PCIC4,0)+ISNULL(VI.PCNC5,0)+ISNULL(VI.PCIC5,0)+ISNULL(VI.PCC6,0)),3),
		ROUND((ISNULL(CG.PesoMolecularGas,0)),3),
		ROUND((ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)),3),
		ISNULL(FPE.Eventos,'N/A')
	ORDER BY
		C.NumeroContrato,
		P.RegionFiscal,
		PE.Nombre

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

		IF 0 < (SELECT COUNT(1) FROM #ContratosDiaria)
		BEGIN
			SELECT CASE WHEN @SinPoderCalorifico = ''
						THEN 'Sin produccion Conciliada en los contratos: ' + @Contratos
					ELSE 'Sin produccion Conciliada en los contratos: ' + @Contratos + '. Sin Poder Calorífico de Gas en los contratos: ' + @SinPoderCalorifico
				END
		END
--END

END
