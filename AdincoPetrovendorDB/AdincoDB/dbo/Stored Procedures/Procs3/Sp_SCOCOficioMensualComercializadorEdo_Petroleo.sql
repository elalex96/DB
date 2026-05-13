CREATE PROCEDURE Sp_SCOCOficioMensualComercializadorEdo_Petroleo
	@IdContrato    INT, 
    @MesReporte    DATE, 
    @Usuario       INT, 
    @IdContratista INT
AS
BEGIN
-- ===================================================================================
-- Modulo:			SCOC - Reporte Mensual de Petroleo para el Comercializador del Edo
--------------------------------------------------------------------------------------
-- 20190201		BAAC	Creación de SP
-- ===================================================================================
SET NOCOUNT ON;

SET LANGUAGE spanish

CREATE TABLE #PromPonderado
(
	CampoID INT,
	M3_20Grados	FLOAT,
	GradosAPI	FLOAT,
	AguaSedimento	FLOAT,
	Sal			FLOAT,
	Azufre		FLOAT,
	PesoEspec	FLOAT,
	PRIMARY KEY (CampoID)
)

CREATE TABLE #Totales
(
	CampoID	INT,
	Volumen			FLOAT,
	PRIMARY KEY (CampoID)
)

DECLARE
	@EsProduccionCompartida BIT,
	@NumeroContrato VARCHAR(100),
	@FechaCorte DATE,
	@PorcDistEdo_Per1 FLOAT,
	@PorcDistEdo_Per2 FLOAT,
	@PorcDistContra_Per1 FLOAT,
	@PorcDistContra_Per2 FLOAT,
	@FechaFinMes DATE,
	@M3_Totales	FLOAT,
	@AreaContractual	VARCHAR(250),
	@EsLicencia		BIT,
	@EsConsorcio	BIT,
	@ComercializadorEntrega	VARCHAR(500),
	@ComercializadorRecibe	VARCHAR(500)

SELECT @FechaFinMes = DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))

SELECT
	@EsProduccionCompartida = CASE
                                    WHEN IdTipoContrato = 2
                                    THEN 1
                                    ELSE 0
                                END, 
    @EsLicencia		=	CASE WHEN CO.IdTipoContrato = 3	THEN 1
					ELSE 0 END,
	@NumeroContrato	=	CO.NumeroContrato,
	@EsConsorcio	=	ISNULL(CO.IsConsorcio,0),
	@AreaContractual	=	UPPER(AC.NombreAreaContractual)
FROM
	dbo.CO_Contrato	CO
JOIN
	CO_AreaContractual	AC
	ON	CO.IdAreaContractual	=	AC.IdAreaContractual
WHERE
	CO.IdContrato = @IdContrato

SELECT
	@ComercializadorEntrega	=	EntregaPetroleo,
	@ComercializadorRecibe	=	RecibePetroleo
FROM 
	dbo.SCOC_TipoArchivos
WHERE
	IdTipoArchivo = 25	-- reporte de petroleo

INSERT INTO #Totales
(
	CampoID,
	Volumen
)
SELECT
	CampoID,
	SUM(BL_20C)
FROM
	SCOC_CalculoDiario_Petroleo
WHERE
	IdContrato	=	@IdContrato
	AND
	MesReporte	=	@MesReporte
GROUP BY
	CampoID

-- SE OBTIENE DATOS PARA CALCULAR EL PROMEDIO PONDERADO DE LA CALIDAD DEL PETROLEO
INSERT INTO #PromPonderado
(
	CampoID,
	GradosAPI,
	AguaSedimento,
	Sal,
	Azufre,
	PesoEspec
)
SELECT
	T.CampoID,
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
	AND C.MesReporte = R.MesReporte
	AND C.CampoID	=	R.CampoID
	AND C.Dia = R.Dia
JOIN
	#Totales	T
	ON	C.CampoID	=	T.CampoID
WHERE
	C.IdContrato	=	@IdContrato
	AND
	C.MesReporte	=	@MesReporte
GROUP BY
	T.CampoID

IF @EsProduccionCompartida = 1
BEGIN
    SELECT
		@FechaCorte = IdFecha
    FROM AP_Calendario
    WHERE
		Anio = YEAR(@MesReporte)
        AND Mes = MONTH(@MesReporte)
        AND Descripcion = 'Resultados y Elementos del Cálculo (Fecha máxima)'
    
	SELECT 
		@PorcDistEdo_Per1 = RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)],
		@PorcDistContra_Per1	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)]
    FROM dbo.PC_RM RM53
    WHERE
		RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -2, @MesReporte))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -2, @MesReporte))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato

    SELECT
		@PorcDistEdo_Per2 = RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)],
		@PorcDistContra_Per2	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)]
    FROM dbo.PC_RM RM53
    WHERE
		RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -1, @MesReporte))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -1, @MesReporte))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato

---------------------Pie y encabezado de pagina--------------
	SELECT
		@NumeroContrato AS Contrato,
		C.CampoID,
		'ÁREA CONTRACTUAL ' + @AreaContractual			AS A3,
		ISNULL(CO.VolumenPetroleoEntregadoPor,'')		AS A6,
		ISNULL(CO.PetroleoEntregadoA,'')				AS A9,
		--CONVERT(VARCHAR(10),R.CreadoEn,105)				AS J6,
		CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105) AS J6,
		CONVERT(VARCHAR(10),@MesReporte,105)			AS H7, 
		CONVERT(VARCHAR(10),@FechaFinMes,105)			AS H8,
		--*-*-*-*-*-*-*-*-*-*---------- PERIODO 1 ---------------------
		'- PERIODO DEL ' + LTRIM(DAY(@MesReporte)) + '° AL ' + LTRIM(DAY(@FechaCorte)) + ' DE ' + UPPER(DATENAME(MONTH, @MesReporte)) + ' DE ' + LTRIM(YEAR(@MesReporte))	AS D10,
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_20Grados ELSE 0 END),'###,###,###.###','en-US')	AS D14,	--Volumen entregado neto M3 a 20°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.BL_20C ELSE 0 END),'###,###,###.###','en-US')			AS E14, --Volumen entregado neto BLS a 20°
		LTRIM(@PorcDistEdo_Per1) + '%'						AS F14, --Distribución a Favor del ESTADO Periodo 1 PORCENTAJE
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_60F ELSE 0 END),'###,###,###.###','en-US')			AS D19, --Volumen entregado neto m3 a 15.56°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.BL_60F ELSE 0 END),'###,###,###.###','en-US')			AS E19, --Volumen entregado neto Bls a 15.56°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo ELSE 0 END),'###,###,###.###','en-US')		AS F19, --Distribución a Favor del ESTADO Bls
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContratista ELSE 0 END),'###,###,###.###','en-US') AS I19, --Volumen del Contratista
		-- LO MISMO PORQUE EN EL PRIMER PERIODO NO SE COMPENSA (F19)
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo ELSE 0 END),'###,###,###.###','en-US')		AS K19, --Volumen Total a Favor del ESTADO 
		0													AS E21, --Bls Compensación volumentrica a favor del estado, 0 PORQUE EL PRIMER PERIODO NO SE COMPENSA
		--*-*-*-*-*-*-*-*-*-*---------- PERIODO 2 ----------*-*-*-*-*-*-*-*-*-*--------
		'- PERIODO DEL ' + LTRIM(DAY(DATEADD(DAY, 1, @FechaCorte))) + ' AL ' + LTRIM(DAY(@FechaFinMes)) + ' DE ' + UPPER(DATENAME(MONTH, @MesReporte)) + ' DE ' + LTRIM(YEAR(@MesReporte))	AS D23,
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_20Grados ELSE 0 END),'###,###,###.###','en-US')		AS D27, --VOLUMEN ENTREGADO NETO M3 a 20°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.BL_20C ELSE 0 END),'###,###,###.###','en-US')			AS E27, --VOLUMEN ENTREGADO NETO BLS a 20°
		LTRIM(@PorcDistEdo_Per2) + '%'						AS F27,	--Distribución a Favor del Estado Periodo 2  PORCENTAJE
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_60F ELSE 0 END),'###,###,###.###','en-US')			AS D32, --VOLUMEN ENTREGADO NETO M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.BL_60F ELSE 0 END),'###,###,###.###','en-US')			AS E32, --VOLUMEN ENTREGADO NETO BLS a 15°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo ELSE 0 END),'###,###,###.###','en-US')			AS F32, --Distribución a Favor del Estado BLS periodo 2°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContratista ELSE 0 END),'###,###,###.###','en-US')	AS I32, --Volumen del Contratista BLS periodo 2°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada <> 0 THEN C.Aplicada WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada = 0 THEN C.DistEdo ELSE 0 END),'###,###,###.###','en-US')	 AS K32, --Volumen total a favor del EDO periodo2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion ELSE 0 END),'###,###,###.###','en-US')	 AS E34, --COMPENSACIÓN VOLUMÉTRICA A FAVOR DEL ESTADO periodo 2
		------------------------- CALIDAD --------------------------
		ROUND(PP.GradosAPI, 1)			AS C37, -- GRADOS API
		ROUND(PP.PesoEspec, 4)			AS C38, --PEso Especifico a 20°
		ROUND(PP.AguaSedimento, 1)		AS C39, -- Agua Sedimento
		ROUND(PP.Sal,0)					AS C40,
		--CASE WHEN ISNULL(PP.Sal,0) = 0 THEN '0' ELSE FORMAT(PP.Sal,'###,###,###.##','en-US') END AS Sal, 
		ROUND(PP.Azufre, 3)				AS C41, 
		FORMAT(SUM(CASE WHEN C.Aplicada <> 0 THEN C.Aplicada ELSE C.DistEdo END),'###,###,###.###','en-US') AS J39,    --Volumen total del Estado FINAL BLS
		ISNULL(@ComercializadorEntrega,'REPRESENTANTE COMERCIAL')		AS B44,
		ISNULL(@ComercializadorRecibe,'GCIA. COMERCIALIZACIÓN HIDROCARBUROS Y CONTRATOS')	AS G44
	FROM
		SCOC_CalculoDiario_Petroleo C
	JOIN
		dbo.SCOC_ReporteDiarioPetroleo R
		ON C.IdContrato = R.IdContrato
		AND C.MesReporte = R.MesReporte
		AND C.Dia = R.Dia
		AND C.CampoID	=	R.CampoID
	JOIN
		#PromPonderado	PP
		ON	C.CampoID	=	PP.CampoID
	JOIN
		SCOC_Contrato	CO
		ON	C.IdContrato	=	CO.IdContrato
	WHERE
		C.IdContrato = @IdContrato
		AND C.MesReporte = @MesReporte
	GROUP BY
		C.CampoID,
		--CONVERT(VARCHAR(10),R.CreadoEn,105),
		ISNULL(CO.SubdireccionProduccion,''), 
		ISNULL(CO.ActivoIntegral,''),
		ISNULL(CO.PetroleoEntregadoA,''),
		ISNULL(CO.VolumenPetroleoEntregadoPor,''),
		ISNULL(CO.PetroleoEntregadoEn,''),
		ROUND(PP.GradosAPI, 1), -- garod api
		ROUND(PP.PesoEspec, 4), --PEso Especifico a 20°
		ROUND(PP.AguaSedimento, 1), -- Agua Sedimento
		ROUND(PP.Sal,0),
		--CASE WHEN ISNULL(PP.Sal,0) = 0 THEN '0' ELSE FORMAT(PP.Sal,'###,###,###.##','en-US') END,
		ROUND(PP.Azufre, 3)
END

END