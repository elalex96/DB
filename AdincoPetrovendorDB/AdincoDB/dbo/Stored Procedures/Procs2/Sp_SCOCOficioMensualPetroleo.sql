CREATE PROCEDURE Sp_SCOCOficioMensualPetroleo
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
---___________________________--Mensual Petroleo_____________________________
SET LANGUAGE spanish

CREATE TABLE #PromPonderado
(
--	Dia	INT,
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
	@PorcDefault	FLOAT = 100,
	@ApruebaPEP		BIT,
	@ContratistaRecibe	VARCHAR(500),
	@ContratistaEntrega	VARCHAR(500)

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

-- SE OBTIENE EL INDICADOR PARA SABER SI EL FORMATO VA FIRMADO POR PEP O POR EL COMERCIALIZADOR
SELECT
	@ApruebaPEP = ISNULL(ApruebaRepPEP,1)
FROM
	dbo.SCOC_Contrato
WHERE
	IdContrato	=	@IdContrato

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
		@ContratistaRecibe	=	RecibeGas,
		@ContratistaEntrega	=	EntregaGas
	FROM 
		dbo.SCOC_TipoArchivos
	WHERE
		IdTipoArchivo = 4	-- Producción Compartida MES PETROLEO  Edo

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
		ISNULL(CO.SubdireccionProduccion,'')	AS NombreBloque, 
		ISNULL(CO.ActivoIntegral,'')				AS ClaveBloque,
		@PorcDistEdo_Per1					AS PorcentajeFE, ----porcentaje distribución definitiva (Pie de pagina)
		DAY(@MesReporte)					AS PrimerDia, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		DAY(@FechaCorte)					AS UltimoDia, --Periodo 1--(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		DATENAME(MONTH, @MesReporte)		AS Mes, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		YEAR(@MesReporte)					AS Año, --Periodo 1 --(Aplicable del 1° al 24 de diciembre de 2017). (PIE DE PAGINA)
		@PorcDistEdo_Per2					AS PorcentajeFE2, ----porcentaje distribución definitiva (Pie de pagina) *******PERIODO 2*****
		DAY(DATEADD(DAY, 1, @FechaCorte))	AS PrimerDia2, -- (Aplicable del 25 al 31 de diciembre de 2017).   (Pie de pagina) *******PERIODO 2*****
		DAY(@FechaFinMes)					AS UltimoDia2, -- (Aplicable del 25 al 31 de diciembre de 2017).   (Pie de pagina) *******PERIODO 2*****
		------------------------------------------------------------------------------------
		ISNULL(CO.PetroleoEntregadoA,'')			AS EntregaA,  
		ISNULL(CO.PetroleoEntregadoEn,'')			AS EntregaEn, 
		--CONVERT(VARCHAR(10),@MesReporte,105)			AS FechaE, 
		--CONVERT(VARCHAR(10),R.CreadoEn,105)				AS FechaE,
		CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105)	AS FechaE,
		CONVERT(VARCHAR(10),@MesReporte,105)			AS FechaDE, 
		CONVERT(VARCHAR(10),@FechaFinMes,105)			AS FechaA,
		----------------------------PERIODO 1------------------------------------
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_20Grados ELSE 0 END),'###,###,###.###','en-US')	AS VEM320, --Volumen entregado neto M3 a 20°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.BL_20C ELSE 0 END),'###,###,###.###','en-US')		AS BLS, --Volumen entregado neto BLS a 20°
		@PorcDistEdo_Per1	AS DFEP, --Distribución a Favor del ESTADO Periodo 1 PORCENTAJE
		@PorcDistContra_Per1	AS DFCOP,	-- Distribucion a favor del CONTRATISTA Porcentaje
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.M3_60F ELSE 0 END),'###,###,###.###','en-US')		AS VENM315, --m3 a 15.56°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.BL_60F ELSE 0 END),'###,###,###.###','en-US')		AS BLS15, --Bls a 15.56°
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo ELSE 0 END),'###,###,###.###','en-US')		AS DFEBLS, --Distribución a Favor del ESTADO Bls
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContratista ELSE 0 END),'###,###,###.###','en-US')		AS DFCOBLS,	-- Distribucion a favor del CONTRATISTA
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContratista ELSE 0 END),'###,###,###.###','en-US') AS BLSVC, --Volumen del Contratista
				-- LO MISMO PORQUE EN EL PRIMER PERIODO NO SE COMPENSA
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistEdo ELSE 0 END),'###,###,###.###','en-US')		AS BLSV, --Volumen Total a Favor del ESTADO 
		FORMAT(SUM(CASE WHEN C.Dia <= DAY(@FechaCorte) THEN C.DistContratista ELSE 0 END),'###,###,###.###','en-US')	AS BLSVCO,	-- Volumen Total a Favor del CONTRATISTA
		0		AS BLSCVFE, --Bls Compensación volumentrica a favor del estado, 0 PORQUE EL PRIMER PERIODO NO SE COMPENSA
		0		AS BLSCVFCO, --Bls Compensación volumentrica a favor del CONTRATISTA, 0 PORQUE EL PRIMER PERIODO NO SE COMPENSA
	-- *************************************************************    
		-------------------------- PERIODO 2
	-- *************************************************************
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_20Grados ELSE 0 END),'###,###,###.###','en-US')		AS VEM3202, --VOLUMEN ENTREGADO NETO M3 a 20°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.BL_20C ELSE 0 END),'###,###,###.###','en-US')			AS BLS2, --VOLUMEN ENTREGADO NETO BLS a 20°
		@PorcDistEdo_Per2		AS DFEP2, --Distribución a Favor del Estado Periodo 2  PORCENTAJE
		@PorcDistContra_Per2	AS DFCOP2,	-- Distribucion a favor del CONTRATISTA Porcentaje
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.M3_60F ELSE 0 END),'###,###,###.###','en-US')			AS VENM3152, --VOLUMEN ENTREGADO NETO M3 a 15°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.BL_60F ELSE 0 END),'###,###,###.###','en-US')			AS BLS152, --VOLUMEN ENTREGADO NETO BLS a 15°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistEdo ELSE 0 END),'###,###,###.###','en-US')			AS DFEBLS2, --Distribución a Favor del Estado BLS periodo 2°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContratista ELSE 0 END),'###,###,###.###','en-US')	AS DFCOBLS2,	-- Distribución a Favor del CONTRATISTA Periodo 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContratista ELSE 0 END),'###,###,###.###','en-US')	 AS BLSVC2, --Volumen del Contratista BLS periodo 2°
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada <> 0 THEN C.Aplicada WHEN C.Dia > DAY(@FechaCorte) AND C.Aplicada = 0 THEN C.DistEdo ELSE 0 END),'###,###,###.###','en-US')	 AS BLSV2, --Volument total a favor del estado periodo2

		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion ELSE 0 END),'###,###,###.###','en-US')	 AS BLSCVFE2, --COMPENSACIÓN VOLUMÉTRICA A FAVOR DEL ESTADO periodo 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion ELSE 0 END)*-1,'###,###,###.###','en-US')		AS BLSCVFCO2,	-- Compensacion Volumetrica a favor del CONTRATISTA Periodo 2
		FORMAT(SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.DistContratista ELSE 0 END) + (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion ELSE 0 END)*-1),'###,###,###.###','en-US')	AS BLSCOV2,	-- Volumen total a Favor del CONTRATISTA Periodo 2

		------------------------- CALIDAD --------------------------
		ROUND(PP.GradosAPI, 1) AS GAPI, -- garod api
		ROUND(PP.PesoEspec, 4) AS PE20, --PEso Especifico a 20°
		ROUND(PP.AguaSedimento, 1) AS 'AS', -- Agua Sedimento
		ROUND(PP.Sal,0)		AS Sal,
		--CASE WHEN ISNULL(PP.Sal,0) = 0 THEN '0' ELSE FORMAT(PP.Sal,'###,###,###.##','en-US') END AS Sal, 
		ROUND(PP.Azufre, 3) AS Azufre, 
		FORMAT(SUM(CASE WHEN C.Aplicada <> 0 THEN C.Aplicada ELSE C.DistEdo END),'###,###,###.###','en-US') AS VTEBLS,    --Volumen total del Estado FINAL BLS
		FORMAT(SUM(C.DistContratista)+ (SUM(CASE WHEN C.Dia > DAY(@FechaCorte) THEN C.Compensacion ELSE 0 END)*-1) ,'###,###,###.###','en-US') AS VTEBLSC,    --Volumen total del CONTRATISTA FINAL BLS
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
		CONVERT(VARCHAR(10),R.CreadoEn,105),
		ISNULL(CO.SubdireccionProduccion,''), 
		ISNULL(CO.ActivoIntegral,''),
		ISNULL(CO.PetroleoEntregadoA,''),
		ISNULL(CO.PetroleoEntregadoEn,''),
		ROUND(PP.GradosAPI, 1), -- garod api
		ROUND(PP.PesoEspec, 4), --PEso Especifico a 20°
		ROUND(PP.AguaSedimento, 1), -- Agua Sedimento
		ROUND(PP.Sal,0),
		--CASE WHEN ISNULL(PP.Sal,0) = 0 THEN '0' ELSE FORMAT(PP.Sal,'###,###,###.##','en-US') END,
		ROUND(PP.Azufre, 3)
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
			CONVERT(VARCHAR(10),@MesReporte,105)												AS I14, 
			CONVERT(VARCHAR(10),DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)),105)			AS I15, 
			ISNULL(CO.PetroleoEntregadoA,'')					AS B10,
			'Dirección: ' + ISNULL(CO.DireccionPetroleoEntregadoA,'')							AS B11,
			CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105)	AS K13,
			ISNULL(CA.PetroleoEntregadoEn,CO.PetroleoEntregadoEn)					AS J20, 
			ISNULL(CO.PetroleoTransporte,'')					AS J22,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')			AS A25,
-- 3 DECIMALES
			-------------- VOLUMEN MEDIDO A CONDICIONES 20° ---------------------------------------
			CASE WHEN SUM(ROUND(ISNULL(C.M3_20Grados,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.M3_20Grados,3)),'###,###,###.###','en-US') END		AS F31, --VOLUMEN TOTAL M3 a 20°
			CASE WHEN SUM(ROUND(ISNULL(C.BL_20C,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.BL_20C,3)),'###,###,###.###','en-US') END					AS H31, --VOLUMEN TOTAL BLS
			'(' + LTRIM(ISNULL(PC.PorcentajeSocio,@PorcDefault)) + '%)'				AS L29,	-- PORCENTAJE OPERADOR
			--CASE WHEN SUM(ISNULL(ROUND(C.M3_20Grados,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),0)) = 0 THEN '0'
			--	ELSE	FORMAT(SUM(ROUND(C.M3_20Grados,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US') END		AS	J31,		-- VOLUMEN DEL OPERADOR M3 A 20°
			--CASE WHEN SUM(ISNULL(ROUND(C.BL_20C,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),0)) = 0 THEN '0'
			--	ELSE FORMAT(SUM(ROUND(C.BL_20C,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US') END				AS	L31,		-- VOLUMEN DEL OPERADOR BBL A 20°
			-------------- VOLUMEN MEDIDO A CONDICIONES 15° ---------------------------------------
			--CASE WHEN SUM(ROUND(ISNULL(C.M3_60F,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.M3_60F,3)),'###,###,###.###','en-US') END				AS F37, -- VOLUMEN ENTREGADO NETO M3 A 15°
			--CASE WHEN SUM(ROUND(ISNULL(C.BL_60F,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.BL_60F,3)),'###,###,###.###','en-US') END				AS H37, --VOLUMEN TOTAL BLS A 15.56°
			--CASE WHEN SUM(ISNULL(ROUND(C.M3_60F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault),0)) = 0 THEN '0'
			--	ELSE FORMAT(SUM(ROUND(C.M3_60F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US') END			AS	J37,		-- VOLUMEN DEL OPERADOR M3 A 15°
			--CASE WHEN ISNULL(SUM(ROUND(C.BL_60F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),0) = 0 THEN '0'
			--	ELSE FORMAT(SUM(ROUND(C.BL_60F,3) * (ISNULL(CONVERT(FLOAT,PC.PorcentajeSocio),@PorcDefault)/@PorcDefault)),'###,###,###.###','en-US') END			AS	L37,		-- VOLUMEN DEL OPERADOR BBL A 15°
-- 4 DECIMALES
			------------ VOLUMEN MEDIDO A CONDICIONES 20° ---------------------------------------
			--CASE WHEN SUM(ROUND(ISNULL(C.M3_20Grados,0),4)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.M3_20Grados,4)),'###,###,###.####','en-US') END		AS F31, --VOLUMEN TOTAL M3 a 20°
			--CASE WHEN SUM(ROUND(ISNULL(C.BL_20C,0),4)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.BL_20C,4)),'###,###,###.####','en-US') END					AS H31, --VOLUMEN TOTAL BLS
			--'(' + LTRIM(ISNULL(PC.PorcentajeSocio,@PorcDefault)) + '%)'				AS L29,	-- PORCENTAJE OPERADOR
			CASE WHEN SUM(ISNULL(ROUND(C.M3_20Grados,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),0)) = 0 THEN '0'
				ELSE	FORMAT(SUM(ROUND(C.M3_20Grados,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US') END		AS	J31,		-- VOLUMEN DEL OPERADOR M3 A 20°

			CASE WHEN SUM(ISNULL(ROUND(C.BL_20C,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),0)) = 0 THEN '0'
				ELSE FORMAT(SUM(ROUND(C.BL_20C,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US') END				AS	L31,		-- VOLUMEN DEL OPERADOR BBL A 20°
			------------ VOLUMEN MEDIDO A CONDICIONES 15° ---------------------------------------
			CASE WHEN SUM(ROUND(ISNULL(C.M3_60F,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.M3_60F,3)),'###,###,###.###','en-US') END				AS F37, -- VOLUMEN ENTREGADO NETO M3 A 15°
			CASE WHEN SUM(ROUND(ISNULL(C.BL_60F,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.BL_60F,3)),'###,###,###.###','en-US') END				AS H37, --VOLUMEN TOTAL BLS A 15.56°
			CASE WHEN SUM(ISNULL(ROUND(C.M3_60F,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault),0)) = 0 THEN '0'
				ELSE FORMAT(SUM(ROUND(C.M3_60F,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US') END			AS	J37,		-- VOLUMEN DEL OPERADOR M3 A 15°
			CASE WHEN ISNULL(SUM(ROUND(C.BL_60F,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),0) = 0 THEN '0'
				ELSE FORMAT(SUM(ROUND(C.BL_60F,3) * (CONVERT(FLOAT,PC.PorcentajeSocio)/@PorcDefault)),'###,###,###.####','en-US') END			AS	L37,		-- VOLUMEN DEL OPERADOR BBL A 15°
			------------ CALIDAD DEL PETROLEO -----------------------------------------------------
			ROUND(PP.GradosAPI,1)								AS K43, -- grados api
			ROUND(PP.PesoEspec,4)								AS K44, --PEso Especifico a 20°
			ROUND(PP.AguaSedimento,1)							AS K45, -- Agua Sedimento
			ROUND(PP.Sal,0)										AS K46,
			ROUND(PP.Azufre,3)									AS K47
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
			CONVERT(VARCHAR(10),R.CreadoEn,105),
			ISNULL(CO.SubdireccionProduccion,''), 
			ISNULL(CO.ActivoIntegral,''),
			ISNULL(CO.PetroleoEntregadoA,''),
			ISNULL(CA.PetroleoEntregadoEn,CO.PetroleoEntregadoEn),
			ISNULL(CO.PetroleoTransporte,''),
			'Dirección: ' + ISNULL(CO.DireccionPetroleoEntregadoA,''),
			'CAMPO: ' + ISNULL(CA.NombreCampo,''),
			ISNULL(PC.PorcentajeSocio,@PorcDefault),
			ROUND(PP.GradosAPI, 1), -- garod api
			ROUND(PP.PesoEspec, 4), --PEso Especifico a 20°
			ROUND(PP.AguaSedimento, 1), -- Agua Sedimento
			ROUND(PP.Sal,0),
			--CASE WHEN ISNULL(PP.Sal,0) = 0 THEN '0' ELSE FORMAT(PP.Sal,'###,###,###.##','en-US') END, 
			ROUND(PP.Azufre, 3)

	END
	ELSE
	BEGIN
		SELECT
			@NumeroContrato										AS Contrato,
			C.CampoID,
			'ÁREA CONTRACTUAL ' + @AreaContractual									AS	I7,
			'SUBDIRECCIÓN DE PRODUCCIÓN BLOQUES ' + ISNULL(CO.SubdireccionProduccion,'')	AS F3, 
			'ACTIVO INTEGRAL DE PRODUCCIÓN BLOQUE ' + ISNULL(CO.ActivoIntegral,'')			AS G4,
			CONVERT(VARCHAR(10),@MesReporte,105)												AS I14, 
			CONVERT(VARCHAR(10),DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)),105)			AS I15, 
			ISNULL(CO.PetroleoEntregadoA,'')					AS B10,
			'Dirección: ' + ISNULL(CO.DireccionPetroleoEntregadoA,'')							AS B11,
			--CONVERT(VARCHAR(10),@MesReporte,105)					AS K13, 
			--CONVERT(VARCHAR(10),R.CreadoEn,105)					AS K13,
			CONVERT(VARCHAR(10),DATEADD(MONTH,1,@MesReporte),105)	AS K13,
			ISNULL(CA.PetroleoEntregadoEn,CO.PetroleoEntregadoEn)					AS J20, 
			ISNULL(CO.PetroleoTransporte,'')					AS J22,
			'CAMPO: ' + ISNULL(CA.NombreCampo,'')					AS A25,
			------------ VOLUMEN MEDIDO A CONDICIONES 20° ---------------------------------------
			CASE WHEN SUM(ROUND(ISNULL(C.M3_20Grados,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.M3_20Grados,3)),'###,###,###.###','en-US') END		AS F31, --VOLUMEN TOTAL M3 a 20°
			CASE WHEN SUM(ROUND(ISNULL(C.BL_20C,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.BL_20C,3)),'###,###,###.###','en-US') END					AS H31, --VOLUMEN TOTAL BLS
			------------ VOLUMEN MEDIDO A CONDICIONES 15° ---------------------------------------
			CASE WHEN SUM(ROUND(ISNULL(C.M3_60F,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.M3_60F,3)),'###,###,###.###','en-US') END				AS F37, -- VOLUMEN ENTREGADO NETO M3 A 15°
			CASE WHEN SUM(ROUND(ISNULL(C.BL_60F,0),3)) = 0 THEN '0' ELSE FORMAT(SUM(ROUND(C.BL_60F,3)),'###,###,###.###','en-US') END				AS H37, --VOLUMEN TOTAL BLS A 15.56°
			------------ CALIDAD DEL PETROLEO -----------------------------------------------------
			ROUND(PP.GradosAPI,1)								AS K43, -- grados api
			ROUND(PP.PesoEspec,4)								AS K44, --PEso Especifico a 20°
			ROUND(PP.AguaSedimento,1)							AS K45, -- Agua Sedimento
			ROUND(PP.Sal,0)										AS K46,
			--CASE WHEN ISNULL(PP.Sal,0) = 0 THEN '0' ELSE FORMAT(PP.Sal,'###,###,###.##','en-US') END				AS K46, -- SAL
			ROUND(PP.Azufre,3)									AS K47
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
		LEFT JOIN
			dbo.SCOC_Campo	CA
			ON	C.CampoID = CA.CampoID
		WHERE
			C.IdContrato = @IdContrato
			AND C.MesReporte = @MesReporte
		GROUP BY
			C.CampoID,
			CONVERT(VARCHAR(10),R.CreadoEn,105),
			ISNULL(CO.SubdireccionProduccion,''), 
			ISNULL(CO.ActivoIntegral,''),
			ISNULL(CO.PetroleoEntregadoA,''),
			ISNULL(CA.PetroleoEntregadoEn,CO.PetroleoEntregadoEn),
			ISNULL(CO.PetroleoTransporte,''),
			'Dirección: ' + ISNULL(CO.DireccionPetroleoEntregadoA,''),
			'CAMPO: ' + ISNULL(CA.NombreCampo,''),
			ROUND(PP.GradosAPI, 1), -- garod api
			ROUND(PP.PesoEspec, 4), --PEso Especifico a 20°
			ROUND(PP.AguaSedimento, 1), -- Agua Sedimento
			ROUND(PP.Sal,0),
			--CASE WHEN ISNULL(PP.Sal,0) = 0 THEN '0' ELSE FORMAT(PP.Sal,'###,###,###.##','en-US') END, 
			ROUND(PP.Azufre, 3)
	END
END
END
