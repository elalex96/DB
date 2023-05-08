CREATE PROCEDURE Sp_SCOCOficioMensualGas
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
	@PorcDefault	FLOAT = 100,
	@ApruebaPEP		BIT,
	@ContratistaRecibe	VARCHAR(500),
	@ContratistaEntrega	VARCHAR(500)

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
		IdTipoArchivo = 3	-- Producción Compartida MES Gas Edo

	IF @ApruebaPEP = 0
	BEGIN
		SELECT
			@ContratistaRecibe	=	EntregaGas
		FROM 
			dbo.SCOC_TipoArchivos
		WHERE
			IdTipoArchivo = 26	-- COMERCIALIZADOR GAS
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


	SELECT
		@NumeroContrato								AS Contrato, 
		C.CampoID,
		ISNULL(CO.SubdireccionProduccion,'')		AS NombreBloque, 
		ISNULL(CO.ActivoIntegral,'')				AS ClaveBloque, 
		@PorcDistEdo_Per1							AS PorcentajeFE, ----porcentaje distribución definitiva (Pie de pagina)
		DAY(@MesReporte)							AS PrimerDia, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		DAY(@FechaCorte)							AS UltimoDia, --Periodo 1--(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		UPPER(DATENAME(MONTH, @MesReporte))			AS Mes, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		YEAR(@MesReporte)							AS Año, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		@PorcDistEdo_Per2							AS PorcentajeFE2, ----porcentaje distribución definitiva (Pie de pagina) *******PERIODO 2*****
		DAY(DATEADD(DAY, 1, @FechaCorte))			AS PrimerDia2, -- (Aplicable del 25 al 31 de diciembre de 2017).   (Pie de pagina) *******PERIODO 2*****
		DAY(@FechaFinMes)							AS UltimoDia2, -- (Aplicable del 25 al 31 de diciembre de 2017).   (Pie de pagina) *******PERIODO 2*****
		------------------------------------------------------------------------------------
		ISNULL(CO.GasEntregadoA,'')					AS EntregaA, 
		ISNULL(CO.GasEntregadoEn,'')				AS EntregaEn, 
		--CONVERT(VARCHAR(10),@MesReporte,105)			AS FechaE, 
		--CONVERT(VARCHAR(10),R.CreadoEn,105)			AS FechaE,
		CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105)			AS FechaE, 
		CONVERT(VARCHAR(10),@MesReporte,105)			AS FechaDE,		--	DAY(@MesReporte)  
		CONVERT(VARCHAR(10),@FechaFinMes,105)			AS FechaA,		--DAY(@FechaFinMes) 
 		------------------Cromatografía--------------------
		CONVERT(VARCHAR(10),R.FechaCromatografia,105) AS FechaCrom, --Cromatografía de análisis realizado el
		ROUND(R.N2,4) AS N2, 
		ROUND(R.CO2,4) AS CO2, 
		ROUND(R.H2S,4) AS H2S, 
		ROUND(R.C1,4) AS C1, 
		ROUND(R.C2,4) AS C2, 
		ROUND(R.C3,4) AS C3, 
		ROUND(R.IC4,4) AS IC4, 
		ROUND(R.NC4,4) AS nC4, 
		ROUND(R.IC5,4) AS iC5, 
		ROUND(R.NC5,4) AS nC5, 
		ROUND(R.C6,4) AS C6, 
		ROUND(R.PM,4) AS PM, 
		ROUND(R.DensidadRelativa,4) AS Den, 
		FORMAT(R.PoderCalBTU,'###,###,###.####','en-US') AS PC,
				---------------------------PERIODO 1-------------------
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_20C_GasEntregado ELSE 0 END),'###,###,###.###','en-US') AS VEM320, --VOLUMEN TOTAL M3 a 20°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMPC_20C_GasEntregado ELSE 0 END),'###,###,###.######','en-US') AS VEMMPC20, --VOLUMEN TOTAL MMPC a 20°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_60_F ELSE 0 END),'###,###,###.###','en-US') AS VEM315, --VOLUMEN TOTAL M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMPC_60F_Gas ELSE 0 END),'###,###,###.######','en-US') AS VMMPC15, --VOLUMEN TOTAL MMPC a 15°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_60F ELSE 0 END),'###,###,###.###','en-US') AS MMBTU, 
		@PorcDistEdo_Per1 AS DEPor, --Porcentaje Distribucion del ESTADO 
		@PorcDistContra_Per1	AS DCOPor,	-- Porcentaje Distribucion del CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END),'###,###,###.###','en-US') AS TC1, --Total c1
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END),'###,###,###.###','en-US') AS TC2, --Total c2
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END),'###,###,###.###','en-US') AS TC3, --Total c3
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END),'###,###,###.###','en-US') AS TC4, --Total c4
		FORMAT(SUM(CASE  WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END) +
			SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END) +
			SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END) +
			SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END),'###,###,###.###','en-US') AS TOTAL, 

		0 AS FEC1, --Compensacion volumetrica Favor del ESTADO C1
		0 AS FEC2, --Compensacion volumetrica Favor del ESTADO C2
		0 AS FEC3, --Compensacion volumetrica Favor del ESTADO C3
		0 AS FEC4, --Compensacion volumetrica Favor del ESTADO C4
		0 AS FET, --Compensacion volumetrica Favor del ESTADO total   
		
		0	AS FCOC1,	-- Compensacion Volumetrica Favor del CONTRATISTA C1
		0	AS FCOC2,	-- Compensacion Volumetrica Favor del CONTRATISTA C2
		0	AS FCOC3,	-- Compensacion Volumetrica Favor del CONTRATISTA C3
		0	AS FCOC4,	-- Compensacion Volumetrica Favor del CONTRATISTA C4
		0	AS FCOT,	-- Compensacion Volumetrica Favor del CONTRATISTA TOTAL
		                         
		0 AS CVAC1, --Compensacion volumetrica Aplicada MMBTU c1
		0 AS CVAC2, --Compensacion volumetrica Aplicada MMBTU c2
		0 AS CVAC3, --Compensacion volumetrica Aplicada MMBTU c3
		0 AS CVAC4, --Compensacion volumetrica Aplicada MMBTU c4
		0 AS CVAT, --Compensacion volumetrica Aplicada Total
		0 AS CVPC1, --Compensacion volumetrica Pendiente C1
		0 AS CVPC2, --Compensacion volumetrica Pendiente C2
		0 AS CVPC3, --Compensacion volumetrica Pendiente C3
		0 AS CVPC4, --Compensacion volumetrica Pendiente C4
		0 AS CVPT, --Compensacion volumetrica Pendiente total 
		-- DISTRIBUCION A FAVOR DEL ESTADO
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C1 ELSE 0 END),'###,###,###.###','en-US')			AS DFEC1, --Distribucion a favor del ESTADO c1
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C2 ELSE 0 END),'###,###,###.###','en-US')			AS DFEC2, --Distribucion a favor del ESTADO c2
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C3 ELSE 0 END),'###,###,###.###','en-US')			AS DFEC3, --Distribucion a favor del ESTADO c3
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US')			AS DFEC4, --Distribucion a favor del ESTADO c4
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.TotalMMBTUEdo_C1C4 ELSE 0 END),'###,###,###.###','en-US') AS DFET, --Distribucion a favor del ESTADO total
		-- DISTRIBUCION A FAVOR DEL CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C1 ELSE 0 END),'###,###,###.###','en-US')			AS DFCOC1, --Distribucion a favor del CONTRATISTA c1
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C2 ELSE 0 END),'###,###,###.###','en-US')			AS DFCOC2, --Distribucion a favor del CONTRATISTA c2
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C3 ELSE 0 END),'###,###,###.###','en-US')			AS DFCOC3, --Distribucion a favor del CONTRATISTA c3
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C4 ELSE 0 END),'###,###,###.###','en-US')			AS DFCOC4, --Distribucion a favor del CONTRATISTA c4
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.TotalMMBTUContra_C1C4 ELSE 0 END),'###,###,###.###','en-US') AS DFCOT, --Distribucion a favor del CONTRATISTA total
		-- LO MISMO QUE EL ANTERIOR PORQUE EN EL PRIMER PERIODO NO SE COMPENSA
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C1 ELSE 0 END),'###,###,###.###','en-US')				AS VTFEC1, --Volumen total a favor del estado c1 
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C2 ELSE 0 END),'###,###,###.###','en-US')				AS VTFEC2, --Volumen total a favor del estado c2
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C3 ELSE 0 END),'###,###,###.###','en-US')				AS VTFEC3, --Volumen total a favor del estado c3
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US')				AS VTFEC4, --Volumen total a favor del estado c4
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.TotalMMBTUEdo_C1C4 ELSE 0 END),'###,###,###.###','en-US') AS VTFET, --Volumen total a favor del estado total
		-- LO MISMO QUE EL ANTERIOR PORQUE EN EL PRIMER PERIODO NO SE COMPENSA
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C1 ELSE 0 END),'###,###,###.###','en-US')			AS VTFCOC1, --Volumen total a favor del CONTRATISTA c1
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C2 ELSE 0 END),'###,###,###.###','en-US')			AS VTFCOC2, --Volumen total a favor del CONTRATISTA c2
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C3 ELSE 0 END),'###,###,###.###','en-US')			AS VTFCOC3, --Volumen total a favor del CONTRATISTA c3
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContra_C4 ELSE 0 END),'###,###,###.###','en-US')			AS VTFCOC4, --Volumen total a favor del CONTRATISTA c4
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.TotalMMBTUContra_C1C4 ELSE 0 END),'###,###,###.###','en-US')	AS VTFCOT, --Volumen total a favor del CONTRATISTA total
		--****************************************************************************************************************************************
		--*****************************------------------------------------PERIODO 2----------------------------------------*****************-----
		--****************************************************************************************************************************************
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_20C_GasEntregado ELSE 0 END),'###,###,###.###','en-US')		AS [2VTM320],	--VOLUMEN TOTAL M3 a 20° 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMPC_20C_GasEntregado ELSE 0 END),'###,###,###.######','en-US') AS [2VTMMPC20], --VOLUMEN TOTAL MMPC a 20°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_60_F ELSE 0 END),'###,###,###.###','en-US')					AS [2VTM315],	--VOLUMEN TOTAL M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMPC_60F_Gas ELSE 0 END),'###,###,###.######','en-US')			AS [2VTMPC15],	--VOLUMEN TOTAL MMPC a 15° 
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_60F ELSE 0 END),'###,###,###.###','en-US')				AS [2TMMBTU],	---VOLUMEN TOTAL MMBTU 

		@PorcDistEdo_Per2 AS '2DEPor', --Distribucion del ESTADO porcentaje
		@PorcDistEdo_Per1	AS '2DCOPor',	-- Distribucion del CONTRATISTA porcentaje
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END),'###,###,###.###','en-US')		AS [2TC1], --Total c1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END),'###,###,###.###','en-US')		AS [2TC2], --Total c2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END),'###,###,###.###','en-US')		AS [2TC3], --Total c3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END),'###,###,###.###','en-US')		AS [2TC4], --Total c4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END),'###,###,###.###','en-US')			AS [2TOTAL], --Total componentes MMBTU
		-- COMPENSACION VOLUMETRICA FAVOR DEL ESTADO
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C1 ELSE 0 END),'###,###,###.###','en-US') AS [2FEC1], --Compensacion volumetrica Favor del ESTADO C1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C2 ELSE 0 END),'###,###,###.###','en-US') AS [2FEC2], --Compensacion volumetrica Favor del ESTADO C2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C3 ELSE 0 END),'###,###,###.###','en-US') AS [2FEC3], --Compensacion volumetrica Favor del ESTADO C3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C4 ELSE 0 END),'###,###,###.###','en-US') AS [2FEC4], --Compensacion volumetrica Favor del ESTADO C4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C1 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C2 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C3 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C4 ELSE 0 END),'###,###,###.###','en-US')	AS [2FET], --Compensacion volumetrica Favor ESTADO total
		--COMPENSACION VOLUMETRICA FAVOR DEL CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C1 ELSE 0 END)*-1,'###,###,###.###','en-US') AS [2FCOC1], --Compensacion volumetrica Favor del CONTRATISTA C1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C2 ELSE 0 END)*-1,'###,###,###.###','en-US') AS [2FCOC2], --Compensacion volumetrica Favor del CONTRATISTA C2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C3 ELSE 0 END)*-1,'###,###,###.###','en-US') AS [2FCOC3], --Compensacion volumetrica Favor del CONTRATISTA C3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C4 ELSE 0 END)*-1,'###,###,###.###','en-US') AS [2FCOC4], --Compensacion volumetrica Favor del CONTRATISTA C4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C1 ELSE 0 END)*-1 +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C2 ELSE 0 END)*-1 +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C3 ELSE 0 END)*-1 +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C4 ELSE 0 END)*-1,'###,###,###.###','en-US')		AS [2FCOT], --Compensacion volumetrica Favor CONTRATISTA total
		--COMPENSACION VOLUMETRICA APLICADA ESTADO
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN (C.Aplicada_C1 - C.DistEdo_C1 ) ELSE 0 END),'###,###,###.###','en-US')	AS [2CVAC1], --Compensacion volumetrica aplicada ESTADO c1 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN (C.Aplicada_C2 - C.DistEdo_C2 ) ELSE 0 END),'###,###,###.###','en-US')	AS [2CVAC2], --Compensacion volumetrica aplicada ESTADO c2 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN (C.Aplicada_C3 - C.DistEdo_C3 ) ELSE 0 END),'###,###,###.###','en-US')	AS [2CVAC3], --Compensacion volumetrica aplicada ESTADO c3 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN (C.Aplicada_C4 - C.DistEdo_C4 ) ELSE 0 END),'###,###,###.###','en-US')	AS [2CVAC4], --Compensacion volumetrica aplicada ESTADO c4 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN (C.Aplicada_C1 - C.DistEdo_C1 ) ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN (C.Aplicada_C2 - C.DistEdo_C2 ) ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN (C.Aplicada_C3 - C.DistEdo_C3 ) ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN (C.Aplicada_C4 - C.DistEdo_C4 ) ELSE 0 END),'###,###,###.###','en-US')		AS [2CVAT], --Compensacion volumetrica aplicada TOTAL ESTADO MMBTU
		--COMPENSACION VOLUMETRICA APLICADA CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN (C.Aplicada_C1 - C.DistEdo_C1 ) ELSE 0 END)*-1,'###,###,###.###','en-US')	AS [2CVAC1C], --Compensacion volumetrica aplicada CONTRATISTA c1 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN (C.Aplicada_C2 - C.DistEdo_C2 ) ELSE 0 END)*-1,'###,###,###.###','en-US')	AS [2CVAC2C], --Compensacion volumetrica aplicada CONTRATISTA c2 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN (C.Aplicada_C3 - C.DistEdo_C3 ) ELSE 0 END)*-1,'###,###,###.###','en-US')	AS [2CVAC3C], --Compensacion volumetrica aplicada CONTRATISTA c3 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN (C.Aplicada_C4 - C.DistEdo_C4 ) ELSE 0 END)*-1,'###,###,###.###','en-US')	AS [2CVAC4C], --Compensacion volumetrica aplicada CONTRATISTA c4 MMBTU
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN (C.Aplicada_C1 - C.DistEdo_C1 ) ELSE 0 END)*-1 + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN (C.Aplicada_C2 - C.DistEdo_C2 ) ELSE 0 END)*-1 + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN (C.Aplicada_C3 - C.DistEdo_C3 ) ELSE 0 END)*-1 + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN (C.Aplicada_C4 - C.DistEdo_C4 ) ELSE 0 END)*-1,'###,###,###.###','en-US')	AS [2CVATC], --Compensacion volumetrica aplicada TOTAL CONTRATISTA MMBTU
		-- COMPENSACION VOLUMETRICA PENDIENTE ESTADO
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END) = 0 THEN '0'
			ELSE	FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END),'###,###,###.###','en-US')
		END					AS [2CVPC1], --Compensacion volumetrica pendiente C1 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END),'###,###,###.###','en-US')
		END					AS [2CVPC2], --Compensacion volumetrica pendiente C2 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END),'###,###,###.###','en-US')
		END					AS [2CVPC3], --Compensacion volumetrica pendiente C3 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END),'###,###,###.###','en-US')
		END					AS [2CVPC4], --Compensacion volumetrica pendiente C4 MMBTU
		CASE WHEN (SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END)) = 0 THEN '0'
			ELSE	FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END),'###,###,###.###','en-US') 
		END					AS [2CVPT], --Compensacion volumetrica pendiente TOTAL MMBTU
		-- COMPENSACION VOLUMETRICA PENDIENTE CONTRATISTA
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END) = 0 THEN '0'
			ELSE	FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END)*-1,'###,###,###.###','en-US')
		END					AS [2CVPC1C], --Compensacion volumetrica pendiente CONTRATISTA C1 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END)*-1,'###,###,###.###','en-US')
		END					AS [2CVPC2C], --Compensacion volumetrica pendiente CONTRATISTA C2 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END)*-1,'###,###,###.###','en-US')
		END					AS [2CVPC3C], --Compensacion volumetrica pendiente CONTRATISTA C3 MMBTU
		CASE WHEN SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END) = 0 THEN '0'
			ELSE FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END)*-1,'###,###,###.###','en-US')
		END					AS [2CVPC4C], --Compensacion volumetrica pendiente CONTRATISTA C4 MMBTU
		CASE WHEN (SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END) + SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END) + 	SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END)) = 0 THEN '0'
			ELSE	FORMAT(SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C1 <> 0 THEN C.Pendiente_C1 ELSE 0 END)*-1 + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C2 <> 0 THEN C.Pendiente_C2 ELSE 0 END)*-1 + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C3 <> 0 THEN C.Pendiente_C3 ELSE 0 END)*-1 + 
			SUM(CASE WHEN C.Dia = DAY(@FechaFinMes) AND C.Pendiente_C4 <> 0 THEN C.Pendiente_C4 ELSE 0 END)*-1,'###,###,###.###','en-US') 
		END					AS [2CVPTC], --Compensacion volumetrica pendiente CONTRATISTA TOTAL MMBTU
		-- DISTRIBUCION A FAVOR DEL ESTADO
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C1 ELSE 0 END),'###,###,###.###','en-US') AS '2DFEC1', --Distribucion a favor del estado c1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C2 ELSE 0 END),'###,###,###.###','en-US') AS '2DFEC2', --Distribucion a favor del estado c2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C3 ELSE 0 END),'###,###,###.###','en-US') AS '2DFEC3', --Distribucion a favor del estado c3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US') AS '2DFEC4', --Distribucion a favor del estado c4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C2 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US') AS '2DFET', --Distribucion a favor del estado total
		--DISTRIBUCION A FAVOR DEL CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C1 ELSE 0 END),'###,###,###.###','en-US') AS '2DFCOC1', --Distribucion a favor del CONTRATISTA c1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C2 ELSE 0 END),'###,###,###.###','en-US') AS '2DFCOC2', --Distribucion a favor del CONTRATISTA c2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C3 ELSE 0 END),'###,###,###.###','en-US') AS '2DFCOC3', --Distribucion a favor del CONTRATISTA c3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C4 ELSE 0 END),'###,###,###.###','en-US') AS '2DFCOC4', --Distribucion a favor del CONTRATISTA c4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C2 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C4 ELSE 0 END),'###,###,###.###','en-US') AS '2DFCOT', --Distribucion a favor del CONTRATISTA total
		--VOLUMEN TOTAL A FAVOR DEL ESTADO
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN C.Aplicada_C1 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 = 0 THEN C.DistEdo_C1 ELSE 0 END),'###,###,###.###','en-US') AS '2VTFEC1', --Volumen total a favor del estado c1
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN C.Aplicada_C2 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 = 0 THEN C.DistEdo_C2 ELSE 0 END),'###,###,###.###','en-US') AS '2VTFEC2', --Volumen total a favor del estado c2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN C.Aplicada_C3 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 = 0 THEN C.DistEdo_C3 ELSE 0 END),'###,###,###.###','en-US') AS '2VTFEC3', --Volumen total a favor del estado c3
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN C.Aplicada_C4 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 = 0 THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US') AS '2VTFEC4', --Volumen total a favor del estado c4
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 <> 0 THEN C.Aplicada_C1 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C1 = 0 THEN C.DistEdo_C1 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 <> 0 THEN C.Aplicada_C2 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C2 = 0 THEN C.DistEdo_C2 ELSE 0 END) +
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 <> 0 THEN C.Aplicada_C3 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C3 = 0 THEN C.DistEdo_C3 ELSE 0 END) + 
			SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 <> 0 THEN C.Aplicada_C4 WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada_C4 = 0 THEN C.DistEdo_C4 ELSE 0 END),'###,###,###.###','en-US')	 AS '2VTFET', --Volumen total a favor del estado total
		-- VOLUMEN TOTAL A FAVOR DEL CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C1 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C1 ELSE 0 END)*-1), '###,###,###.###','en-US')	AS [2VTFCOC1],	-- Volumen Total a Favor del CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C2 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C2 ELSE 0 END)*-1), '###,###,###.###','en-US')	AS [2VTFCOC2],	-- Volumen Total a Favor del CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C3 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C3 ELSE 0 END)*-1), '###,###,###.###','en-US')	AS [2VTFCOC3],	-- Volumen Total a Favor del CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C4 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C4 ELSE 0 END)*-1), '###,###,###.###','en-US')	AS [2VTFCOC4],	-- Volumen Total a Favor del CONTRATISTA
		FORMAT((SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C1 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C1 ELSE 0 END)*-1))+
			(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C2 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C2 ELSE 0 END)*-1))+
			(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C3 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C3 ELSE 0 END)*-1))+
			(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContra_C4 ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion_C4 ELSE 0 END)*-1)), '###,###,###.###','en-US')	AS [2VTFCOT],

		-------------------------- TOTALES --------------------------
		FORMAT(SUM(C.TotalMMBTUEdo_C1C4),'###,###,###.###','en-US')			AS 'TMMBTUE', --total MMBTU Estado
		FORMAT(SUM(C.Edo_MMPC_C1C4),'###,###,###.######','en-US')			AS 'TMMPCE',	-- total MMPC Estado
		FORMAT(SUM(C.TotalMMBTUContra_C1C4),'###,###,###.###','en-US')		AS 'TMMBTUCO',	-- TOTAL MMBTU CONTRATISTA
		FORMAT(SUM(C.Contra_MMPC_C1C4),'###,###,###.######','en-US')		AS 'TMMPCCO',	-- TOTAL MMPC CONTRATISTA
		ISNULL(@ContratistaRecibe,'REPRESENTANTE OPERATIVO PEP')	AS Recibe,
		ISNULL(@ContratistaEntrega,'REPRESENTANTE OPERATIVO OPERADOR')	AS Entrega
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
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,'')							AS B11,
			CONVERT(VARCHAR(10),@MesReporte,105)												AS I14, 
			CONVERT(VARCHAR(10),DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)),105)			AS I15, 
			ISNULL(CO.GasEntregadoA,'')					AS B10, 
			-- PONER LA FECHA EN LA QUE SE CARGA EL FORMATO
			CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105)			AS K13, 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn)			    AS J20,
			ISNULL(CO.GasTransporte,'')					AS J22,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')			AS A25,
-- 3 DECIMALES ---------------------------------------------------------------------------------
			FORMAT(SUM(ROUND(C.M3_20C_GasEntregado,3)),'###,###,###.###','en-US')						AS G31, --VOLUMEN TOTAL M3 a 20°
			FORMAT(SUM(C.MMPC_20C_GasEntregado),'###,###,###.######','en-US')						AS H31, --VOLUMEN TOTAL MMPC a 20°
			'(' + LTRIM(ISNULL(PC.PorcentajeSocio,@PorcDefault)) + '%)'				AS L29,	-- PORCENTAJE OPERADOR
			FORMAT(SUM(ROUND(C.M3_20C_GasEntregado,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')	AS J31,	-- VOLUMEN DEL OPERADOR M3 A 20°
			FORMAT(SUM(C.MMPC_20C_GasEntregado * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.######','en-US')	AS K31,	-- VOLUMEN DEL OPERADOR MMPC A 20°
			FORMAT(SUM(ROUND(C.M3_60_F,3)),'###,###,###.###','en-US')									AS G37, --VOLUMEN TOTAL M3 a 15°
			FORMAT(SUM(C.MMPC_60F_Gas),'###,###,###.######','en-US')								AS H37, --VOLUMEN TOTAL MMPC a 15°
			FORMAT(SUM(ROUND(C.MMBTU_60F,3)),'###,###,###.###','en-US')									AS I37,	--MMBTU A 15°
			FORMAT(SUM(ROUND(C.M3_60_F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS J37,	-- VOLUMEN DEL OPERADOR M3 A 15°
			--FORMAT(SUM(ROUND(C.MMPC_60F_Gas,6) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.######','en-US')	AS K37,	-- VOLUMEN DEL OPERADOR MMPC A 15°
			FORMAT(SUM(ROUND(C.MMPC_60F_Gas,6)) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),'###,###,###.#######','en-US')	AS K37,	-- VOLUMEN DEL OPERADOR MMPC A 15°
			FORMAT(SUM(ROUND(C.MMBTU_60F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS L37,	-- VOLUMEN DEL OPERADOR MMBTU
------ 4 DECIMALES
--			FORMAT(SUM(C.M3_20C_GasEntregado),'###,###,###.####','en-US')						AS G31, --VOLUMEN TOTAL M3 a 20°
--			CASE WHEN SUBSTRING(FORMAT(SUM(C.MMPC_20C_GasEntregado),'###,###,###.######','en-US'),1,1) = '.'
--				THEN '0'+FORMAT(SUM(C.MMPC_20C_GasEntregado),'###,###,###.######','en-US')
--				ELSE FORMAT(SUM(C.MMPC_20C_GasEntregado),'###,###,###.######','en-US')			END			AS H31, --VOLUMEN TOTAL MMPC a 20°
--			'(' + LTRIM(ISNULL(PC.PorcentajeSocio,@PorcDefault)) + '%)'				AS L29,	-- PORCENTAJE OPERADOR
--			FORMAT(SUM(C.M3_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')	AS J31,	-- VOLUMEN DEL OPERADOR M3 A 20°
--			CASE WHEN SUBSTRING(FORMAT(SUM(C.MMPC_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.######','en-US'),1,1) = '.'
--				THEN '0'+FORMAT(SUM(C.MMPC_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.######','en-US')
--				ELSE FORMAT(SUM(C.MMPC_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.######','en-US')	END		AS K31,	-- VOLUMEN DEL OPERADOR MMPC A 20°
--			FORMAT(SUM(C.M3_60_F),'###,###,###.####','en-US')									AS G37, --VOLUMEN TOTAL M3 a 15°
--			CASE WHEN SUBSTRING(FORMAT(SUM(C.MMPC_60F_Gas),'###,###,###.######','en-US'),1,1) = '.'
--				THEN '0'+FORMAT(SUM(C.MMPC_60F_Gas),'###,###,###.######','en-US')
--				ELSE FORMAT(SUM(C.MMPC_60F_Gas),'###,###,###.######','en-US')			END					AS H37, --VOLUMEN TOTAL MMPC a 15°
--			FORMAT(SUM(C.MMBTU_60F),'###,###,###.####','en-US')									AS I37,	--MMBTU A 15°
--			FORMAT(SUM(C.M3_60_F * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')		AS J37,	-- VOLUMEN DEL OPERADOR M3 A 15°
--			CASE WHEN SUBSTRING(FORMAT(SUM(C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.######','en-US'),1,1) = '.'
--				THEN '0'+FORMAT(SUM(C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.######','en-US')
--				ELSE FORMAT(SUM(C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.######','en-US')	END				AS K37,	-- VOLUMEN DEL OPERADOR MMPC A 15°
--			FORMAT(SUM(C.MMBTU_60F * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')		AS L37,	-- VOLUMEN DEL OPERADOR MMBTU
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
			------------- TOTALES MMBTU POR COMPONENTE -------------------------
			FORMAT(SUM(ROUND(C.MMBTU_C1,3)),'###,###,###.###','en-US')			AS I43, --Total componente c1
			FORMAT(SUM(ROUND(C.MMBTU_C2,3)),'###,###,###.###','en-US')			AS I44, --Total componente c2
			FORMAT(SUM(ROUND(C.MMBTU_C3,3)),'###,###,###.###','en-US')			AS I45, --Total componente c3
			FORMAT(SUM(ROUND(C.MMBTU_C4,3)),'###,###,###.###','en-US')			AS I46, --Total componente c4
			FORMAT(SUM((ROUND(C.MMBTU_C1,3) + ROUND(C.MMBTU_C2,3) + ROUND(C.MMBTU_C3,3) + ROUND(C.MMBTU_C4,3))),'###,###,###.###','en-US')		AS I48,
			------------- TOTALES  A FAVOR DE PEP MMBTU POR COMPONENTE -------------------------
			FORMAT(SUM(ROUND(ROUND(C.MMBTU_C1,3) * (ISNULL(PC.PorcentajePemex,@PorcDefault)/@PorcDefault),4)),'###,###,###.####','en-US')		AS J43, --Total PEP componente c1
			FORMAT(SUM(ROUND(C.MMBTU_C2,3) * (ISNULL(PC.PorcentajePemex,@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS J44, --Total PEP componente c2
			FORMAT(SUM(ROUND(C.MMBTU_C3,3) * (ISNULL(PC.PorcentajePemex,@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS J45, --Total PEP componente c3
			FORMAT(SUM(ROUND(C.MMBTU_C4,3) * (ISNULL(PC.PorcentajePemex,@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS J46, --Total PEP componente c4
			FORMAT(SUM(( ROUND(C.MMBTU_C1,3) + ROUND(C.MMBTU_C2,3) + ROUND(C.MMBTU_C3,3) + ROUND(C.MMBTU_C4,3))	* (ISNULL(PC.PorcentajePemex,@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')	AS J48,
			------------- TOTALES  A FAVOR DEL OPERADOR MMBTU POR COMPONENTE -------------------------
			FORMAT(SUM(ROUND(C.MMBTU_C1,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS K43, --Total PEP componente c1
			FORMAT(SUM(ROUND(C.MMBTU_C2,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS K44, --Total PEP componente c2
			FORMAT(SUM(ROUND(C.MMBTU_C3,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS K45, --Total PEP componente c3
			FORMAT(SUM(ROUND(C.MMBTU_C4,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')		AS K46, --Total PEP componente c4
			FORMAT(SUM((ROUND(C.MMBTU_C1,3) + ROUND(C.MMBTU_C2,3) + ROUND(C.MMBTU_C3,3) + ROUND(C.MMBTU_C4,3))	* (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')	AS K48,
			----------- TOTALES ------------------------------
			FORMAT(SUM((ROUND(C.MMPC_60F_Gas*1000,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault))),'###,###,###.####','en-US')	AS J53,	-- GAS FORMACION
			CASE WHEN SUM((ROUND((ISNULL(R.MMPC20BN,0)/@FactorConv20c15_5)*1000,3))*(ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)) = 0 THEN '0'
				ELSE FORMAT(SUM((ROUND((ISNULL(R.MMPC20BN,0)/@FactorConv20c15_5)*1000,3))*(ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')
			END				 AS	I53,	-- GAS BN
			FORMAT(SUM((ROUND(C.MMPC_60F_Gas*1000,3)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+((ROUND(ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000,3)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)))),'###,###,###.####','en-US')	AS H53	-- VOLUMEN TOTAL
-- 4 DECIMALES
			--------------- TOTALES MMBTU POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C1),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C1),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C1),'###,###,###.####','en-US')		END			AS I43, --Total componente c1
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C2),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C2),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C2),'###,###,###.####','en-US')		END			AS I44, --Total componente c2
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C3),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C3),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C3),'###,###,###.####','en-US')		END			AS I45, --Total componente c3
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C4),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C4),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C4),'###,###,###.####','en-US')		END			AS I46, --Total componente c4
			--CASE WHEN SUBSTRING(FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)),'###,###,###.####','en-US')	END		AS I48,
			--------------- TOTALES  A FAVOR DE PEP MMBTU POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C1 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C1 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C1 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')		END			AS J43, --Total PEP componente c1
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C2 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C2 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C2 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')		END			AS J44, --Total PEP componente c2
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C3 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C3 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C3 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')		END			AS J45, --Total PEP componente c3
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C4 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C4 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C4 * (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')		END			AS J46, --Total PEP componente c4
			--CASE WHEN SUBSTRING(FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)	* (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)	* (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)	* (PC.PorcentajePemex/@PorcDefault)),'###,###,###.####','en-US')	END		AS J48,
			--------------- TOTALES  A FAVOR DEL OPERADOR MMBTU POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C1 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C1 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C1 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')		END			AS K43, --Total PEP componente c1
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C2 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C2 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C2 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')		END			AS K44, --Total PEP componente c2
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C3 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C3 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C3 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')		END			AS K45, --Total PEP componente c3
			--CASE WHEN SUBSTRING(FORMAT(SUM(C.MMBTU_C4 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM(C.MMBTU_C4 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM(C.MMBTU_C4 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')		END			AS K46, --Total PEP componente c4
			--CASE WHEN SUBSTRING(FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)	* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)	* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')
			--	ELSE FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)	* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US')	END			AS K48,
			------------- TOTALES ------------------------------
			--FORMAT(SUM((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000)),'###,###,###.####','en-US')	AS J53,	-- GAS FORMACION
			--CASE WHEN SUM(((ISNULL(R.MMPC20BN,0)/@FactorConv20c15_5)*1000)*(ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)) = 0 THEN '0'
			--	ELSE FORMAT(SUM(((ISNULL(R.MMPC20BN,0)/@FactorConv20c15_5)*1000)*(ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.####','en-US')
			--END				 AS	I53,	-- GAS BN
			--FORMAT(SUM((C.MMPC_60F_Gas*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000)+((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))*1000)),'###,###,###.####','en-US')	AS H53	-- VOLUMEN TOTAL			
		FROM
			SCOC_CalculoDiario_Gas C
		JOIN
			dbo.SCOC_ReporteDiarioGas R 
			ON C.IdContrato = R.IdContrato
			AND C.MesReporte = R.MesReporte
			AND C.Dia = R.Dia
			AND C.CampoID	=	R.CampoID
		JOIN
			SCOC_Contrato	CO
			ON	C.IdContrato	=	CO.IdContrato
		LEFT JOIN
			CO_PorcentajesContrato	PC
			ON	C.IdContrato	=	PC.idContrato
		LEFT JOIN
			dbo.SCOC_Campo	CA
			ON	C.CampoID = CA.CampoID
		WHERE
			C.IdContrato = @IdContrato
			AND C.MesReporte = @MesReporte
		GROUP BY
			C.CampoID,
			--CONVERT(VARCHAR(10),R.CreadoEn,105),
			ISNULL(CO.SubdireccionProduccion,''),
			ISNULL(CO.ActivoIntegral,''),
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,''),
			ISNULL(CO.GasEntregadoA,''), 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn),
			ISNULL(CO.GasTransporte,''),
			'CAMPO: ' + ISNULL(CA.NombreCampo,''),
			CONVERT(VARCHAR(10),R.FechaCromatografia,105), 
			ISNULL(PC.PorcentajeSocio,@PorcDefault),
			ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault),
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
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,'')							AS B11,
			CONVERT(VARCHAR(10),@MesReporte,105)												AS I14, 
			CONVERT(VARCHAR(10),DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)),105)			AS I15, 
			ISNULL(CO.GasEntregadoA,'')						AS B10, 
			--CONVERT(VARCHAR(10),@MesReporte,105)			AS K13, 
			-- PONER LA FECHA EN LA QUE SE CARGA EL FORMATO
			--CONVERT(VARCHAR(10),R.CreadoEn,105)			AS K13,
			CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105)			AS K13, 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn)					AS J20,
			ISNULL(CO.GasTransporte,'')						AS J22,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')				AS A25,
		------------------------------------------------------------------------------------
			FORMAT(SUM(C.M3_20C_GasEntregado),'###,###,###.###','en-US')						AS I31, --VOLUMEN TOTAL M3 a 20°
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
			ROUND(R.PM,4)				AS E53, 
			ROUND(R.DensidadRelativa,4)	AS E54, 
			FORMAT(R.PoderCalBTU,'###,###,###.####','en-US')		AS E55,
			CASE WHEN CO.AplicaFactorCompresibilidad = 1
					THEN 'Factor de Compresibilidad: ' + LTRIM(ISNULL(C.FactorCompresibilidad,0))
			ELSE ''		END											AS B56,
			------------- TOTALES MMBTU POR COMPONENTE -------------------------
			FORMAT(SUM(C.MMBTU_C1),'###,###,###.###','en-US')			AS I43, --Total componente c1
			FORMAT(SUM(C.MMBTU_C2),'###,###,###.###','en-US')			AS I44, --Total componente c2
			FORMAT(SUM(C.MMBTU_C3),'###,###,###.###','en-US')			AS I45, --Total componente c3
			FORMAT(SUM(C.MMBTU_C4),'###,###,###.###','en-US')			AS I46, --Total componente c4
			FORMAT(SUM((C.MMBTU_C1 + C.MMBTU_C2 + C.MMBTU_C3 + C.MMBTU_C4)),'###,###,###.###','en-US')		AS I48,
			----------- TOTALES --------------------------
			FORMAT(SUM((C.MMPC_60F_Gas*1000)),'###,###,###.###','en-US')	AS J53,	-- GAS FORMACION
			CASE WHEN SUM(ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000) = 0 THEN '0'
				ELSE FORMAT(SUM(ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000),'###,###,###.###','en-US')
			END				 AS	I53,	-- GAS BN
			FORMAT(SUM((C.MMPC_60F_Gas*1000) + (ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)),'###,###,###.###','en-US')	AS H53	-- VOLUMEN TOTAL
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
		LEFT JOIN
			dbo.SCOC_Campo	CA
			ON	C.CampoID = CA.CampoID
		WHERE
			C.IdContrato = @IdContrato
			AND C.MesReporte = @MesReporte
		GROUP BY
			C.CampoID,
			--CONVERT(VARCHAR(10),R.CreadoEn,105),
			ISNULL(CO.SubdireccionProduccion,''),
			ISNULL(CO.ActivoIntegral,''),
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,''),
			ISNULL(CO.GasEntregadoA,''), 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn),
			ISNULL(CO.GasTransporte,''),
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
			ROUND(R.PM,4),
			ROUND(R.DensidadRelativa,4),
			FORMAT(R.PoderCalBTU,'###,###,###.####','en-US'),
			CASE WHEN CO.AplicaFactorCompresibilidad = 1
					THEN 'Factor de Compresibilidad: ' + LTRIM(ISNULL(C.FactorCompresibilidad,0))
			ELSE ''		END
	END
END

END
