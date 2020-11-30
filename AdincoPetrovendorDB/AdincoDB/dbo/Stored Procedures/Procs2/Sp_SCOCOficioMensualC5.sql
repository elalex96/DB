CREATE PROCEDURE dbo.Sp_SCOCOficioMensualC5
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
	@PorcDefault FLOAT = 100,
	@ApruebaPEP		BIT,
	@ContratistaRecibe	VARCHAR(500),
	@ContratistaEntrega	VARCHAR(500)

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

-- SE OBTIENE EL INDICADOR PARA SABER SI EL FORMATO VA FIRMADO POR PEP O POR EL COMERCIALIZADOR
SELECT
	@ApruebaPEP = ISNULL(ApruebaRepPEP,1)
FROM
	dbo.SCOC_Contrato
WHERE
	IdContrato	=	@IdContrato

IF @EsProduccionCompartida = 1
BEGIN
	SELECT
		@ContratistaRecibe	=	RecibeGas,
		@ContratistaEntrega	=	EntregaGas
	FROM 
		dbo.SCOC_TipoArchivos
	WHERE
		IdTipoArchivo = 5	-- Producción Compartida MES C5 Edo

	IF @ApruebaPEP = 0
	BEGIN
		SELECT
			@ContratistaRecibe	=	EntregaGas
		FROM 
			dbo.SCOC_TipoArchivos
		WHERE
			IdTipoArchivo = 27	-- COMERCIALIZADOR C5
	END

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
		ISNULL(CO.SubdireccionProduccion,'')	AS NombreBloque, 
		ISNULL(CO.ActivoIntegral,'')				AS ClaveBloque, 
		@PorcDistEdo_Per1		AS PorcentajeFE, ----porcentaje distribución definitiva (Pie de pagina)
		DAY(@MesReporte)		AS PrimerDia, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		DAY(@FechaCorte)		AS UltimoDia, --Periodo 1--(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		UPPER(DATENAME(MONTH, @MesReporte)) AS Mes, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		YEAR(@MesReporte)		AS Año, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		@PorcDistEdo_Per2		AS PorcentajeFE2, ----porcentaje distribución definitiva (Pie de pagina) *******PERIODO 2*****
		DAY(DATEADD(DAY, 1, @FechaCorte)) AS PrimerDia2, -- (Aplicable del 25 al 31 de diciembre de 2017).   (Pie de pagina) *******PERIODO 2*****
		DAY(@FechaFinMes)		AS UltimoDia2, -- (Aplicable del 25 al 31 de diciembre de 2017).   (Pie de pagina) *******PERIODO 2*****
		------------------------------------------------------------------------------------
		ISNULL(CO.GasEntregadoA,'') AS EntregaA, 
		ISNULL(CO.GasEntregadoEn,'')				 AS EntregaEn, 
		--CONVERT(VARCHAR(10),@MesReporte,105) AS FechaE, 
		--CONVERT(VARCHAR(10),R.CreadoEn,105)		AS FechaE,
		CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105) AS FechaE,
		CONVERT(VARCHAR(10),@MesReporte,105)	AS FechaDE,
		CONVERT(VARCHAR(10),@FechaFinMes,105)	AS FechaA,
		---Cromatografia
		ROUND(R.N2,4)	 AS N2, 
		ROUND(R.CO2,4)	 AS CO2, 
		ROUND(R.H2S,4)	 AS H2S, 
		ROUND(R.C1,4)	 AS C1, 
		ROUND(R.C2,4)	 AS C2, 
		ROUND(R.C3,4)	 AS C3, 
		ROUND(R.IC4,4)	 AS IC4, 
		ROUND(R.NC4,4)	 AS nC4, 
		ROUND(R.IC5,4)	 AS iC5, 
		ROUND(R.NC5,4)	 AS nC5, 
		ROUND(R.C6,4)	 AS C6, 
		ROUND(R.PM,4) AS PM, 
		ROUND(R.DensidadRelativa,4) AS Den, 
		FORMAT(R.PoderCalBTU,'###,###,###.####','en-US') AS PC,
		CONVERT(VARCHAR(10),R.FechaCromatografia,105) AS FechaCrom,
------------------------------ PERIODO 1 ------------------------------------
		@PorcDistEdo_Per1 AS DFEP,--DISTRIBUCIÓN DEL ESTADO
		@PorcDistContra_Per1	AS DCOPor,	-- Distribucion a Favor del CONTRATISTA 
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_20C_GasEntregado ELSE 0 END),'###,###,###.###','en-US') AS VEM320, --VOLUMEN TOTAL M3 a 20°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMPC_20C_GasEntregado ELSE 0 END),'###,###,###.######','en-US') AS VEMMPC20, --VOLUMEN TOTAL MMPC a 20°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_60_F ELSE 0 END),'###,###,###.###','en-US') AS VEM315, --VOLUMEN TOTAL M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMPC_60F_Gas ELSE 0 END),'###,###,###.######','en-US') AS VMMPC15, --VOLUMEN TOTAL MMPC a 15°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_60F ELSE 0 END),'###,###,###.###','en-US') AS MMBTU, 
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C5 ELSE 0 END),'###,###,###.###','en-US')		AS TC5,
		0		AS FEC5,--Compensación Volumétrica a Favor del ESTADO MMBTU
		0		AS FCOC5, -- Compensacion Volumetrica a favor del CONTRATISTA MMBTU
		0		AS CVAC5,--Compensación Volumétrica Aplicada MMBTU
		0		AS CVPC5,--MMBTU Compensación Volumétrica Pendiente
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C5 ELSE 0 END),'###,###,###.###','en-US')			AS DFEC5,--Distribución a Favor del ESTADO MMBTU
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C5 ELSE 0 END),'###,###,###.###','en-US')		AS DFCOC5,	-- Distribucion a Favor del CONTRATISTA MMBTU
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C5 ELSE 0 END),'###,###,###.###','en-US')			AS VTFEC5,--Volumen Total a Favor del ESTADO MBTU
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C5 ELSE 0 END),'###,###,###.###','en-US')		AS VTFCOC5,	-- Volumen Total a Favor del CONTRATISTA MMBTU
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.BarrilesC5_Equiv ELSE 0 END),'###,###,###.###','en-US')	 AS TBLC5,--Total Condensado BLS
		0 AS FEBLC5,--Compensación Volumétrica a Favor del Estado BLS
		0		AS	FCOBLC5,	-- Compensacion Voluemtrica a Favor del CONTRATISTA BLS
		0 AS CVABLC5,--Compensación Volumétrica Aplicada BLS
		0 AS CVPBLC5,--Compensación Volumétrica Pendiente BLS
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistBarriles ELSE 0 END),'###,###,###.###','en-US')			AS DFEBLC5,--Distribución a Favor del ESTADO BLS
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_Barriles ELSE 0 END),'###,###,###.###','en-US')	AS DFCOBLC5,	-- Distribucion a favor del CONTRATISTA BLS
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistBarriles ELSE 0 END),'###,###,###.###','en-US')			AS VTFEBLC5,--Volumen Total a Favor del ESTADO
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_Barriles ELSE 0 END),'###,###,###.###','en-US')	AS VTFCOBLC5,	-- Volumen Total a Favor del CONTRATISTA
		-- **********************************************************************
		-- PERIODO 2
		@PorcDistEdo_Per2 AS DEPor2,--DISTRIBUCIÓN DEL ESTADO periodo 2
		@PorcDistContra_Per2	AS DCOPor2, -- Distribucion a favor del CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_20C_GasEntregado ELSE 0 END),'###,###,###.###','en-US')			AS '2VTM320', --VOLUMEN TOTAL M3 a 20° 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMPC_20C_GasEntregado ELSE 0 END),'###,###,###.######','en-US')	AS '2VTMMPC20', --VOLUMEN TOTAL MMPC a 20°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_60_F ELSE 0 END),'###,###,###.###','en-US')						AS '2VTM315', --VOLUMEN TOTAL M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMPC_60F_Gas ELSE 0 END),'###,###,###.######','en-US')				AS '2VTMPC15', --VOLUMEN TOTAL MMPC a 15° 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_60F ELSE 0 END),'###,###,###.###','en-US')					AS '2TMMBTU', ---VOLUMEN TOTAL MMBTU 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C5 ELSE 0 END),'###,###,###.###','en-US')					AS TC52,--TOTAL C5 PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C5 ELSE 0 END),'###,###,###.###','en-US')				AS FEC52,--Compensación Volumétrica a Favor del Estado MMBTU PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C5 ELSE 0 END)*-1,'###,###,###.###','en-US')			AS FCOC52,	-- Compensacion Volumetrica a favor del CONTRATISTA Periodo 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C5 <> 0 THEN (C.Aplicada_C5 - C.DistEdo_C5 ) ELSE 0 END),'###,###,###.###','en-US')	AS CVAC52,--Compensación Volumétrica Aplicada ESTADO MMBTU PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C5 <> 0 THEN (C.Aplicada_C5 - C.DistEdo_C5 ) ELSE 0 END)*-1,'###,###,###.###','en-US')	AS CVAC52C,	--Compensacion Volumetrica Aplicada CONTRATISTA
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C5 <> 0 THEN C.Pendiente_C5 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C5 <> 0 THEN C.Pendiente_C5 ELSE 0 END),'###,###,###.###','en-US') END		AS CVPC52,--Compensación Volumétrica Pendiente ESTADO MMBTU PERIODO 2
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C5 <> 0 THEN C.Pendiente_C5 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C5 <> 0 THEN C.Pendiente_C5 ELSE 0 END)*-1,'###,###,###.###','en-US') END	AS CVPC52C,	-- Compensacion Volumetrica Pendiente CONTRATISTA MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C5 ELSE 0 END),'###,###,###.###','en-US')					AS DFEC52,--Distribución a Favor del Estado C5 MMBTU PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C5 ELSE 0 END),'###,###,###.###','en-US')				AS DFCOC52,	-- DistribuCion a favor del CONTRATISTA MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C5 <> 0 THEN C.Aplicada_C5 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C5 = 0 THEN C.DistEdo_C5 ELSE 0 END),'###,###,###.###','en-US') AS VTFEC52,--Volumen Total a Favor del EDO MMBTU PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C5 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C5 ELSE 0 END)*-1),'###,###,###.###','en-US')	AS VTFCOC52,	-- Volumen Total a Favor del CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.BarrilesC5_Equiv ELSE 0 END),'###,###,###.###','en-US')			AS TBLC52,--Total Condensado BLS PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_Barriles ELSE 0 END),'###,###,###.###','en-US')		AS FEBLC52,--Compensación Volumétrica a Favor del Estado BLS PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_Barriles ELSE 0 END)*-1,'###,###,###.###','en-US')	AS FCOBLC52,	-- Compensacion Volumetrica a Favor del CONTRATISTA BLS
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_Barriles <> 0 THEN (C.Aplicada_Barriles - C.DistBarriles ) ELSE 0 END),'###,###,###.###','en-US')	AS CVABLC52,--Compensación Volumétrica Aplicada ESTADO BLS C5 PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_Barriles <> 0 THEN (C.Aplicada_Barriles - C.DistBarriles ) ELSE 0 END)*-1,'###,###,###.###','en-US')	AS CVABLC52C,	-- Compensacion Volumetrica Aplicada CONTRATISTA BLS
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_Barriles <> 0 THEN C.Pendiente_Barriles ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_Barriles <> 0 THEN C.Pendiente_Barriles ELSE 0 END),'###,###,###.###','en-US') END		AS CVPBLC52,--Compensación Volumétrica Pendiente ESTADO BLS C5 PERIODO 2
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_Barriles <> 0 THEN C.Pendiente_Barriles ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_Barriles <> 0 THEN C.Pendiente_Barriles ELSE 0 END)*-1,'###,###,###.###','en-US') END	AS CVPBLC52C,	--Compensacion Volumetrica Pendiente CONTRATISTA BLS

		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistBarriles ELSE 0 END),'###,###,###.###','en-US')				AS DFEBLC52,--Distribución a Favor del Estado BLS C5 PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_Barriles ELSE 0 END),'###,###,###.###','en-US')			AS DFCOBLC52,	-- Distribución a Favor del CONTRATISTA BLS
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_Barriles <> 0 THEN C.Aplicada_Barriles WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_Barriles = 0 THEN C.DistBarriles ELSE 0 END),'###,###,###.###','en-US')	AS VTBLC52,--Volumen Total a Favor del EDO BLS C5 PERIODO 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_Barriles ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_Barriles ELSE 0 END)*-1),'###,###,###.###','en-US')	AS VTCOBLC52,	-- Volumen Total a Favor del CONTRATISTA

		------------------ TOTALES ---------------------------
		FORMAT(SUM(CASE WHEN C.Aplicada_Barriles <> 0 THEN C.Aplicada_Barriles ELSE C.DistBarriles END),'###,###,###.###','en-US')		 AS TBLSE,--Total Barriles Estado VOLUMEN ENTREGADO
		FORMAT(SUM(C.DistEdo_C5),'###,###,###.###','en-US')				AS TMMBTUE,--Total MMBTU Estado
		FORMAT(SUM(C.Edo_MMPC_C5),'###,###,###.######','en-US')			AS TMMPCE,--	Total MMPC Estado
		FORMAT(SUM(C.DistContra_Barriles),'###,###,###.######','en-US')	AS TBLSCO,	-- Total de Barriles del CONTRATISTA
		FORMAT(SUM(C.DistContra_C5),'###,###,###.###','en-US')			AS TMMBTUCO,	-- Total MMBTU CONTRATISTA
		FORMAT(SUM(C.Contra_MMPC_C5),'###,###,###.######','en-US')		AS TMMPCCO,	-- Total MMPC CONTRATISTA
		ISNULL(@ContratistaRecibe,'REPRESENTANTE OPERATIVO PEP')	AS Recibe,
		ISNULL(@ContratistaEntrega,'REPRESENTANTE OPERATIVO OPERADOR')	AS Entrega
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
		ISNULL(CO.SubdireccionProduccion,''),
		ISNULL(CO.ActivoIntegral,''),
		ISNULL(CO.GasEntregadoA,''), 
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
		FORMAT(R.PoderCalBTU,'###,###,###.####','en-US')
END
ELSE
BEGIN
---- LICENCIA EN CONSORCIO CON PEMEX
	IF @EsLicencia = 1 AND @EsConsorcio = 1
	BEGIN
		SELECT
			-------------------------------ENCABEZADO-----------------------------------------------------
			@NumeroContrato								AS Contrato,
			C.CampoID,
			'ÁREA CONTRACTUAL ' + @AreaContractual							AS	I7,
			'SUBDIRECCIÓN DE PRODUCCIÓN BLOQUES ' + ISNULL(CO.SubdireccionProduccion,'')	AS F3, 
			'ACTIVO INTEGRAL DE PRODUCCIÓN BLOQUE ' + ISNULL(CO.ActivoIntegral,'')			AS G4,
			CONVERT(VARCHAR(10),@MesReporte,105)												AS I14, 
			CONVERT(VARCHAR(10),DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)),105)			AS I15, 
			ISNULL(CO.GasEntregadoA,'')					AS B10,
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,'')							AS B11,
			CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105)			AS K13, 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn)				AS J20, 
			ISNULL(CO.GasTransporte,'')					AS J22,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')			AS A25,
--- 3 DECIMALES---------------------------------------------------------------------------------
			FORMAT(SUM(ROUND(C.M3_20C_GasEntregado,3)),'###,###,###.###','en-US')					AS G31, --VOLUMEN TOTAL M3 a 20°
			FORMAT(SUM(ROUND(C.MMPC_20C_GasEntregado,3)),'###,###,###.######','en-US')						AS H31, --VOLUMEN TOTAL MMPC a 20°
			'(' + LTRIM(ISNULL(PC.PorcentajeSocio,@PorcDefault)) + '%)'				AS L29,	-- PORCENTAJE OPERADOR
			--FORMAT(SUM(C.M3_20C_GasEntregado * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')	AS J31,	-- VOLUMEN DEL OPERADOR M3 A 20°
			----C.M3_20C_GasEntregado * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),100)/100)	AS J31,	-- VOLUMEN DEL OPERADOR M3 A 20°
			--FORMAT(SUM(C.MMPC_20C_GasEntregado * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.######','en-US')	AS K31,	-- VOLUMEN DEL OPERADOR MMPC A 20°
			--FORMAT(SUM(C.M3_60_F),'###,###,###.###','en-US')									AS G37, --VOLUMEN TOTAL M3 a 15°
			--FORMAT(SUM(C.MMPC_60F_Gas),'###,###,###.######','en-US')								AS H37, --VOLUMEN TOTAL MMPC a 15°
			--FORMAT(SUM(C.MMBTU_60F),'###,###,###.###','en-US')									AS I37,	--MMBTU A 15°
			--FORMAT(SUM(C.M3_60_F * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')		AS J37,	-- VOLUMEN DEL OPERADOR M3 A 15°
			--FORMAT(SUM(C.MMPC_60F_Gas * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.######','en-US')	AS K37,	-- VOLUMEN DEL OPERADOR MMPC A 15°
			--FORMAT(SUM(C.MMBTU_60F * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')		AS L37,	-- VOLUMEN DEL OPERADOR MMBTU
-- 4 DECIMALES
			--FORMAT(SUM(C.M3_20C_GasEntregado),'###,###,###.####','en-US')					AS G31, --VOLUMEN TOTAL M3 a 20°
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMPC_20C_GasEntregado),'###,###,###.######','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMPC_20C_GasEntregado),'###,###,###.######','en-US')
			--	ELSE FORMAT(SUM(C.MMPC_20C_GasEntregado),'###,###,###.######','en-US')		END				AS H31, --VOLUMEN TOTAL MMPC a 20°
			--'(' + LTRIM(ISNULL(PC.PorcentajeSocio,@PorcDefault)) + '%)'				AS L29,	-- PORCENTAJE OPERADOR
			FORMAT(SUM(ROUND(C.M3_20C_GasEntregado,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')	AS J31,	-- VOLUMEN DEL OPERADOR M3 A 20°
			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.MMPC_20C_GasEntregado,6) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.#######','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.MMPC_20C_GasEntregado,6) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.#######','en-US')
				ELSE FORMAT(SUM(ROUND(C.MMPC_20C_GasEntregado,6) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.######','en-US')	END		AS K31,	-- VOLUMEN DEL OPERADOR MMPC A 20°
			FORMAT(SUM(ROUND(C.M3_60_F,3)),'###,###,###.###','en-US')									AS G37, --VOLUMEN TOTAL M3 a 15°
			CASE WHEN SUBSTRING(FORMAT(SUM(C.MMPC_60F_Gas),'###,###,###.######','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.MMPC_60F_Gas,6)),'###,###,###.######','en-US')
				ELSE FORMAT(SUM(ROUND(C.MMPC_60F_Gas,6)),'###,###,###.######','en-US')			END					AS H37, --VOLUMEN TOTAL MMPC a 15°
			FORMAT(SUM(ROUND(C.MMBTU_60F,3)),'###,###,###.###','en-US')																						AS I37,	--MMBTU A 15°
			FORMAT(SUM(ROUND(C.M3_60_F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS J37,	-- VOLUMEN DEL OPERADOR M3 A 15°
			CASE WHEN SUBSTRING(FORMAT(SUM(C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.#######','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.MMPC_60F_Gas,6) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.#######','en-US')
				ELSE FORMAT(SUM(ROUND(C.MMPC_60F_Gas,6) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.#######','en-US')	END		AS K37,	-- VOLUMEN DEL OPERADOR MMPC A 15°
			FORMAT(SUM(ROUND(C.MMBTU_60F,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')							AS L37,	-- VOLUMEN DEL OPERADOR MMBTU
			------------------CROMATOGRAFÍA--------------------
			ROUND(R.N2,4)				AS E42, 
			ROUND(R.CO2,4)				AS E43, 
			ROUND(R.H2S,4)				AS E44, 
			ROUND(R.C1,4)				AS E45, 
			ROUND(R.C2,4)				AS E46, 
			ROUND(R.C3,4)				AS E47, 
			ROUND(R.IC4,4)				AS E48, 
			ROUND(R.NC4,4)				AS E49, 
			ROUND(R.IC5,4)				AS E50, 
			ROUND(R.NC5,4)				AS E51, 
			ROUND(R.C6,4)				AS E52, 
			ROUND(R.PM,4)				AS E53, 
			ROUND(R.DensidadRelativa,4)	AS E54, 
			FORMAT(R.PoderCalBTU,'###,###,###.####','en-US')		AS E55,
			CASE WHEN CO.AplicaFactorCompresibilidad = 1
					THEN 'Factor de Compresibilidad: ' + LTRIM(ISNULL(C.FactorCompresibilidad,0))
			ELSE ''		END											AS B56,
-- 3 DECIMALES
			--------------- TOTALES MMBTU POR COMPONENTE -------------------------
			--FORMAT(SUM(C.MMBTU_C5),'###,###,###.###','en-US')	AS I42,	--Total componente c5
			--------------- TOTALES  A FAVOR DE PEP MMBTU POR COMPONENTE -------------------------
			--FORMAT(SUM(C.MMBTU_C5 * (ISNULL(PC.PorcentajePemex,@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')		AS J42, --Total PEP componente c5
			--------------- TOTALES  A FAVOR DEL OPERADOR MMBTU POR COMPONENTE -------------------------
			--FORMAT(SUM(C.MMBTU_C5 * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')		AS K42, --Total OPERADOR componente c5
			--------------- TOTALES BBL POR COMPONENTE -------------------------
			--FORMAT(SUM(C.BarrilesC5_Equiv),'###,###,###.###','en-US')	AS I46,	-- TOTAL BARRILES C5
			--------------- TOTALES  A FAVOR DE PEP BBL POR COMPONENTE -------------------------
			--FORMAT(SUM(C.BarrilesC5_Equiv * (ISNULL(PC.PorcentajePemex,@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')		AS J46, --Total PEP componente BBL
			--------------- TOTALES  A FAVOR DEL OPERADOR BBL POR COMPONENTE -------------------------
			--FORMAT(SUM(C.BarrilesC5_Equiv * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')		AS K46, --Total OPERADOR componente BBL
		 --  -- **************************** VOLUMENES TOTALES MPC ****************************
			--FORMAT(SUM((C.MMPC_60F_Gas * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)*1000)),'###,###,###.###','en-US')	AS K53,	-- GAS FORMACION
			--CASE WHEN SUM(ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000) = 0 THEN '0'
			--	ELSE FORMAT(SUM((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)* (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')
			--END					 AS	L53,	-- GAS BN O RESIDUAL?
			--FORMAT(SUM(C.BarrilesC5_Equiv * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')	AS I53,	-- TOTAL BARRILES OPERADOR
			--FORMAT(SUM(C.MMBTU_C5 * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US')			AS J53,	-- TOTAL MMBTU OPERADOR
			--FORMAT(SUM((C.MMPC_60F_Gas *(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000)+((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))),'###,###,###.###','en-US')	AS H53	-- VOLUMEN TOTAL
-- 4 DECIMALES
			------------- TOTALES MMBTU POR COMPONENTE -------------------------
			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.MMBTU_C5,3)),'###,###,###.###','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.MMBTU_C5,3)),'###,###,###.###','en-US')
				ELSE FORMAT(SUM(ROUND(C.MMBTU_C5,3)),'###,###,###.###','en-US')	END						AS I42,	--Total componente c5
			------------- TOTALES  A FAVOR DE PEP MMBTU POR COMPONENTE -------------------------
			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')
				ELSE FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')		END		AS J42, --Total PEP componente c5
			------------- TOTALES  A FAVOR DEL OPERADOR MMBTU POR COMPONENTE -------------------------
			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
				ELSE FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')	END		AS K42, --Total OPERADOR componente c5
			------------- TOTALES BBL POR COMPONENTE -------------------------
			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3)),'###,###,###.###','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3)),'###,###,###.###','en-US')
				ELSE FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3)),'###,###,###.###','en-US')	END						AS I46,	-- TOTAL BARRILES C5
			------------- TOTALES  A FAVOR DE PEP BBL POR COMPONENTE -------------------------
			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')
				ELSE FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')		END		AS J46, --Total PEP componente BBL
			------------- TOTALES  A FAVOR DEL OPERADOR BBL POR COMPONENTE -------------------------
			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
				ELSE FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')	END		AS K46, --Total OPERADOR componente BBL
		   -- **************************** VOLUMENES TOTALES MPC ****************************
			CASE WHEN SUBSTRING(FORMAT(SUM((ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))),'###,###,###.####','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM((ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))),'###,###,###.####','en-US')
				ELSE FORMAT(SUM((ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))),'###,###,###.####','en-US')	END		AS K53,	-- GAS FORMACION
			CASE WHEN SUM((ROUND((ISNULL(R.MMPC20BN,0)/@FactorConv20c15_5)*1000,3))*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) = 0 THEN '0'
				ELSE FORMAT(SUM((ROUND((ISNULL(R.MMPC20BN,0)/@FactorConv20c15_5)*1000,3))*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
			END				 AS	L53,	-- GAS BN O RESIDUAL?

			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
				ELSE FORMAT(SUM(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')	END			AS I53,	-- TOTAL BARRILES OPERADOR

			CASE WHEN SUBSTRING(FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
				THEN '0'+FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
				ELSE FORMAT(SUM(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')			END			AS J53,	-- TOTAL MMBTU OPERADOR
			FORMAT(SUM(( ROUND(C.MMPC_60F_Gas*1000,3) *(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+
				((ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0))* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))),'###,###,###.####','en-US')	AS H53	-- VOLUMEN TOTAL
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
		LEFT JOIN
			CO_PorcentajesContrato	PC
			ON	C.IdContrato	=	PC.idContrato
		LEFT JOIN
			dbo.SCOC_Campo	CA
			ON	C.CampoID	=	CA.CampoID
		WHERE
			C.IdContrato = @IdContrato
			AND C.MesReporte = @MesReporte
		GROUP BY
			C.CampoID,
			--CONVERT(VARCHAR(10),R.CreadoEn,105),
			ISNULL(CO.SubdireccionProduccion,''),
			ISNULL(CO.ActivoIntegral,''),
			ISNULL(CO.GasEntregadoA,''), 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn),
			--CONVERT(VARCHAR(10),R.CreadoEn,105),
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,''),
			'CAMPO: ' + ISNULL(CA.NombreCampo,''),
			ISNULL(CO.GasTransporte,''),
			ISNULL(PC.PorcentajeSocio,@PorcDefault),
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
	ELSE
	BEGIN
	-- LICENCIA SIN CONSORCIO CON PEMEX
		SELECT
			-------------------------------ENCABEZADO-----------------------------------------------------
			@NumeroContrato								AS Contrato,
			C.CampoID,
			'ÁREA CONTRACTUAL ' + @AreaContractual							AS	I7,
			'SUBDIRECCIÓN DE PRODUCCIÓN BLOQUES ' + ISNULL(CO.SubdireccionProduccion,'')	AS F3, 
			'ACTIVO INTEGRAL DE PRODUCCIÓN BLOQUE ' + ISNULL(CO.ActivoIntegral,'')			AS G4,
			CONVERT(VARCHAR(10),@MesReporte,105)												AS I14, 
			CONVERT(VARCHAR(10),DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)),105)			AS I15, 
			ISNULL(CO.GasEntregadoA,'')					AS B10, 
			--CONVERT(VARCHAR(10),@MesReporte,105)			AS K13, 
			--CONVERT(VARCHAR(10),R.CreadoEn,105)			AS K13,
			CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105)			AS K13, 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn)				AS J20,
			ISNULL(CO.GasTransporte,'')					AS J22,
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,'')							AS B11,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')			AS A25,
		------------------------------------------------------------------------------------
			FORMAT(SUM(C.M3_20C_GasEntregado),'###,###,###.###','en-US')					AS I31, --VOLUMEN TOTAL M3 a 20°
			FORMAT(SUM(C.MMPC_20C_GasEntregado),'###,###,###.######','en-US')						AS J31, --VOLUMEN TOTAL MMPC a 20°

			FORMAT(SUM(C.M3_60_F),'###,###,###.###','en-US')									AS I37, --VOLUMEN TOTAL M3 a 15°
			FORMAT(SUM(C.MMPC_60F_Gas),'###,###,###.######','en-US')								AS J37, --VOLUMEN TOTAL MMPC a 15°
			FORMAT(SUM(C.MMBTU_60F),'###,###,###.###','en-US')									AS K37,	--MMBTU A 15°
			------------------CROMATOGRAFÍA--------------------
			ROUND(R.N2,4)				AS E42, 
			ROUND(R.CO2,4)				AS E43, 
			ROUND(R.H2S,4)				AS E44, 
			ROUND(R.C1,4)				AS E45, 
			ROUND(R.C2,4)				AS E46, 
			ROUND(R.C3,4)				AS E47, 
			ROUND(R.IC4,4)				AS E48, 
			ROUND(R.NC4,4)				AS E49, 
			ROUND(R.IC5,4)				AS E50, 
			ROUND(R.NC5,4)				AS E51, 
			ROUND(R.C6,4)				AS E52, 
			ROUND(ISNULL(R.PM,0),4)				AS E53, 
			ROUND(R.DensidadRelativa,4)			AS E54, 
			FORMAT(R.PoderCalBTU,'###,###,###.####','en-US')		AS E55,
			CASE WHEN CO.AplicaFactorCompresibilidad = 1
				THEN 'Factor de Compresibilidad: ' + LTRIM(ISNULL(C.FactorCompresibilidad,0))
			ELSE ''		END					AS B56,
			------------- TOTALES MMBTU POR COMPONENTE -------------------------
			FORMAT(SUM(C.MMBTU_C5),'###,###,###.###','en-US')	AS J42,
			------------- TOTALES BBL POR COMPONENTE -------------------------
			FORMAT(SUM(C.BarrilesC5_Equiv),'###,###,###.###','en-US')	AS J46,	-- TOTAL BARRILES C5
		   -- **************************** VOLUMENES TOTALES MPC ****************************
			FORMAT(SUM((C.MMPC_60F_Gas*1000)),'###,###,###.###','en-US')	AS K53,	-- GAS FORMACION
			CASE WHEN SUM(ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000) = 0 THEN '0'
				ELSE FORMAT(SUM(ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000),'###,###,###.###','en-US')
			END				 AS	L53,	-- GAS BN O RESIDUAL?
			FORMAT(SUM(C.BarrilesC5_Equiv),'###,###,###.###','en-US')	AS I53,	-- TOTAL BARRILES OPERADOR
			FORMAT(SUM(C.MMBTU_C5),'###,###,###.###','en-US')			AS J53,	-- TOTAL MMBTU OPERADOR
			FORMAT(SUM((C.MMPC_60F_Gas*1000) + (ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)),'###,###,###.###','en-US')	AS H53	-- VOLUMEN TOTAL
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
		LEFT JOIN
			dbo.SCOC_Campo	CA
			ON	C.CampoID	=	CA.CampoID
		WHERE
			C.IdContrato = @IdContrato
			AND C.MesReporte = @MesReporte
		GROUP BY
			C.CampoID,
			ISNULL(CO.SubdireccionProduccion,''),
			ISNULL(CO.ActivoIntegral,''),
			ISNULL(CO.GasEntregadoA,''), 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn),
			ISNULL(CO.GasTransporte,''),
			--CONVERT(VARCHAR(10),R.CreadoEn,105),
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,''),
			'CAMPO: ' + ISNULL(CA.NombreCampo,''),
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
			ROUND(ISNULL(R.PM,0),4),
			ROUND(R.DensidadRelativa,4),
			FORMAT(R.PoderCalBTU,'###,###,###.####','en-US'),
			CASE WHEN CO.AplicaFactorCompresibilidad = 1
				THEN 'Factor de Compresibilidad: ' + LTRIM(ISNULL(C.FactorCompresibilidad,0))
			ELSE ''		END

	END
END

END
