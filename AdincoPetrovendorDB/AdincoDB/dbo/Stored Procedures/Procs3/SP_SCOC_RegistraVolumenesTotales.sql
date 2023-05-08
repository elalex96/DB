CREATE PROCEDURE dbo.SP_SCOC_RegistraVolumenesTotales
	@IdContrato    INT, 
    @MesReporte    DATE, 
    @Usuario       INT, 
    @IdContratista INT
AS
BEGIN
-- ============================================================
-- Modulo:			SCOC - Calculo de Volumenes de Gas
--					Registra los volumenes finales en la tabla PC_VolumenProduccionPeriodo
--------------------------------------------------------------
-- 20181004		BAAC	Creación de SP
-- ============================================================
SET NOCOUNT ON

CREATE TABLE #PromPonderado
(
	M3_20Grados	FLOAT,
	GradosAPI	FLOAT,
	AguaSedimento	FLOAT,
	Sal			FLOAT,
	Azufre		FLOAT,
	PesoEspec	FLOAT,
)

CREATE TABLE #Totales
(
	Volumen			FLOAT,
	Volumen_1556	FLOAT,
)

CREATE TABLE #VolumenesXPeriodo
(
	IdContrato	INT,
	MesReporte	DATE,
	Periodo		INT,
	Petroleo	FLOAT,
	C1			FLOAT,
	C2			FLOAT,
	C3			FLOAT,
	C4			FLOAT,
	Condensado	FLOAT
)

CREATE TABLE #VolumenesLic
(
	IdContrato	INT,
	MesReporte	DATE,
	Petroleo	FLOAT,
	C1			FLOAT,
	C2			FLOAT,
	C3			FLOAT,
	C4			FLOAT,
	Condensado	FLOAT
)

DECLARE
	@EsProduccionCompartida	BIT,
	@FechaCorte				DATE,
	@Petroleo	FLOAT,
	@TieneGas	BIT,
	@BitCondensable BIT


SELECT @EsProduccionCompartida = CASE
                                    WHEN CO.IdTipoContrato = 2
                                    THEN 1
                                    ELSE 0
                                END
FROM
	dbo.CO_Contrato	CO
JOIN
	CO_AreaContractual	AC
	ON	CO.IdAreaContractual	=	AC.IdAreaContractual
WHERE
	IdContrato = @IdContrato

SELECT
	@BitCondensable = ISNULL(Condensable,0)
FROM
	dbo.SCOC_Contrato
WHERE
	IdContrato	=	@IdContrato

INSERT INTO #Totales
(
	--CampoID,
	Volumen,
	Volumen_1556
)
SELECT
	SUM(BL_20C),
	SUM(BL_60F)
FROM
	SCOC_CalculoDiario_Petroleo
WHERE
	IdContrato	=	@IdContrato
	AND
	MesReporte	=	@MesReporte


-- SE OBTIENE DATOS PARA CALCULAR EL PROMEDIO PONDERADO DE LA CALIDAD DEL PETROLEO
INSERT INTO #PromPonderado
(
	GradosAPI,
	AguaSedimento,
	Sal,
	Azufre,
	PesoEspec
)
SELECT
	SUM((C.BL_20C * R.GradosAPI)/T.Volumen),
	SUM((C.BL_20C * R.AguaSedimento)/T.Volumen),
	SUM((C.BL_20C * R.Sal)/T.Volumen),
	SUM((C.BL_20C * R.Azufre)/T.Volumen),
	SUM((C.BL_20C * R.PesoEspec)/T.Volumen)
FROM
	SCOC_CalculoDiario_Petroleo C
JOIN
	dbo.SCOC_ReporteDiarioPetroleo R
	ON C.IdContrato = R.IdContrato
	AND C.CampoID	=	R.CampoID
	AND C.MesReporte = R.MesReporte
	AND C.Dia = R.Dia
CROSS JOIN
	#Totales	T
WHERE
	C.IdContrato	=	@IdContrato
	AND
	C.MesReporte	=	@MesReporte


IF @EsProduccionCompartida = 1
BEGIN
    SELECT
		@FechaCorte = IdFecha
    FROM AP_Calendario
    WHERE Anio = YEAR(@MesReporte)
        AND Mes = MONTH(@MesReporte)
        AND Descripcion = 'Resultados y Elementos del Cálculo (Fecha máxima)'


	INSERT INTO #VolumenesXPeriodo
	(
	    IdContrato,
	    MesReporte,
	    Periodo,
	    --Petroleo,
	    C1,
	    C2,
	    C3,
	    C4,
	    Condensado
	)
	SELECT
		IdContrato,
		MesReporte,
		1,
		SUM(MMBTU_C1),
		SUM(MMBTU_C2),
		SUM(MMBTU_C3),
		SUM(MMBTU_C4),
		SUM(BarrilesC5_Equiv)
	FROM
		dbo.SCOC_CalculoDiario_Gas
	WHERE
		IdContrato = @IdContrato 
		AND MesReporte = @MesReporte
		AND Dia <= DAY(@FechaCorte)
	GROUP BY
		IdContrato,
		MesReporte

	SELECT @TieneGas = @@ROWCOUNT

	IF @TieneGas = 1
	BEGIN
		SELECT
			@Petroleo	=	SUM(BL_60F)
		FROM
			dbo.SCOC_CalculoDiario_Petroleo
		WHERE
			IdContrato = @IdContrato 
			AND MesReporte = @MesReporte
			AND Dia <= DAY(@FechaCorte)

		UPDATE	#VolumenesXPeriodo
			SET	Petroleo	=	@Petroleo
		WHERE	Periodo	=	1
	END
	ELSE
	BEGIN
		INSERT INTO #VolumenesXPeriodo
		(
			IdContrato,
			MesReporte,
			Periodo,
			Petroleo,
			C1,
			C2,
			C3,
			C4,
			Condensado
		)
		SELECT
			IdContrato,
			MesReporte,
			1,
			SUM(BL_60F),
			0,0,0,0,0
		FROM
			dbo.SCOC_CalculoDiario_Petroleo
		WHERE
			IdContrato = @IdContrato 
			AND MesReporte = @MesReporte
			AND Dia <= DAY(@FechaCorte)
		GROUP BY
			IdContrato,
			MesReporte
	END
	-- PERIODO 2
	SELECT @TieneGas = 0, @Petroleo = 0
	INSERT INTO #VolumenesXPeriodo
	(
	    IdContrato,
	    MesReporte,
	    Periodo,
	    --Petroleo,
	    C1,
	    C2,
	    C3,
	    C4,
	    Condensado
	)
	SELECT
		IdContrato,
		MesReporte,
		2,
		SUM(MMBTU_C1),
		SUM(MMBTU_C2),
		SUM(MMBTU_C3),
		SUM(MMBTU_C4),
		SUM(BarrilesC5_Equiv)
	FROM
		dbo.SCOC_CalculoDiario_Gas
	WHERE
		IdContrato = @IdContrato 
		AND MesReporte = @MesReporte
		AND Dia > DAY(@FechaCorte)
	GROUP BY
		IdContrato,
		MesReporte

	SELECT @TieneGas = @@ROWCOUNT

	IF @TieneGas = 1
	BEGIN
		SELECT
			@Petroleo	=	SUM(BL_60F)
		FROM
			dbo.SCOC_CalculoDiario_Petroleo
		WHERE
			IdContrato = @IdContrato 
			AND MesReporte = @MesReporte
			AND Dia > DAY(@FechaCorte)

		UPDATE	#VolumenesXPeriodo
			SET	Petroleo	=	@Petroleo
		WHERE	Periodo	=	2
	END
	ELSE
	BEGIN
		INSERT INTO #VolumenesXPeriodo
		(
			IdContrato,
			MesReporte,
			Periodo,
			Petroleo,
			C1,
			C2,
			C3,
			C4,
			Condensado
		)
		SELECT
			IdContrato,
			MesReporte,
			2,
			SUM(BL_60F),
			0,0,0,0,0
		FROM
			dbo.SCOC_CalculoDiario_Petroleo
		WHERE
			IdContrato = @IdContrato 
			AND MesReporte = @MesReporte
			AND Dia > DAY(@FechaCorte)
		GROUP BY
			IdContrato,
			MesReporte
	END

	IF 0 = (SELECT COUNT(1) FROM PC_VolumenProduccionPeriodo WHERE IdContrato = @IdContrato AND MesReporte = @MesReporte)
	BEGIN
		INSERT INTO dbo.PC_VolumenProduccionPeriodo
		(
			IdContrato,
			MesReporte,
			FechaInicio,
			FechaFin,
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
			CreadoPor,
			CreadoEn,
			VolumenCondensablePuntoMedicion,
			VolumenCondensableAutoconsumo
		)
		SELECT
			VP.IdContrato,
			VP.MesReporte,
			CASE WHEN VP.Periodo = 1 THEN VP.MesReporte ELSE DATEADD(DAY,1,@FechaCorte) END,
			CASE WHEN VP.Periodo = 1 THEN @FechaCorte ELSE DATEADD(DAY,-1,DATEADD(MONTH,1,VP.MesReporte)) END,
			VP.Petroleo,
			ROUND(PP.GradosAPI,1),
			ROUND(PP.Azufre,3),
			0,
			VP.C1,
			VP.C2,
			VP.C3,
			VP.C4,
			0,0,0,0,
			CASE WHEN @BitCondensable = 0 THEN VP.Condensado ELSE 0 END,
			0,
			@Usuario,
			GETDATE(),
			CASE WHEN @BitCondensable = 1 THEN VP.Condensado ELSE 0 END, 
			0
		FROM
			#VolumenesXPeriodo	VP
		CROSS JOIN
			#PromPonderado	PP
	END
END
ELSE
BEGIN
	INSERT INTO  #VolumenesLic
	(
		IdContrato,
		MesReporte,
		--Petroleo,
		C1,
		C2,
		C3,
		C4,
		Condensado
	)
	SELECT
		IdContrato,
		MesReporte,
		SUM(MMBTU_C1),
		SUM(MMBTU_C2),
		SUM(MMBTU_C3),
		SUM(MMBTU_C4),
		SUM(BarrilesC5_Equiv)
	FROM
		dbo.SCOC_CalculoDiario_Gas
	WHERE
		IdContrato = @IdContrato 
		AND MesReporte = @MesReporte
	GROUP BY
		IdContrato,
		MesReporte

	SELECT @TieneGas = @@ROWCOUNT

	IF @TieneGas = 1
	BEGIN
		SELECT
			@Petroleo	=	SUM(BL_60F)
		FROM
			dbo.SCOC_CalculoDiario_Petroleo
		WHERE
			IdContrato = @IdContrato 
			AND MesReporte = @MesReporte

		UPDATE	#VolumenesLic
			SET	Petroleo	=	@Petroleo
	END
	ELSE
	BEGIN
		INSERT INTO #VolumenesLic
		(
			IdContrato,
			MesReporte,
			Petroleo,
			C1,
			C2,
			C3,
			C4,
			Condensado
		)
		SELECT
			IdContrato,
			MesReporte,
			SUM(BL_60F),
			0,0,0,0,0
		FROM
			dbo.SCOC_CalculoDiario_Petroleo
		WHERE
			IdContrato = @IdContrato 
			AND MesReporte = @MesReporte
		GROUP BY
			IdContrato,
			MesReporte
	END

	IF 0 = ( SELECT COUNT(1) FROM PR_VolumenMensualProduccionPetroleo WHERE IdContrato = @IdContrato AND MesReporte = @MesReporte)
	BEGIN
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
			VolumenCondensablePuntoMedicion,
			VolumenCondensableAutoconsumo
		)
		SELECT
			VL.IdContrato,
			VL.MesReporte,
			ROUND(VL.Petroleo,3),
			ROUND(PP.GradosAPI,1),
			ROUND(PP.Azufre,3),
			0,
			ROUND(VL.C1,3),
			ROUND(VL.C2,3),
			ROUND(VL.C3,3),
			ROUND(VL.C4,3),
			0,0,0,0,
			CASE WHEN @BitCondensable = 0 THEN ROUND(VL.Condensado,3) ELSE 0 END,
			0,
			CASE WHEN @BitCondensable = 1 THEN ROUND(VL.Condensado,3) ELSE 0 END, 
			0
		FROM
			#VolumenesLic	VL
		CROSS JOIN
			#PromPonderado	PP
	END
END

END


