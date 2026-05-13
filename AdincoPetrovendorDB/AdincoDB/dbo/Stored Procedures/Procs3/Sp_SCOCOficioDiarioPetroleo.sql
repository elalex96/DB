CREATE PROCEDURE Sp_SCOCOficioDiarioPetroleo
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
--_________________________________-Diario Petroleo
SET LANGUAGE spanish

--CREATE TABLE #Balance
--(
--	CampoID	INT,
--	VolMensual_20	FLOAT,
--	VolDiario_20	FLOAT,
--	Diferencia_20	FLOAT,
--	VolMensual_15	FLOAT,
--	VolDiario_15	FLOAT,
--	Diferencia_15	FLOAT,
--	UltimoDia	INT
--)

DECLARE
	@EsProduccionCompartida BIT,
	@NumeroContrato VARCHAR(100),
	@FechaCorte DATE,
	@PorcDistEdo_Per1 FLOAT,
	@PorcDistEdo_Per2 FLOAT,
	@AreaContractual	VARCHAR(250),
	@EsLicencia		BIT,
	@EsConsorcio	BIT,
	@PorcDefault	FLOAT = 100,
	@ApruebaPEP		BIT,
	@ContratistaRecibe	VARCHAR(500),
	@ContratistaEntrega	VARCHAR(500)

SELECT
	@EsProduccionCompartida = CASE WHEN IdTipoContrato = 2
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


--INSERT INTO #Balance
--(
--	CampoID,
--	VolMensual_20,
--	VolDiario_20,
--	Diferencia_20,
--	VolMensual_15,
--	VolDiario_15,
--	Diferencia_15,
--	UltimoDia
--)
--SELECT CampoID,  
--	ROUND(SUM(BL_20C),3), 
--	SUM(ROUND(BL_20C,3)),
--	ROUND(ROUND(SUM(BL_20C),3) - SUM(ROUND(BL_20C,3)),3),
--	ROUND(SUM(BL_60F),3), 
--	SUM(ROUND(BL_60F,3)),
--	ROUND(ROUND(SUM(BL_60F),3) - SUM(ROUND(BL_60F,3)),3),
--	DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)))
--FROM
--	dbo.SCOC_CalculoDiario_Petroleo
--WHERE
--	IdContrato = @IdContrato
--	AND
--	MesReporte	=	@MesReporte
--GROUP BY
--	CampoID

IF @EsProduccionCompartida = 1
BEGIN

	SELECT
		@ContratistaRecibe	=	RecibePetroleo,
		@ContratistaEntrega	=	EntregaPetroleo
	FROM 
		dbo.SCOC_TipoArchivos
	WHERE
		IdTipoArchivo = 2	-- Producción Compartida Dia PETROLEO Edo

	IF @ApruebaPEP = 0
	BEGIN
		SELECT
			@ContratistaRecibe	=	EntregaPetroleo
		FROM 
			dbo.SCOC_TipoArchivos
		WHERE
			IdTipoArchivo = 25	-- COMERCIALIZADOR PETROLEO
	END

    SELECT
		@FechaCorte = IdFecha
    FROM AP_Calendario
    WHERE Anio = YEAR(@MesReporte)
        AND Mes = MONTH(@MesReporte)
        AND Descripcion = 'Resultados y Elementos del Cálculo (Fecha máxima)'

    SELECT
		@PorcDistEdo_Per1 = RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)]
    --PorcDistContra	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)],
    FROM dbo.PC_RM RM53
    WHERE RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -2, @MesReporte))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -2, @MesReporte))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato

    SELECT
		@PorcDistEdo_Per2 = RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)]
    --PorcDistContra	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)],
    FROM dbo.PC_RM RM53
    WHERE RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -1, @MesReporte))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -1, @MesReporte))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato


	---------------------------------------Encabezado y pie de pagina------------------------------
	SELECT
		@NumeroContrato									AS Contrato, 
		C.CampoID,
		ISNULL(CO.SubdireccionProduccion,'')			AS NombreBloque, 
		ISNULL(CO.ActivoIntegral,'')					AS ClaveBloque,
		-------------------------------------Periodo 1
		@PorcDistEdo_Per1								AS PorcentajeFE, --Porcentaje a favor del estado
		DAY(@MesReporte)								AS PrimerDia, 
		DAY(@FechaCorte)								AS UltimoDia, 
		DATENAME(MONTH, @MesReporte)					AS Mes, 
		YEAR(@MesReporte)								AS Año,
		-----------------------------Periodo 2
		@PorcDistEdo_Per2								AS PorcentajeFE2, 
		DAY(DATEADD(DAY, 1, @FechaCorte))				AS PrimerDia2, 
		DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) AS UltimoDia2, 
	------------------------------------------------------------------------------------------------------------
		ISNULL(CO.PetroleoEntregadoA,'')				AS EntregaA, 
		ISNULL(CO.PetroleoEntregadoEn,'')				AS EntregaEn,
		ISNULL(CO.PetroleoTransporte,'')				AS Transport, 
		CONVERT(VARCHAR(10),C.FechaEntrega,105)				AS FechaE, 
		FORMAT(C.M3_20Grados,'###,###,###.###','en-US') AS VEM320, --VOLUMEN TOTAL M3 a 20°
		FORMAT(C.BL_20C,'###,###,###.###','en-US')		AS BLS, --Volumen total BLS
		FORMAT(C.PorcDistEdo,'###.###','en-US')			AS DFEP, --Distribucion a favor del ESTADO Porcentaje
		FORMAT(C.PorcDistContra,'###.###','en-US')		AS DFCOP,	-- Distribucion a favor del CONTRATISTA Porcentaje
		FORMAT(C.M3_60F,'###,###,###.###','en-US')		AS VENM315, --Volumen entregado neto M3
		FORMAT(C.BL_60F,'###,###,###.###','en-US')		AS BLS15, --Bls a 15.56°
		FORMAT(C.DistEdo,'###,###,###.###','en-US')						AS DFEBLS, --Distribución a Favor del Estado Bls
		FORMAT(C.DistContratista,'###,###,###.###','en-US')				AS BLSVC, --Volumen del Contratista
		FORMAT(C.DistContratista,'###,###,###.###','en-US')				AS DFCOBLS,	-- Distribución a favor del CONTRATISTA
		CASE WHEN C.Aplicada <> 0 THEN FORMAT(C.Aplicada,'###,###,###.###','en-US') ELSE FORMAT(C.DistEdo,'###,###,###.###','en-US') END			AS BLSV, --Volumen Total a Favor del ESTADO
		CASE WHEN ISNULL(C.Compensacion,0) = 0 THEN '0' ELSE	FORMAT(C.Compensacion,'###,###,###.###','en-US') END									AS BLSCVFE, --Bls Compensación volumetrica a favor del ESTADO
		CASE WHEN ISNULL(C.Compensacion,0) = 0 THEN '0' ELSE FORMAT((C.Compensacion*-1),'###,###,###.###','en-US') END	AS BLSCVFCO,	--- Compensacion Volumetrica a Favor del CONTRATISTA
		FORMAT(C.DistContratista + (C.Compensacion*-1),'###,###,###.###','en-US')	AS BLSCOV,	-- Volumen Total a Favor del  CONTRATISTA
		ROUND(R.GradosAPI,2)							AS GAPI, -- grados api
		ROUND(R.PesoEspec,4)							AS PE20, --PEso Especifico a 20°
		ROUND(R.AguaSedimento,2)						AS 'AS', -- Agua Sedimento
		FORMAT(R.Sal,'###,###,###.##','en-US')			AS Sal, 
		ROUND(R.Azufre,3)								AS Azufre,
		ISNULL(@ContratistaRecibe,'REPRESENTANTE OPERATIVO PEP')	AS Recibe,
		ISNULL(@ContratistaEntrega,'REPRESENTANTE OPERATIVO OPERADOR')	AS Entrega
	FROM
		SCOC_CalculoDiario_Petroleo C
	JOIN
		dbo.SCOC_ReporteDiarioPetroleo R
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

END
ELSE
BEGIN
---- LICENCIA EN CONSORCIO CON PEMEX
	IF @EsLicencia = 1 AND @EsConsorcio = 1
	BEGIN
		SELECT
			@NumeroContrato										AS Contrato,
			C.CampoID,
			'ÁREA CONTRACTUAL ' + @AreaContractual									AS	I7,
			'SUBDIRECCIÓN DE PRODUCCIÓN BLOQUES ' + ISNULL(CO.SubdireccionProduccion,'')	AS F3, 
			'ACTIVO INTEGRAL DE PRODUCCIÓN BLOQUE ' + ISNULL(CO.ActivoIntegral,'')			AS G4,
			CONVERT(VARCHAR(10),C.FechaReporte, 105) + ' 05:00 AM'							AS I14,
			CONVERT(VARCHAR(10),DATEADD(DAY,1,C.FechaReporte), 105) + ' 05:00 AM'				AS I15,
			ISNULL(CO.PetroleoEntregadoA,'')					AS B10, 
			CONVERT(VARCHAR(10),C.FechaEntrega,105)					AS K13, 
			ISNULL(CA.PetroleoEntregadoEn,CO.PetroleoEntregadoEn)					AS J20, 
			ISNULL(CO.PetroleoTransporte,'')					AS J22,
			'Dirección: ' + ISNULL(CO.DireccionPetroleoEntregadoA,'')							AS B11,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')			AS A25,
-- 3 DECIMALES
			-------------- VOLUMEN MEDIDO A CONDICIONES 20° ---------------------------------------
			CASE WHEN ISNULL(C.M3_20Grados,0) = 0 THEN '0' ELSE FORMAT(ROUND(C.M3_20Grados,3),'###,###,###.###','en-US') END		AS F31, --VOLUMEN TOTAL M3 a 20°
			CASE WHEN ISNULL(C.BL_20C,0) = 0 THEN '0' --AND C.Dia <> B.UltimoDia THEN '0' 
			ELSE FORMAT(ROUND(C.BL_20C,3),'###,###,###.###','en-US')		END														AS H31, --VOLUMEN TOTAL BLS
			'(' + LTRIM(ISNULL(PC.PorcentajeSocio,100)) + '%)'																		AS L29,	-- PORCENTAJE OPERADOR
			--CASE WHEN ISNULL(C.M3_20Grados * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),0) = 0 THEN '0'
			--	ELSE	FORMAT(ROUND(ROUND(C.M3_20Grados,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),3),'###,###,###.###','en-US') END		AS	J31,		-- VOLUMEN DEL OPERADOR M3 A 20°

			--CASE WHEN ISNULL(C.BL_20C * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),0) = 0 THEN '0' -- AND C.Dia <> B.UltimoDia THEN '0'
			--	ELSE FORMAT(ROUND(ROUND(C.BL_20C,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),3),'###,###,###.###','en-US') END				AS	L31,		-- VOLUMEN DEL OPERADOR BBL A 20°
			-------------- VOLUMEN MEDIDO A CONDICIONES 15° ---------------------------------------
			--CASE WHEN ISNULL(C.M3_60F,0) = 0 THEN '0' ELSE FORMAT(ROUND(C.M3_60F,3),'###,###,###.###','en-US') END				AS F37, -- VOLUMEN ENTREGADO NETO M3 A 15°
			--CASE WHEN ISNULL(C.BL_60F,0) = 0 THEN '0' --AND C.Dia <> B.UltimoDia THEN '0'
			--ELSE FORMAT(ROUND(C.BL_60F,3),'###,###,###.###','en-US') END				AS H37, --VOLUMEN TOTAL BLS A 15.56°
			--CASE WHEN ISNULL(C.M3_60F * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),0) = 0 THEN '0'
			--	ELSE FORMAT(ROUND(ROUND(C.M3_60F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),3),'###,###,###.###','en-US') END			AS	J37,		-- VOLUMEN DEL OPERADOR M3 A 15°
			--CASE WHEN ISNULL(C.BL_60F * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),0) = 0 THEN '0' --AND C.Dia <> B.UltimoDia THEN '0'
			--	ELSE FORMAT(ROUND(ROUND(C.BL_60F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),3),'###,###,###.###','en-US') END			AS	L37,		-- VOLUMEN DEL OPERADOR BBL A 15°
-- 4 DECIMALES
			------------ VOLUMEN MEDIDO A CONDICIONES 20° ---------------------------------------
			--CASE WHEN ISNULL(C.M3_20Grados,0) = 0 THEN '0' ELSE FORMAT(ROUND(C.M3_20Grados,4),'###,###,###.####','en-US') END		AS F31, --VOLUMEN TOTAL M3 a 20°
			--CASE WHEN ISNULL(C.BL_20C,0) = 0 THEN '0' --AND C.Dia <> B.UltimoDia THEN '0' 
			--ELSE FORMAT(ROUND(C.BL_20C,4),'###,###,###.####','en-US')		END						AS H31, --VOLUMEN TOTAL BLS
			--'(' + LTRIM(ISNULL(PC.PorcentajeSocio,100)) + '%)'				AS L29,	-- PORCENTAJE OPERADOR
			CASE WHEN ISNULL(C.M3_20Grados,0) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) = 0 THEN '0'
				WHEN CONVERT(INT,ROUND(C.M3_20Grados,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.M3_20Grados,3) < 1
				  THEN '0'+FORMAT(((ROUND(C.M3_20Grados,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.M3_20Grados,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.M3_20Grados,3) > 1
				  THEN FORMAT(((ROUND(C.M3_20Grados,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.M3_20Grados,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US') END								AS	J31,		-- VOLUMEN DEL OPERADOR M3 A 20°

			CASE WHEN ISNULL(C.BL_20C,0) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) = 0 THEN '0'
				WHEN CONVERT(INT, CONVERT(DECIMAL(12,3),ROUND(C.BL_20C,3)) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.BL_20C,3) < 1
				  THEN '0'+FORMAT(((ROUND(C.BL_20C,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT, CONVERT(DECIMAL(12,3),ROUND(C.BL_20C,3)) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.BL_20C,3) > 1
				  THEN FORMAT(((ROUND(C.BL_20C,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.BL_20C,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US') END					AS	L31,		-- VOLUMEN DEL OPERADOR BBL A 20°

			------------ VOLUMEN MEDIDO A CONDICIONES 15° ---------------------------------------
			CASE WHEN ISNULL(C.M3_60F,0) = 0 THEN '0' ELSE FORMAT(ROUND(C.M3_60F,3),'###,###,###.###','en-US') END						AS F37, -- VOLUMEN ENTREGADO NETO M3 A 15°
			CASE WHEN ISNULL(C.BL_60F,0) = 0 THEN '0' --AND C.Dia <> B.UltimoDia THEN '0'
				ELSE FORMAT(ROUND(C.BL_60F,3),'###,###,###.###','en-US') END															AS H37, --VOLUMEN TOTAL BLS A 15.56°
			CASE WHEN ISNULL(C.M3_60F,0) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) = 0 THEN '0'
				WHEN CONVERT(INT,ROUND(C.M3_60F,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.M3_60F,3) < 1
				  THEN '0'+FORMAT(((ROUND(C.M3_60F,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,ROUND(C.M3_60F,3) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.M3_60F,3) > 1
				  THEN FORMAT(((ROUND(C.M3_60F,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.M3_60F,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US') END					AS	J37,		-- VOLUMEN DEL OPERADOR M3 A 15°

			CASE WHEN ISNULL(C.BL_60F,0) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault) = 0 THEN '0'
				WHEN CONVERT(INT,CONVERT(DECIMAL(12,3),ROUND(C.BL_60F,3)) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.BL_60F,3) < 1
					THEN '0'+FORMAT(((ROUND(C.BL_60F,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				WHEN CONVERT(INT,CONVERT(DECIMAL(12,3),ROUND(C.BL_60F,3)) * 1000)%2 = 1 AND PC.PorcentajeSocio = 50 AND ROUND(C.BL_60F,3) > 1
					THEN FORMAT(((ROUND(C.BL_60F,3)-.001) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault))+.0005,'###,###,###.####','en-US')
				ELSE FORMAT(ROUND(C.BL_60F,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),'###,###,###.###','en-US') END					AS	L37,		-- VOLUMEN DEL OPERADOR BBL A 15°

			------------ CALIDAD DEL PETROLEO -----------------------------------------------------
			ROUND(R.GradosAPI,2)								AS K43, -- grados api
			ROUND(R.PesoEspec,4)								AS K44, --PEso Especifico a 20°
			ROUND(R.AguaSedimento,2)							AS K45, -- Agua Sedimento
			CASE WHEN ISNULL(R.Sal,0) = 0 THEN '0' ELSE FORMAT(R.Sal,'###,###,###.##','en-US') END				AS K46, -- SAL
			ROUND(R.Azufre,3)									AS K47
		FROM
			SCOC_CalculoDiario_Petroleo C
		JOIN
			dbo.SCOC_ReporteDiarioPetroleo R
			ON C.IdContrato = R.IdContrato
			AND C.MesReporte = R.MesReporte
			AND C.Dia = R.Dia
			AND C.CampoID	=	R.CampoID
		JOIN
			SCOC_Contrato	CO
			ON	C.IdContrato	=	CO.IdContrato
		--JOIN
		--	#Balance	B
		--	ON	C.CampoID	=	B.CampoID
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
		SELECT
			@NumeroContrato								AS Contrato,
			C.CampoID,
			'ÁREA CONTRACTUAL ' + @AreaContractual							AS	I7,
			'SUBDIRECCIÓN DE PRODUCCIÓN BLOQUES ' + ISNULL(CO.SubdireccionProduccion,'')	AS F3, 
			'ACTIVO INTEGRAL DE PRODUCCIÓN BLOQUE ' + ISNULL(CO.ActivoIntegral,'')			AS G4,
			--CONVERT(VARCHAR(10),C.FechaReporte, 105)										AS I14,
			--CONVERT(VARCHAR(10),C.FechaReporte, 105)										AS I15,
			CONVERT(VARCHAR(10),C.FechaReporte, 105) + ' 05:00 AM'							AS I14,
			CONVERT(VARCHAR(10),DATEADD(DAY,1,C.FechaReporte), 105) + ' 05:00 AM'			AS I15,
			ISNULL(CO.PetroleoEntregadoA,'')					AS B10, 
			CONVERT(VARCHAR(10),C.FechaEntrega,105)					AS K13, 
			ISNULL(CA.PetroleoEntregadoEn,CO.PetroleoEntregadoEn)					AS J20,
			ISNULL(CO.PetroleoTransporte,'')					AS J22,
			'Dirección: ' + ISNULL(CO.DireccionPetroleoEntregadoA,'')						AS B11,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')					AS A25, 
			------------ VOLUMEN MEDIDO A CONDICIONES 20° ---------------------------------------
			CASE WHEN ISNULL(C.M3_20Grados,0) = 0 THEN '0' ELSE FORMAT(C.M3_20Grados,'###,###,###.###','en-US') END		AS F31, --VOLUMEN TOTAL M3 a 20°
			CASE WHEN ISNULL(C.BL_20C,0) = 0 THEN '0' ELSE FORMAT(C.BL_20C,'###,###,###.###','en-US') END					AS H31, --VOLUMEN TOTAL BLS
			------------ VOLUMEN MEDIDO A CONDICIONES 15° ---------------------------------------
			CASE WHEN ISNULL(C.M3_60F,0) = 0 THEN '0' ELSE FORMAT(C.M3_60F,'###,###,###.###','en-US') END				AS F37, -- VOLUMEN ENTREGADO NETO M3 A 15°
			CASE WHEN ISNULL(C.BL_60F,0) = 0 THEN '0' ELSE FORMAT(C.BL_60F,'###,###,###.###','en-US') END				AS H37, --VOLUMEN TOTAL BLS A 15.56°
			------------ CALIDAD DEL PETROLEO -----------------------------------------------------
			ROUND(R.GradosAPI,2)								AS K43, -- grados api
			ROUND(R.PesoEspec,4)								AS K44, --PEso Especifico a 20°
			ROUND(R.AguaSedimento,2)							AS K45, -- Agua Sedimento
			CASE WHEN ISNULL(R.Sal,0) = 0 THEN '0' ELSE FORMAT(R.Sal,'###,###,###.##','en-US') END				AS K46, -- SAL
			ROUND(R.Azufre,3)									AS K47	-- AZUFRE
		FROM
			SCOC_CalculoDiario_Petroleo C
		JOIN
			dbo.SCOC_ReporteDiarioPetroleo R
			ON C.IdContrato = R.IdContrato
			AND C.MesReporte = R.MesReporte
			AND C.Dia = R.Dia
			AND C.CampoID	=	R.CampoID
		JOIN
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