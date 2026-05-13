CREATE PROCEDURE dbo.sp_SCOC_DetalleFormato
	@Formato NVARCHAR(1),	--=(D,M) 
	@Hidrocarburo NVARCHAR(1),	--=(P,G,C), 
	@Mes DATE, 
	@idContrato INT
AS
BEGIN

CREATE TABLE #Volumen
(
	Hidrocarburo	VARCHAR(15),
	Volumen			FLOAT
)

CREATE TABLE #Datos
(
	PuntoEntregaID	INT,
	PuntoEntrega	VARCHAR(150),
	Hidrocarburo	VARCHAR(15),
	VolumenTotal	FLOAT,
	VolumenP1		FLOAT,
	VolumenP2		FLOAT
)

DECLARE
	@EsProduccionCompartida BIT,
	@NumeroContrato VARCHAR(100),
	@PorcDistEdo_Per1 FLOAT,
	@PorcDistEdo_Per2 FLOAT,
	@PorcDistContra_Per1 FLOAT,
	@PorcDistContra_Per2 FLOAT,
	@FechaFinMes	DATE,
	@AreaContractual	VARCHAR(250),
	@EsLicencia		BIT,
	@EsConsorcio	BIT,
	@PorcSocio		FLOAT,
	@PorcPEP		FLOAT,
	@Operador		VARCHAR(300),
	@SCOC			VARCHAR(300),
	@VolPetroleo	FLOAT,
	@FechaCorte		DATE

IF @Formato = 'M'	-- REPORTE MENSUAL
BEGIN
	SELECT @FechaFinMes = DATEADD(DAY,-1,DATEADD(MONTH,1,@Mes))
END
ELSE
BEGIN
	SELECT @FechaFinMes	=	@Mes,
			@FechaCorte =   @Mes
END

SELECT @EsProduccionCompartida = CASE
                                    WHEN CO.IdTipoContrato = 2
                                    THEN 1
                                    ELSE 0
                                END, 
	@EsLicencia		=	CASE WHEN CO.IdTipoContrato = 3	THEN 1
					ELSE 0 END,
	@NumeroContrato	=	CO.NumeroContrato,
	@EsConsorcio	=	ISNULL(CO.IsConsorcio,0),
	@AreaContractual	=	UPPER(AC.NombreAreaContractual),
	@Operador		=	ISNULL(CC.RazonSocial,'')
FROM
	dbo.CO_Contrato	CO
JOIN
	CO_AreaContractual	AC
	ON	CO.IdAreaContractual	=	AC.IdAreaContractual
JOIN
	dbo.CO_Contratista	CC
    ON	CO.IdContratista	=	CC.IdContratista
WHERE
	IdContrato = @idContrato

IF @EsProduccionCompartida = 1
BEGIN
    SELECT @FechaCorte = IdFecha
    FROM AP_Calendario
    WHERE Anio = YEAR(@Mes)
        AND Mes = MONTH(@Mes)
        AND Descripcion = 'Resultados y Elementos del Cálculo (Fecha máxima)'

	SELECT
		@PorcDistEdo_Per1 = CONVERT(FLOAT,RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)])/100,
		@PorcDistContra_Per1 = CONVERT(FLOAT,RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)])/100
    FROM dbo.PC_RM RM53
    WHERE RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -2, @Mes))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -2, @Mes))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato;

    SELECT
		@PorcDistEdo_Per2 = CONVERT(FLOAT,RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)])/100,
		@PorcDistContra_Per2 = CONVERT(FLOAT,RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)])/100
    FROM dbo.PC_RM RM53
    WHERE RM53.[Año de reporte (RM53_01)] = YEAR(DATEADD(MONTH, -1, @Mes))
        AND RM53.[Mes de reporte (RM53_00)] = MONTH(DATEADD(MONTH, -1, @Mes))
        AND RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato
		
END

SELECT
	@PorcSocio	=	ISNULL(PorcentajeSocio,100)/100,
	@PorcPEP	=	ISNULL(PorcentajePemex,100)/100
FROM
	CO_PorcentajesContrato
WHERE
	idContrato	=	@idContrato

IF @Hidrocarburo	=	'P'
BEGIN

	INSERT INTO #Datos
	(
		PuntoEntregaID,
		PuntoEntrega,
		Hidrocarburo,
		VolumenTotal,
		VolumenP1,
		VolumenP2
	)
	SELECT
		C.PuntoEntregaID,
		PE.Nombre,
		'Petroleo',
		SUM(BL_60F),
		SUM(CASE WHEN Dia <= DAY(@FechaCorte) THEN BL_60F ELSE 0 END),
		SUM(CASE WHEN Dia > DAY(@FechaCorte) THEN BL_60F ELSE 0 END)
	FROM
		SCOC_CalculoDiario_Petroleo	C
	JOIN
		SCOC_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.IdContrato
		AND C.PuntoEntregaID	=	PEC.PuntoEntregaID
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	WHERE
		C.IdContrato	=	@idContrato
		AND
		YEAR(C.MesReporte)	=	YEAR(@Mes)
		AND
		MONTH(C.MesReporte)	=	MONTH(@Mes)
		AND
		C.Dia	BETWEEN DATEPART(DAY,@Mes) AND DATEPART(DAY,@FechaFinMes)
	GROUP BY
		C.PuntoEntregaID,
		PE.Nombre

	SELECT
		@NumeroContrato	AS Contrato,
		PuntoEntrega,
		CASE WHEN @EsProduccionCompartida = 1 THEN 'Produccion Compartida'
			WHEN @EsLicencia = 1 AND @EsConsorcio = 0 THEN 'Licencia'
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN 'Licencia en Consorcio'
		END			AS	Tipocontrato,
		CASE WHEN @Formato = 'M' THEN 'Reporte Mensual'
			ELSE 'Reporte Diario'
		END					AS Tiporeporte,
		Hidrocarburo		AS Tipohidrocarburo,
		FORMAT(VolumenTotal,'###,###,###.###','en-US')							AS Volumen,
		CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistEdo_Per1 * 100
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcPEP * 100
			ELSE 100
		END																		AS Porcentaje1,
		CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistContra_Per1 * 100
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcSocio * 100
			ELSE 100
		END																		AS Porcentaje2,
		FORMAT(VolumenP1,'###,###,###.###','en-US')								AS VolumenP1,
-- PERIODO 1
		FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP1 * @PorcDistEdo_Per1
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcPEP
			ELSE VolumenTotal
		END,'###,###,###.###','en-US')											AS VolPorcentaje1,
		FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP1 * @PorcDistContra_Per1
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcSocio
			ELSE VolumenTotal
		END,'###,###,###.###','en-US')											AS VolPorcentaje2,
-- PERIODO 2
		CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistEdo_Per2 * 100
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcPEP * 100
			ELSE 100
		END																		AS Porcentaje1P2,
		CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistContra_Per2 * 100
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcSocio * 100
			ELSE 100
		END																		AS Porcentaje2P2,
		FORMAT(VolumenP2,'###,###,###.###','en-US')								AS VolumenP2,
		FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP2 * @PorcDistEdo_Per2
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcPEP
			ELSE VolumenTotal
		END,'###,###,###.###','en-US')					AS VolPorcentaje21,
		FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP2 * @PorcDistContra_Per2
			WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcSocio
			ELSE VolumenTotal
		END,'###,###,###.###','en-US')					 AS VolPorcentaje22
	FROM
		#Datos

END
ELSE
BEGIN

-- SI ES GAS SE MANDAN TODOS LOS COMPONENTES
	--INSERT INTO #Volumen
	--(
	--	Hidrocarburo,
	--	Volumen
	--)
	INSERT INTO #Datos
	(
		PuntoEntregaID,
		PuntoEntrega,
		Hidrocarburo,
		VolumenTotal,
		VolumenP1,
		VolumenP2
	)
	SELECT 
		unpvt.PuntoEntregaID,
		unpvt.Nombre,
		unpvt.Hidrocarburo,
		unpvt.Volumen,
		CASE WHEN unpvt.Hidrocarburo = 'C5Blls' THEN C5BllsP1
			WHEN unpvt.Hidrocarburo = 'C1' THEN C1P1
			WHEN unpvt.Hidrocarburo = 'C2' THEN C2P1
			WHEN unpvt.Hidrocarburo = 'C3' THEN C3P1
			WHEN unpvt.Hidrocarburo = 'C4' THEN C4P1
			WHEN unpvt.Hidrocarburo = 'C5' THEN C5P1
		END,
		CASE WHEN unpvt.Hidrocarburo = 'C5Blls' THEN C5BllsP2
			WHEN unpvt.Hidrocarburo = 'C1' THEN C1P2
			WHEN unpvt.Hidrocarburo = 'C2' THEN C2P2
			WHEN unpvt.Hidrocarburo = 'C3' THEN C3P2
			WHEN unpvt.Hidrocarburo = 'C4' THEN C4P2
			WHEN unpvt.Hidrocarburo = 'C5' THEN C5P2
		END
	FROM
	(	
		SELECT
			C.PuntoEntregaID,
			PE.Nombre,
			SUM(C.BarrilesC5_Equiv) AS C5Blls,
			SUM(C.MMBTU_C1)		AS C1,
			SUM(C.MMBTU_C2)		AS C2,
			SUM(C.MMBTU_C3)		AS C3,
			SUM(C.MMBTU_C4)		AS C4,
			SUM(C.MMBTU_C5)		AS C5,
			SUM(CASE WHEN Dia <= DAY(@FechaCorte) THEN C.BarrilesC5_Equiv ELSE 0 END) AS C5BllsP1,
			SUM(CASE WHEN Dia > DAY(@FechaCorte) THEN C.BarrilesC5_Equiv ELSE 0 END)	AS C5BllsP2,
			SUM(CASE WHEN Dia <= DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END) AS C1P1,
			SUM(CASE WHEN Dia > DAY(@FechaCorte) THEN C.MMBTU_C1 ELSE 0 END)	AS C1P2,
			SUM(CASE WHEN Dia <= DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END) AS C2P1,
			SUM(CASE WHEN Dia > DAY(@FechaCorte) THEN C.MMBTU_C2 ELSE 0 END)	AS C2P2,
			SUM(CASE WHEN Dia <= DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END) AS C3P1,
			SUM(CASE WHEN Dia > DAY(@FechaCorte) THEN C.MMBTU_C3 ELSE 0 END)	AS C3P2,
			SUM(CASE WHEN Dia <= DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END) AS C4P1,
			SUM(CASE WHEN Dia > DAY(@FechaCorte) THEN C.MMBTU_C4 ELSE 0 END)	AS C4P2,
			SUM(CASE WHEN Dia <= DAY(@FechaCorte) THEN C.MMBTU_C5 ELSE 0 END) AS C5P1,
			SUM(CASE WHEN Dia > DAY(@FechaCorte) THEN C.MMBTU_C5 ELSE 0 END)	AS C5P2
		FROM dbo.SCOC_CalculoDiario_Gas	C
		JOIN
			SCOC_PuntosdeEntregaContrato	PEC
			ON	C.IdContrato	=	PEC.IdContrato
			AND C.PuntoEntregaID	=	PEC.PuntoEntregaID
		JOIN
			dbo.CO_PuntosdeEntrega	PE
			ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
		WHERE
			C.IdContrato	=	@idContrato
			AND
			YEAR(C.MesReporte)	=	YEAR(@Mes)
			AND
			MONTH(C.MesReporte)	=	MONTH(@Mes)
			AND
			Dia	BETWEEN DATEPART(DAY,@Mes) AND DATEPART(DAY,@FechaFinMes)
		GROUP BY
			C.PuntoEntregaID,
			PE.Nombre
	)		P
	UNPIVOT 
	(
		Volumen FOR Hidrocarburo IN (C5Blls, C1, C2, C3, C4, C5)
	)	AS unpvt

	-- C1 A C4
	IF @Hidrocarburo = 'G'
	BEGIN

		SELECT
			@NumeroContrato	AS Contrato,
			PuntoEntrega,
			CASE WHEN @EsProduccionCompartida = 1 THEN 'Produccion Compartida'
				WHEN @EsLicencia = 1 AND @EsConsorcio = 0 THEN 'Licencia'
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN 'Licencia en Consorcio'
			END													AS	Tipocontrato,
			CASE WHEN @Formato = 'M' THEN 'Reporte Mensual'
				ELSE 'Reporte Diario'
			END													AS Tiporeporte,
			'Gas: ' + Hidrocarburo		AS Tipohidrocarburo,
			FORMAT(VolumenTotal,'###,###,###.###','en-US')		AS Volumen,
-- PERIODO 1
			CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistEdo_Per1 * 100
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcPEP * 100
				ELSE 100
			END													AS Porcentaje1,
			CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistContra_Per1 * 100
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcSocio * 100
				ELSE 100
			END													AS Porcentaje2,
			FORMAT(VolumenP1,'###,###,###.###','en-US')								AS VolumenP1,
			FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP1 * @PorcDistEdo_Per1
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcPEP
				ELSE VolumenTotal
			END,'###,###,###.###','en-US')											AS VolPorcentaje1,
			FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP1 * @PorcDistContra_Per1
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcSocio
				ELSE VolumenTotal
			END,'###,###,###.###','en-US')											AS VolPorcentaje2,
-- PERIODO 2
			CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistEdo_Per2 * 100
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcPEP * 100
				ELSE 100
			END																		AS Porcentaje1P2,
			CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistContra_Per2 * 100
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcSocio * 100
				ELSE 100
			END																		AS Porcentaje2P2,
			FORMAT(VolumenP2,'###,###,###.###','en-US')								AS VolumenP2,
			FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP2 * @PorcDistEdo_Per2
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcPEP
				ELSE VolumenTotal
			END,'###,###,###.###','en-US')					AS VolPorcentaje21,
			FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP2 * @PorcDistContra_Per2
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcSocio
				ELSE VolumenTotal
			END,'###,###,###.###','en-US')					 AS VolPorcentaje22
		FROM
			#Datos
		WHERE
			Hidrocarburo	NOT LIKE '%C5%'

	END
	-- C5 MMBTU Y C5 BBL
	ELSE
	BEGIN
		SELECT
			@NumeroContrato	AS Contrato,
			PuntoEntrega,
			CASE WHEN @EsProduccionCompartida = 1 THEN 'Produccion Compartida'
				WHEN @EsLicencia = 1 AND @EsConsorcio = 0 THEN 'Licencia'
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN 'Licencia en Consorcio'
			END			AS	Tipocontrato,
			CASE WHEN @Formato = 'M' THEN 'Reporte Mensual'
				ELSE 'Reporte Diario'
			END				AS Tiporeporte,
			CASE WHEN Hidrocarburo = 'C5'	THEN 'C5+'
				ELSE 'C5 BBL'
			END				AS Tipohidrocarburo,
			FORMAT(VolumenTotal,'###,###,###.###','en-US')		AS Volumen,
-- PERIODO 1
			CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistEdo_Per1 * 100
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcPEP * 100
				ELSE 100
			END													AS Porcentaje1,
			CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistContra_Per1 * 100
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcSocio * 100
				ELSE 100
			END													AS Porcentaje2,
			FORMAT(VolumenP1,'###,###,###.###','en-US')								AS VolumenP1,
			FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP1 * @PorcDistEdo_Per1
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcPEP
				ELSE VolumenTotal
			END,'###,###,###.###','en-US')											AS VolPorcentaje1,
			FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP1 * @PorcDistContra_Per1
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcSocio
				ELSE VolumenTotal
			END,'###,###,###.###','en-US')											AS VolPorcentaje2,
-- PERIODO 2
			CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistEdo_Per2 * 100
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcPEP * 100
				ELSE 100
			END																		AS Porcentaje1P2,
			CASE WHEN @EsProduccionCompartida = 1 THEN @PorcDistContra_Per2 * 100
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN @PorcSocio * 100
				ELSE 100
			END																		AS Porcentaje2P2,
			FORMAT(VolumenP2,'###,###,###.###','en-US')								AS VolumenP2,
			FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP2 * @PorcDistEdo_Per2
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcPEP
				ELSE VolumenTotal
			END,'###,###,###.###','en-US')					AS VolPorcentaje21,
			FORMAT(CASE WHEN @EsProduccionCompartida = 1 THEN VolumenP2 * @PorcDistContra_Per2
				WHEN @EsLicencia = 1 AND @EsConsorcio = 1 THEN VolumenTotal * @PorcSocio
				ELSE VolumenTotal
			END,'###,###,###.###','en-US')					 AS VolPorcentaje22
		FROM
			#Datos
		WHERE
			Hidrocarburo	LIKE '%C5%'
	END

END

END