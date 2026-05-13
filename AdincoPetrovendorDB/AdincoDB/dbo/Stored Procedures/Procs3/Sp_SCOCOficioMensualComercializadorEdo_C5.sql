CREATE PROCEDURE dbo.Sp_SCOCOficioMensualComercializadorEdo_C5
	@IdContrato    INT, 
    @MesReporte    DATE, 
    @Usuario       INT, 
    @IdContratista INT
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181005
-- Description:	<Description,,>
-- =============================================
SET NOCOUNT ON
SET LANGUAGE spanish

DECLARE
	@EsProduccionCompartida BIT,
	@NumeroContrato VARCHAR(100),
	@FechaCorte DATE,
	@PorcDistEdo_Per1 FLOAT,
	@PorcDistEdo_Per2 FLOAT,
	@PorcDistContra_Per1 FLOAT,
	@PorcDistContra_Per2 FLOAT,
	@FechaFinMes DATE,
	@AreaContractual	VARCHAR(250),
	@EsLicencia		BIT,
	@EsConsorcio	BIT,
	@FactorConv20c15_5	FLOAT = 1.015394385,
	@ComercializadorEntrega	VARCHAR(500),
	@ComercializadorRecibe	VARCHAR(500)

SELECT @FechaFinMes = DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))

SELECT
	@EsProduccionCompartida = CASE    WHEN CO.IdTipoContrato = 2
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
	@ComercializadorEntrega	=	EntregaGas,
	@ComercializadorRecibe	=	RecibeGas
FROM 
	dbo.SCOC_TipoArchivos
WHERE
	IdTipoArchivo = 27

IF @EsProduccionCompartida = 1
BEGIN
    SELECT
		@FechaCorte = IdFecha
    FROM AP_Calendario
    WHERE Anio = YEAR(@MesReporte)
        AND Mes = MONTH(@MesReporte)
        AND Descripcion = 'Resultados y Elementos del Cálculo (Fecha máxima)';

    SELECT
		@PorcDistEdo_Per1 = RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)],
		@PorcDistContra_Per1	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)]
    FROM dbo.PC_RM RM53
    WHERE RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -2, @MesReporte))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -2, @MesReporte))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato;

    SELECT
		@PorcDistEdo_Per2 = RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)],
		@PorcDistContra_Per2	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)]
    FROM dbo.PC_RM RM53
    WHERE RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -1, @MesReporte))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -1, @MesReporte))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato;

---------------C5
	SELECT 
		@NumeroContrato			AS Contrato,
		C.CampoID,
		'ÁREA CONTRACTUAL ' + @AreaContractual			AS A3,
		ISNULL(CO.VolumenGasEntregadoPor,'')					AS A6,
		ISNULL(CO.GasEntregadoA,'')						AS A9,
		ISNULL(CO.GasEntregadoEn,'')					AS F11, 
		--CONVERT(VARCHAR(10),R.CreadoEn,105)				AS J7, 
		CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105) AS J7,
		CONVERT(VARCHAR(10),@MesReporte,105)			AS I8,
		CONVERT(VARCHAR(10),@FechaFinMes,105)			AS I9,
		--*-*-*-*-*-*-*-*-*-*---------- PERIODO 1 ---------------------
		'- PERIODO DEL ' + LTRIM(DAY(@MesReporte)) + '° AL ' + LTRIM(DAY(@FechaCorte)) + ' DE ' + UPPER(DATENAME(MONTH, @MesReporte)) + ' DE ' + LTRIM(YEAR(@MesReporte))	AS E13,
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_20C_GasEntregado ELSE 0 END),'###,###,###.###','en-US')		AS F19, --VOLUMEN TOTAL M3 a 20°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMPC_20C_GasEntregado ELSE 0 END),'###,###,###.######','en-US')	AS H19, --VOLUMEN TOTAL MMPC a 20°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_60_F ELSE 0 END),'###,###,###.###','en-US')				AS I19, --VOLUMEN TOTAL M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMPC_60F_Gas ELSE 0 END),'###,###,###.######','en-US')		AS J19, --VOLUMEN TOTAL MMPC a 15°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_60F ELSE 0 END),'###,###,###.###','en-US')				AS K19,
		@PorcDistEdo_Per1								AS K21, ----porcentaje distribución definitiva
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C5 ELSE 0 END),'###,###,###.###','en-US')				AS F26, -- TOTAL POR COMPONENTE MMBTU
		0			AS G26,--Compensación Volumétrica a Favor del ESTADO MMBTU
		0			AS H26,--Compensación Volumétrica Aplicada MMBTU
		0			AS I26,--MMBTU Compensación Volumétrica Pendiente
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C5 ELSE 0 END),'###,###,###.###','en-US')				AS J26,--Distribución a Favor del ESTADO MMBTU
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C5 ELSE 0 END),'###,###,###.###','en-US')				AS K26,--Volumen Total a Favor del ESTADO MMBTU
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.BarrilesC5_Equiv ELSE 0 END),'###,###,###.###','en-US')		AS F29,--Total Condensado BLS
		0 AS G29,--Compensación Volumétrica a Favor del Estado BLS
		0 AS H29,--Compensación Volumétrica Aplicada BLS
		0 AS I29,--Compensación Volumétrica Pendiente BLS
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistBarriles ELSE 0 END),'###,###,###.###','en-US')			AS J29,--Distribución a Favor del ESTADO BLS
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistBarriles ELSE 0 END),'###,###,###.###','en-US')			AS K29,--Volumen Total a Favor del ESTADO
		-- CROMATOGRAFIA
		CONVERT(VARCHAR(10),R.FechaCromatografia,105) AS A27, --Cromatografía de análisis realizado el
		ROUND(R.N2,4)		AS C29, 
		ROUND(R.CO2,4)		AS C30, 
		ROUND(R.H2S,4)		AS C31, 
		ROUND(R.C1,4)		AS C32, 
		ROUND(R.C2,4)		AS C33, 
		ROUND(R.C3,4)		AS C34, 
		ROUND(R.IC4,4)		AS C35, 
		ROUND(R.NC4,4)		AS C36, 
		ROUND(R.IC5,4)		AS C37, 
		ROUND(R.NC5,4)		AS C38, 
		ROUND(R.C6,4)		AS C39, 
		ROUND(R.PM,4)		AS C40, 
		ROUND(R.DensidadRelativa,4) AS C41, 
		FORMAT(R.PoderCalBTU,'###,###,###.####','en-US') AS C42,
		CASE WHEN CO.AplicaFactorCompresibilidad = 1
					THEN 'Factor de Compresibilidad: ' + LTRIM(ISNULL(C.FactorCompresibilidad,0))
		ELSE ''		END											AS A43,
		-- **********************************************************************
		-- PERIODO 2
		-- **********************************************************************
		'- PERIODO DEL ' + LTRIM(DAY(DATEADD(DAY, 1, @FechaCorte))) + ' AL ' + LTRIM(DAY(@FechaFinMes)) + ' DE ' + UPPER(DATENAME(MONTH, @MesReporte)) + ' DE ' + LTRIM(YEAR(@MesReporte))	AS E32,
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_20C_GasEntregado ELSE 0 END),'###,###,###.###','en-US')				AS F38, --VOLUMEN TOTAL M3 a 20° 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMPC_20C_GasEntregado ELSE 0 END),'###,###,###.######','en-US')		AS G38, --VOLUMEN TOTAL MMPC a 20°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_60_F ELSE 0 END),'###,###,###.###','en-US')							AS I38, --VOLUMEN TOTAL M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMPC_60F_Gas ELSE 0 END),'###,###,###.######','en-US')					AS J38, --VOLUMEN TOTAL MMPC a 15° 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_60F ELSE 0 END),'###,###,###.###','en-US')						AS K38, ---VOLUMEN TOTAL MMBTU 
		@PorcDistEdo_Per2		AS K40,--DISTRIBUCIÓN DEL ESTADO periodo 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C5 ELSE 0 END),'###,###,###.###','en-US')						AS F45,--TOTAL C5 PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C5 ELSE 0 END),'###,###,###.###','en-US')					AS G45,--Compensación Volumétrica a Favor del Estado MMBTU PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C5 <> 0 THEN (C.Aplicada_C5 - C.DistEdo_C5 ) ELSE 0 END),'###,###,###.###','en-US')	AS H45,--Compensación Volumétrica Aplicada ESTADO MMBTU PERIODO 2
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C5 <> 0 THEN C.Pendiente_C5 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C5 <> 0 THEN C.Pendiente_C5 ELSE 0 END),'###,###,###.###','en-US') END		AS I45,--Compensación Volumétrica Pendiente ESTADO MMBTU PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C5 ELSE 0 END),'###,###,###.###','en-US')						AS J45,--Distribución a Favor del Estado C5 MMBTU PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C5 <> 0 THEN C.Aplicada_C5 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C5 = 0 THEN C.DistEdo_C5 ELSE 0 END),'###,###,###.###','en-US') AS K45,--Volumen Total a Favor del Estado MMBTU PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.BarrilesC5_Equiv ELSE 0 END),'###,###,###.###','en-US')				AS F48,--Total Condensado BLS PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_Barriles ELSE 0 END),'###,###,###.###','en-US')			AS G48,--Compensación Volumétrica a Favor del Estado BLS PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_Barriles <> 0 THEN (C.Aplicada_Barriles - C.DistBarriles ) ELSE 0 END),'###,###,###.###','en-US')	AS H48,--Compensación Volumétrica Aplicada ESTADO BLS C5 PERIODO 2
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_Barriles <> 0 THEN C.Pendiente_Barriles ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_Barriles <> 0 THEN C.Pendiente_Barriles ELSE 0 END),'###,###,###.###','en-US') END		AS I48,--Compensación Volumétrica Pendiente ESTADO BLS C5 PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistBarriles ELSE 0 END),'###,###,###.###','en-US')					AS J48,--Distribución a Favor del Estado BLS C5 PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_Barriles <> 0 THEN C.Aplicada_Barriles WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_Barriles = 0 THEN C.DistBarriles ELSE 0 END),'###,###,###.###','en-US')	AS K48,--Volumen Total a Favor del Estado BLS C5 PERIODO 2
				------------------ TOTALES ---------------------------
		FORMAT(SUM(CASE WHEN C.Aplicada_Barriles <> 0 THEN C.Aplicada_Barriles ELSE C.DistBarriles END),'###,###,###.###','en-US')		 AS E52,--Total Barriles Estado VOLUMEN ENTREGADO
		FORMAT(SUM(C.DistEdo_C5),'###,###,###.###','en-US')				AS G52,--Total MMBTU Estado
		FORMAT(SUM(C.Edo_MMPC_C5),'###,###,###.######','en-US')			AS I52,--	Total MMPC Estado
		ISNULL(@ComercializadorEntrega,'Técnico CFEnergía, S.A. de C.V.')									AS A55,
		ISNULL(@ComercializadorRecibe,'Representante Comercial del Contrato de compraVenta')				AS I55
	FROM
		SCOC_CalculoDiario_Gas C
    JOIN
		dbo.SCOC_ReporteDiarioGas R 
		ON C.IdContrato = R.IdContrato
        AND C.MesReporte = R.MesReporte
        AND C.Dia = R.Dia
		AND	C.CampoID	=	R.CampoID
	JOIN
		SCOC_Contrato	CO
		ON	C.IdContrato	=	CO.IdContrato
    WHERE
		C.IdContrato = @IdContrato
        AND C.MesReporte = @MesReporte
	GROUP BY
		C.CampoID,
		--CONVERT(VARCHAR(10),R.CreadoEn,105),
		ISNULL(CO.GasEntregadoA,''), 
		ISNULL(CO.VolumenGasEntregadoPor,''),
		ISNULL(CO.GasEntregadoEn,''),
		CONVERT(VARCHAR(10),R.FechaCromatografia,105), 
		ROUND(R.N2,4), 
		ROUND(R.CO2,4),
		ROUND(R.H2S,4),
		ROUND(R.C1,4),
		ROUND(R.C2,4),
		ROUND(R.C3,4),
		ROUND(R.IC4,4),
		ROUND(R.NC4,4),
		ROUND(R.IC5,4),
		ROUND(R.NC5,4),
		ROUND(R.C6,4),
		ROUND(R.PM,4),
		ROUND(R.DensidadRelativa,4),
		FORMAT(R.PoderCalBTU,'###,###,###.####','en-US'),
		CASE WHEN CO.AplicaFactorCompresibilidad = 1
					THEN 'Factor de Compresibilidad: ' + LTRIM(ISNULL(C.FactorCompresibilidad,0))
		ELSE ''		END
END

END