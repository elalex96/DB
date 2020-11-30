CREATE PROCEDURE dbo.SP_CO_PC_ProduccionCalcularEnergia
    @Idcontrato      INT,
    @fechaMesDiaAnio DATE,
    @puntoEntrega    INT,
	@Usuario	INT,
	@Debug		BIT = 0
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 08/02/2018
-- Description:	Nueva metodologia Sipac para Produccion
-- -------------------------------------------------
-- 20180405	BAAC	Modificación para guardar lo calculado en una tabla
-- 20180507	BAAC	Se modifica para no borrar las comercializaciones correspondientes a PEMEX
-- 20180606	BAAC	Se modifica para que las comercializaciones se generen con fecha del ultimo dia del mes
-- 20180704	BAAC	Se modifica para guardar un log de los parametros utilizados para el calculo
-- 20190219	BAAC	Se crea versión 2 ya que se cambia el calculo de la energia al API 14.5
-- 20190603	BAAC	Se modifica para calcular el precio del condensado de yacimiento
-- 20190904	BAAC	Se crea nueva versión para calcular la energia por periodo para contratos de Produccion Compartida
-- ===============================================================================================
SET NOCOUNT ON
--************************************************************************************************
CREATE TABLE #DiasHabiles
(
	Fecha       DATETIME,
	Anio        INT,
	Mes         INT,
	Dia         INT,
	NumDiaHabil INT
)

CREATE TABLE #CalculosGPA
(
	IdContrato		INT,
	MesReporte		DATE,
	PuntoEntregaID	INT,
	FechaIniPeriodo	DATE,
	C1				FLOAT,
    C2				FLOAT,
    C3			   FLOAT,
    IC4			   FLOAT,
    NC4			   FLOAT,
    IC5			   FLOAT,
    NC5			   FLOAT,
    C6			   FLOAT,
	C7			   FLOAT,
	C8			   FLOAT,
	C9			   FLOAT,
	C10			   FLOAT,
	CO2				FLOAT,
	H2S				FLOAT,
	N2				FLOAT,
	Grados_API		FLOAT,
	Azufre			FLOAT,
	VolumenGas_15Grados	FLOAT,
	VolumenGas_20Grados	FLOAT,
	MMBTU_C1		FLOAT,
	MMBTU_C2		FLOAT,
	MMBTU_C3		FLOAT,
	MMBTU_IC4		FLOAT,
	MMBTU_NC4		FLOAT,
	--MMBTU_C5		FLOAT,
	MMBTU_IC5		FLOAT,
	MMBTU_NC5		FLOAT,
	MMBTU_C6		FLOAT,
	MMBTU_C7		FLOAT,
	MMBTU_C8		FLOAT,
	MMBTU_C9		FLOAT,
	MMBTU_C10		FLOAT,
	MMBTU_Total		FLOAT,
	Zmes			FLOAT,
	Bll_C5_Equiv	FLOAT,
	VolumenPetroleo_15	FLOAT,
	VolumenPetroleo_20	FLOAT,
	MMBTU_C1_20		FLOAT,
	MMBTU_C2_20		FLOAT,
	MMBTU_C3_20		FLOAT,
	MMBTU_IC4_20	FLOAT,
	MMBTU_NC4_20	FLOAT,
	MMBTU_C5_20		FLOAT,
	VolumenCondensado_15	FLOAT,
	VolumenCondensado_20	FLOAT,
	PresionParcial_C1	FLOAT,
	PresionParcial_C2	FLOAT,
	PresionParcial_C3	FLOAT,
	PresionParcial_nC4	FLOAT,
	PresionParcial_iC4	FLOAT,
	PresionParcial_nC5	FLOAT,
	PresionParcial_iC5	FLOAT,
	PresionParcial_C6Mas	FLOAT,
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
	LCi_C6		FLOAT,
	LCi_C7		FLOAT,
	LCi_C8		FLOAT,
	LCi_C9		FLOAT,
	LCi_C10		FLOAT,
	LCi_CO2		FLOAT,
	LCi_H2S		FLOAT,
	LCi_N2		FLOAT
)

CREATE TABLE #TipoHidrocarburo
(
	IdTipoHidrocarburo	INT,
	IdHidrocarburo		INT
)

DECLARE
	@FechaLimite DATETIME,
    @Año INT,
    @mes INT,
	@PromAPI			FLOAT = 0,
	@PromAzufre			FLOAT = 0,
	@UniMedidaBl		INT,
	@UniMedidaBTU		INT,
	@RegistrosActualizados	INT,
	@TotalVolumenPetroleo	FLOAT,
	@FactorConv15_20	FLOAT = 1.015394385,
	@Petroleo_15	FLOAT,
	@Gas_15		FLOAT,
	@Condensado_15	FLOAT,
	@ConstanteBll FLOAT = 42,
	@SumaValoresGPA	FLOAT,
	@Petroleo_20	FLOAT,
	@Gas_20		FLOAT,
	@Condensado_20	FLOAT,
	@60F_R         FLOAT = 519.67, -- 60 grados Fahrenheit a rankine
    @68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
	@PrecioPromPonCondensado	FLOAT

-- SE VALIDA QUE EL REPORTE SE ESTE GENERANDO DURANTE LOS PRIMEROS 10 DIAS HABILES DEL SIGUIENTE MES
INSERT INTO #DiasHabiles
(
	Fecha,
	Anio,
	Mes,
	Dia,
	NumDiaHabil
)
SELECT
	IdFecha,
	Anio,
	Mes,
	Dia,
	ROW_NUMBER() OVER (ORDER BY Dia) AS NumDiaHabil
FROM
	dbo.AP_Calendario
WHERE
	PrimerDiaMes  = DATEADD( MONTH, 1, @fechaMesDiaAnio )
	AND NombreDia NOT IN ( 'Sábado', 'Domingo' )
	AND DiaFeriado <> 1
ORDER BY
	Dia

SELECT
	@FechaLimite = DATEADD( MINUTE, 59, DATEADD( HOUR, 23, Fecha ))
FROM
	#DiasHabiles
WHERE
	NumDiaHabil = 10

--Calculo del volumen de crudo a vender basado en reparticion preliminar
SELECT	@UniMedidaBl = idUnidadMedida
FROM dbo.CO_UnidadMedida
WHERE	Abreviatura = 'BL'

SELECT	@UniMedidaBTU = idUnidadMedida
FROM dbo.CO_UnidadMedida
WHERE	Abreviatura = 'MMBTU'

INSERT INTO #CalculosGPA
(
	IdContrato,
	MesReporte,
	PuntoEntregaID,
	C1,
    C2,
    C3,
    IC4,
    NC4,
    IC5,
    NC5,
    C6,
	C7,
	C8,
	C9,
	C10,
	CO2,
	H2S,
	N2,
	Grados_API,
	Azufre,
	FechaIniPeriodo,
	VolumenGas_15Grados,
	VolumenPetroleo_15,
	VolumenCondensado_15
)
SELECT
	C.IdContrato,
	@fechaMesDiaAnio,
	PuntoEntregaID,
    ISNULL(CV.C1,0),
    ISNULL(CV.C2,0),
    ISNULL(CV.C3,0),
	ISNULL(CV.lC4,0),
    ISNULL(CV.nC4,0),
    ISNULL(CV.lC5,0),
    ISNULL(CV.nC5,0),
    ISNULL(CV.C6_plus,0),
	ISNULL(CV.C7,0),
	ISNULL(CV.C8,0),
	ISNULL(CV.C9,0),
	ISNULL(CV.C10,0),
    ISNULL(CV.MOL_CO2,0),
    ISNULL(CV.MOL_h2S,0),
    ISNULL(CV.MOL_N2,0),
	ISNULL(CV.GradosAPI,0),
	ISNULL(CV.Azufre,0),
	VPP.FechaInicio,
	ISNULL(VPP.VolumenGasMMPC,0),
	ISNULL(VPP.VolumenPetroleoPuntoMedicion,0),
	ISNULL(VPP.VolumenCondensadoPuntoMedicion,0)
FROM
    CO_Cromatografia             C
JOIN
    CO_CromatografiaValores      CV
    ON C.IdCromatografia     = CV.IdCromatografia
JOIN
    CO_PuntosdeEntregaContrato	 PEC
    ON C.IdContrato	=	PEC.idContrato
	AND CV.IdPuntoEntregaContrato = PEC.PuntoEntregaContratoID
JOIN
	PC_VolumenProduccionPeriodo	VPP
	ON	PEC.idContrato	=	VPP.IdContrato
	AND DATEFROMPARTS(C.Anio,C.Mes,1) = VPP.MesReporte
WHERE
    C.IdContrato                 = @Idcontrato
    AND C.Mes                  = MONTH( @fechaMesDiaAnio )
    AND C.Anio                      = YEAR( @fechaMesDiaAnio )
    AND PEC.PuntoEntregaID		= @puntoEntrega

SELECT	
	@Petroleo_20	=	SUM(CASE WHEN idHidrocarburo = 1001 THEN VolumenProgramado ELSE 0 END),
	@Gas_20	=	SUM(CASE WHEN idHidrocarburo = 1000 THEN VolumenProgramado ELSE 0 END),
	@Condensado_20	=	SUM(CASE WHEN idHidrocarburo = 1002 THEN VolumenProgramado ELSE 0 END)
FROM
	PR_ProduccionMensualSipac
WHERE
	idContrato        = @Idcontrato
    AND idFecha        = @fechaMesDiaAnio
	AND PuntoEntregaID = @puntoEntrega

-- SE CONVIERTEN LOS VOLUMENES A 20° SE ASUME QUE EL VOLUMEN INGRESADO EN EL FORMATO ESTA A 15
UPDATE #CalculosGPA
	SET
		VolumenGas_20Grados	=	VolumenGas_15Grados / (((15.56*1.8)+491.67)/@68F_R),
		VolumenPetroleo_20	=	VolumenPetroleo_15 / EXP( -(341.0957 / POWER( ((141.5 / (Grados_API + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (Grados_API + 131.5)) * 999.012), 2 )) * 8)),
		VolumenCondensado_20	=	ROUND(VolumenCondensado_15 / EXP( -(341.0957/POWER(((141.5/(0 + 131.5))*999.012),2)) * 8 * (1 + 0.8 * (341.0957/POWER(((141.5/(0 + 131.5))*999.012),2)) * 8)),4)


UPDATE	C
	SET
		PresionParcial_C1	= ROUND(GPA.Metano_C1 * (C.C1/100),6),
		PresionParcial_C2	= ROUND(GPA.Etano_C2 * (C.C2/100),6),
		PresionParcial_C3	= ROUND(GPA.Propano_C3 * (C.C3/100),6),
		PresionParcial_nC4	= ROUND(GPA.Butano_nC4 * (C.NC4/100),6),
		PresionParcial_iC4	= ROUND(GPA.Butano_iC4 * (C.IC4/100),6),
		PresionParcial_nC5	= ROUND(GPA.Pentano_nC5 * (C.NC5/100),6),
		PresionParcial_iC5	= ROUND(GPA.Pentano_iC5 * (C.IC5/100),6),
		PresionParcial_C6Mas	= ROUND(GPA.Hexano_C6 * (C.C6/100),6),
		PresionParcial_C7	= ROUND(GPA.Heptano_C7 * (C.C7/100),6),
		PresionParcial_C8	= ROUND(GPA.Octano_C8 * (C.C8/100),6),
		PresionParcial_C9	= ROUND(GPA.Nonano_C9 * (C.C9/100),6),
		PresionParcial_C10	= ROUND(GPA.Decano_C10 * (C.C10/100),6),
		PresionParcial_CO2	= ROUND(GPA.CO2 * (C.CO2/100),6),
		PresionParcial_H2S	= ROUND(GPA.H2S * (C.H2S/100),6),
		PresionParcial_N2	= ROUND(GPA.Nitrogeno_N2 * (C.N2/100),6)
FROM
	#CalculosGPA	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	5	-- bi Presión Base
	AND	@fechaMesDiaAnio	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia

UPDATE #CalculosGPA
	SET Zmes = ROUND(1 - 14.696  * POWER(PresionParcial_C1 + PresionParcial_C2 + PresionParcial_C3 + PresionParcial_nC4 +
									PresionParcial_iC4 + PresionParcial_nC5 + PresionParcial_iC5 + PresionParcial_C6Mas +
									PresionParcial_C7 + PresionParcial_C8 + PresionParcial_C9 + PresionParcial_C10 +
									PresionParcial_CO2 + PresionParcial_H2S + PresionParcial_N2, 2),6)

UPDATE C
	SET
	LCid_C1		=	ROUND((C.C1/100) * 1000 * (1/GPA.Metano_C1) * (14.696/14.696),6),
	LCid_C2		=	ROUND((C.C2/100) * 1000 * (1/GPA.Etano_C2)* (14.696/14.696),6),
	LCid_C3		=	ROUND((C.C3/100) * 1000 * (1/GPA.Propano_C3)* (14.696/14.696),6),
	LCid_nC4	=	ROUND((C.NC4/100) * 1000 * (1/GPA.Butano_nC4)* (14.696/14.696),6),
	LCid_iC4	=	ROUND((C.IC4/100) * 1000 * (1/GPA.Butano_iC4)* (14.696/14.696),6),
	LCid_nC5	=	ROUND((C.NC5/100) * 1000 * (1/GPA.Pentano_nC5)* (14.696/14.696),6),
	LCid_iC5	=	ROUND((C.IC5/100) * 1000 * (1/GPA.Pentano_iC5)* (14.696/14.696),6),
	LCid_C6		=	ROUND((C.C6/100) * 1000 * (1/GPA.Hexano_C6)* (14.696/14.696),6),
	LCid_C7		=	ROUND((C.C7/100) * 1000 * (1/GPA.Heptano_C7)* (14.696/14.696),6),
	LCid_C8		=	ROUND((C.C8/100) * 1000 * (1/GPA.Octano_C8)* (14.696/14.696),6),
	LCid_C9		=	ROUND((C.C9/100) * 1000 * (1/GPA.Nonano_C9)* (14.696/14.696),6),
	LCid_C10	=	ROUND((C.C10/100) * 1000 * (1/GPA.Decano_C10)* (14.696/14.696),6),
	LCid_CO2	=	ROUND((C.CO2/100) * 1000 * (1/GPA.CO2)* (14.696/14.696),6),
	LCid_H2S	=	ROUND((C.H2S/100) * 1000 * (1/GPA.H2S)* (14.696/14.696),6),
	LCid_N2		=	ROUND((C.N2/100) * 1000 * (1/GPA.Nitrogeno_N2)* (14.696/14.696),6)
FROM
	#CalculosGPA	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	4	-- ft3 ideal gas/gal liquid
	AND	@fechaMesDiaAnio	BETWEEN IdFecIniVigencia AND FecFinVigencia

UPDATE #CalculosGPA
	SET
		LCi_C1		= ROUND(LCid_C1 / Zmes,6),
		LCi_C2		= ROUND(LCid_C2 / Zmes,6),
		LCi_C3		= ROUND(LCid_C3 / Zmes,6),
		LCi_nC4		= ROUND(LCid_nC4 / Zmes,6),
		LCi_iC4		= ROUND(LCid_iC4 / Zmes,6),
		LCi_nC5		= ROUND(LCid_nC5 / Zmes,6),
		LCi_iC5		= ROUND(LCid_iC5 / Zmes,6),
		LCi_C6		= ROUND(LCid_C6 / Zmes,6),
		LCi_C7		= ROUND(LCid_C7 / Zmes,6),
		LCi_C8		= ROUND(LCid_C8 / Zmes,6),
		LCi_C9		= ROUND(LCid_C9 / Zmes,6),
		LCi_C10		= ROUND(LCid_C10 / Zmes,6),
		LCi_CO2		= ROUND(LCid_CO2 / Zmes,6),
		LCi_H2S		= ROUND(LCid_H2S / Zmes,6),
		LCi_N2		= ROUND(LCid_N2 / Zmes,6)

UPDATE	C
	SET
		MMBTU_C1	=	ROUND((GPA.Metano_C1 * ((VolumenGas_15Grados*1000000) * (C.C1 / 100)))/1000000,0),
		MMBTU_C2	=	ROUND((GPA.Etano_C2 * ((VolumenGas_15Grados*1000000) * (C.C2 / 100)))/1000000,0),
		MMBTU_C3	=	ROUND((GPA.Propano_C3 * ((VolumenGas_15Grados*1000000) * (C.C3 / 100)))/1000000,0),
		MMBTU_IC4	=	ROUND((GPA.Butano_iC4 * ((VolumenGas_15Grados*1000000) * (C.IC4 / 100)))/1000000,0),
		MMBTU_NC4	=	ROUND((GPA.Butano_nC4 * ((VolumenGas_15Grados*1000000) * (C.NC4 / 100)))/1000000,0),
		MMBTU_IC5	=	ROUND((GPA.Pentano_iC5 * ((VolumenGas_15Grados*1000000) * (C.IC5 / 100)))/1000000,0),
		MMBTU_NC5	=	ROUND((GPA.Pentano_nC5 * ((VolumenGas_15Grados*1000000) * (C.NC5 / 100)))/1000000,0),
		MMBTU_C6	=	ROUND((GPA.Hexano_C6 * ((VolumenGas_15Grados*1000000) * (C.C6 / 100)))/1000000,0),
		MMBTU_C7	=	ROUND((GPA.Heptano_C7 * ((VolumenGas_15Grados*1000000) * (C.C7 / 100)))/1000000,0),
		MMBTU_C8	=	ROUND((GPA.Octano_C8 * ((VolumenGas_15Grados*1000000) * (C.C8 / 100)))/1000000,0),
		MMBTU_C9	=	ROUND((GPA.Nonano_C9 * ((VolumenGas_15Grados*1000000) * (C.C9 / 100)))/1000000,0),
		MMBTU_C10	=	ROUND((GPA.Decano_C10 * ((VolumenGas_15Grados*1000000) * (C.C10 / 100)))/1000000,0)
FROM
	#CalculosGPA	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	2
	AND	@fechaMesDiaAnio	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia

UPDATE	#CalculosGPA
	SET	Bll_C5_Equiv	=	ROUND((VolumenGas_15Grados * 1000 * LCi_nC5)/@ConstanteBll,3) + ROUND((VolumenGas_15Grados * 1000 * LCi_iC5)/@ConstanteBll,3) +
							ROUND((VolumenGas_15Grados * 1000 * LCi_C6)/@ConstanteBll,3) + ROUND((VolumenGas_15Grados * 1000 * LCi_C7)/@ConstanteBll,3) +
							ROUND((VolumenGas_15Grados * 1000 * LCi_C8)/@ConstanteBll,3) + ROUND((VolumenGas_15Grados * 1000 * LCi_C9)/@ConstanteBll,3) +
							ROUND((VolumenGas_15Grados * 1000 * LCi_C10)/@ConstanteBll,3),
		MMBTU_Total = MMBTU_C1 + MMBTU_C2 + MMBTU_C3 + MMBTU_IC4 + MMBTU_NC4 + MMBTU_IC5 + MMBTU_NC5 + MMBTU_C6 + MMBTU_C7 + MMBTU_C8 + MMBTU_C9 + MMBTU_C10

		
UPDATE #CalculosGPA
	SET
		MMBTU_C1_20 =	ROUND(MMBTU_C1,0) * @FactorConv15_20,
		MMBTU_C2_20	=	ROUND(MMBTU_C2,0) * @FactorConv15_20,
		MMBTU_C3_20	=	ROUND(MMBTU_C3,0) * @FactorConv15_20,
		MMBTU_IC4_20 =	ROUND(MMBTU_IC4,0) * @FactorConv15_20,
		MMBTU_NC4_20	=	ROUND(MMBTU_NC4,0) * @FactorConv15_20,
		MMBTU_C5_20	=	(ROUND(MMBTU_IC5,0) * @FactorConv15_20) + (ROUND(MMBTU_NC5,0) * @FactorConv15_20)


IF @Debug = 1
BEGIN
	SELECT
		*
	FROM
		#CalculosGPA	C
	JOIN
		PC_VolumenProduccionPeriodo	VPP
		ON	C.IdContrato	=	VPP.IdContrato
		AND	C.MesReporte	=	VPP.MesReporte
		AND	C.FechaIniPeriodo	=	VPP.FechaInicio
END

IF @FechaLimite >= GETDATE()
BEGIN
	-- SE ACTUALIZAN LOS DATOS DE LA ENERGIA EN LA TABLA DE PERIODOS
	UPDATE	VPP
		SET
			MetanoC1	=	ROUND(MMBTU_C1,0),
			EtanoC2		=	ROUND(MMBTU_C2,0),
			PropanoC3	=	ROUND(MMBTU_C3,0),
			ButanoC4	=	ROUND(MMBTU_IC4,0) + ROUND(MMBTU_NC4,0),
			VolumenCondensadoPuntoMedicion = ISNULL(C.Bll_C5_Equiv,0)			
	FROM
		#CalculosGPA	C
	JOIN
		PC_VolumenProduccionPeriodo	VPP
		ON	C.IdContrato	=	VPP.IdContrato
		AND	C.MesReporte	=	VPP.MesReporte
		AND	C.FechaIniPeriodo	=	VPP.FechaInicio
END

--************************************************************************************************
END

