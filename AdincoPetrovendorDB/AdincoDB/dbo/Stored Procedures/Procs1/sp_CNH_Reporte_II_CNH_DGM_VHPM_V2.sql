CREATE PROCEDURE dbo.sp_CNH_Reporte_II_CNH_DGM_VHPM_V2
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
-- 20190305	BAAC	Se modifica para calcular la energia con el API 14.5
-- 20190321	BAAC	Se modifica para agregar las nuevas columnas del reporte de CNH en la hoja 2
-- 20200722	BAAC	Se modifica para obtener poder calorifico de la croma cargada
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
	SinCromatografia	BIT,
	PoderCalorifico	FLOAT,
	PoderCalorifico_Gas	FLOAT,
	------------ BL EQUIVALENTES C5 -------------------------------
	C5EqBl		FLOAT,
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
	C1MMBTU	FLOAT,
	C2MMBTU	FLOAT,
	C3MMBTU	FLOAT,
	NC4MMBTU	FLOAT,
	IC4MMBTU	FLOAT,
	NC5MMBTU	FLOAT,
	IC5MMBTU	FLOAT,
	C6MASMMBTU		FLOAT,
	C6MMBTU		FLOAT,
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
	PoderCalorifico_Gas	FLOAT
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
	PRIMARY KEY (IdContrato, PuntoEntregaID, Fecha, TipoFluido)
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

--CREATE TABLE #ValoresAC
--(
--	IdContrato	INT,
--	MMPC_Gas	DECIMAL(24,8),
--	C1MMBTU	FLOAT,
--	C2MMBTU	FLOAT,
--	C3MMBTU	FLOAT,
--	NC4MMBTU	FLOAT,
--	IC4MMBTU	FLOAT,
--	NC5MMBTU	FLOAT,
--	IC5MMBTU	FLOAT,
--	C6MMBTU		FLOAT,
--	C5EqBl		FLOAT
--)

CREATE TABLE #ConversionGasAC
(
	IdContrato	INT,
	MMPC_Gas	DECIMAL(24,8),
	C1MMBTU	FLOAT,
	C2MMBTU	FLOAT,
	C3MMBTU	FLOAT,
	NC4MMBTU	FLOAT,
	IC4MMBTU	FLOAT,
	NC5MMBTU	FLOAT,
	IC5MMBTU	FLOAT,
	C6MASMMBTU		FLOAT,
	C6MMBTU		FLOAT,
	C7MMBTU		FLOAT,
	C8MMBTU		FLOAT,
	C9MMBTU		FLOAT,
	C10MMBTU		FLOAT,
	C5EqBl		FLOAT
)



DECLARE
	@FactorConverM3_MMPC FLOAT = 0.00003531467,
--	@60F_R         FLOAT = 519.678, -- 60 grados Fahrenheit a rankine
--  @68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
	@60F_R         FLOAT = 519.67, -- 60 grados Fahrenheit a rankine
    @68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
	@BitConciliada	BIT = 1,
	@TotalPetroleo	FLOAT,
	@TotalGas		FLOAT,
	@IdRelacionado	INT,
	@Contratos		VARCHAR(800) = '',
	@SinPoderCalorifico VARCHAR(4000) = '',
	@ConstanteBll FLOAT = 42

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
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	C.IdContrato	=	PEC.idContrato
	AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
JOIN
	dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
	ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	AND P.PuntoEntregaID	=	PE.PuntoEntregaID
LEFT JOIN
	dbo.PR_ProdDiariaPozo	PDP	(NOLOCK)
	ON P.Id	=	PDP.Pozo
	AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
	AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
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
	dbo.CO_Contrato	C	(NOLOCK)
	ON	CO.IdContrato	=	C.IdContrato
JOIN
	CO_Instalacion	I	(NOLOCK)
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P	(NOLOCK)
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_ProdDiariaPozo	PDP	(NOLOCK)
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

	-- SE VALIDA SI EXISTE GAS EN ALGUNO DE LOS POZOS PARA REALIZAR EL CALCULO DE % MOLAR
	INSERT INTO #ConversionGas
	(	IdContrato,	PuntoEntregaID, Fecha,	MMPC_Gas,
		C1MOL,	C2MOL,	C3MOL,	NC4MOL,	IC4MOL,	NC5MOL,	IC5MOL,	C6MOL,
		C6, C7, C8, C9, C10,
		CO2MOL, H2S, N2,
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
		ISNULL(CROMA.C6_plus,0), ISNULL(CROMA.C7,0), ISNULL(CROMA.C8,0), ISNULL(CROMA.C9,0), ISNULL(CROMA.C10,0),
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
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
		ON	C.IdContrato	=	PEC.idContrato
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	LEFT JOIN	
		dbo.CO_Cromatografia	CR	(NOLOCK)
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	LEFT JOIN
		CO_CromatografiaValores	CROMA	(NOLOCK)
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	LEFT JOIN
		dbo.PR_ProdDiaria	PD	(NOLOCK)
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
		ISNULL(CROMA.C6_plus,0), ISNULL(CROMA.C7,0), ISNULL(CROMA.C8,0), ISNULL(CROMA.C9,0), ISNULL(CROMA.C10,0),
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
		AND	p.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo	PDP	(NOLOCK)
		ON P.Id	=	PDP.Pozo
		AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria	PD	(NOLOCK)
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
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
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo	PDP	(NOLOCK)
		ON P.Id	=	PDP.Pozo
		AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria	PD(NOLOCK)
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

	-- SE VALIDA SI EXISTE GAS EN ALGUNO DE LOS POZOS PARA REALIZAR EL CALCULO DE % MOLAR
	INSERT INTO #ConversionGas
	(	IdContrato,	PuntoEntregaID, Fecha,	MMPC_Gas,
		C1MOL,	C2MOL,	C3MOL,	NC4MOL,	IC4MOL,	NC5MOL,	IC5MOL,	C6MOL,
		C6, C7, C8, C9, C10,
		CO2MOL, H2S, N2,
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
		ISNULL(CROMA.C6_plus,0), ISNULL(CROMA.C7,0), ISNULL(CROMA.C8,0), ISNULL(CROMA.C9,0), ISNULL(CROMA.C10,0),
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
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	LEFT JOIN	
		dbo.CO_Cromatografia	CR	(NOLOCK)
		ON C.IdContrato	=	CR.IdContrato
		AND	YEAR(@MesReporte) = CR.Anio
		AND	MONTH(@MesReporte)	=	CR.Mes
	LEFT JOIN
		CO_CromatografiaValores	CROMA	(NOLOCK)
		ON	CR.IdCromatografia	=	CROMA.IdCromatografia
		AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD	(NOLOCK)
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		YEAR(@MesReporte) = YEAR(PDP.Fecha)
		AND	MONTH(@MesReporte) = MONTH(PDP.Fecha)
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
		ISNULL(CROMA.C6_plus,0), ISNULL(CROMA.C7,0), ISNULL(CROMA.C8,0), ISNULL(CROMA.C9,0), ISNULL(CROMA.C10,0),
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
		SUM(CASE WHEN ROUND(ISNULL(PD.Temperatura,20),2) <> 15.56 THEN ROUND(ISNULL(PDP.ProdCondensadoNeto,0),3)
			ELSE 0 END),
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
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo_Previo	PDP	(NOLOCK)
		ON P.Id	=	PDP.Pozo
		AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD	(NOLOCK)
		ON	PDP.ProdDiaria	=	PD.Id
		AND	PDP.Fecha		=	PD.Fecha
	WHERE
		I.Activo = 1
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
		AND	P.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_ProdDiariaPozo_Previo	PDP	(NOLOCK)
		ON P.Id	=	PDP.Pozo
		AND	YEAR(PDP.Fecha)	=	YEAR(@MesReporte)
		AND	MONTH(PDP.Fecha) = MONTH(@MesReporte)
	LEFT JOIN
		dbo.PR_ProdDiaria_Previo	PD	(NOLOCK)
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
		C6		=	ISNULL(CROMA.C6_plus,0),
		C7		=	ISNULL(CROMA.C7,0),
		C8		=	ISNULL(CROMA.C8,0),
		C9		=	ISNULL(CROMA.C9,0),
		C10		=	ISNULL(CROMA.C10,0),
		CO2MOL	=	ISNULL(CROMA.MOL_CO2,0),
		H2S		=	ISNULL(CROMA.MOL_N2,0),
		N2		=	ISNULL(CROMA.MOL_h2S,0),
		PoderCalorifico	=	ISNULL(CROMA.PoderCalorifico,0),
		PoderCalorifico_Gas	=	ISNULL(CROMA.PoderCalorificoGas,0)
FROM
	#ConversionGas	CG
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	CG.IdContrato	=	PEC.idContrato
	AND CG.PuntoEntregaID	=	PEC.PuntoEntregaID
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
	LCid_C10	=	ROUND((C.C10/100) * 1000 * (1/GPA.Decano_C10)* (14.696/14.696),6),
	LCid_CO2	=	ROUND((C.CO2MOL/100) * 1000 * (1/GPA.CO2)* (14.696/14.696),6),
	LCid_H2S	=	ROUND((C.H2S/100) * 1000 * (1/GPA.H2S)* (14.696/14.696),6),
	LCid_N2		=	ROUND((C.N2/100) * 1000 * (1/GPA.Nitrogeno_N2)* (14.696/14.696),6)
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
		LCi_C10		= ROUND(LCid_C10 / Zmes,6),
		LCi_CO2		= ROUND(LCid_CO2 / Zmes,6),
		LCi_H2S		= ROUND(LCid_H2S / Zmes,6),
		LCi_N2		= ROUND(LCid_N2 / Zmes,6)

UPDATE	#ConversionGas
	SET	C5EqBl	=	ROUND((MMPC_Gas * 1000 * LCi_nC5)/@ConstanteBll,3) + ROUND((MMPC_Gas * 1000 * LCi_iC5)/@ConstanteBll,3) +
					ROUND((MMPC_Gas * 1000 * LCi_C6)/@ConstanteBll,3) + ROUND((MMPC_Gas * 1000 * LCi_C7)/@ConstanteBll,3) +
					ROUND((MMPC_Gas * 1000 * LCi_C8)/@ConstanteBll,3) + ROUND((MMPC_Gas * 1000 * LCi_C9)/@ConstanteBll,3) +
					ROUND((MMPC_Gas * 1000 * LCi_C10)/@ConstanteBll,3)

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
	C6,
	C7,
	C8,
	C9,
	C10,
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
	PoderCalorifico_Gas
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
	SUM(C6),
	SUM(C7),
	SUM(C8),
	SUM(C9),
	SUM(C10),
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
    SUM(C6MASMMBTU),
	SUM(C6MMBTU),
	SUM(C7MMBTU),
	SUM(C8MMBTU),
	SUM(C9MMBTU),
	SUM(C10MMBTU),
    SUM(ROUND(PCC1,3)),
    SUM(ROUND(PCC2,3)),
    SUM(ROUND(PCC3,3)),
    SUM(ROUND(PCNC4,3)),
    SUM(ROUND(PCIC4,3)),
    SUM(ROUND(PCNC5,3)),
    SUM(ROUND(PCIC5,3)),
    SUM(ROUND(PCC6,3)),
	SUM(ROUND(PCC7,3)),
	SUM(ROUND(PCC8,3)),
	SUM(ROUND(PCC9,3)),
	SUM(ROUND(PCC10,3)),
    ROUND(PesoMolecularGas,3),
	ROUND(PoderCalorifico_Gas,3)
FROM
	#ConversionGas
GROUP BY
	IdContrato,
	PuntoEntregaID,
	ROUND(PesoMolecularGas,3),
	ROUND(PoderCalorifico_Gas,3)

INSERT INTO #ConversionGasAC
(
    IdContrato,
    MMPC_Gas,
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
    C5EqBl
)
SELECT
	IdContrato,
	SUM(MMPC_Gas),
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
    SUM(ROUND(C5EqBl,3))
FROM
	#ConversionGas
GROUP BY
	IdContrato


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
	C6,
	C7,
	C8,
	C9,
	C10,
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
	SUM(CASE WHEN CGAC.C6MASMMBTU = 0 THEN 0 ELSE (CG.C6MASMMBTU * CG.C6MOL )/ CGAC.C6MASMMBTU END),
	SUM(CASE WHEN CGAC.C6MMBTU = 0 THEN 0 ELSE (CG.C6MMBTU * CG.C6 )/ CGAC.C6MMBTU END),
	SUM(CASE WHEN CGAC.C7MMBTU = 0 THEN 0 ELSE (CG.C7MMBTU * CG.C7 )/ CGAC.C7MMBTU END),
	SUM(CASE WHEN CGAC.C8MMBTU = 0 THEN 0 ELSE (CG.C8MMBTU * CG.C8 )/ CGAC.C8MMBTU END),
	SUM(CASE WHEN CGAC.C9MMBTU = 0 THEN 0 ELSE (CG.C9MMBTU * CG.C9 )/ CGAC.C9MMBTU END),
	SUM(CASE WHEN CGAC.C10MMBTU = 0 THEN 0 ELSE (CG.C10MMBTU * CG.C10 )/ CGAC.C10MMBTU END),
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
    SUM(CASE WHEN CGAC.C6MASMMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C6MASMMBTU)/CGAC.C6MASMMBTU END),
	SUM(CASE WHEN CGAC.C6MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C6MMBTU)/CGAC.C6MMBTU END),
	SUM(CASE WHEN CGAC.C7MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C7MMBTU)/CGAC.C7MMBTU END),
	SUM(CASE WHEN CGAC.C8MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C8MMBTU)/CGAC.C8MMBTU END),
	SUM(CASE WHEN CGAC.C9MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C9MMBTU)/CGAC.C9MMBTU END),
	SUM(CASE WHEN CGAC.C10MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C10MMBTU)/CGAC.C10MMBTU END),
	SUM( CASE WHEN CGAC.C1MMBTU = 0 THEN 0 WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas)/CGAC.C1MMBTU END),
	SUM( CASE WHEN CGAC.C2MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C2MMBTU/CG.PoderCalorifico_Gas)/CGAC.C2MMBTU END),
	SUM( CASE WHEN CGAC.C3MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C3MMBTU/CG.PoderCalorifico_Gas)/CGAC.C3MMBTU END),
	SUM( CASE WHEN CGAC.NC4MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.NC4MMBTU/CG.PoderCalorifico_Gas)/CGAC.NC4MMBTU END),
	SUM( CASE WHEN CGAC.IC4MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.IC4MMBTU/CG.PoderCalorifico_Gas)/CGAC.IC4MMBTU END),
	SUM( CASE WHEN CGAC.NC5MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.NC5MMBTU/CG.PoderCalorifico_Gas)/CGAC.NC5MMBTU END),
	SUM( CASE WHEN CGAC.IC5MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.IC5MMBTU/CG.PoderCalorifico_Gas)/CGAC.IC5MMBTU END),
	SUM( CASE WHEN CGAC.C6MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C6MMBTU/CG.PoderCalorifico_Gas)/CGAC.C6MMBTU END),
	SUM( CASE WHEN CGAC.C7MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C7MMBTU/CG.PoderCalorifico_Gas)/CGAC.C7MMBTU END),
	SUM( CASE WHEN CGAC.C8MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C8MMBTU/CG.PoderCalorifico_Gas)/CGAC.C8MMBTU END),
	SUM( CASE WHEN CGAC.C9MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C9MMBTU/CG.PoderCalorifico_Gas)/CGAC.C9MMBTU END),
	SUM( CASE WHEN CGAC.C10MMBTU = 0 THEN 0	WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		ELSE (CG.C10MMBTU/CG.PoderCalorifico_Gas)/CGAC.C10MMBTU END),
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


---- CALCULAR LOS PORCENTAJES MOLARES POR AREA CONTRACTUAL
--INSERT INTO #ValoresAC
--(
--	IdContrato,
--    MMPC_Gas,
--    C1MMBTU,
--    C2MMBTU,
--    C3MMBTU,
--    NC4MMBTU,
--    IC4MMBTU,
--    NC5MMBTU,
--    IC5MMBTU,
--    C6MMBTU,
--	C5EqBl
--)
--SELECT
--	CG.IdContrato,
--	SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE CG.MMPC_Gas * (CG.MMPC_Gas/CGAC.MMPC_Gas) END),
--	SUM(CASE WHEN CGAC.C1MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C1MMBTU)/CGAC.C1MMBTU END),
--	SUM(CASE WHEN CGAC.C2MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C2MMBTU)/CGAC.C2MMBTU END),
--	SUM(CASE WHEN CGAC.C3MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C3MMBTU)/CGAC.C3MMBTU END),
--	SUM(CASE WHEN CGAC.NC4MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.NC4MMBTU)/CGAC.NC4MMBTU END),
--	SUM(CASE WHEN CGAC.IC4MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.IC4MMBTU)/CGAC.IC4MMBTU END),
--	SUM(CASE WHEN CGAC.NC5MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.NC5MMBTU)/CGAC.NC5MMBTU END),
--    SUM(CASE WHEN CGAC.IC5MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.IC5MMBTU)/CGAC.IC5MMBTU END),
--    SUM(CASE WHEN CGAC.C6MMBTU = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C6MMBTU)/CGAC.C6MMBTU END),
--	SUM(CASE WHEN CGAC.MMPC_Gas = 0 THEN 0 ELSE (CG.MMPC_Gas * CG.C5EqBl)/ CGAC.MMPC_Gas END)
--FROM
--	#ConversionGas	CG
--JOIN
--	#ConversionGasAC	CGAC
--	ON	CG.IdContrato	=	CGAC.IdContrato
--GROUP BY
--	CG.IdContrato

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
	PR_ProdDiariaPozo	PDPP	(NOLOCK)
	ON P.Id		=	PDPP.Pozo
	AND YEAR(PDPP.Fecha)	=	YEAR(@MesReporte)
	AND MONTH(PDPP.Fecha)	=	MONTH(@MesReporte)
LEFT JOIN
	dbo.CO_Cromatografia	CRO	(NOLOCK)
	ON	PEC.IdContrato	=	CRO.IdContrato
	AND CRO.Anio		=	YEAR(@MesReporte)
	AND CRO.Mes			=	MONTH(@MesReporte)
LEFT JOIN
	dbo.CO_CromatografiaValores	CROMA	(NOLOCK)
	ON	CRO.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
LEFT JOIN
	PR_PuntoEntregaDiario	PED	(NOLOCK)
	ON	PEC.PuntoEntregaID	=	PED.PuntoEntregaID
	AND PDPP.Fecha			=	PED.Fecha
LEFT JOIN
	dbo.PR_ProdDiaria	PD	(NOLOCK)
	ON	PDPP.ProdDiaria	=	PD.Id
	AND PDPP.Fecha		=	PD.Fecha
WHERE
	I.Activo = 1
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
	PR_ProdDiariaPozo_Previo	PDPP	(NOLOCK)
	ON P.Id		=	PDPP.Pozo
	AND YEAR(PDPP.Fecha)	=	YEAR(@MesReporte)
	AND MONTH(PDPP.Fecha)	=	MONTH(@MesReporte)
LEFT JOIN
	dbo.CO_Cromatografia	CRO	(NOLOCK)
	ON	PEC.IdContrato	=	CRO.IdContrato
	AND CRO.Anio		=	YEAR(@MesReporte)
	AND CRO.Mes			=	MONTH(@MesReporte)
LEFT JOIN
	dbo.CO_CromatografiaValores	CROMA	(NOLOCK)
	ON	CRO.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
LEFT JOIN
	PR_PuntoEntregaDiario	PED	(NOLOCK)
	ON	PEC.PuntoEntregaID	=	PED.PuntoEntregaID
	AND PDPP.Fecha			=	PED.Fecha
LEFT JOIN
	dbo.PR_ProdDiaria_Previo	PD	(NOLOCK)
	ON	PDPP.ProdDiaria	=	PD.Id
	AND	PDPP.Fecha		=	PD.Fecha
WHERE
	I.Activo = 1
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
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	PP.IdContrato	=	PEC.idContrato
	AND PP.PuntoEntregaID	=	PEC.PuntoEntregaID
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
	--CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Presion * SUM(VPE.VolumenGas))/TC.Gas
	--	WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
	--	ELSE (PP.Presion * SUM(VPE.VolumenPetroleo))/ISNULL(TC.Petroleo,0) END,
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Presion * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.Presion * VPE.VolumenPetroleo)/TC.Petroleo END),
	--CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Temperatura * SUM(VPE.VolumenGas))/TC.Gas
	--	WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
	--	ELSE (PP.Temperatura * SUM(VPE.VolumenPetroleo))/ISNULL(TC.Petroleo,0) END,
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Temperatura * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.Temperatura * VPE.VolumenPetroleo)/TC.Petroleo END),
	--CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.DensidadAPI * SUM(VPE.VolumenGas))/TC.Gas
	--	WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
	--	ELSE (PP.DensidadAPI * SUM(VPE.VolumenPetroleo))/ISNULL(TC.Petroleo,0) END,
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.DensidadAPI * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.DensidadAPI * VPE.VolumenPetroleo)/TC.Petroleo END),
	--CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Salinidad * SUM(VPE.VolumenGas))/TC.Gas
	--	WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
	--	ELSE (PP.Salinidad * SUM(VPE.VolumenPetroleo))/ISNULL(TC.Petroleo,0) END,
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Salinidad * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.Salinidad * VPE.VolumenPetroleo)/TC.Petroleo END),
	--CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.PorcentajeAguaSedimentos * SUM(VPE.VolumenGas))/TC.Gas
	--	WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
	--	ELSE (PP.PorcentajeAguaSedimentos * SUM(VPE.VolumenPetroleo))/ISNULL(TC.Petroleo,0) END,
	SUM(CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.PorcentajeAguaSedimentos * VPE.VolumenGas)/TC.Gas
			WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
			ELSE (PP.PorcentajeAguaSedimentos * VPE.VolumenPetroleo)/TC.Petroleo END),
	--CASE WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas > 0 THEN (PP.Azufre * SUM(VPE.VolumenGas))/TC.Gas
	--	WHEN ISNULL(TC.Petroleo,0) = 0 AND TC.Gas = 0	THEN 0
	--	ELSE (PP.Azufre * SUM(VPE.VolumenPetroleo))/ISNULL(TC.Petroleo,0) END
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
	--ISNULL(TC.Petroleo,0),
	--TC.Gas,
	--PP.Presion,
	--PP.Temperatura,
	--PP.DensidadAPI,
	--PP.Salinidad,
	--PP.Azufre,
	--PP.PorcentajeAguaSedimentos

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
	--SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoBruto * PP.CTL,3)
	--	ELSE ROUND(P.ProdPetroleoBruto,3) END),
-- NUEVO CALCULO DE TEMPERATURA 
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdPetroleoBruto * EXP( -(341.0957 / POWER( ((141.5 / (PP.DensidadAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (PP.DensidadAPI + 131.5)) * 999.012), 2 )) * 8)),3)
		ELSE ROUND(P.ProdPetroleoBruto,3) END),
--	SUM(CASE WHEN P.Temperatura <> 15.56 THEN P.ProdPetroleoBruto * PP.CTL
--		ELSE P.ProdPetroleoBruto END),
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN P.ProdPetroleoBruto * EXP( -(341.0957 / POWER( ((141.5 / (PP.DensidadAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (PP.DensidadAPI + 131.5)) * 999.012), 2 )) * 8))
		ELSE P.ProdPetroleoBruto END),
--	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdAceiteNeto * PP.CTL,3)
--		ELSE ROUND(P.ProdAceiteNeto,3) END),
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN ROUND(P.ProdAceiteNeto * EXP( -(341.0957 / POWER( ((141.5 / (PP.DensidadAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (PP.DensidadAPI + 131.5)) * 999.012), 2 )) * 8)),3)
		ELSE ROUND(P.ProdAceiteNeto,3) END),
	--SUM(CASE WHEN P.Temperatura <> 15.56 THEN P.ProdAceiteNeto * PP.CTL
	--	ELSE P.ProdAceiteNeto END)
	SUM(CASE WHEN P.Temperatura <> 15.56 THEN P.ProdAceiteNeto * EXP( -(341.0957 / POWER( ((141.5 / (PP.DensidadAPI + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (PP.DensidadAPI + 131.5)) * 999.012), 2 )) * 8))
		ELSE P.ProdAceiteNeto END)
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
		--VolumenCondensado_15_56	=	VPE.VolumenCondensado_15_56 + (VPE.VolumenCondensado * PP.CTL_Condensado)
-- NUEVO CALCULO DE TEMPERATURA
		VolumenCondensado_15_56	= VPE.VolumenCondensado_15_56 +	ROUND(VPE.VolumenCondensado * EXP( -(341.0957/POWER(((141.5/(0 + 131.5))*999.012),2)) * 8 * (1 + 0.8 * (341.0957/POWER(((141.5/(0 + 131.5))*999.012),2)) * 8)),4)
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

-- *********************************************
-- Reporte diario de producción por instalación	
-- *********************************************
SELECT
	C.NumeroContrato					AS [ID Contrato o Asignación],
	ISNULL(VPE.RegionFiscal,'N/A')		AS [Región Fiscal],
	PE.Nombre							AS [Ubicación del Punto de Medición],
	ISNULL(PE.TagPatinMedicion,'N/A')	AS [Tag del Patín de Medición],
	ISNULL(PE.TipoMedidor,'N/A')		AS [Tipo de Medidor],
	ISNULL(PE.TagMedidor,'N/A')			AS [Tag del Medidor],
	ISNULL(PE.Clasificacion,'N/A')		AS [Clasificación del Sistema de Medición],
	ISNULL(VPE.TipoFluido,'N/A')		AS [Tipo de Hidrocarburo],
	VPE.Fecha							AS [Fecha],
	ROUND(ISNULL(PED.Presion,0),3)			AS [Presion],
	ROUND(ISNULL(PED.Temperatura,0),3)		AS [Temperatura],
	ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
	ROUND(ISNULL(PP.DensidadAPI,0),3)		AS [°API],
	ROUND(ISNULL(PP.Azufre,0),3)			AS [% S],
	ROUND(ISNULL(PP.Salinidad,0),3)			AS [Sal],
	CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
		ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
	END										AS [% H2O],
	ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3)		AS [Producción de Condensado Medido Neto],
	0	AS [°API],		-- CONDENSADO
	0	AS [% S],		-- CONDENSADO
	0	AS [% H2O],		-- CONDENSADO
	ROUND(ISNULL(VPE.VolumenGas,0),3)		AS [Producción de Gas Medido],
	--CASE WHEN CG.PoderCalorifico_Gas = 0 THEN 0
	--	ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas)+ (CG.C2MMBTU/CG.PoderCalorifico_Gas)+ (CG.C3MMBTU/CG.PoderCalorifico_Gas)+ (CG.NC4MMBTU/CG.PoderCalorifico_Gas)+ (CG.IC4MMBTU/CG.PoderCalorifico_Gas)+
	--		 (CG.NC5MMBTU/CG.PoderCalorifico_Gas)+ (CG.IC5MMBTU/CG.PoderCalorifico_Gas)+ (CG.C6MMBTU/CG.PoderCalorifico_Gas)+ (CG.C7MMBTU/CG.PoderCalorifico_Gas)+ (CG.C8MMBTU/CG.PoderCalorifico_Gas)+
	--		 (CG.C9MMBTU/CG.PoderCalorifico_Gas) + (CG.C10MMBTU/CG.PoderCalorifico_Gas)	END																		AS [Poder Calorífico de Gas],
	ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3)		AS [Poder Calorífico de Gas],
	ROUND(ISNULL(CG.PesoMolecularGas,0),3)	AS [Peso Molecular de Gas],
	ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+
		ISNULL(CG.C6MMBTU,0)+ ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3)	AS [Energia de Gas],
	ISNULL(PED.Eventos,'N/A')				AS [Eventos]
FROM
	#ContratosConciliada	CC
JOIN
	dbo.CO_Contrato	C	(NOLOCK)
	ON	CC.IdContrato	=	C.IdContrato
JOIN
	#VolumenXPtoEntrega	VPE
	ON	C.IdContrato	=	VPE.IdContrato
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
	ON	VPE.IdContrato	=	PEC.idContrato
	AND VPE.PuntoEntregaID	=	PEC.PuntoEntregaID
JOIN
	dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
	ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	AND VPE.PuntoEntregaID	=	PE.PuntoEntregaID
LEFT JOIN
	dbo.PR_PuntoEntregaDiario	PED	(NOLOCK)
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
	PE.Nombre,
	ISNULL(PE.TagPatinMedicion,'N/A'),
	ISNULL(PE.TipoMedidor,'N/A'),
	ISNULL(PE.TagMedidor,'N/A'),
	ISNULL(PE.Clasificacion,'N/A'),
	ISNULL(VPE.TipoFluido,'N/A'),
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
	--CASE WHEN ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3) = 0 THEN 0
	--	ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3),3)
	--END,
	--CASE WHEN CG.PoderCalorifico_Gas = 0 THEN 0
	--	ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas)+ (CG.C2MMBTU/CG.PoderCalorifico_Gas)+ (CG.C3MMBTU/CG.PoderCalorifico_Gas)+ (CG.NC4MMBTU/CG.PoderCalorifico_Gas)+ (CG.IC4MMBTU/CG.PoderCalorifico_Gas)+
	--		 (CG.NC5MMBTU/CG.PoderCalorifico_Gas)+ (CG.IC5MMBTU/CG.PoderCalorifico_Gas)+ (CG.C6MMBTU/CG.PoderCalorifico_Gas)+ (CG.C7MMBTU/CG.PoderCalorifico_Gas)+ (CG.C8MMBTU/CG.PoderCalorifico_Gas)+
	--		 (CG.C9MMBTU/CG.PoderCalorifico_Gas) + (CG.C10MMBTU/CG.PoderCalorifico_Gas)	END,
	ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3),
	ROUND(ISNULL(CG.PesoMolecularGas,0),3),
	ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+
		ISNULL(CG.C6MMBTU,0)+ ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3),
	ISNULL(PED.Eventos,'N/A')

UNION

	SELECT
		C.NumeroContrato				AS [ID Contrato o Asignación],
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
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3)			AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(PP.DensidadAPI,0),3)		AS [°API],
		ROUND(ISNULL(PP.Azufre,0),3)			AS [% S],
		ROUND(ISNULL(PP.Salinidad,0),3)			AS [Sal],
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END										AS [% H2O],
		ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3)			AS [Producción de Condensado Medido Neto],
		0	AS [°API],		-- CONDENSADO
		0	AS [% S],		-- CONDENSADO
		0	AS [% H2O],		-- CONDENSADO
		ROUND(ISNULL(VPE.VolumenGas,0),3)					AS [Producción de Gas Medido],
		--CASE WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		--	ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas) + (CG.C2MMBTU/CG.PoderCalorifico_Gas) + (CG.C3MMBTU/CG.PoderCalorifico_Gas) + (CG.NC4MMBTU/CG.PoderCalorifico_Gas) + 
		--		(CG.IC4MMBTU/CG.PoderCalorifico_Gas) + (CG.NC5MMBTU/CG.PoderCalorifico_Gas) + (CG.IC5MMBTU/CG.PoderCalorifico_Gas) + (CG.C6MMBTU/CG.PoderCalorifico_Gas) +
		--		(CG.C7MMBTU/CG.PoderCalorifico_Gas)+ (CG.C8MMBTU/CG.PoderCalorifico_Gas)+ (CG.C9MMBTU/CG.PoderCalorifico_Gas) + (CG.C10MMBTU/CG.PoderCalorifico_Gas)
		--END									AS [Poder Calorífico de Gas],
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3)		AS [Poder Calorífico de Gas],
		ROUND(ISNULL(CG.PesoMolecularGas,0),3)	AS [Peso Molecular de Gas],
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+
			ISNULL(CG.C6MMBTU,0)+ ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3)			AS [Energia de Gas],
		ISNULL(PED.Eventos,'N/A')			AS [Eventos]
	FROM
		#ContratosDiaria	CD
	JOIN
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CD.IdContrato	=	C.IdContrato
	JOIN
		#VolumenXPtoEntrega	VPE
		ON	C.IdContrato	=	VPE.IdContrato
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC	(NOLOCK)
		ON	VPE.IdContrato	=	PEC.idContrato
		AND	VPE.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND VPE.PuntoEntregaID	=	PE.PuntoEntregaID
	LEFT JOIN
		dbo.PR_PuntoEntregaDiario	PED	(NOLOCK)
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
		--CASE WHEN ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3) = 0 THEN 0
		--	ELSE ROUND((ROUND(ISNULL(VPE.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VPE.VolumenCondensado_15_56,0),3),3)
		--END,
		--CASE WHEN CG.PoderCalorifico_Gas = 0 THEN 0
		--	ELSE (CG.C1MMBTU/CG.PoderCalorifico_Gas) + (CG.C2MMBTU/CG.PoderCalorifico_Gas) + (CG.C3MMBTU/CG.PoderCalorifico_Gas) + (CG.NC4MMBTU/CG.PoderCalorifico_Gas) + 
		--		(CG.IC4MMBTU/CG.PoderCalorifico_Gas) + (CG.NC5MMBTU/CG.PoderCalorifico_Gas) + (CG.IC5MMBTU/CG.PoderCalorifico_Gas) + (CG.C6MMBTU/CG.PoderCalorifico_Gas) +
		--		(CG.C7MMBTU/CG.PoderCalorifico_Gas)+ (CG.C8MMBTU/CG.PoderCalorifico_Gas)+ (CG.C9MMBTU/CG.PoderCalorifico_Gas) + (CG.C10MMBTU/CG.PoderCalorifico_Gas)
		--END,
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3),
		ROUND(ISNULL(CG.PesoMolecularGas,0),3),
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+ISNULL(CG.IC5MMBTU,0)+
			ISNULL(CG.C6MMBTU,0)+ ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3),
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
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(VMI.DensidadAPI,0),3)		AS [API],
		ROUND(ISNULL(VMI.Azufre,0),3)			AS [% S],
		ROUND(ISNULL(VMI.Salinidad,0),3)		AS [Sal],
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND(ROUND((ISNULL(VTH.VolumenAgua,0) * 100),3) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END										AS [% H2O],
		ROUND(ISNULL(VTH.Condensado_15_56,0),3)		AS [Producción de Condensado Medido Neto],
		0	AS [°API],
		0	AS [% S],
		0	AS [% H2O],
		--ROUND(ISNULL(VMI.DensidadAPI,0),3)		AS [°API],
		--ROUND(ISNULL(VMI.Azufre,0),3)			AS [% S],
		--CASE WHEN ROUND(ISNULL(VTH.Condensado_15_56,0),3) = 0 THEN 0
		--	ELSE ROUND((ROUND(ISNULL(VTH.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VTH.Condensado_15_56,0),3),3)
		--END											AS [% H2O],
		ROUND(ISNULL(VTH.MMPC_Gas,0),3)				AS [Producción de Gas Medido],
		ROUND(ISNULL(VI.C1MOL,0),3)					AS [C1],
		ROUND(ISNULL(VI.C2MOL,0),3)					AS [C2],
		ROUND(ISNULL(VI.C3MOL,0),3)					AS [C3],
		ROUND(ISNULL(VI.NC4MOL,0),3)				AS [nC4],
		ROUND(ISNULL(VI.IC4MOL,0),3)				AS [IC4],
		ROUND(ISNULL(VI.NC5MOL,0),3)				AS [nC5],
		ROUND(ISNULL(VI.IC5MOL,0),3)				AS [IC5],
		ROUND(ISNULL(VI.C6,0),3)					AS [C6],
		ROUND(ISNULL(VI.C7,0),3)					AS [C7],
		ROUND(ISNULL(VI.C8,0),3)					AS [C8],
		ROUND(ISNULL(VI.C9,0),3)					AS [C9],
		ROUND(ISNULL(VI.C10,0),3)					AS [C10],
		ROUND(ISNULL(VI.CO2MOL,0),3)				AS [CO2],
		ROUND(ISNULL(VI.H2S,0),3)					AS [H2S],
		ROUND(ISNULL(VI.N2,0),3)					AS [N2],
		0										AS [O2],
		--ROUND((ISNULL(VI.PCC1,0)+ISNULL(VI.PCC2,0)+ISNULL(VI.PCC3,0)+ISNULL(VI.PCNC4,0)+ISNULL(VI.PCIC4,0)+ISNULL(VI.PCNC5,0)+
		--	ISNULL(VI.PCIC5,0)+ISNULL(VI.PCC6,0)+ISNULL(VI.PCC7,0)+ISNULL(VI.PCC8,0)+ISNULL(VI.PCC9,0)+ISNULL(VI.PCC10,0)),3)		AS [Poder Calorifico de Gas],
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3)	AS [Poder Calorifico de Gas],
		ROUND((ISNULL(CG.PesoMolecularGas,0)),3)		AS [Peso Molecular de Gas],
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+
			ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)+ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3)	AS [Energia de Gas],
		ROUND(ISNULL(VAC.C1MMBTU,0),3)				AS [Energía C1 MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.C2MMBTU,0),3)				AS [Energía C2 MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.C3MMBTU,0),3)				AS [Energía C3 MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.NC4MMBTU,0),3) + ROUND(ISNULL(VAC.IC4MMBTU,0),3)	AS [Energía C4 MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.NC5MMBTU,0),3) + ROUND(ISNULL(VAC.IC5MMBTU,0),3) + ROUND(ISNULL(VAC.C6MMBTU,0),3) + ROUND(ISNULL(VAC.C7MMBTU,0),3) +
		ROUND(ISNULL(VAC.C8MMBTU,0),3) + ROUND(ISNULL(VAC.C9MMBTU,0),3) + ROUND(ISNULL(VAC.C10MMBTU,0),3)	AS [Energía C5+ MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.C5EqBl,0),3)				AS [Vol. C5+ bls (Asig - AC)],
		ISNULL(FPE.Eventos,'N/A')					AS [Eventos]
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
		dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		#VolumenesTotalesHidro	VTH
		ON	PEC.idContrato	=	VTH.IdContrato
		AND	PE.PuntoEntregaID	=	VTH.PuntoEntregaID
	LEFT JOIN
		PR_FactorPuntoEntrega	FPE	(NOLOCK)
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
	LEFT JOIN
		--#ValoresAC		VAC
		#ConversionGasAC	VAC
		ON	C.IdContrato	=	VAC.IdContrato
	WHERE
		I.Activo = 1
	GROUP BY
		C.NumeroContrato,
		P.RegionFiscal,
		PE.Nombre,
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
		--CASE WHEN ROUND(ISNULL(VTH.Condensado_15_56,0),3) = 0 THEN 0
		--	ELSE ROUND((ROUND(ISNULL(VTH.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VTH.Condensado_15_56,0),3),3)
		--END,
		ROUND(ISNULL(VTH.Condensado_15_56,0),3),
		ROUND(ISNULL(VTH.MMPC_Gas,0),3),
		ROUND(ISNULL(VI.C1MOL,0),3),
		ROUND(ISNULL(VI.C2MOL,0),3),
		ROUND(ISNULL(VI.C3MOL,0),3),
		ROUND(ISNULL(VI.NC4MOL,0),3),
		ROUND(ISNULL(VI.IC4MOL,0),3),
		ROUND(ISNULL(VI.NC5MOL,0),3),
		ROUND(ISNULL(VI.IC5MOL,0),3),
		ROUND(ISNULL(VI.C6,0),3),
		ROUND(ISNULL(VI.C7,0),3),
		ROUND(ISNULL(VI.C8,0),3),
		ROUND(ISNULL(VI.C9,0),3),
		ROUND(ISNULL(VI.C10,0),3),
		ROUND(ISNULL(VI.CO2MOL,0),3),
		ROUND(ISNULL(VI.H2S,0),3),
		ROUND(ISNULL(VI.N2,0),3),
		--ROUND((ISNULL(VI.PCC1,0)+ISNULL(VI.PCC2,0)+ISNULL(VI.PCC3,0)+ISNULL(VI.PCNC4,0)+ISNULL(VI.PCIC4,0)+ISNULL(VI.PCNC5,0)+
		--	ISNULL(VI.PCIC5,0)+ISNULL(VI.PCC6,0)+ISNULL(VI.PCC7,0)+ISNULL(VI.PCC8,0)+ISNULL(VI.PCC9,0)+ISNULL(VI.PCC10,0)),3),
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3),
		ROUND((ISNULL(CG.PesoMolecularGas,0)),3),
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+
			ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)+ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3),
		ROUND(ISNULL(VAC.C1MMBTU,0),3),
		ROUND(ISNULL(VAC.C2MMBTU,0),3),
		ROUND(ISNULL(VAC.C3MMBTU,0),3),
		ROUND(ISNULL(VAC.NC4MMBTU,0),3) + ROUND(ISNULL(VAC.IC4MMBTU,0),3),
		ROUND(ISNULL(VAC.NC5MMBTU,0),3) + ROUND(ISNULL(VAC.IC5MMBTU,0),3) + ROUND(ISNULL(VAC.C6MMBTU,0),3) + ROUND(ISNULL(VAC.C7MMBTU,0),3) +
		ROUND(ISNULL(VAC.C8MMBTU,0),3) + ROUND(ISNULL(VAC.C9MMBTU,0),3) + ROUND(ISNULL(VAC.C10MMBTU,0),3),
		ROUND(ISNULL(VAC.C5EqBl,0),3),
		ISNULL(FPE.Eventos,'N/A')

UNION
	/* ********************************** REPORTE 2 HOJA 2 *********************************/

	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		P.RegionFiscal		AS [Región Fiscal],
		PE.Nombre			AS [Ubicación del Punto de Medición],
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
		ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3)		AS [Producción de Petroleo Medido Neto bbl/dia],
		ROUND(ISNULL(VMI.DensidadAPI,0),3)		AS [API],
		ROUND(ISNULL(VMI.Azufre,0),3)			AS [% S],
		ROUND(ISNULL(VMI.Salinidad,0),3)		AS [Sal],
		CASE WHEN ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3) = 0 THEN 0
			ELSE ROUND(ROUND((ISNULL(VTH.VolumenAgua,0) * 100),3) / ROUND(ISNULL(P15_56.ProdAceiteNeto,0),3),3)
		END										AS [% H2O],
		ROUND(ISNULL(VTH.Condensado_15_56,0),3)		AS [Producción de Condensado Medido Neto],
		0	AS [°API],
		0	AS [% S],
		0	AS [% H2O],
		--ROUND(ISNULL(VMI.DensidadAPI,0),3)		AS [°API],
		--ROUND(ISNULL(VMI.Azufre,0),3)			AS [% S],
		--CASE WHEN ROUND(ISNULL(VTH.Condensado_15_56,0),3) = 0 THEN 0
		--	ELSE ROUND((ROUND(ISNULL(VTH.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VTH.Condensado_15_56,0),3),4)
		--END										AS [% H2O],
		ROUND(ISNULL(VTH.MMPC_Gas,0),3)			AS [Producción de Gas Medido],
		ROUND(ISNULL(VI.C1MOL,0),3)			AS [C1],
		ROUND(ISNULL(VI.C2MOL,0),3)			AS [C2],
		ROUND(ISNULL(VI.C3MOL,0),3)			AS [C3],
		ROUND(ISNULL(VI.NC4MOL,0),3)			AS [nC4],
		ROUND(ISNULL(VI.IC4MOL,0),3)				AS [IC4],
		ROUND(ISNULL(VI.NC5MOL,0),3)			AS [nC5],
		ROUND(ISNULL(VI.IC5MOL,0),3)				AS [IC5],
		ROUND(ISNULL(VI.C6,0),3)					AS [C6],
		ROUND(ISNULL(VI.C7,0),3)					AS [C7],
		ROUND(ISNULL(VI.C8,0),3)					AS [C8],
		ROUND(ISNULL(VI.C9,0),3)					AS [C9],
		ROUND(ISNULL(VI.C10,0),3)					AS [C10],
		ROUND(ISNULL(VI.CO2MOL,0),3)				AS [CO2],
		ROUND(ISNULL(VI.H2S,0),3)					AS [H2S],
		ROUND(ISNULL(VI.N2,0),3)					AS [N2],
		0										AS [O2],
		--ROUND((ISNULL(VI.PCC1,0)+ISNULL(VI.PCC2,0)+ISNULL(VI.PCC3,0)+ISNULL(VI.PCNC4,0)+ISNULL(VI.PCIC4,0)+ISNULL(VI.PCNC5,0)+
		--	ISNULL(VI.PCIC5,0)+ISNULL(VI.PCC6,0)+ISNULL(VI.PCC7,0)+ISNULL(VI.PCC8,0)+ISNULL(VI.PCC9,0)+ISNULL(VI.PCC10,0)),3)	AS [Poder calorifico de Gas],
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3)		AS [Poder calorifico de Gas],
		ROUND((ISNULL(CG.PesoMolecularGas,0)),3)		AS [Peso Molecular de Gas],
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+
			ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)+ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3)	AS [Energia de Gas],
		ROUND(ISNULL(VAC.C1MMBTU,0),3)				AS [Energía C1 MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.C2MMBTU,0),3)				AS [Energía C2 MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.C3MMBTU,0),3)				AS [Energía C3 MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.NC4MMBTU,0),3) + ROUND(ISNULL(VAC.IC4MMBTU,0),3)	AS [Energía C4 MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.NC5MMBTU,0),3) + ROUND(ISNULL(VAC.IC5MMBTU,0),3) + ROUND(ISNULL(VAC.C6MMBTU,0),3) + ROUND(ISNULL(VAC.C7MMBTU,0),3) +
		ROUND(ISNULL(VAC.C8MMBTU,0),3) + ROUND(ISNULL(VAC.C9MMBTU,0),3) + ROUND(ISNULL(VAC.C10MMBTU,0),3)	AS [Energía C5+ MMBTU (Asig - AC)],
		ROUND(ISNULL(VAC.C5EqBl,0),3)				AS [Vol. C5+ bls (Asig - AC)],
		ISNULL(FPE.Eventos,'N/A')		AS [Eventos]
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
		AND	P.PuntoEntregaID	=PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE	(NOLOCK)
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		AND P.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		#VolumenesTotalesHidro	VTH
		ON	PEC.idContrato	=	VTH.IdContrato
		AND	PE.PuntoEntregaID	=	VTH.PuntoEntregaID
	LEFT JOIN
		PR_FactorPuntoEntrega	FPE	(NOLOCK)
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
	LEFT JOIN
		--#ValoresAC		VAC
		#ConversionGasAC	VAC
		ON	C.IdContrato	=	VAC.IdContrato
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
		--CASE WHEN ROUND(ISNULL(VTH.Condensado_15_56,0),3) = 0 THEN 0
		--	ELSE ROUND((ROUND(ISNULL(VTH.VolumenAgua,0),3) * 100) / ROUND(ISNULL(VTH.Condensado_15_56,0),3),4)
		--END,
		ROUND(ISNULL(VTH.Condensado_15_56,0),3),
		ROUND(ISNULL(VTH.MMPC_Gas,0),3),
		ROUND(ISNULL(VI.C1MOL,0),3),
		ROUND(ISNULL(VI.C2MOL,0),3),
		ROUND(ISNULL(VI.C3MOL,0),3),
		ROUND(ISNULL(VI.NC4MOL,0),3),
		ROUND(ISNULL(VI.IC4MOL,0),3),
		ROUND(ISNULL(VI.NC5MOL,0),3),
		ROUND(ISNULL(VI.IC5MOL,0),3),
		ROUND(ISNULL(VI.C6,0),3),
		ROUND(ISNULL(VI.C7,0),3),
		ROUND(ISNULL(VI.C8,0),3),
		ROUND(ISNULL(VI.C9,0),3),
		ROUND(ISNULL(VI.C10,0),3),
		ROUND(ISNULL(VI.CO2MOL,0),3),
		ROUND(ISNULL(VI.H2S,0),3),
		ROUND(ISNULL(VI.N2,0),3),
		--ROUND((ISNULL(VI.PCC1,0)+ISNULL(VI.PCC2,0)+ISNULL(VI.PCC3,0)+ISNULL(VI.PCNC4,0)+ISNULL(VI.PCIC4,0)+ISNULL(VI.PCNC5,0)+
		--	ISNULL(VI.PCIC5,0)+ISNULL(VI.PCC6,0)+ISNULL(VI.PCC7,0)+ISNULL(VI.PCC8,0)+ISNULL(VI.PCC9,0)+ISNULL(VI.PCC10,0)),3),
		ROUND(ISNULL(CG.PoderCalorifico_Gas,0),3),
		ROUND((ISNULL(CG.PesoMolecularGas,0)),3),
		ROUND(ISNULL(CG.C1MMBTU,0)+ISNULL(CG.C2MMBTU,0)+ISNULL(CG.C3MMBTU,0)+ISNULL(CG.NC4MMBTU,0)+ISNULL(CG.IC4MMBTU,0)+ISNULL(CG.NC5MMBTU,0)+
			ISNULL(CG.IC5MMBTU,0)+ISNULL(CG.C6MMBTU,0)+ISNULL(CG.C7MMBTU,0)+ISNULL(CG.C8MMBTU,0)+ISNULL(CG.C9MMBTU,0)+ISNULL(CG.C10MMBTU,0),3),
		ROUND(ISNULL(VAC.C1MMBTU,0),3),
		ROUND(ISNULL(VAC.C2MMBTU,0),3),
		ROUND(ISNULL(VAC.C3MMBTU,0),3),
		ROUND(ISNULL(VAC.NC4MMBTU,0),3) + ROUND(ISNULL(VAC.IC4MMBTU,0),3),
		ROUND(ISNULL(VAC.NC5MMBTU,0),3) + ROUND(ISNULL(VAC.IC5MMBTU,0),3) + ROUND(ISNULL(VAC.C6MMBTU,0),3) + ROUND(ISNULL(VAC.C7MMBTU,0),3) +
		ROUND(ISNULL(VAC.C8MMBTU,0),3) + ROUND(ISNULL(VAC.C9MMBTU,0),3) + ROUND(ISNULL(VAC.C10MMBTU,0),3),
		ROUND(ISNULL(VAC.C5EqBl,0),3),
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
END
