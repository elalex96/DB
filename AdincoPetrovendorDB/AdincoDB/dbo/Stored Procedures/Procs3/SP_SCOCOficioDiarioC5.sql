CREATE PROCEDURE dbo.SP_SCOCOficioDiarioC5
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
SET NOCOUNT ON;
-- =============================================
SET LANGUAGE spanish

DECLARE
	@EsProduccionCompartida BIT,
	@NumeroContrato VARCHAR(100),
	@FechaCorte DATE,
	@PorcDistEdo_Per1 FLOAT,
	@PorcDistEdo_Per2 FLOAT,
	@AreaContractual	VARCHAR(250),
	@EsLicencia		BIT,
	@EsConsorcio	BIT,
	@FactorConv20c15_5	FLOAT = 1.015394385,
	@PorcDefault FLOAT = 100,
	@ApruebaPEP		BIT,
	@ContratistaRecibe	VARCHAR(500),
	@ContratistaEntrega	VARCHAR(500)

SELECT
	@EsProduccionCompartida = CASE	WHEN CO.IdTipoContrato = 2	THEN 1
                                    ELSE 0	END, 
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
		IdTipoArchivo = 1	-- Producción Compartida Dia Gas Edo

	IF @ApruebaPEP = 0
	BEGIN
		SELECT
			@ContratistaRecibe	=	EntregaGas
		FROM 
			dbo.SCOC_TipoArchivos
		WHERE
			IdTipoArchivo = 27	-- contratista gas
	END

    SELECT @FechaCorte = IdFecha
    FROM AP_Calendario
    WHERE Anio = YEAR(@MesReporte)
        AND Mes = MONTH(@MesReporte)
        AND Descripcion = 'Resultados y Elementos del Cálculo (Fecha máxima)';

    SELECT
		@PorcDistEdo_Per1 = RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)]
    --PorcDistContra	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)],
    FROM
		dbo.PC_RM RM53
    WHERE
		RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -2, @MesReporte))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -2, @MesReporte))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato;

    SELECT
		@PorcDistEdo_Per2 = RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)]
    --PorcDistContra	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)],
    FROM
		dbo.PC_RM RM53
    WHERE
		RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -1, @MesReporte))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -1, @MesReporte))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato;


    SELECT
	-------------------------------ENCABEZADO-----------------------------------------------------
		@NumeroContrato					AS Contrato,
		C.CampoID,
		ISNULL(CO.SubdireccionProduccion,'')	AS NombreBloque, 
		ISNULL(CO.ActivoIntegral,'')			AS ClaveBloque,
        @PorcDistEdo_Per1				AS PorcentajeFE, 
        DAY(@MesReporte)				AS PrimerDia, 
        DAY(@FechaCorte)				AS UltimoDia, 
        DATENAME(MONTH, @MesReporte) AS Mes, 
        YEAR(@MesReporte)			AS Año, 
        @PorcDistEdo_Per2			AS PorcentajeFE2, 
        DAY(DATEADD(DAY, 1, @FechaCorte)) AS PrimerDia2, 
        DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) AS UltimoDia2, 
		ISNULL(CO.GasEntregadoA,'')				AS EntregaA, 
		ISNULL(CO.GasEntregadoEn,'')			AS EntregaEn, 
        ISNULL(CO.GasTransporte,'')				AS Transport, 
        CONVERT(VARCHAR(10),C.FechaEntrega, 105) AS FechaE, 
	------------------------------------------------------------------------------------
        FORMAT(C.M3_20C_GasEntregado,'###,###,###.###','en-US')		AS VEM320, --VOLUMEN TOTAL M3 a 20°
        FORMAT(C.MMPC_20C_GasEntregado,'###,###,###.######','en-US')	AS VEMMPC20, --VOLUMEN TOTAL MMPC a 20°
        FORMAT(C.M3_60_F,'###,###,###.###','en-US')					AS VEM315, --VOLUMEN TOTAL M3 a 15°
        FORMAT(C.MMPC_60F_Gas,'###,###,###.######','en-US')			AS VMMPC15, --VOLUMEN TOTAL MMPC a 15°
        FORMAT(C.MMBTU_60F,'###,###,###.###','en-US')				AS MMBTU,
        ------------------CROMATOGRAFÍA--------------------
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
        -------------------- TOTAL POR COMPONENTE PERIODO 1 ----------------------------------
        FORMAT(C.MMBTU_C5,'###,###,###.###','en-US')				AS TC5, --Total componente c5
        FORMAT(C.Compensacion_C5,'###,###,###.###','en-US')			AS FEC5, -- Compensacion Favor ESTADO c5
		FORMAT((C.Compensacion_C5*-1),'###,###,###.###','en-US')	AS FCOC5,	-- Compensacion Volumetrica a Favor del CONTRATISTA
		FORMAT(CASE WHEN C.Aplicada_C5 <> 0 THEN C.Aplicada_C5 - C.DistEdo_C5 ELSE 0 END,'###,###,###.###','en-US')				 AS CVAC5, --Compensacion Volumetrica Aplicada c5
        FORMAT(C.Pendiente_C5,'###,###,###.###','en-US')			AS CVPC5, --Compensacion Volumetrica pendiente c5
        C.PorcDistEdo												AS DFEPor, --Distribucion a favor del ESTADO porcentaje
		C.PorcDistContra											AS DCOPor,	-- Porcentaje a favor del CONTRATISTA
        FORMAT(C.DistEdo_C5,'###,###,###.###','en-US')				AS DFEC5, --Distribucion a favor del ESTADO c5
		FORMAT(C.DistContra_C5,'###,###,###.###','en-US')			AS DFCOC5,	-- Distribución a Favor del CONTRATISTA
		FORMAT((CASE WHEN C.Aplicada_C5 <> 0 THEN C.Aplicada_C5 ELSE C.DistEdo_C5 END),'###,###,###.###','en-US')	AS VTFEC5,		-- Volumen Total a Favor del ESTADO
		FORMAT(C.DistContra_C5 + (C.Compensacion_C5*-1),'###,###,###.###','en-US')	AS VTFCOC5,	-- Volumen Total a Favor del CONTRATISTA
        FORMAT(C.TotalMMBTUEdo_C5,'###,###,###.###','en-US')		AS TC5BTU, --Total C5 MMBTU
        FORMAT(C.Edo_MMPC_C5,'###,###,###.######','en-US')			AS TC5MP, --Total C5 MMPC
        FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US')		AS TBLSC5, -- Total condensado BLS 
        FORMAT(C.Compensacion_Barriles,'###,###,###.###','en-US')	AS CVTBLS, --Compensacion volumetrica Total BLS
        FORMAT(C.Aplicada_Barriles,'###,###,###.###','en-US')		AS CVABLS, --Compensacion volumetrica aplicada BLS 
        FORMAT(C.Pendiente_Barriles,'###,###,###.###','en-US')		AS CVPBLS, --Compensacion volumetrica pendiente BLS 
        FORMAT(C.DistBarriles,'###,###,###.###','en-US')			AS DFEBLS, --Distribucion a favor del estado BLS
        FORMAT((CASE WHEN Aplicada_Barriles <> 0 THEN C.Aplicada_Barriles ELSE C.DistBarriles END),'###,###,###.###','en-US') AS VTFEBLS,	-- Volumen total a favor del estado BLS
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
    WHERE C.IdContrato = @IdContrato
        AND C.MesReporte = @MesReporte
END
ELSE
BEGIN
-- LICENCIA EN CONSORCIO CON PEMEX
	IF @EsLicencia = 1 AND @EsConsorcio = 1
	BEGIN
		SELECT
			-------------------------------ENCABEZADO-----------------------------------------------------
			@NumeroContrato								AS Contrato,
			C.CampoID,
			'ÁREA CONTRACTUAL ' + @AreaContractual							AS	I7,
			'SUBDIRECCIÓN DE PRODUCCIÓN BLOQUES ' + ISNULL(CO.SubdireccionProduccion,'')	AS F3, 
			'ACTIVO INTEGRAL DE PRODUCCIÓN BLOQUE ' + ISNULL(CO.ActivoIntegral,'')			AS G4,
			CONVERT(VARCHAR(10),C.FechaReporte, 105) + ' 05:00 AM'							AS I14,
			CONVERT(VARCHAR(10),DATEADD(DAY,1,C.FechaReporte), 105) + ' 05:00 AM'			AS I15,
			ISNULL(CO.GasEntregadoA,'')					AS B10, 
			CONVERT(VARCHAR(10),C.FechaEntrega, 105)			AS K13, 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn)				AS J20,
			ISNULL(CO.GasTransporte,'')					AS J22,
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,'')							AS B11,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')			AS A25,
		--------------------------------------3 DECIMALES ----------------------------------------------
			FORMAT(C.M3_20C_GasEntregado,'###,###,###.###','en-US')											AS G31, --VOLUMEN TOTAL M3 a 20°
			CASE WHEN ISNULL(C.MMPC_20C_GasEntregado,0) = 0 THEN '0'
				WHEN SUBSTRING(FORMAT(C.MMPC_20C_GasEntregado,'###,###,###.######','en-US'),1,1) = '.'
					THEN '0'+FORMAT(C.MMPC_20C_GasEntregado,'###,###,###.######','en-US')
				ELSE FORMAT(C.MMPC_20C_GasEntregado,'###,###,###.######','en-US')		END					AS H31, --VOLUMEN TOTAL MMPC a 20°
			'(' + LTRIM(ISNULL(PC.PorcentajeSocio,100)) + '%)'												AS L29,	-- PORCENTAJE OPERADOR
			--FORMAT(C.M3_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')	AS J31,	-- VOLUMEN DEL OPERADOR M3 A 20°
			--CASE WHEN ISNULL(C.MMPC_20C_GasEntregado,0) = 0 THEN '0'
			--	WHEN SUBSTRING(FORMAT(C.MMPC_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US'),1,1) = '.'
			--		THEN '0'+FORMAT(C.MMPC_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US')
			--	ELSE FORMAT(C.MMPC_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US')	END	AS K31,	-- VOLUMEN DEL OPERADOR MMPC A 20°
			--FORMAT(C.M3_60_F,'###,###,###.###','en-US')														AS G37, --VOLUMEN TOTAL M3 a 15°
			--CASE WHEN ISNULL(C.MMPC_60F_Gas,0) = 0 THEN '0'
			--	WHEN SUBSTRING(FORMAT(C.MMPC_60F_Gas,'###,###,###.######','en-US'),1,1) = '.'
			--		THEN '0'+FORMAT(C.MMPC_60F_Gas,'###,###,###.######','en-US')
			--	ELSE FORMAT(C.MMPC_60F_Gas,'###,###,###.######','en-US')			END						AS H37, --VOLUMEN TOTAL MMPC a 15°
			--CASE WHEN ISNULL(C.MMBTU_60F,0) = 0 THEN '0'
			--	WHEN SUBSTRING(FORMAT(C.MMBTU_60F,'###,###,###.###','en-US'),1,1) = '.'
			--		THEN '0'+FORMAT(C.MMBTU_60F,'###,###,###.###','en-US')
			--	ELSE FORMAT(C.MMBTU_60F,'###,###,###.###','en-US')					END						AS I37,	--MMBTU A 15°
			--FORMAT(C.M3_60_F * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),'###,###,###.###','en-US')		AS J37,	-- VOLUMEN DEL OPERADOR M3 A 15°
			--CASE WHEN ISNULL(C.MMPC_60F_Gas,0) = 0 THEN '0'
			--	WHEN SUBSTRING(FORMAT(C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US'),1,1) = '.'
			--		THEN '0'+FORMAT(C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US')
			--	ELSE FORMAT(C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US')	END		AS K37,	-- VOLUMEN DEL OPERADOR MMPC A 15°
			--CASE WHEN ISNULL(C.MMBTU_60F,0) = 0 THEN '0'
			--	WHEN SUBSTRING(FORMAT(C.MMBTU_60F * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US'),1,1) = '.'
			--		THEN '0'+FORMAT(C.MMBTU_60F * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')
			--	ELSE FORMAT(C.MMBTU_60F * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')		END		AS L37,	-- VOLUMEN DEL OPERADOR MMBTU
			-------------------------- 4 DECIMALES ----------------------
			--FORMAT(C.M3_20C_GasEntregado,'###,###,###.####','en-US')											AS G31, --VOLUMEN TOTAL M3 a 20°
			--CASE WHEN ISNULL(C.MMPC_20C_GasEntregado,0) = 0 THEN '0'
			--	WHEN SUBSTRING(FORMAT(C.MMPC_20C_GasEntregado,'###,###,###.######','en-US'),1,1) = '.'
			--		THEN '0'+FORMAT(C.MMPC_20C_GasEntregado,'###,###,###.######','en-US')
			--	ELSE FORMAT(C.MMPC_20C_GasEntregado,'###,###,###.######','en-US')		END					AS H31, --VOLUMEN TOTAL MMPC a 20°
			--'(' + LTRIM(ISNULL(PC.PorcentajeSocio,100)) + '%)'												AS L29,	-- PORCENTAJE OPERADOR
			CASE WHEN CONVERT(INT,ROUND(C.M3_20C_GasEntregado,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50
				THEN FORMAT( ((ROUND(C.M3_20C_GasEntregado,3)-.001) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(C.M3_20C_GasEntregado * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),'###,###,###.###','en-US')	END		AS J31,	-- VOLUMEN DEL OPERADOR M3 A 20°

			CASE WHEN ISNULL(C.MMPC_20C_GasEntregado,0) = 0 THEN '0'
				WHEN CONVERT(INT,ROUND(C.MMPC_20C_GasEntregado,6) * 1000000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.MMPC_20C_GasEntregado,6) < 1
				  THEN '0'+FORMAT(((ROUND(C.MMPC_20C_GasEntregado,6)-.000001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0000005,'###,###,###.#######','en-US')
				WHEN CONVERT(INT,ROUND(C.MMPC_20C_GasEntregado,6) * 1000000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.MMPC_20C_GasEntregado,6) > 1
				  THEN FORMAT(((ROUND(C.MMPC_20C_GasEntregado,6)-.000001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0000005,'###,###,###.#######','en-US')
				ELSE FORMAT(C.MMPC_20C_GasEntregado * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US') END	AS K31,	-- VOLUMEN DEL OPERADOR MMPC A 20°

			FORMAT(C.M3_60_F,'###,###,###.###','en-US')														AS G37, --VOLUMEN TOTAL M3 a 15°

			CASE WHEN ISNULL(C.MMPC_60F_Gas,0) = 0 THEN '0'
				WHEN SUBSTRING(FORMAT(C.MMPC_60F_Gas,'###,###,###.######','en-US'),1,1) = '.'
					THEN '0'+FORMAT(C.MMPC_60F_Gas,'###,###,###.######','en-US')
				ELSE FORMAT(C.MMPC_60F_Gas,'###,###,###.######','en-US')			END						AS H37, --VOLUMEN TOTAL MMPC a 15°
			CASE WHEN ISNULL(C.MMBTU_60F,0) = 0 THEN '0'
				WHEN SUBSTRING(FORMAT(C.MMBTU_60F,'###,###,###.###','en-US'),1,1) = '.'
					THEN '0'+FORMAT(C.MMBTU_60F,'###,###,###.###','en-US')
				ELSE FORMAT(C.MMBTU_60F,'###,###,###.###','en-US')					END						AS I37,	--MMBTU A 15°

			CASE WHEN CONVERT(INT,ROUND(C.M3_60_F,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.M3_60_F,3) < 1
				THEN '0'+FORMAT((((ROUND(C.M3_60_F,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005),'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.M3_60_F,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.M3_60_F,3) > 1
				THEN FORMAT((((ROUND(C.M3_60_F,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005),'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.M3_60_F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),'###,###,###.###','en-US')	END		AS J37,	-- VOLUMEN DEL OPERADOR M3 A 15°

			CASE WHEN ISNULL(C.MMPC_60F_Gas,0) = 0 THEN '0'
				WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas* 1000000,6) )%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.MMPC_60F_Gas,6) < 1
					THEN '0'+FORMAT( ((ROUND(C.MMPC_60F_Gas,6)-.000001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0000005,'###,###,###.#######','en-US')
				WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas* 1000000,6) )%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.MMPC_60F_Gas,6) > 1
					THEN FORMAT( ((ROUND(C.MMPC_60F_Gas,6)-.000001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0000005,'###,###,###.#######','en-US')
				ELSE FORMAT(ROUND(C.MMPC_60F_Gas,6) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US')	END		AS K37,	-- VOLUMEN DEL OPERADOR MMPC A 15°

			CASE WHEN ISNULL(C.MMBTU_60F,0) = 0 THEN '0'
				WHEN CONVERT(INT, CONVERT(DECIMAL(12,4),ROUND(C.MMBTU_60F,3)) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.MMBTU_60F,3) < 1
					THEN '0'+FORMAT( ((ROUND(C.MMBTU_60F,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+0.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT, CONVERT(DECIMAL(12,4),ROUND(C.MMBTU_60F,3)) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.MMBTU_60F,3) > 1
					THEN FORMAT( ((ROUND(C.MMBTU_60F,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+0.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.MMBTU_60F,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')		END		AS L37,	-- VOLUMEN DEL OPERADOR MMBTU

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
			ELSE ''		END										AS B56,
-- 3 DEICMALES
			--------------- TOTALES MMBTU POR COMPONENTE -------------------------
			CASE WHEN SUBSTRING(FORMAT(C.MMBTU_C5,'###,###,###.###','en-US'),1,1) = '.' 
					THEN '0'+FORMAT(C.MMBTU_C5,'###,###,###.###','en-US')
				WHEN FORMAT(C.MMBTU_C5,'###,###,###.###','en-US') = '' THEN '0'
				ELSE FORMAT(C.MMBTU_C5,'###,###,###.###','en-US')	END				AS I42,
			--------------- TOTALES  A FAVOR DE PEP MMBTU POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US')
			--	WHEN FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US') = '' THEN '0'
			--	ELSE FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US')	END					AS J42, --Total PEP componente c5
			--------------- TOTALES  A FAVOR DEL OPERADOR MMBTU POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')
			--	WHEN FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US') = '' THEN '0'
			--	ELSE FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')	END					AS K42, --Total OPERADOR componente c5
			--------------- TOTALES BBL POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US')
			--	WHEN FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US') = '' THEN '0'
			--	ELSE FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US')	END																AS I46,	-- TOTAL BARRILES C5
			--------------- TOTALES  A FAVOR DE PEP BBL POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US')
			--	WHEN FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US') = '' THEN '0'
			--	ELSE FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US')	END			AS J46, --Total PEP componente BBL
			--------------- TOTALES  A FAVOR DEL OPERADOR BBL POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')
			--	WHEN FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US') = '' THEN '0'
			--	ELSE FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')	END			AS K46, --Total OPERADOR componente BBL
		 --  -- **************************** VOLUMENES TOTALES  ****************************
			--CASE WHEN SUBSTRING(FORMAT((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000),'###,###,###.######','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000),'###,###,###.######','en-US')
			--	WHEN FORMAT((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000),'###,###,###.######','en-US') = '' THEN '0'
			--	ELSE FORMAT((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000),'###,###,###.######','en-US')	END		AS K53,	-- GAS FORMACION
			--CASE WHEN ISNULL(R.MMPC20BN,0) = 0 THEN '0'
			--	ELSE FORMAT((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.######','en-US')
			--END			 AS	L53,	-- GAS BN O RESIDUAL?
			--CASE WHEN SUBSTRING(FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')
			--	WHEN FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US') = '' THEN '0'
			--	ELSE FORMAT(C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')	END			AS I53,	-- TOTAL BARRILES OPERADOR
			--CASE WHEN SUBSTRING(FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US'),1,1) = '.'
			--	THEN '0'+FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')
			--	WHEN FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US') = '' THEN '0'
			--	ELSE FORMAT(C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')			END			AS J53,	-- TOTAL MMBTU OPERADOR
			--FORMAT((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)/1000) + ((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.######','en-US')	AS H53	-- VOLUMEN TOTAL
-- 4 DECIMALES
			------------- TOTALES MMBTU POR COMPONENTE -------------------------
			--CASE WHEN SUBSTRING(FORMAT(C.MMBTU_C5,'###,###,###.####','en-US'),1,1) = '.' 
			--		THEN '0'+FORMAT(C.MMBTU_C5,'###,###,###.####','en-US')
			--	WHEN FORMAT(C.MMBTU_C5,'###,###,###.####','en-US') = '' THEN '0'
			--	ELSE FORMAT(C.MMBTU_C5,'###,###,###.####','en-US')	END				AS I42,
			------------- TOTALES  A FAVOR DE PEP MMBTU POR COMPONENTE -------------------------
			CASE WHEN CONVERT(INT,ROUND(C.MMBTU_C5,3) * 1000)%2 = 1 AND PC.PorcentajePemex = 50 AND C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault) < 1
				THEN '0'+ FORMAT( ((ROUND(C.MMBTU_C5,3)-.001) * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.MMBTU_C5,3) * 1000)%2 = 1 AND PC.PorcentajePemex = 50 AND C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault) > 1
				THEN FORMAT( ((ROUND(C.MMBTU_C5,3)-.001) * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US')		END		AS J42, --Total PEP componente c5
			------------- TOTALES  A FAVOR DEL OPERADOR MMBTU POR COMPONENTE -------------------------
			CASE WHEN CONVERT(INT,ROUND(C.MMBTU_C5,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) < 1
				THEN '0'+ FORMAT( ((ROUND(C.MMBTU_C5,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.MMBTU_C5,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) > 1
				THEN FORMAT( ((ROUND(C.MMBTU_C5,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')		END		AS K42, --Total OPERADOR componente c5
			------------- TOTALES BBL POR COMPONENTE -------------------------
			CASE WHEN SUBSTRING(FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US'),1,1) = '.'
				THEN '0'+FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US')
				WHEN FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US') = '' THEN '0'
				ELSE FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US')	END																AS I46,	-- TOTAL BARRILES C5
			------------- TOTALES  A FAVOR DE PEP BBL POR COMPONENTE -------------------------
			CASE WHEN CONVERT(INT,ROUND(C.BarrilesC5_Equiv,3) * 1000)%2 = 1 AND PC.PorcentajePemex = 50 AND C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault) < 1
				THEN '0'+ FORMAT( ((ROUND(C.BarrilesC5_Equiv,3)-.001) * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.BarrilesC5_Equiv,3) * 1000)%2 = 1 AND PC.PorcentajePemex = 50 AND C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault) > 1
				THEN FORMAT( ((ROUND(C.BarrilesC5_Equiv,3)-.001) * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajePemex)/@PorcDefault),'###,###,###.###','en-US')		END		AS J46, --Total PEP componente BBL
			------------- TOTALES  A FAVOR DEL OPERADOR BBL POR COMPONENTE -------------------------
			CASE WHEN CONVERT(INT,ROUND(C.BarrilesC5_Equiv,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) < 1
				THEN '0'+ FORMAT( ((ROUND(C.BarrilesC5_Equiv,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.BarrilesC5_Equiv,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) > 1
				THEN FORMAT( ((ROUND(C.BarrilesC5_Equiv,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')		END		AS K46, --Total OPERADOR componente BBL
		   -- **************************** VOLUMENES TOTALES  ****************************
			CASE WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas*1000,3)*1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) < 1
				THEN '0'+FORMAT(((ROUND(C.MMPC_60F_Gas*1000,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas*1000,3)*1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) > 1
				THEN FORMAT(((ROUND(C.MMPC_60F_Gas*1000,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT((ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.###','en-US')	END		AS K53,	-- GAS FORMACION
			CASE WHEN ISNULL(R.MMPC20BN/@FactorConv20c15_5,0) = 0 THEN '0'
				WHEN CONVERT(INT,ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0)*1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND (ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) < 1
				THEN '0' + FORMAT( (((ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0))-.001)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5*1000),3),0)*1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND (ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) > 1
				THEN FORMAT( (((ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0))-.001)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT( ROUND((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000),3)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')
			END			AS	I53,	-- GAS BN O RESIDUAL	MPC

			CASE WHEN CONVERT(INT,ROUND(C.BarrilesC5_Equiv,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) < 1
				THEN '0'+ FORMAT( ((ROUND(C.BarrilesC5_Equiv,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.BarrilesC5_Equiv,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND C.BarrilesC5_Equiv * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) > 1
				THEN FORMAT( ((ROUND(C.BarrilesC5_Equiv,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.BarrilesC5_Equiv,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')		END		AS I53,	-- TOTAL BARRILES OPERADOR

			CASE WHEN CONVERT(INT,ROUND(C.MMBTU_C5,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) < 1
				THEN '0'+ FORMAT( ((ROUND(C.MMBTU_C5,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.MMBTU_C5,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND C.MMBTU_C5 * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) > 1
				THEN FORMAT( ((ROUND(C.MMBTU_C5,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.MMBTU_C5,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US')		END		AS J53,	-- TOTAL MMBTU OPERADOR

			CASE WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas*1000,3)*1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND CONVERT(INT,ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0)*1000)%2 = 1
						AND (ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) + ((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) < 1
				THEN '0'+FORMAT( (((ROUND(C.MMPC_60F_Gas*1000,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005) + 
					((((ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0))-.001)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005) ,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas*1000,3)*1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND CONVERT(INT,ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0)*1000)%2 = 1
						AND (ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) + ((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) > 1
				THEN FORMAT( (((ROUND(C.MMPC_60F_Gas*1000,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005) + 
					((((ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0))-.001)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005) ,'###,###,###.####','en-US')
				 WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas*1000,3)*1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND CONVERT(INT,ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0)*1000)%2 = 0
						AND (ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) + ((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) < 1
				THEN '0'+FORMAT( (((ROUND(C.MMPC_60F_Gas*1000,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005) + 
					((((ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0)))* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))) ,'###,###,###.####','en-US')
				 WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas*1000,3)*1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND CONVERT(INT,ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0)*1000)%2 = 0
						AND (ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) + ((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) > 1
				THEN FORMAT( (((ROUND(C.MMPC_60F_Gas*1000,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005) + 
					ROUND((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) ,3) ,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas*1000,3)*1000)%2 = 0 AND PC.PorcentajeSocio = 50 AND CONVERT(INT,ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0)*1000)%2 = 1
						AND (ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) + ((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) < 1
				THEN '0'+ FORMAT( ROUND((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000),3)	 + 
					((((ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0))-.001)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005) ,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.MMPC_60F_Gas*1000,3)*1000)%2 = 0 AND PC.PorcentajeSocio = 50 AND CONVERT(INT,ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0)*1000)%2 = 1
						AND (ROUND(C.MMPC_60F_Gas*1000,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) + ((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)*(CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)) > 1
				THEN FORMAT( ROUND((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000),3)	 + 
					((((ISNULL(ROUND((R.MMPC20BN/@FactorConv20c15_5)*1000,3),0))-.001)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005) ,'###,###,###.####','en-US')
				ELSE FORMAT((C.MMPC_60F_Gas * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)*1000)+((ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000)* (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.###','en-US')	END		AS H53	-- VOLUMEN TOTAL
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
			--CONVERT(VARCHAR(10),C.FechaReporte, 105)										AS I14,
			--CONVERT(VARCHAR(10),C.FechaReporte, 105)										AS I15,
			CONVERT(VARCHAR(10),C.FechaReporte, 105) + ' 05:00 AM'							AS I14,
			CONVERT(VARCHAR(10),DATEADD(DAY,1,C.FechaReporte), 105) + ' 05:00 AM'			AS I15,
			ISNULL(CO.GasEntregadoA,'')					AS B10, 
			CONVERT(VARCHAR(10),C.FechaEntrega, 105)			AS K13, 
			ISNULL(CA.GasEntregadoEn,CO.GasEntregadoEn)				AS J20, 
			ISNULL(CO.GasTransporte,'')					AS J22,
			'Dirección: ' + ISNULL(CO.DireccionGasEntregadoA,'')							AS B11,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')			AS A25,
		------------------------------------------------------------------------------------
			FORMAT(C.M3_20C_GasEntregado,'###,###,###.###','en-US')					AS I31, --VOLUMEN TOTAL M3 a 20°
			FORMAT(C.MMPC_20C_GasEntregado,'###,###,###.######','en-US')						AS J31, --VOLUMEN TOTAL MMPC a 20°
			FORMAT(C.M3_60_F,'###,###,###.###','en-US')									AS I37, --VOLUMEN TOTAL M3 a 15°
			FORMAT(C.MMPC_60F_Gas,'###,###,###.######','en-US')								AS J37, --VOLUMEN TOTAL MMPC a 15°
			FORMAT(C.MMBTU_60F,'###,###,###.###','en-US')									AS K37,	--MMBTU A 15°
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
			ROUND(R.DensidadRelativa,4)		AS E54, 
			FORMAT(R.PoderCalBTU,'###,###,###.####','en-US')		AS E55,
			------------- TOTALES MMBTU POR COMPONENTE -------------------------
			FORMAT(C.MMBTU_C5,'###,###,###.###','en-US')	AS I42,	--Total componente c5
			------------- TOTALES BBL POR COMPONENTE -------------------------
			FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US')	AS I46,	-- TOTAL BARRILES C5
		   -- **************************** VOLUMENES TOTALES  ****************************
			FORMAT((C.MMPC_60F_Gas*1000),'###,###,###.######','en-US')	AS K53,	-- GAS FORMACION
			CASE WHEN ISNULL(R.MMPC20BN,0) = 0 THEN '0'
				ELSE FORMAT(ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000,'###,###,###.######','en-US')
			END			 AS	L53,	-- GAS BN O RESIDUAL?
			FORMAT(C.BarrilesC5_Equiv,'###,###,###.###','en-US')	AS I53,	-- TOTAL BARRILES OPERADOR
			FORMAT(C.MMBTU_C5,'###,###,###.###','en-US')			AS J53,	-- TOTAL MMBTU OPERADOR
			FORMAT((C.MMPC_60F_Gas*1000) + (ISNULL(R.MMPC20BN/@FactorConv20c15_5,0)*1000),'###,###,###.######','en-US')	AS H53	-- VOLUMEN TOTAL
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
	END
END

END
