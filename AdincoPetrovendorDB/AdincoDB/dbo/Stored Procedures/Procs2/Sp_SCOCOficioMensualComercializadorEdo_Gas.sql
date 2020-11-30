CREATE PROCEDURE Sp_SCOCOficioMensualComercializadorEdo_Gas
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

SELECT @EsProduccionCompartida = CASE
                                    WHEN CO.IdTipoContrato = 2
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
	IdContrato = @IdContrato

SELECT
	@ComercializadorEntrega	=	EntregaGas,
	@ComercializadorRecibe	=	RecibeGas
FROM 
	dbo.SCOC_TipoArchivos
WHERE
	IdTipoArchivo = 26	-- reporte de gas

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


	SELECT
		@NumeroContrato									AS Contrato, 
		C.CampoID,
		'ÁREA CONTRACTUAL ' + @AreaContractual			AS A3,
		ISNULL(CO.VolumenGasEntregadoPor,'')			AS A6,
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
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_60_F ELSE 0 END),'###,###,###.###','en-US')					AS I19, --VOLUMEN TOTAL M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMPC_60F_Gas ELSE 0 END),'###,###,###.######','en-US')			AS J19, --VOLUMEN TOTAL MMPC a 15°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_60F ELSE 0 END),'###,###,###.###','en-US')					AS K19, 
		@PorcDistEdo_Per1	AS K21, --Porcentaje Distribucion del ESTADO
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END),'###,###,###.###','en-US') AS F26, --Total c1
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END),'###,###,###.###','en-US') AS F27, --Total c2
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END),'###,###,###.###','en-US') AS F28, --Total c3
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END),'###,###,###.###','en-US') AS F29, --Total c4
		FORMAT(SUM(CASE  WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END) +
			SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END) +
			SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END) +
			SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END),'###,###,###.###','en-US') AS F30, 
		-- TODO ES CERO PORQUE EN EL PRIMER PERIODO NO SE COMPENSA --
		0		AS G26, --Compensacion volumetrica Favor del ESTADO C1
		0		AS G27, --Compensacion volumetrica Favor del ESTADO C2
		0		AS G28, --Compensacion volumetrica Favor del ESTADO C3
		0		AS G29, --Compensacion volumetrica Favor del ESTADO C4
		0		AS G30, --Compensacion volumetrica Favor del ESTADO total
		0		AS H26, --Compensacion volumetrica Aplicada MMBTU c1
		0		AS H27, --Compensacion volumetrica Aplicada MMBTU c2
		0		AS H28, --Compensacion volumetrica Aplicada MMBTU c3
		0		AS H29, --Compensacion volumetrica Aplicada MMBTU c4
		0		AS H30, --Compensacion volumetrica Aplicada Total
		0		AS I26, --Compensacion volumetrica Pendiente C1
		0		AS I27, --Compensacion volumetrica Pendiente C2
		0		AS I28, --Compensacion volumetrica Pendiente C3
		0		AS I29, --Compensacion volumetrica Pendiente C4
		0		AS I30, --Compensacion volumetrica Pendiente total
		-- DISTRIBUCION A FAVOR DEL ESTADO
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C1 ELSE 0 END),'###,###,###.###','en-US')				AS J26, --Distribucion a favor del ESTADO c1
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C2 ELSE 0 END),'###,###,###.###','en-US')				AS J27, --Distribucion a favor del ESTADO c2
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C3 ELSE 0 END),'###,###,###.###','en-US')				AS J28, --Distribucion a favor del ESTADO c3
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US')				AS J29, --Distribucion a favor del ESTADO c4
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.TotalMMBTUEdo_C1C4 ELSE 0 END),'###,###,###.###','en-US')		AS J30, --Distribucion a favor del ESTADO total
		-- LO MISMO QUE EL ANTERIOR PORQUE EN EL PRIMER PERIODO NO SE COMPENSA
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C1 ELSE 0 END),'###,###,###.###','en-US')				AS K26, --Volumen total a favor del estado c1 
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C2 ELSE 0 END),'###,###,###.###','en-US')				AS K27, --Volumen total a favor del estado c2
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C3 ELSE 0 END),'###,###,###.###','en-US')				AS K28, --Volumen total a favor del estado c3
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US')				AS K29, --Volumen total a favor del estado c4
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.TotalMMBTUEdo_C1C4 ELSE 0 END),'###,###,###.###','en-US')		AS K30, --Volumen total a favor del estado total
 		------------------Cromatografía--------------------
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
		--****************************************************************************************************************************************
		--*****************************------------------------------------PERIODO 2----------------------------------------*****************-----
		--****************************************************************************************************************************************
		'- PERIODO DEL ' + LTRIM(DAY(DATEADD(DAY, 1, @FechaCorte))) + ' AL ' + LTRIM(DAY(@FechaFinMes)) + ' DE ' + UPPER(DATENAME(MONTH, @MesReporte)) + ' DE ' + LTRIM(YEAR(@MesReporte))	AS E32,
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_20C_GasEntregado ELSE 0 END),'###,###,###.###','en-US')			AS F38,	--VOLUMEN TOTAL M3 a 20° 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMPC_20C_GasEntregado ELSE 0 END),'###,###,###.######','en-US')	AS G38, --VOLUMEN TOTAL MMPC a 20°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_60_F ELSE 0 END),'###,###,###.###','en-US')						AS I38,	--VOLUMEN TOTAL M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMPC_60F_Gas ELSE 0 END),'###,###,###.######','en-US')				AS J38,	--VOLUMEN TOTAL MMPC a 15° 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_60F ELSE 0 END),'###,###,###.###','en-US')					AS K38,	---VOLUMEN TOTAL MMBTU
		@PorcDistEdo_Per2			AS K40, --Distribucion del ESTADO porcentaje
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END),'###,###,###.###','en-US')			AS F45, --Total c1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END),'###,###,###.###','en-US')			AS F46, --Total c2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END),'###,###,###.###','en-US')			AS F47, --Total c3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END),'###,###,###.###','en-US')			AS F48, --Total c4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END),'###,###,###.###','en-US')				AS F49, --Total componentes MMBTU
		-- COMPENSACION VOLUMETRICA FAVOR DEL ESTADO
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C1 ELSE 0 END),'###,###,###.###','en-US')		AS G45, --Compensacion volumetrica Favor del ESTADO C1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C2 ELSE 0 END),'###,###,###.###','en-US')		AS G46, --Compensacion volumetrica Favor del ESTADO C2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C3 ELSE 0 END),'###,###,###.###','en-US')		AS G47, --Compensacion volumetrica Favor del ESTADO C3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C4 ELSE 0 END),'###,###,###.###','en-US')		AS G48, --Compensacion volumetrica Favor del ESTADO C4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C1 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C2 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C3 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C4 ELSE 0 END),'###,###,###.###','en-US')		AS G49, --Compensacion volumetrica Favor ESTADO total
		--COMPENSACION VOLUMETRICA APLICADA ESTADO
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN (C.Aplicada_C1 - C.DistEdo_C1 ) ELSE 0 END),'###,###,###.###','en-US')	AS H45, --Compensacion volumetrica aplicada ESTADO c1 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN (C.Aplicada_C2 - C.DistEdo_C2 ) ELSE 0 END),'###,###,###.###','en-US')	AS H46, --Compensacion volumetrica aplicada ESTADO c2 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN (C.Aplicada_C3 - C.DistEdo_C3 ) ELSE 0 END),'###,###,###.###','en-US')	AS H47, --Compensacion volumetrica aplicada ESTADO c3 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN (C.Aplicada_C4 - C.DistEdo_C4 ) ELSE 0 END),'###,###,###.###','en-US')	AS H48, --Compensacion volumetrica aplicada ESTADO c4 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN (C.Aplicada_C1 - C.DistEdo_C1 ) ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN (C.Aplicada_C2 - C.DistEdo_C2 ) ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN (C.Aplicada_C3 - C.DistEdo_C3 ) ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN (C.Aplicada_C4 - C.DistEdo_C4 ) ELSE 0 END),'###,###,###.###','en-US')		AS H49, --Compensacion volumetrica aplicada TOTAL ESTADO MMBTU
		-- COMPENSACION VOLUMETRICA PENDIENTE ESTADO
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END) = 0 THEN '0'
			ELSE	FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END),'###,###,###.###','en-US')
		END					AS I45, --Compensacion volumetrica pendiente C1 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END),'###,###,###.###','en-US')
		END					AS I46, --Compensacion volumetrica pendiente C2 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END),'###,###,###.###','en-US')
		END					AS I47, --Compensacion volumetrica pendiente C3 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END),'###,###,###.###','en-US')
		END					AS I48, --Compensacion volumetrica pendiente C4 MMBTU
		CASE WHEN (SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END)) = 0 THEN '0'
			ELSE	FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END),'###,###,###.###','en-US') 
		END					AS I49, --Compensacion volumetrica pendiente TOTAL MMBTU
		-- DISTRIBUCION A FAVOR DEL ESTADO
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C1 ELSE 0 END),'###,###,###.###','en-US')		AS J45, --Distribucion a favor del estado c1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C2 ELSE 0 END),'###,###,###.###','en-US')		AS J46, --Distribucion a favor del estado c2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C3 ELSE 0 END),'###,###,###.###','en-US')		AS J47, --Distribucion a favor del estado c3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US')		AS J48, --Distribucion a favor del estado c4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C2 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US')			AS J49, --Distribucion a favor del estado total
		--VOLUMEN TOTAL A FAVOR DEL ESTADO
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN C.Aplicada_C1 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 = 0 THEN C.DistEdo_C1 ELSE 0 END),'###,###,###.###','en-US') AS K45, --Volumen total a favor del estado c1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN C.Aplicada_C2 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 = 0 THEN C.DistEdo_C2 ELSE 0 END),'###,###,###.###','en-US') AS K46, --Volumen total a favor del estado c2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN C.Aplicada_C3 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 = 0 THEN C.DistEdo_C3 ELSE 0 END),'###,###,###.###','en-US') AS K47, --Volumen total a favor del estado c3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN C.Aplicada_C4 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 = 0 THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US') AS K48, --Volumen total a favor del estado c4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN C.Aplicada_C1 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 = 0 THEN C.DistEdo_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN C.Aplicada_C2 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 = 0 THEN C.DistEdo_C2 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN C.Aplicada_C3 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 = 0 THEN C.DistEdo_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN C.Aplicada_C4 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 = 0 THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US')	 AS K49, --Volumen total a favor del estado total
		-------------------------- TOTALES --------------------------
		FORMAT(SUM(C.TotalMMBTUEdo_C1C4),'###,###,###.###','en-US')			AS E52, --total MMBTU Estado
		FORMAT(SUM(C.Edo_MMPC_C1C4),'###,###,###.######','en-US')			AS I52,	-- total MMPC Estado
		ISNULL(@ComercializadorEntrega,'Técnico CFEnergía, S.A. de C.V.')									AS A55,
		ISNULL(@ComercializadorRecibe,'Representante Comercial del Contrato de compraVenta')				AS I55
    FROM
		SCOC_CalculoDiario_Gas C
    JOIN
		dbo.SCOC_ReporteDiarioGas R 
		ON C.IdContrato = R.IdContrato
        AND C.MesReporte = R.MesReporte
        AND C.Dia = R.Dia
		AND C.CampoID	=	R.CampoID
	LEFT JOIN
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
