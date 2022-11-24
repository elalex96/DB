CREATE PROCEDURE dbo.SP_CO_SipacProduccionCalcular_V2
    @Idcontrato      INT,
    @fechaMesDiaAnio DATE,
    @puntoEntrega    INT,
	@Usuario	INT = 1
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
	ImporteGas		FLOAT,
	ImportePetroleo	FLOAT,
	ImporteCondensado	FLOAT,
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
	Precio_C1		FLOAT,
	Precio_C2		FLOAT,
	Precio_C3		FLOAT,
	Precio_C4		FLOAT,
	Precio_C5Mas	FLOAT,
	Precio_Petroleo	FLOAT,
	Precio_Gas		FLOAT,
	Precio_Condensado	FLOAT,
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
	LCi_N2		FLOAT,
	SumaMMBTUs	FLOAT,
-- VALORES GPA *  MMBTU
	GPA_MMBTU_C1	FLOAT,
	GPA_MMBTU_C2	FLOAT,
	GPA_MMBTU_C3	FLOAT,
	GPA_MMBTU_NC4	FLOAT,
	GPA_MMBTU_IC4	FLOAT,
	GPA_MMBTU_NC5	FLOAT,
	GPA_MMBTU_IC5	FLOAT,
	GPA_MMBTU_C6	FLOAT,
	GPA_MMBTU_C7	FLOAT,
	GPA_MMBTU_C8	FLOAT,
	GPA_MMBTU_C9	FLOAT,
	GPA_MMBTU_C10	FLOAT,
	SUMA_GPA_MMBTU	FLOAT,
	ftXCroma_C1		FLOAT,
	ftXCroma_C2		FLOAT,
	ftXCroma_C3		FLOAT,
	ftXCroma_IC4		FLOAT,
	ftXCroma_nC4		FLOAT,
	ftXCroma_iC5		FLOAT,
	ftXCroma_nC5		FLOAT,
	ftXCroma_C6		FLOAT,
	ftXCroma_C7		FLOAT,
	ftXCroma_C8		FLOAT,
	ftXCroma_C9		FLOAT,
	ftXCroma_C10		FLOAT,
	BDxBP		FLOAT,
	SUM_AR_BC	FLOAT,
--- CALCULOS PARA GAS BN
	VolumenGasBN_15Grados	FLOAT,
	VolumenGasBN_20Grados	FLOAT,
	BN_MMBTU_C1		FLOAT,
	BN_MMBTU_C2		FLOAT,
	BN_MMBTU_C3		FLOAT,
	BN_MMBTU_IC4		FLOAT,
	BN_MMBTU_NC4		FLOAT,
	BN_MMBTU_IC5		FLOAT,
	BN_MMBTU_NC5		FLOAT,
	BN_MMBTU_C6		FLOAT,
	BN_MMBTU_C7		FLOAT,
	BN_MMBTU_C8		FLOAT,
	BN_MMBTU_C9		FLOAT,
	BN_MMBTU_C10		FLOAT,
	BN_MMBTU_C1_20		FLOAT,
	BN_MMBTU_C2_20		FLOAT,
	BN_MMBTU_C3_20		FLOAT,
	BN_MMBTU_IC4_20	FLOAT,
	BN_MMBTU_NC4_20	FLOAT,
	BN_MMBTU_C5_20		FLOAT,
	BN_Bll_C5_Equiv	FLOAT
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
	@ConstanteBll FLOAT = 42.00,
	@SumaValoresGPA	FLOAT,
	@Petroleo_20	FLOAT,
	@Gas_20		FLOAT,
	@Condensado_20	FLOAT,
	@60F_R         FLOAT = 519.67, -- 60 grados Fahrenheit a rankine
    @68F_R         FLOAT = 527.67, --68  grados Fahrenheit a rankine
	@PrecioPromPonCondensado	FLOAT,
	@GasBN_20	FLOAT,
	@PetroleoVTA_20	FLOAT,
	@GasVTA_20	FLOAT,
	@CondensadoVTA_20	FLOAT,
	@VTA_PrecioPromPonCondensado	FLOAT,
	@Mil FLOAT = 1000,
	@Cien	FLOAT = 100

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
	ImporteGas,
	ImportePetroleo,
	ImporteCondensado
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
    ISNULL(CV.PrecioGas,0),
	ISNULL(CV.PrecioPetroleo,0),
	ISNULL(CV.PrecioCondensado,0)
FROM
    CO_Cromatografia             C
JOIN
    CO_CromatografiaValores      CV
    ON C.IdCromatografia     = CV.IdCromatografia
JOIN
    CO_PuntosdeEntregaContrato	 PEC
    ON C.IdContrato	=	PEC.idContrato
	AND CV.IdPuntoEntregaContrato = PEC.PuntoEntregaContratoID
WHERE
    C.IdContrato                 = @Idcontrato
    AND C.Mes                  = MONTH( @fechaMesDiaAnio )
    AND C.Anio                      = YEAR( @fechaMesDiaAnio )
    AND PEC.PuntoEntregaID		= @puntoEntrega

SELECT	
	@Petroleo_20	=	SUM(CASE WHEN idHidrocarburo = 1001 THEN VolumenProgramado ELSE 0 END),
	@Gas_20	=	SUM(CASE WHEN idHidrocarburo = 1000 THEN VolumenProgramado ELSE 0 END),
	@Condensado_20	=	SUM(CASE WHEN idHidrocarburo = 1002 THEN VolumenProgramado ELSE 0 END),
	@GasBN_20	=	SUM(CASE WHEN idHidrocarburo = 1003 THEN VolumenProgramado ELSE 0 END)
FROM
	PR_ProduccionMensualSipac
WHERE
	idContrato        = @Idcontrato
    AND idFecha        = @fechaMesDiaAnio
	AND PuntoEntregaID = @puntoEntrega

--UPDATE #CalculosGPA
--	SET	PrecioUnitario_Petroleo	=	CASE WHEN @Petroleo_20 = 0 THEN 0 ELSE ImportePetroleo / @Petroleo_20 END,
--		PrecioUnitario_Gas	=	CASE WHEN @Gas_20 = 0 THEN 0 ELSE (ImporteGas / @Gas_20)/1000 END,
--		PrecioUnitario_Condensado = CASE WHEN @Condensado_20 = 0 THEN 0 ELSE ImporteCondensado / @Condensado_20 END

IF 0 = (SELECT ISNULL(IsConsorcio,1) FROM CO_CONTRATO WHERE IdContrato = @Idcontrato) AND (SELECT ISNULL(IdTipoContrato,3) FROM CO_CONTRATO WHERE IdContrato = @Idcontrato) <> 2
BEGIN

	UPDATE #CalculosGPA
		SET
			--VolumenGas_15Grados	=	@Gas_20 * (@60F_R / @68F_R),
			VolumenGas_15Grados	=	@Gas_20 * (((15.56*1.8)+491.67)/@68F_R),
			VolumenPetroleo_15	=	@Petroleo_20 * EXP( -(341.0957 / POWER( ((141.5 / (Grados_API + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (Grados_API + 131.5)) * 999.012), 2 )) * 8)),
			VolumenGas_20Grados =	@Gas_20,
			VolumenPetroleo_20	=	@Petroleo_20,
			VolumenCondensado_15	=	ROUND(@Condensado_20 * EXP( -(341.0957/POWER(((141.5/(0 + 131.5))*999.012),2)) * 8 * (1 + 0.8 * (341.0957/POWER(((141.5/(0 + 131.5))*999.012),2)) * 8)),4),
			VolumenCondensado_20	=	@Condensado_20,
			VolumenGasBN_15Grados	=	@GasBN_20 * (((15.56*1.8)+491.67)/@68F_R)
END
ELSE
BEGIN
-- SI ES CONSORCIO, LOS VOLUMENES INGRESADOS EN EL FORMATOS ESTAN YA A 15°, POR QUE SE REALIZA LA CPNVERSION INVERSA: DE 15 A 20

	UPDATE #CalculosGPA
		SET
			VolumenGas_15Grados	=	@Gas_20,
			VolumenPetroleo_15	=	@Petroleo_20,
			VolumenCondensado_15	= @Condensado_20,
			VolumenGasBN_15Grados	= @GasBN_20,
			VolumenGas_20Grados	=	@Gas_20 / (((15.56*1.8)+491.67)/@68F_R),
			VolumenPetroleo_20	=	@Petroleo_20 / EXP( -(341.0957 / POWER( ((141.5 / (Grados_API + 131.5)) * 999.012), 2 )) * 8 * (1 + 0.8 * (341.0957 / POWER( ((141.5 / (Grados_API + 131.5)) * 999.012), 2 )) * 8)),
			VolumenCondensado_20	=	ROUND(@Condensado_20 / EXP( -(341.0957/POWER(((141.5/(0 + 131.5))*999.012),2)) * 8 * (1 + 0.8 * (341.0957/POWER(((141.5/(0 + 131.5))*999.012),2)) * 8)),4),
			VolumenGasBN_20Grados	=	@GasBN_20 / (((15.56*1.8)+491.67)/@68F_R)
END

SELECT
	@TotalVolumenPetroleo	=	SUM(VolumenProgramado)
FROM
    PR_ProduccionMensualSipac
WHERE
    idContrato        = @Idcontrato
    AND idFecha        = @fechaMesDiaAnio
    AND idHidrocarburo = 1001

IF @TotalVolumenPetroleo > 0
BEGIN
	SELECT
		@PromAPI = CASE WHEN @TotalVolumenPetroleo = 0 THEN 0 ELSE SUM((ISNULL(CV.GradosAPI,0) * P.VolumenProgramado)/@TotalVolumenPetroleo) END,
		@PromAzufre	= CASE WHEN @TotalVolumenPetroleo = 0 THEN 0 ELSE SUM((ISNULL(CV.Azufre,0) * P.VolumenProgramado)/@TotalVolumenPetroleo) END
	FROM
		PR_ProduccionMensualSipac	P
	JOIN
		CO_Cromatografia             C
		ON	P.idContrato	=	C.IdContrato
		AND YEAR( P.idFecha )	=	C.Anio
		AND MONTH( P.idFecha )	=	C.Mes
	JOIN
		CO_CromatografiaValores      CV
		ON C.IdCromatografia         = CV.IdCromatografia
	JOIN
		CO_PuntosdeEntregaContrato	 PEC
		ON	C.IdContrato		=	PEC.idContrato
		AND CV.IdPuntoEntregaContrato = PEC.PuntoEntregaContratoID
	WHERE
		P.IdContrato                 = @Idcontrato
		AND P.idFecha                = @fechaMesDiaAnio
		AND P.idHidrocarburo = 1001
END

UPDATE	C
	SET
		PresionParcial_C1	= ROUND(GPA.Metano_C1 * (C.C1/@Cien),6),
		PresionParcial_C2	= ROUND(GPA.Etano_C2 * (C.C2/@Cien),6),
		PresionParcial_C3	= ROUND(GPA.Propano_C3 * (C.C3/@Cien),6),
		PresionParcial_nC4	= ROUND(GPA.Butano_nC4 * (C.NC4/@Cien),6),
		PresionParcial_iC4	= ROUND(GPA.Butano_iC4 * (C.IC4/@Cien),6),
		PresionParcial_nC5	= ROUND(GPA.Pentano_nC5 * (C.NC5/@Cien),6),
		PresionParcial_iC5	= ROUND(GPA.Pentano_iC5 * (C.IC5/@Cien),6),
		PresionParcial_C6Mas	= ROUND(GPA.Hexano_C6 * (C.C6/@Cien),6),
		PresionParcial_C7	= ROUND(GPA.Heptano_C7 * (C.C7/@Cien),6),
		PresionParcial_C8	= ROUND(GPA.Octano_C8 * (C.C8/@Cien),6),
		PresionParcial_C9	= ROUND(GPA.Nonano_C9 * (C.C9/@Cien),6),
		PresionParcial_C10	= ROUND(GPA.Decano_C10 * (C.C10/@Cien),6),
		PresionParcial_CO2	= ROUND(GPA.CO2 * (C.CO2/@Cien),6),
		PresionParcial_H2S	= ROUND(GPA.H2S * (C.H2S/@Cien),6),
		PresionParcial_N2	= ROUND(GPA.Nitrogeno_N2 * (C.N2/@Cien),6)
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
	LCid_C1		=	ROUND((C.C1/@Cien) * @Mil * (1/GPA.Metano_C1) * (14.696/14.696),6),
	LCid_C2		=	ROUND((C.C2/@Cien) * @Mil * (1/GPA.Etano_C2)* (14.696/14.696),6),
	LCid_C3		=	ROUND((C.C3/@Cien) * @Mil * (1/GPA.Propano_C3)* (14.696/14.696),6),
	LCid_nC4	=	ROUND((C.NC4/@Cien) * @Mil * (1/GPA.Butano_nC4)* (14.696/14.696),6),
	LCid_iC4	=	ROUND((C.IC4/@Cien) * @Mil * (1/GPA.Butano_iC4)* (14.696/14.696),6),
	LCid_nC5	=	ROUND((C.NC5/@Cien) * @Mil * (1/GPA.Pentano_nC5)* (14.696/14.696),6),
	LCid_iC5	=	ROUND((C.IC5/@Cien) * @Mil * (1/GPA.Pentano_iC5)* (14.696/14.696),6),
	LCid_C6		=	ROUND((C.C6/@Cien) * @Mil * (1/GPA.Hexano_C6)* (14.696/14.696),6),
	LCid_C7		=	ROUND((C.C7/@Cien) * @Mil * (1/GPA.Heptano_C7)* (14.696/14.696),6),
	LCid_C8		=	ROUND((C.C8/@Cien) * @Mil * (1/GPA.Octano_C8)* (14.696/14.696),6),
	LCid_C9		=	ROUND((C.C9/@Cien) * @Mil * (1/GPA.Nonano_C9)* (14.696/14.696),6),
	LCid_C10	=	ROUND((C.C10/@Cien) * @Mil * (1/GPA.Decano_C10)* (14.696/14.696),6),
	LCid_CO2	=	ROUND((C.CO2/@Cien) * @Mil * (1/GPA.CO2)* (14.696/14.696),6),
	LCid_H2S	=	ROUND((C.H2S/@Cien) * @Mil * (1/GPA.H2S)* (14.696/14.696),6),
	LCid_N2		=	ROUND((C.N2/@Cien) * @Mil * (1/GPA.Nitrogeno_N2)* (14.696/14.696),6)
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
		MMBTU_C1	=	ROUND((GPA.Metano_C1 * ((VolumenGas_15Grados*1000000) * (C.C1 / @Cien)))/1000000,0),
		MMBTU_C2	=	ROUND((GPA.Etano_C2 * ((VolumenGas_15Grados*1000000) * (C.C2 / @Cien)))/1000000,0),
		MMBTU_C3	=	ROUND((GPA.Propano_C3 * ((VolumenGas_15Grados*1000000) * (C.C3 / @Cien)))/1000000,0),
		MMBTU_IC4	=	ROUND((GPA.Butano_iC4 * ((VolumenGas_15Grados*1000000) * (C.IC4 / @Cien)))/1000000,0),
		MMBTU_NC4	=	ROUND((GPA.Butano_nC4 * ((VolumenGas_15Grados*1000000) * (C.NC4 / @Cien)))/1000000,0),
		MMBTU_IC5	=	ROUND((GPA.Pentano_iC5 * ((VolumenGas_15Grados*1000000) * (C.IC5 / @Cien)))/1000000,0),
		MMBTU_NC5	=	ROUND((GPA.Pentano_nC5 * ((VolumenGas_15Grados*1000000) * (C.NC5 / @Cien)))/1000000,0),
		MMBTU_C6	=	ROUND((GPA.Hexano_C6 * ((VolumenGas_15Grados*1000000) * (C.C6 / @Cien)))/1000000,0),
		MMBTU_C7	=	ROUND((GPA.Heptano_C7 * ((VolumenGas_15Grados*1000000) * (C.C7 / @Cien)))/1000000,0),
		MMBTU_C8	=	ROUND((GPA.Octano_C8 * ((VolumenGas_15Grados*1000000) * (C.C8 / @Cien)))/1000000,0),
		MMBTU_C9	=	ROUND((GPA.Nonano_C9 * ((VolumenGas_15Grados*1000000) * (C.C9 / @Cien)))/1000000,0),
		MMBTU_C10	=	ROUND((GPA.Decano_C10 * ((VolumenGas_15Grados*1000000) * (C.C10 / @Cien)))/1000000,0),
-- CALCULO DE LOS BTUS DEL GAS BN
		BN_MMBTU_C1	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Metano_C1 * ((VolumenGasBN_15Grados*1000000) * (C.C1 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_C2	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Etano_C2 * ((VolumenGasBN_15Grados*1000000) * (C.C2 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_C3	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Propano_C3 * ((VolumenGasBN_15Grados*1000000) * (C.C3 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_IC4	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Butano_iC4 * ((VolumenGasBN_15Grados*1000000) * (C.IC4 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_NC4	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Butano_nC4 * ((VolumenGasBN_15Grados*1000000) * (C.NC4 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_IC5	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Pentano_iC5 * ((VolumenGasBN_15Grados*1000000) * (C.IC5 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_NC5	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Pentano_nC5 * ((VolumenGasBN_15Grados*1000000) * (C.NC5 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_C6	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Hexano_C6 * ((VolumenGasBN_15Grados*1000000) * (C.C6 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_C7	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Heptano_C7 * ((VolumenGasBN_15Grados*1000000) * (C.C7 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_C8	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Octano_C8 * ((VolumenGasBN_15Grados*1000000) * (C.C8 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_C9	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Nonano_C9 * ((VolumenGasBN_15Grados*1000000) * (C.C9 / @Cien)))/1000000,0) ELSE 0 END,
		BN_MMBTU_C10	=	CASE WHEN ISNULL(VolumenGasBN_15Grados,0) > 0 THEN ROUND((GPA.Decano_C10 * ((VolumenGasBN_15Grados*1000000) * (C.C10 / @Cien)))/1000000,0) ELSE 0 END
FROM
	#CalculosGPA	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	2
	AND	@fechaMesDiaAnio	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia

UPDATE	#CalculosGPA
	--SET	Bll_C5_Equiv	=	ROUND((VolumenGas_15Grados * 1000 * LCi_nC5)/@ConstanteBll,3) + ROUND((VolumenGas_15Grados * 1000 * LCi_iC5)/@ConstanteBll,3) +
	--						ROUND((VolumenGas_15Grados * 1000 * LCi_C6)/@ConstanteBll,3) + ROUND((VolumenGas_15Grados * 1000 * LCi_C7)/@ConstanteBll,3) +
	--						ROUND((VolumenGas_15Grados * 1000 * LCi_C8)/@ConstanteBll,3) + ROUND((VolumenGas_15Grados * 1000 * LCi_C9)/@ConstanteBll,3) +
	--						ROUND((VolumenGas_15Grados * 1000 * LCi_C10)/@ConstanteBll,3),
	SET	Bll_C5_Equiv	=	ROUND((VolumenGas_15Grados * @Mil * LCi_nC5)/@ConstanteBll,0) + ROUND((VolumenGas_15Grados * @Mil * LCi_iC5)/@ConstanteBll,0) +
							ROUND((VolumenGas_15Grados * @Mil * LCi_C6)/@ConstanteBll,0) + ROUND((VolumenGas_15Grados * @Mil * LCi_C7)/@ConstanteBll,0) +
							ROUND((VolumenGas_15Grados * @Mil * LCi_C8)/@ConstanteBll,0) + ROUND((VolumenGas_15Grados * @Mil * LCi_C9)/@ConstanteBll,0) +
							ROUND((VolumenGas_15Grados * @Mil * LCi_C10)/@ConstanteBll,0),
	-- BN
		BN_Bll_C5_Equiv	=	ROUND((VolumenGasBN_15Grados * @Mil * LCi_nC5)/@ConstanteBll,3) + ROUND((VolumenGasBN_15Grados * @Mil * LCi_iC5)/@ConstanteBll,3) +
							ROUND((VolumenGasBN_15Grados * @Mil * LCi_C6)/@ConstanteBll,3) + ROUND((VolumenGasBN_15Grados * @Mil * LCi_C7)/@ConstanteBll,3) +
							ROUND((VolumenGasBN_15Grados * @Mil * LCi_C8)/@ConstanteBll,3) + ROUND((VolumenGasBN_15Grados * @Mil * LCi_C9)/@ConstanteBll,3) +
							ROUND((VolumenGasBN_15Grados * @Mil * LCi_C10)/@ConstanteBll,3),
		SumaMMBTUs		=	ROUND(MMBTU_C1,0) + ROUND(MMBTU_C2,0) + ROUND(MMBTU_C3,0) + ROUND(MMBTU_NC4,0) + ROUND(MMBTU_IC4,0) +
							ROUND(MMBTU_NC5,0) + ROUND(MMBTU_IC5,0) + ROUND(MMBTU_C6,0) + ROUND(MMBTU_C7,0) + ROUND(MMBTU_C8,0) + ROUND(MMBTU_C9,0) + ROUND(MMBTU_C10,0)

SELECT
	@SumaValoresGPA	=	Metano_C1+ Etano_C2+ Propano_C3+ Butano_iC4 + Butano_nC4 + Pentano_iC5 + Pentano_nC5 + Hexano_C6 + Heptano_C7 + Octano_C8 + Nonano_C9 + Decano_C10
FROM
	SCOC_ValoresEstandaresGPA_2145	
WHERE
	IdComponente	=	2
	AND	@fechaMesDiaAnio	BETWEEN IdFecIniVigencia AND FecFinVigencia


UPDATE C
	SET
		GPA_MMBTU_C1	=	GPA.Metano_C1 * ROUND(C.MMBTU_C1,0),
		GPA_MMBTU_C2	=	GPA.Etano_C2 * ROUND(C.MMBTU_C2,0),
		GPA_MMBTU_C3	=	GPA.Propano_C3 * ROUND(C.MMBTU_C3,0),
		GPA_MMBTU_NC4	=	GPA.Butano_nC4 * ROUND(C.MMBTU_NC4,0),
		GPA_MMBTU_IC4	=	GPA.Butano_iC4 * ROUND(C.MMBTU_IC4,0),
		GPA_MMBTU_NC5	=	GPA.Pentano_nC5 * ROUND(C.MMBTU_NC5,0),
		GPA_MMBTU_IC5	=	GPA.Pentano_iC5 * ROUND(C.MMBTU_IC5,0),
		GPA_MMBTU_C6	=	GPA.Hexano_C6 * ROUND(C.MMBTU_C6,0),
		GPA_MMBTU_C7	=	GPA.Heptano_C7 * ROUND(MMBTU_C7,0),
		GPA_MMBTU_C8	=	GPA.Octano_C8 * ROUND(MMBTU_C8,0),
		GPA_MMBTU_C9	=	GPA.Nonano_C9 *ROUND(MMBTU_C9,0),
		GPA_MMBTU_C10	=	GPA.Decano_C10 * ROUND(MMBTU_C10,0),
		ftXCroma_C1		=	GPA.Metano_C1 * ((VolumenGas_15Grados*1000000) * (C.C1/100)),
		ftXCroma_C2		=	GPA.Etano_C2 * ((VolumenGas_15Grados*1000000) * (C.C2/100)),
		ftXCroma_C3		=	GPA.Propano_C3 * ((VolumenGas_15Grados*1000000) * (C.C3/100)),
		ftXCroma_IC4	=	GPA.Butano_iC4 * ((VolumenGas_15Grados*1000000) * (C.IC4/100)),
		ftXCroma_nC4	=	GPA.Butano_nC4 * ((VolumenGas_15Grados*1000000) * (C.NC4/100)),
		ftXCroma_iC5	=	GPA.Pentano_iC5 * ((VolumenGas_15Grados*1000000) * (C.IC5/100)),
		ftXCroma_nC5	=	GPA.Pentano_nC5 * ((VolumenGas_15Grados*1000000) * (C.NC5/100)),
		ftXCroma_C6		=	GPA.Hexano_C6 * ((VolumenGas_15Grados*1000000) * (C.C6/100)),
		ftXCroma_C7		=	GPA.Heptano_C7 * (VolumenGas_15Grados*1000000) * (C.C7/100),
		ftXCroma_C8		=	GPA.Octano_C8 * (VolumenGas_15Grados*1000000) * (C.C8/100),
		ftXCroma_C9		=	GPA.Nonano_C9 * (VolumenGas_15Grados*1000000) * (C.C9/100),
		ftXCroma_C10	=	GPA.Decano_C10 * (VolumenGas_15Grados*1000000) * (C.C10/100),
		BDxBP			=	CASE WHEN SumaMMBTUs = 0 THEN 0
							ELSE 
						((ROUND(C.MMBTU_C1,0)/SumaMMBTUs)* (GPA.Metano_C1/@SumaValoresGPA)) + ((ROUND(C.MMBTU_C2,0)/SumaMMBTUs)* (GPA.Etano_C2/@SumaValoresGPA)) +
						((ROUND(C.MMBTU_C3,0)/SumaMMBTUs)* (GPA.Propano_C3/@SumaValoresGPA)) + ((ROUND(C.MMBTU_NC4,0)/SumaMMBTUs)* (GPA.Butano_nC4/@SumaValoresGPA)) +
						((ROUND(C.MMBTU_IC4,0)/SumaMMBTUs)* (GPA.Butano_iC4/@SumaValoresGPA)) + ((ROUND(C.MMBTU_NC5,0)/SumaMMBTUs)* (GPA.Pentano_nC5/@SumaValoresGPA)) +
						((ROUND(C.MMBTU_IC5,0)/SumaMMBTUs)* (GPA.Pentano_iC5/@SumaValoresGPA)) + ((ROUND(C.MMBTU_C6,0)/SumaMMBTUs)* (GPA.Hexano_C6/@SumaValoresGPA)) +
						((ROUND(C.MMBTU_C7,0)/SumaMMBTUs)* (GPA.Heptano_C7/@SumaValoresGPA)) + ((ROUND(C.MMBTU_C8,0)/SumaMMBTUs)* (GPA.Octano_C8/@SumaValoresGPA)) +
						((ROUND(C.MMBTU_C9,0)/SumaMMBTUs)* (GPA.Nonano_C9/@SumaValoresGPA)) + ((ROUND(C.MMBTU_C10,0)/SumaMMBTUs)* (GPA.Decano_C10/@SumaValoresGPA)) 
						END
FROM
	#CalculosGPA	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	2
	AND	@fechaMesDiaAnio	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia



UPDATE	#CalculosGPA
	SET SUM_AR_BC = ROUND((( ROUND(ftXCroma_C1,0) + ROUND(ftXCroma_C2,0) + ROUND(ftXCroma_C3,0) + ROUND(ftXCroma_IC4,0) + ROUND(ftXCroma_NC4,0) + ROUND(ftXCroma_IC5,0) +
						 ROUND(ftXCroma_NC5,0) + ROUND(ftXCroma_C6,0) + ROUND(ftXCroma_C7,0) + ROUND(ftXCroma_C8,0) + ROUND(ftXCroma_C9,0) + ROUND(ftXCroma_C10,0))/1000000),0)

UPDATE	#CalculosGPA
		SET SUMA_GPA_MMBTU = GPA_MMBTU_C1 + GPA_MMBTU_C2 + GPA_MMBTU_C3 + GPA_MMBTU_NC4 + GPA_MMBTU_IC4 + GPA_MMBTU_NC5 + GPA_MMBTU_IC5 + GPA_MMBTU_C6 + GPA_MMBTU_C7 + GPA_MMBTU_C8 + GPA_MMBTU_C9 + GPA_MMBTU_C10

UPDATE	C
	SET
		Precio_C1	=	ROUND((GPA.Metano_C1 / SUMA_GPA_MMBTU ) * C.ImporteGas,4),
		Precio_C2	=	ROUND((GPA.Etano_C2 / SUMA_GPA_MMBTU ) * C.ImporteGas,4),
		Precio_C3	=	ROUND((GPA.Propano_C3 / SUMA_GPA_MMBTU ) * C.ImporteGas,4),
						-- BG11																							-- BS11										--BDXBP
		Precio_C4	=	CASE WHEN ISNULL(C.IC4,0) = 0 AND ISNULL(C.nC4,0) = 0 THEN 0
						WHEN (ROUND( GPA.Butano_iC4 * (C.VolumenGas_15Grados * (C.IC4/100)),0) +  ROUND( GPA.Butano_nC4 * (C.VolumenGas_15Grados * (C.nC4/100)) ,0)) = 0	THEN 0
						ELSE
						ROUND(( ( (( ( ROUND( GPA.Butano_iC4 * (C.VolumenGas_15Grados * (C.IC4/100)),0) / C.SUM_AR_BC ) * ( GPA.Butano_IC4/ @SumaValoresGPA ) ) / C.BDxBP ) * C.ImporteGas ) +
						-- BH																					-- BT11									 --BDXBP
						( (( ( ROUND( GPA.Butano_nC4 * (C.VolumenGas_15Grados * (C.nC4/100)),0) / C.SUM_AR_BC ) * ( GPA.Butano_NC4/ @SumaValoresGPA ) ) / C.BDxBP ) * C.ImporteGas ) ) /
						( ROUND( GPA.Butano_iC4 * (C.VolumenGas_15Grados * (C.IC4/100)),0) +  ROUND( GPA.Butano_nC4 * (C.VolumenGas_15Grados * (C.nC4/100)) ,0)),4) END,
		Precio_C5Mas = CASE WHEN ROUND(C.Bll_C5_Equiv,0) = 0 THEN 0
						ELSE
						ROUND(( ( ( ( ( (ROUND(C.ftXCroma_iC5/1000000,0)) / C.SUM_AR_BC) * (GPA.Pentano_iC5/@SumaValoresGPA) )/ C.BDxBP ) * C.ImporteGas )/ ROUND(C.Bll_C5_Equiv,0) ) +
							( ( ( ( ( (ROUND(C.ftXCroma_nC5/1000000,0)) / C.SUM_AR_BC) * (GPA.Pentano_nC5/@SumaValoresGPA) )/ C.BDxBP ) * C.ImporteGas )/ ROUND(C.Bll_C5_Equiv,0) ) +
							( ( ( ( ( (ROUND(C.ftXCroma_C6/1000000,0)) / C.SUM_AR_BC) * (GPA.Hexano_C6/@SumaValoresGPA) )/ C.BDxBP ) * C.ImporteGas )/ ROUND(C.Bll_C5_Equiv,0) ) +
							( ( ( ( ( (ROUND(C.ftXCroma_C7/1000000,0)) / C.SUM_AR_BC) * (GPA.Heptano_C7/@SumaValoresGPA) )/ C.BDxBP ) * C.ImporteGas )/ ROUND(C.Bll_C5_Equiv,0) ) +
							( ( ( ( ( (ROUND(C.ftXCroma_C8/1000000,0)) / C.SUM_AR_BC) * (GPA.Octano_C8/@SumaValoresGPA) )/ C.BDxBP ) * C.ImporteGas )/ ROUND(C.Bll_C5_Equiv,0) ) +
							( ( ( ( ( (ROUND(C.ftXCroma_C9/1000000,0)) / C.SUM_AR_BC) * (GPA.Nonano_C9/@SumaValoresGPA) )/ C.BDxBP ) * C.ImporteGas )/ ROUND(C.Bll_C5_Equiv,0) ) +
							( ( ( ( ( (ROUND(C.ftXCroma_C10/1000000,0)) / C.SUM_AR_BC) * (GPA.Decano_C10/@SumaValoresGPA) )/ C.BDxBP ) * C.ImporteGas )/ ROUND(C.Bll_C5_Equiv,0) ),4)
						END
						-- BG11
FROM
	#CalculosGPA	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	2
	AND	@fechaMesDiaAnio	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia
	AND C.VolumenGas_15Grados > 0


UPDATE #CalculosGPA
	SET 
		Precio_Petroleo = CASE WHEN VolumenPetroleo_20 = 0 THEN 0 ELSE ROUND(ImportePetroleo / VolumenPetroleo_15,4) END,
		Precio_Condensado = CASE WHEN VolumenCondensado_20 = 0 THEN 0 ELSE ROUND(ImporteCondensado / VolumenCondensado_15,4) END,
		Precio_Gas = CASE WHEN VolumenGas_20Grados = 0 THEN 0 ELSE ROUND((ImporteGas / VolumenGas_15Grados)/@Mil,4) END
		--Precio_Petroleo = CASE WHEN VolumenPetroleo_20 = 0 THEN 0 ELSE ROUND(ImportePetroleo / VolumenPetroleo_20,4) END,
		--Precio_Condensado = CASE WHEN VolumenCondensado_20 = 0 THEN 0 ELSE ROUND(ImporteCondensado / VolumenCondensado_20,4) END,
		--Precio_Gas = CASE WHEN VolumenGas_20Grados = 0 THEN 0 ELSE ROUND((ImporteGas / VolumenGas_20Grados)/@Mil,4) END

		
UPDATE #CalculosGPA
	SET
		MMBTU_C1_20 =	ROUND(MMBTU_C1,0) * @FactorConv15_20,
		MMBTU_C2_20	=	ROUND(MMBTU_C2,0) * @FactorConv15_20,
		MMBTU_C3_20	=	ROUND(MMBTU_C3,0) * @FactorConv15_20,
		MMBTU_IC4_20 =	ROUND(MMBTU_IC4,0) * @FactorConv15_20,
		MMBTU_NC4_20	=	ROUND(MMBTU_NC4,0) * @FactorConv15_20,
-- CALCULOS PARA EL GAS BN
		BN_MMBTU_C1_20 =	ROUND(BN_MMBTU_C1,0) * @FactorConv15_20,
		BN_MMBTU_C2_20	=	ROUND(BN_MMBTU_C2,0) * @FactorConv15_20,
		BN_MMBTU_C3_20	=	ROUND(BN_MMBTU_C3,0) * @FactorConv15_20,
		BN_MMBTU_IC4_20 =	ROUND(BN_MMBTU_IC4,0) * @FactorConv15_20,
		BN_MMBTU_NC4_20	=	ROUND(BN_MMBTU_NC4,0) * @FactorConv15_20

-- SE CALCULA PRECIO PROMEDIO PONDERADO PARA EL CONDESADO Y CONDENSABLE
SELECT
	@PrecioPromPonCondensado = CASE WHEN ISNULL(Bll_C5_Equiv,0) + ISNULL(VolumenCondensado_15,0) > 0
									THEN (ISNULL(Bll_C5_Equiv,0) * Precio_C5Mas)/ ((ISNULL(Bll_C5_Equiv,0) + ISNULL(VolumenCondensado_15,0))) +
									(ISNULL(VolumenCondensado_15,0) * Precio_Condensado) / ((ISNULL(Bll_C5_Equiv,0) + ISNULL(VolumenCondensado_15,0)) )
									ELSE 0
									END
FROM
	#CalculosGPA


SELECT
    idContrato,
    VolumenPetroleo_15		AS Petroleo_Venta,
    ROUND(MMBTU_C1,0)				AS C1Venta,
    ROUND(MMBTU_C2,0)				AS C2Venta,
    ROUND(MMBTU_C3,0)				AS C3Venta,
    ROUND(MMBTU_IC4,0) + ROUND(MMBTU_NC4,0)	AS C4Venta,
	--CASE WHEN ISNULL(Bll_C5_Equiv,0) > 0 THEN ROUND(Bll_C5_Equiv,0)
	--	WHEN ISNULL(VolumenCondensado_15,0) > 0 THEN ROUND(VolumenCondensado_15,0)
 --   ELSE 0
	--END	 AS [Condensado_Venta],
	ISNULL(Bll_C5_Equiv,0) + ISNULL(VolumenCondensado_15,0)		AS [Condensado_Venta],
    Precio_Petroleo			AS Petroleo_Precio,
    Precio_C1				AS	C1Precios,
    Precio_C2				AS	C2Precios,
    Precio_C3				AS	C3Precios,
    Precio_C4				AS	C4Precios,
	--CASE WHEN ISNULL(Bll_C5_Equiv,0) > 0 THEN Precio_C5Mas
	--	WHEN ISNULL(VolumenCondensado_15,0) > 0 THEN Precio_Condensado
 --   ELSE 0
	--END			AS	Condensado_Precios
	@PrecioPromPonCondensado	AS	Condensado_Precios,
	Precio_Gas
FROM
	#CalculosGPA

IF @Idcontrato = 3
	SELECT @FechaLimite = DATEADD(day,1,getdate())


IF @FechaLimite >= GETDATE()
BEGIN
	-- SE GUARDA UN REGISTRO DE LOS VALORES UTILIZADOS EN EL CALCULO ( CROMATOGRAFIA Y VOLUMENES )
	-- SI YA EXISTE UN REGISTRO CON LOS MISMO VALORES, SOLO SE ACTUALIZA LA FECHA Y EL USUARIO
	UPDATE LG
		SET UsuarioID	=	@Usuario,
			FecMovto	=	GETDATE()
	FROM
		#CalculosGPA	C
	JOIN
		dbo.LOG_CalculoProduccionMensual	LG
		ON	C.IdContrato	=	LG.IdContrato
		AND	C.MesReporte	=	LG.MesReporte
		AND	C.PuntoEntregaID	=	LG.PuntoEntregaID
		AND	C.VolumenPetroleo_20	=	LG.VolumenPetroleo
		AND C.VolumenGas_20Grados	=	LG.VolumenGas
		AND C.VolumenCondensado_20	=	LG.VolumenCondensado
		AND C.Grados_API	=	LG.GradosAPI
		AND	C.Azufre		=	LG.Azufre
		AND C.C1			=	LG.Cromatografia_C1
		AND	C.C2			=	LG.Cromatografia_C2
		AND C.C3			=	LG.Cromatografia_C3
		AND C.NC4			=	LG.Cromatografia_nC4
		AND C.IC4			=	LG.Cromatografia_iC4
		AND	C.NC5			=	LG.Cromatografia_nC5
		AND	C.IC5			=	LG.Cromatografia_iC5
		AND	C.C6			=	LG.Cromatografia_C6
		AND	C.CO2			=	LG.Cromatografia_CO2
		AND	C.H2S			=	LG.Cromatografia_H2S
		AND	C.N2			=	LG.Cromatografia_N2
		AND	C.ImportePetroleo	=	LG.ImportePetroleo
		AND	C.ImporteGas	=	LG.ImporteGas
		AND C.C7 =	LG.Cromatografia_C7
		AND	C.C8 =	LG.Cromatografia_C8
		AND C.C9 =	LG.Cromatografia_C9
		AND C.C10 = LG.Cromatografia_C10

	SELECT @RegistrosActualizados = @@ROWCOUNT

	IF @RegistrosActualizados = 0
	BEGIN
		INSERT INTO LOG_CalculoProduccionMensual
		(
			IdContrato,
			MesReporte,
			PuntoEntregaID,
			VolumenPetroleo,
			VolumenGas,
			VolumenCondensado,
			GradosAPI,
			Azufre,
			Cromatografia_C1,
			Cromatografia_C2,
			Cromatografia_C3,
			Cromatografia_nC4,
			Cromatografia_iC4,
			Cromatografia_nC5,
			Cromatografia_iC5,
			Cromatografia_C6,
			Cromatografia_CO2,
			Cromatografia_H2S,
			Cromatografia_N2,
			ImportePetroleo,
			ImporteGas,
			UsuarioID,
			FecMovto,
			Cromatografia_C7,
			Cromatografia_C8,
			Cromatografia_C9,
			Cromatografia_C10
		)
		SELECT
			IdContrato,
			MesReporte,
			PuntoEntregaID,
			VolumenPetroleo_20,
			VolumenGas_20Grados,
			VolumenCondensado_20,
			Grados_API,
			Azufre,
			C1,
			C2,
			C3,
			NC4,
			IC4,
			NC5,
			IC5,
			C6,
			CO2,
			H2S,
			N2,
			ImportePetroleo,
			ImporteGas,
			@Usuario,
			GETDATE(),
			C7,
			C8,
			C9,
			C10
		FROM
			#CalculosGPA
	END

	-- SE BORRA LA INFORMACION DEL MES ACTUAL
	DELETE FROM dbo.PR_ProduccionMensualPtoEntrega
	WHERE IdContrato	=	@Idcontrato
		AND IdFecha	=	@fechaMesDiaAnio
		AND	PuntoEntregaID	=	@puntoEntrega
	
	-- SE INSERTA LA INFORMACIÓN EN LA TABLA
	INSERT INTO dbo.PR_ProduccionMensualPtoEntrega
	(
		IdContrato,
		IdFecha,
		PuntoEntregaID,
		IdTipoHidrocarburo,
		VolumenProducido,
		VolumenVendido,
		idUnidadMedida,
		CreadoPor,
		CreadoEl,
		Precio
	)
	SELECT
		C.idContrato,
		C.MesReporte,
		C.PuntoEntregaID,
		TH.IdTipoHidrocarburo,
		CASE 
			WHEN TH.IdTipoHidrocarburo = 10000	THEN C.VolumenPetroleo_15	--C.VolumenPetroleo_20
			--WHEN TH.IdTipoHidrocarburo = 10001	AND ISNULL(C.Bll_C5_Equiv,0) > 0 THEN C.Bll_C5_Equiv
			--WHEN TH.IdTipoHidrocarburo = 10001	AND ISNULL(C.VolumenCondensado_20,0) > 0 THEN C.VolumenCondensado_20
			-- SE CAMBIA PARA SUMAR CONDENSADO Y CONDENSABLE
			WHEN TH.IdTipoHidrocarburo = 10001	THEN ISNULL(C.Bll_C5_Equiv,0) + ISNULL(C.VolumenCondensado_15,0)	--ISNULL(C.VolumenCondensado_20,0)
			WHEN TH.IdTipoHidrocarburo = 10002	THEN C.MMBTU_C1	--C.MMBTU_C1_20
			WHEN TH.IdTipoHidrocarburo = 10003	THEN C.MMBTU_C2	--C.MMBTU_C2_20
			WHEN TH.IdTipoHidrocarburo = 10004	THEN C.MMBTU_C3	--C.MMBTU_C3_20
			WHEN TH.IdTipoHidrocarburo = 10005	THEN C.MMBTU_IC4 + C.MMBTU_NC4	--C.MMBTU_IC4_20 + C.MMBTU_NC4_20
		END	AS	VolumenProducido,
		CASE 
			WHEN TH.IdTipoHidrocarburo = 10000	THEN C.VolumenPetroleo_15
			--WHEN TH.IdTipoHidrocarburo = 10001	AND ISNULL(C.Bll_C5_Equiv,0) > 0 THEN C.Bll_C5_Equiv
			--WHEN TH.IdTipoHidrocarburo = 10001	AND ISNULL(C.VolumenCondensado_15,0) > 0 THEN C.VolumenCondensado_15 
			-- SE CAMBIA PARA SUMAR CONDENSADO Y CONDENSABLE
			WHEN TH.IdTipoHidrocarburo = 10001	THEN ISNULL(C.Bll_C5_Equiv,0) + ISNULL(C.VolumenCondensado_15,0)
			WHEN TH.IdTipoHidrocarburo = 10002	THEN C.MMBTU_C1
			WHEN TH.IdTipoHidrocarburo = 10003	THEN C.MMBTU_C2
			WHEN TH.IdTipoHidrocarburo = 10004	THEN C.MMBTU_C3
			WHEN TH.IdTipoHidrocarburo = 10005	THEN C.MMBTU_IC4 + C.MMBTU_NC4
		END	AS	VolumenVendido,
		CASE TH.IdTipoHidrocarburo
			WHEN 10000	THEN @UniMedidaBl		-- BARRILES
			WHEN 10001	THEN @UniMedidaBl		-- BARRILES
			WHEN 10002	THEN @UniMedidaBTU		-- MMBTU
			WHEN 10003	THEN @UniMedidaBTU		-- MMBTU
			WHEN 10004	THEN @UniMedidaBTU		-- MMBTU
			WHEN 10005	THEN @UniMedidaBTU		-- MMBTU
		END	AS	idUnidadMedida,
		@Usuario,
		GETDATE(),
		CASE 
			WHEN TH.IdTipoHidrocarburo = 10000	THEN C.Precio_Petroleo
			--WHEN TH.IdTipoHidrocarburo = 10001	AND ISNULL(C.Bll_C5_Equiv,0) > 0 THEN C.Precio_C5Mas
			--WHEN TH.IdTipoHidrocarburo = 10001	AND ISNULL(C.VolumenCondensado_15,0) > 0 THEN C.Precio_Condensado
			WHEN TH.IdTipoHidrocarburo = 10001	THEN @PrecioPromPonCondensado
			WHEN TH.IdTipoHidrocarburo = 10002	THEN C.Precio_C1
			WHEN TH.IdTipoHidrocarburo = 10003	THEN C.Precio_C2
			WHEN TH.IdTipoHidrocarburo = 10004	THEN C.Precio_C3
			WHEN TH.IdTipoHidrocarburo = 10005	THEN C.Precio_C4
		END	AS	Precio
	FROM
		#CalculosGPA	C
	CROSS JOIN
		dbo.CO_TipoHidrocarburo	TH

	-- SE BORRAN LAS COMERCIALIZACIONES EXISTENTES PARA EL CONTRATO, MES, PTO ENTREGA, QUE NO PERTENEZCAN A PEMEX
	DELETE	OC
	FROM COM_OperacionComercializacion	OC
		JOIN	dbo.FI_Factura	F
			ON	OC.IdFactura	=	F.IdFactura
	WHERE	OC.IdContrato	=	@Idcontrato
		AND OC.MesReporte	=	@fechaMesDiaAnio
		AND	OC.PuntoEntregaID	=	@puntoEntrega
		AND	F.Emisor	<>	'PEP9207167XA'

	-- SE BORRAN LAS COMERCIALIZACIONES EXISTENTES PARA EL CONTRATO, MES, PTO ENTREGA, QUE AUN NO TIENEN LIGADA UNA FACTURA
	DELETE	OC
	FROM COM_OperacionComercializacion	OC
	WHERE	OC.IdContrato	=	@Idcontrato
		AND OC.MesReporte	=	@fechaMesDiaAnio
		AND	OC.PuntoEntregaID	=	@puntoEntrega
		AND	OC.IdFactura = 0

	-- SE GENERAN LAS COMERCIALIZACIONES EQUIVALENTES
	INSERT INTO dbo.COM_OperacionComercializacion
	(
	   IdContrato,
	    MesReporte,
	    FechaTransaccion,
	    IdTipoHidrocarburo,
	    VolumenVendido,
	    PrecioVentaUnitario,
	    CostoUnitarioComercializacion,
	    PrecioPuntoMedicion,
	    IdFactura,
	    NumeroFolioPedimento,
	    EPT,
	    OperacionBajoReglasMercado,
	  ClasificacionDocumentoSoporte,
	    CreadoPor,
	    CreadoEl,
	    ModificadoPor,
	    ModificadoEl,
	    Activo,
	    NuevoPrecioVentaUnitario,
	    PVUAnterior,
	    PPMAnterior,
		PuntoEntregaID,
		EsCondensable
	)
	SELECT
		C.idContrato,
		C.MesReporte,
		DATEADD(DAY,-1,DATEADD(MONTH,1,C.MesReporte))		AS [FechaTransaccion],
		TH.IdTipoHidrocarburo,
		CASE TH.IdTipoHidrocarburo
			WHEN 10000	THEN C.VolumenPetroleo_15
			WHEN 10001	THEN C.VolumenCondensado_15
			WHEN 10002	THEN C.MMBTU_C1
			WHEN 10003	THEN C.MMBTU_C2
			WHEN 10004	THEN C.MMBTU_C3
			WHEN 10005	THEN C.MMBTU_IC4 + C.MMBTU_NC4
		END	AS	VolumenVendido,
		CASE TH.IdTipoHidrocarburo
			WHEN 10000	THEN C.Precio_Petroleo
			WHEN 10001	THEN C.Precio_Condensado
			WHEN 10002	THEN C.Precio_C1
			WHEN 10003	THEN C.Precio_C2
			WHEN 10004	THEN C.Precio_C3
			WHEN 10005	THEN C.Precio_C4
		END	AS	Precio,
		0,	--   CostoUnitarioComercializacion,
		CASE TH.IdTipoHidrocarburo
			WHEN 10000	THEN C.Precio_Petroleo
			WHEN 10001	THEN  C.Precio_Condensado
			WHEN 10002	THEN  C.Precio_C1
			WHEN 10003	THEN C.Precio_C2
			WHEN 10004	THEN C.Precio_C3
			WHEN 10005	THEN C.Precio_C4
		END	AS	PrecioPuntoMedicion,
		0,	--	IdFactura
		'NA',
		0,
		1,
		2,
		@Usuario,
		GETDATE(),
		NULL,
		NULL,
		1, ---Activo
		0,
		0,
		0,
		C.PuntoEntregaID,
		0				
	FROM
		#CalculosGPA	C
	CROSS JOIN
		dbo.CO_TipoHidrocarburo	TH

	-- SI HAY VOLUMEN DE CONDENSABLE, SE GENERA LA COMERCIALIZACION
	IF 0 < (SELECT ISNULL(Bll_C5_Equiv,0) FROM #CalculosGPA)
	BEGIN

		INSERT INTO dbo.COM_OperacionComercializacion
		(
		   IdContrato,
			MesReporte,
			FechaTransaccion,
			IdTipoHidrocarburo,
			VolumenVendido,
			PrecioVentaUnitario,
			CostoUnitarioComercializacion,
			PrecioPuntoMedicion,
			IdFactura,
			NumeroFolioPedimento,
			EPT,
			OperacionBajoReglasMercado,
			ClasificacionDocumentoSoporte,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl,
			Activo,
			NuevoPrecioVentaUnitario,
			PVUAnterior,
			PPMAnterior,
			PuntoEntregaID,
			EsCondensable
		)
		SELECT
			idContrato,
			MesReporte,
			DATEADD(DAY,-1,DATEADD(MONTH,1,MesReporte))		AS [FechaTransaccion],
			10001,		-- IdTipoHidrocarburo
			Bll_C5_Equiv	AS	VolumenVendido,
			Precio_C5Mas	AS	PrecioVentaUnitario,
			0,	--   CostoUnitarioComercializacion,
			Precio_C5Mas	AS	PrecioPuntoMedicion,
			0,	--	IdFactura
			'NA',
			0,
			1,
			2,
			@Usuario,
			GETDATE(),
			NULL,
			NULL,
			1, ---Activo
			0,
			0,
			0,
			PuntoEntregaID,
			1				
		FROM
			#CalculosGPA

	END

	-- SE BORRAN LAS COMERCIALIZACIONES QUE SE HAYAN GENERADO CON VOLUMEN 0
	DELETE	OC
	FROM COM_OperacionComercializacion	OC
	WHERE	OC.IdContrato	=	@Idcontrato
		AND OC.MesReporte	=	@fechaMesDiaAnio
		AND	OC.PuntoEntregaID	=	@puntoEntrega
		AND	OC.IdFactura = 0
		AND OC.VolumenVendido = 0


	INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10002, 1000)
	INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10003, 1000)
	INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10004, 1000)
	INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10005, 1000)
	INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10000, 1001)
	INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10001, 1002)

	-- SE LIGAN LAS FACTURAS CON LAS COMERCIALIZACIONES EN CASO DE QUE EXISTAN PARA GAS, PETROLEO Y CONDENSADO
	UPDATE C	
		SET IdFactura = FP.idFactura
	FROM
		COM_OperacionComercializacion	C
	JOIN
		#TipoHidrocarburo	T
		ON	C.IdTipoHidrocarburo	=	T.IdTipoHidrocarburo
	JOIN
		FI_FacturaPuntoEntrega	FP
		ON	C.PuntoEntregaID	=	FP.PuntoEntregaId
		AND	C.MesReporte	=	FP.MesReporte
		AND	T.IdHidrocarburo	=	FP.ProductoId
	WHERE
		C.IdContrato	=	@idContrato
		AND	C.MesReporte	=	@fechaMesDiaAnio

-- SE LIGAN LAS FACTURAS DE CONDENSABLE
	UPDATE C	
		SET IdFactura = FP.idFactura
	FROM
		COM_OperacionComercializacion	C
	JOIN
		FI_FacturaPuntoEntrega	FP
		ON	C.PuntoEntregaID	=	FP.PuntoEntregaId
		AND	C.MesReporte	=	FP.MesReporte
		AND	FP.ProductoId	=	1000
	WHERE
		C.IdContrato	=	@idContrato
		AND	C.MesReporte	=	@fechaMesDiaAnio
		--AND C.PuntoEntregaID = @idPuntoEntrega
		AND C.IdTipoHidrocarburo = 10001
		AND C.EsCondensable = 1


IF 0 = (SELECT ISNULL(IsConsorcio,1) FROM CO_CONTRATO WHERE IdContrato = @Idcontrato)
BEGIN
	-- SE BORRA EL VOLUMEN ANTERIORMENTE GENERADO
	DELETE	dbo.PR_VolumenMensualProduccionPetroleo
	WHERE	IdContrato	=	@Idcontrato
		AND MesReporte	=	@fechaMesDiaAnio

	-- SE INSERTA LA INFORMACION EN LA TABLA DE PRODUCCION FINAL
	INSERT INTO dbo.PR_VolumenMensualProduccionPetroleo
	(
	    IdContrato,
	    MesReporte,
	    VolumenPetroleoPuntoMedicion,
	    GradosAPI,
	    ContenidoAzufre,
	    VolumenPetroleoAutoconsumo,
	    MetanoC1,
	    EtanoC2,
	    PropanoC3,
	    ButanoC4,
	    MetanoC1Autoconsumo,
	    EtanoC2Autoconsumo,
	    PropanoC3Autoconsumo,
	    ButanoC4Autoconsumo,
	    VolumenCondensadoPuntoMedicion,
	    VolumenCondensadoAutoconsumo,
	   Bit_CasoFortuito,
	    CantDiasCasoFortuito,
	    OtrosIngresosUsoCompartidoInfraestructura,
	    VolumenPetroleoContratistaReparticion,
	    VolumenMetanoC1ContratistaReparticion,
	    VolumenEtanoC2ContratistaReparticion,
	    VolumenPropanoC3ContratistaReparticion,
	    VolumenButanoC4ContratistaReparticion,
	    VolumenCondensadosContratistaReparticion,
	    VolumenPetroleoEstadoReparticion,
	    VolumenMetanoC1EstadoReparticion,
	    VolumenEtanoC2EstadoReparticion,
	    VolumenPropanoC3EstadoReparticion,
	    VolumenButanoC4EstadoReparticion,
	    VolumenCondensadosEstadoReparticion,
	    VolumenPetroleoContratistaCompensacion,
	    VolumenMetanoC1ContratistaCompensacion,
	    VolumenEtanoC2ContratistaCompensacion,
	    VolumenPropanoC3ContratistaCompensacion,
	    VolumenButanoC4ContratistaCompensacion,
	    VolumenCondensadosContratistaCompensacion,
	    VolumenPetroleoEstadoCompensacion,
	    VolumenMetanoC1EstadoCompensacion,
	    VolumenEtanoC2EstadoCompensacion,
	    VolumenPropanoC3EstadoCompensacion,
	    VolumenButanoC4EstadoCompensacion,
	    VolumenCondensadosEstadoCompensacion,
	    AcumuladoCostosRecuperablesInsolutos
	)
	SELECT
		PTE.IdContrato,
		PTE.IdFecha,
		SUM(CASE	PTE.IdTipoHidrocarburo
			WHEN 10000	THEN PTE.VolumenProducido	ELSE 0
		END)	AS	VolumenPetroleoPuntoMedicion,
		@PromAPI,
		@PromAzufre,
		0,--	VolumenPetroleoAutoconsumo,
		SUM(CASE	PTE.IdTipoHidrocarburo
			WHEN 10002	THEN PTE.VolumenProducido	ELSE 0
		END)	AS	MetanoC1,
		SUM(CASE	PTE.IdTipoHidrocarburo
			WHEN 10003	THEN PTE.VolumenProducido	ELSE 0
		END)	AS	EtanoC2,
		SUM(CASE	PTE.IdTipoHidrocarburo
			WHEN 10004	THEN PTE.VolumenProducido	ELSE 0
		END)	AS	PropanoC3,
		SUM(CASE	PTE.IdTipoHidrocarburo
			WHEN 10005	THEN PTE.VolumenProducido	ELSE 0
		END)	AS	ButanoC4,
		0, --C.BN_MMBTU_C1,--		MetanoC1Autoconsumo,
		0, --C.BN_MMBTU_C2,--	    EtanoC2Autoconsumo,
		0, --C.BN_MMBTU_C3,--	    PropanoC3Autoconsumo,
		0, --C.BN_MMBTU_IC4 + C.BN_MMBTU_NC4,--	    ButanoC4Autoconsumo,
		SUM(CASE	PTE.IdTipoHidrocarburo
			WHEN 10001	THEN PTE.VolumenProducido	ELSE 0
		END)	AS	VolumenCondensadoPuntoMedicion,
		0, --C.BN_Bll_C5_Equiv,--		VolumenCondensadoAutoconsumo,
		0,
		0,
		0,
	    0,--VolumenPetroleoContratistaReparticion,
	    0,--VolumenMetanoC1ContratistaReparticion,
	    0,--VolumenEtanoC2ContratistaReparticion,
	    0,--VolumenPropanoC3ContratistaReparticion,
	    0,--VolumenButanoC4ContratistaReparticion,
	    0,--VolumenCondensadosContratistaReparticion,
	    0,--VolumenPetroleoEstadoReparticion,
	    0,--VolumenMetanoC1EstadoReparticion,
	    0,--VolumenEtanoC2EstadoReparticion,
	    0,--VolumenPropanoC3EstadoReparticion,
	    0,--VolumenButanoC4EstadoReparticion,
	    0,--VolumenCondensadosEstadoReparticion,
	    0,--VolumenPetroleoContratistaCompensacion,
	    0,--VolumenMetanoC1ContratistaCompensacion,
	    0,--VolumenEtanoC2ContratistaCompensacion,
	   0,--VolumenPropanoC3ContratistaCompensacion,
	    0,--VolumenButanoC4ContratistaCompensacion,
	    0,--VolumenCondensadosContratistaCompensacion,
	    0,--VolumenPetroleoEstadoCompensacion,
	    0,--VolumenMetanoC1EstadoCompensacion,
	    0,--VolumenEtanoC2EstadoCompensacion,
	 0,--VolumenPropanoC3EstadoCompensacion,
	    0,--VolumenButanoC4EstadoCompensacion,
	    0,--VolumenCondensadosEstadoCompensacion,
	    0--AcumuladoCostosRecuperablesInsolut
	FROM
		PR_ProduccionMensualPtoEntrega	PTE
	WHERE
		PTE.IdContrato		=	@Idcontrato
		AND PTE.IdFecha		=	@fechaMesDiaAnio
	GROUP BY
		PTE.IdContrato,
		PTE.IdFecha

END
	
--****************************************************************************************************
END
--************************************************************************************************
END
