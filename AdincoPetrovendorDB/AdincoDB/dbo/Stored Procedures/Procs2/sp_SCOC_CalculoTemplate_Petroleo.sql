CREATE PROCEDURE dbo.sp_SCOC_CalculoTemplate_Petroleo
	@IdContrato	INT,
	@MesReporte		DATE,
	@Usuario		INT,
	@IdContratista	INT
AS
BEGIN
SET NOCOUNT ON
-- ============================================================
-- Modulo:			SCOC - Calculo de Volumenes de Petroleo
--------------------------------------------------------------
-- 20181004		BAAC	Creación de SP
-- ============================================================
CREATE TABLE #Calculos
(
	IdContrato	INT,
	MesReporte	DATE,
	FechaReporte	DATE,
	FechaEntrega	DATE,
	Dia			INT,
	CampoID	INT,
	M3_20Grados	FLOAT,
	GradosAPI	FLOAT,
	PesoEspec	FLOAT,
	AguaSedimento	FLOAT,
	Sal			FLOAT,
	Azufre		FLOAT,
	fConvTemp20_15	FLOAT,
	BL_20C		FLOAT,
	M3_60F		FLOAT,
	BL_60F		FLOAT,
	PorcDistEdo	FLOAT,
	PorcDistContra	FLOAT,
	Compensacion FLOAT,
	DistEdo		FLOAT,
	DistContratista	FLOAT,
	Aplicada	FLOAT,
	Pendiente	FLOAT,
	PRIMARY KEY (IdContrato, MesReporte, Dia, CampoID)
)

CREATE TABLE #Balance
(
	CampoID	INT,
	VolMensual_M3_20	FLOAT,
	VolDiario_M3_20		FLOAT,
	VolDiario_PEP_M3_20	FLOAT,
	VolDiario_SOCIO_M3_20	FLOAT,
	Diferencia_M3_20	FLOAT,
	SumaPorc_M3_20		FLOAT,
	Diferencia_Porc_M3_20	FLOAT,
	VolMensual_BL_20	FLOAT,
	VolDiario_BL_20		FLOAT,
	VolDiario_PEP_BL_20		FLOAT,
	VolDiario_SOCIO_BL_20		FLOAT,
	Diferencia_BL_20	FLOAT,
	SumaPorc_BL_20		FLOAT,
	Diferencia_Porc_BL_20	FLOAT,
	VolMensual_M3_60	FLOAT,
	VolDiario_M3_60		FLOAT,
	VolDiario_PEP_M3_60		FLOAT,
	VolDiario_SOCIO_M3_60		FLOAT,
	Diferencia_M3_60	FLOAT,
	SumaPorc_M3_60		FLOAT,
	Diferencia_Porc_M3_60	FLOAT,
	VolMensual_BL_60	FLOAT,
	VolDiario_BL_60		FLOAT,
	VolDiario_PEP_BL_60		FLOAT,
	VolDiario_SOCIO_BL_60		FLOAT,
	Diferencia_BL_60	FLOAT,
	SumaPorc_BL_60		FLOAT,
	Diferencia_Porc_BL_60	FLOAT,
	UltimoDia	INT,
	PRIMARY KEY (CampoID)
)

DECLARE
	@fConv_Vol_M3_Bl	FLOAT = 6.2898,
	@EsProduccionCompartida	BIT,
	@NumeroContrato	VARCHAR(100),
	@FechaCorte	DATE,
	@Dias			INT	= 1,
	@CompPendiente	FLOAT,
	@EsLicencia		BIT,
	@EsConsorcio	BIT,
	@IdUniMedidaM3	INT,
	@AplicaBalance		BIT = 0,
	@PorcDefault FLOAT = 100

SELECT	@EsProduccionCompartida = CASE 
								WHEN IdTipoContrato = 2	THEN 1
							ELSE 0 END,
		@NumeroContrato	=	NumeroContrato,
		@EsLicencia		=	CASE 
								WHEN IdTipoContrato = 3	THEN 1
							ELSE 0 END,
		@EsConsorcio	=	ISNULL(IsConsorcio,0)
FROM
	dbo.CO_Contrato
WHERE
	IdContrato	=	@IdContrato

SELECT @IdUniMedidaM3 =	idUnidadMedida
FROM dbo.CO_UnidadMedida
WHERE Abreviatura = 'M3'

-- SE OBTIENE INDICADOS QUE DETERMINA SI SE INCLUYE EL PETROLEO EN 15 Y 20 GRADOS O SOLO EN UNA DE LAS TEMPERATURAS
SELECT
	@AplicaBalance	=	ISNULL(Balance,0)
FROM
	dbo.SCOC_Contrato
WHERE
	IdContrato	=	@IdContrato

INSERT INTO #Calculos
(
	IdContrato,
	MesReporte,
	FechaReporte,
	FechaEntrega,
	Dia,
	CampoID,
	GradosAPI,
	PesoEspec,
	AguaSedimento,
	Sal,
	Azufre,
	M3_20Grados,
	BL_20C,
	M3_60F,
	BL_60F
)
SELECT
	IdContrato,
	MesReporte,
	FechaReporte,
	FechaEntrega,
	Dia,
	CampoID,
	GradosAPI,
	PesoEspec,
	AguaSedimento,
	Sal,
	Azufre,
	CASE	-- M3_20GRADOS
		WHEN @AplicaBalance = 0 AND IdUnidadMedida = 	@IdUniMedidaM3 AND Temperatura	=	20
		THEN M3_20Grados --ROUND(M3_20Grados,6)
		WHEN @AplicaBalance = 0 AND IdUnidadMedida <> 	@IdUniMedidaM3 AND Temperatura	=	20
		THEN ROUND(M3_20Grados / @fConv_Vol_M3_Bl,3) --ROUND((M3_20Grados / @fConv_Vol_M3_Bl),6) 	-- CONVERTIR DE BBL A M3
		WHEN @AplicaBalance = 0 AND IdUnidadMedida = 	@IdUniMedidaM3 AND Temperatura	=	15.56
		THEN ROUND(Volumen15Grados / EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) ))),3) -- CONVERTIR A 20°
		WHEN @AplicaBalance = 0 AND IdUnidadMedida <> 	@IdUniMedidaM3 AND Temperatura	=	15.56
		THEN ROUND(ROUND(Volumen15Grados / @fConv_Vol_M3_Bl,3) / EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) ))),3) -- CONVERTIR A M3 Y A 20°
		WHEN @AplicaBalance = 1 AND IdUnidadMedida = 	@IdUniMedidaM3
		THEN M3_20Grados --ROUND(M3_20Grados,6)
		WHEN @AplicaBalance = 1 AND IdUnidadMedida <> 	@IdUniMedidaM3
		THEN (M3_20Grados / @fConv_Vol_M3_Bl) --ROUND((M3_20Grados / @fConv_Vol_M3_Bl),6) 	-- CONVERTIR DE BBL A M3
	END,		-- M3_20GRADOS
	CASE --BL_20C -- DATOS ENVIADOS A 20° EN BARRILES
		WHEN @AplicaBalance = 0 AND IdUnidadMedida <> @IdUniMedidaM3 AND Temperatura	=	20
			THEN M3_20Grados -- ROUND(M3_20Grados,6)	-- SE REGISTRARON BARRILES A 20
		WHEN @AplicaBalance = 0 AND IdUnidadMedida = @IdUniMedidaM3 AND Temperatura	=	20		-- SE REGISTRARON M3 A 20
			THEN ROUND(M3_20Grados * @fConv_Vol_M3_Bl,3) --ROUND((M3_20Grados * @fConv_Vol_M3_Bl),6)	-- SE CONVIERTEN A BLLS
		WHEN @AplicaBalance = 0 AND IdUnidadMedida <> @IdUniMedidaM3 AND Temperatura	=	15.56 -- SE REGISTRARON BARRILESS A 15
			THEN (Volumen15Grados / EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) ))))	-- CONVERTIR A 20°
		WHEN @AplicaBalance = 0 AND IdUnidadMedida = @IdUniMedidaM3 AND Temperatura	=	15.56 -- SE REGISTRARON M3 A 15
			THEN ((Volumen15Grados * @fConv_Vol_M3_Bl) / EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) )))) -- CONVERTIR A BLL Y A 20°
		WHEN @AplicaBalance = 1 AND IdUnidadMedida = 	@IdUniMedidaM3	-- SE CONVIERTEN A BLL
			THEN ((M3_20Grados * @fConv_Vol_M3_Bl))
		WHEN @AplicaBalance = 1 AND IdUnidadMedida <> 	@IdUniMedidaM3
			THEN M3_20Grados --ROUND(M3_20Grados,6)
	END,		-- BL_20C
	CASE 
		WHEN @AplicaBalance = 0 AND IdUnidadMedida = @IdUniMedidaM3 AND Temperatura	=	20
		THEN ROUND(M3_20Grados * EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) ))) ,3)	-- SE CONVIERTE A 15°
		WHEN @AplicaBalance = 0 AND IdUnidadMedida <> 	@IdUniMedidaM3 AND Temperatura	=	20
		THEN (ROUND(M3_20Grados / @fConv_Vol_M3_Bl,3) * EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) ))))	-- SE CONVIERTE A m3 y a 15°
		WHEN @AplicaBalance = 0 AND IdUnidadMedida = 	@IdUniMedidaM3 AND Temperatura	=	15.56
		THEN (Volumen15Grados)
		WHEN @AplicaBalance = 0 AND IdUnidadMedida <> @IdUniMedidaM3 AND Temperatura	=	15.56
		THEN ((Volumen15Grados / @fConv_Vol_M3_Bl))
		WHEN @AplicaBalance = 1 AND IdUnidadMedida = 	@IdUniMedidaM3	
		THEN (Volumen15Grados)
		WHEN @AplicaBalance = 1 AND IdUnidadMedida <> 	@IdUniMedidaM3	
		THEN ((Volumen15Grados / @fConv_Vol_M3_Bl))
	END,
	CASE 
	WHEN @AplicaBalance = 0 AND IdUnidadMedida <> @IdUniMedidaM3 AND Temperatura	=	20
		THEN (M3_20Grados * EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) )))) --- SE CONVIERTEN BARRILES A 15°
	WHEN @AplicaBalance = 0 AND IdUnidadMedida = @IdUniMedidaM3 AND Temperatura	=	20
		THEN ROUND((ROUND(M3_20Grados * @fConv_Vol_M3_Bl,3) * EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) )))),3) -- SE CONVIERTE A BARRILES Y A 15°
	WHEN @AplicaBalance = 0 AND IdUnidadMedida <> @IdUniMedidaM3 AND Temperatura	=	15.56
		THEN (Volumen15Grados)
	WHEN @AplicaBalance = 0 AND IdUnidadMedida = @IdUniMedidaM3 AND Temperatura	=	15.56
		THEN (Volumen15Grados * @fConv_Vol_M3_Bl)
	WHEN @AplicaBalance = 1 AND IdUnidadMedida = 	@IdUniMedidaM3
		THEN (Volumen15Grados * @fConv_Vol_M3_Bl)
	WHEN @AplicaBalance = 1 AND IdUnidadMedida <> 	@IdUniMedidaM3
		THEN (Volumen15Grados)
	END
FROM
	SCOC_ReporteDiarioPetroleo
WHERE
	IdContrato	=	@IdContrato
	AND
	MesReporte	=	@MesReporte


UPDATE #Calculos
	SET	fConvTemp20_15 =  EXP( -( (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * 8 * ( 1+0.8* (341.0957/POWER(999.012*(141.5/(131.5+GradosAPI)),2)) * (8+0.01374979547) )))


--UPDATE #Calculos
--	SET
--		BL_20C	=	ROUND(M3_20Grados * @fConv_Vol_M3_Bl,3),
--		M3_60F	=	ROUND(M3_20Grados * fConvTemp20_15,3)

--UPDATE #Calculos
--	SET	BL_60F	=	ROUND(BL_20C * fConvTemp20_15,3)

IF @EsProduccionCompartida = 1
BEGIN

	SELECT
		@FechaCorte	=	IdFecha
	FROM
		AP_Calendario
	WHERE
		Anio	=	YEAR(@MesReporte)
		AND		Mes	=	MONTH(@MesReporte)
		AND	Descripcion	=	'Resultados y Elementos del Cálculo (Fecha máxima)'


	UPDATE	C
		SET	
			PorcDistEdo	=	RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)],
			PorcDistContra	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)],
			Compensacion	=	0,
			Aplicada	=	0,
			Pendiente	=	0
	FROM
		#Calculos	C
	JOIN
		dbo.PC_RM	RM53
		ON	RM53.[Año de reporte (RM53_01)]	= YEAR(DATEADD(MONTH,-2, C.MesReporte))
		AND	RM53.[Mes de reporte (RM53_00)]	= MONTH(DATEADD(MONTH,-2, C.MesReporte))
	WHERE
		RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato
		AND C.FechaReporte	<=	@FechaCorte

	UPDATE	C
		SET	
			PorcDistEdo	=	RM53.[Nueva Distribución Provisional a favor del Estado (RM53_52)],
			PorcDistContra	=	RM53.[Nueva Distribución Provisional a favor del Contratista (RM53_53)],
			Compensacion = CASE WHEN C.FechaReporte = DATEADD(DAY,1,@FechaCorte)
									THEN CONVERT(FLOAT,REPLACE(RM53.[Compensaciones volumétricas: Nuevo saldo acumulado de petróleo a],',',''))
								ELSE 0 END,
			Aplicada	=	0,
			Pendiente	=	0
	FROM
		#Calculos	C
	JOIN
		dbo.PC_RM	RM53
		ON	RM53.[Año de reporte (RM53_01)]	= YEAR(DATEADD(MONTH,-1, C.MesReporte))
		AND	RM53.[Mes de reporte (RM53_00)]	= MONTH(DATEADD(MONTH,-1, C.MesReporte))
	WHERE
		RM53.[ID del contrato asignado por CNH (RF01_01)] = @NumeroContrato
		AND C.FechaReporte	>	@FechaCorte

	UPDATE #Calculos
		SET
				DistEdo	=	ROUND(BL_60F * (PorcDistEdo/100),3),
				DistContratista	=	ROUND(BL_60F * (PorcDistContra/100),3)
				

	-- SE ACTUALIZA LA COMPENSACION APLICADA PARA VER SI EN EL MISMO DIA DE PUEDE CONPENSAR
	UPDATE #Calculos
		SET	Aplicada	= CASE WHEN DistEdo + Compensacion > 0 THEN DistEdo + Compensacion
								ELSE DistEdo
							END,
			Pendiente	= CASE WHEN DistEdo + Compensacion > 0 THEN 0
								ELSE DistEdo + Compensacion
							END
		WHERE
			FechaReporte	= DATEADD(DAY,1,@FechaCorte)

			-- HACER EL ACARREO DE LA COMPENSACION A LOS SIGUIENTES DIAS
		IF 0 <> (SELECT SUM(ABS (ISNULL(Pendiente,0)))
				FROM #Calculos
				WHERE FechaReporte	= DATEADD(DAY,@Dias,@FechaCorte))
		BEGIN
			WHILE 0 <> (SELECT SUM(ABS(ISNULL(Pendiente,0)))
						FROM #Calculos
						WHERE FechaReporte	= DATEADD(DAY,@Dias,@FechaCorte))
			BEGIN
				
				SELECT
					@CompPendiente	=	ISNULL(Pendiente,0)
				FROM
					#Calculos
				WHERE 
					FechaReporte = DATEADD(DAY,@Dias,@FechaCorte)

				SELECT @Dias = @Dias + 1

				UPDATE C
					SET	Aplicada	= CASE 
										WHEN @CompPendiente = 0 THEN 0
										WHEN @CompPendiente <> 0 AND DistEdo + @CompPendiente > 0 THEN DistEdo + @CompPendiente
										ELSE DistEdo
									END,
						Pendiente	= CASE WHEN @CompPendiente = 0 THEN 0
										WHEN @CompPendiente <> 0 AND DistEdo + @CompPendiente > 0 THEN 0
										ELSE DistEdo + @CompPendiente
									END
				FROM
					#Calculos	C
				WHERE
					FechaReporte	= DATEADD(DAY,@Dias,@FechaCorte)

			END
		END
END

ELSE
BEGIN
	IF @EsConsorcio = 1
	BEGIN

		INSERT INTO #Balance
		(
			CampoID,
			--VolMensual_M3_20,
			--VolDiario_M3_20,
			VolMensual_BL_20,
			VolDiario_BL_20,
			--VolMensual_M3_60,
			--VolDiario_M3_60,
			VolMensual_BL_60,
			VolDiario_BL_60,
			UltimoDia
		)
		SELECT
		-- 3 DECIMALES
			CampoID,
			--ROUND(SUM(CASE WHEN DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) = Dia THEN ROUND(M3_20Grados,4) ELSE M3_20Grados END),3), 
			--SUM(ROUND(M3_20Grados,3)),
			--ROUND(SUM(CASE WHEN DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) = Dia THEN ROUND(BL_20C,4) ELSE BL_20C END),3),
			ROUND(SUM(BL_20C),3),
			SUM(ROUND(BL_20C,3)),
			--ROUND(SUM(CASE WHEN DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) = Dia THEN ROUND(M3_60F,4) ELSE M3_60F END),3),
			--SUM(ROUND(M3_60F,3)),
			--ROUND(SUM(CASE WHEN DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) = Dia THEN ROUND(BL_60F,4) ELSE BL_60F END),3),
			ROUND(SUM(BL_60F),3),
			SUM(ROUND(BL_60F,3)),
			DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)))
		-- 4 DECIMALES
			--CampoID,
			--ROUND(SUM(CASE WHEN DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) = Dia THEN ROUND(M3_20Grados,4) ELSE M3_20Grados END),4), 
			--SUM(ROUND(M3_20Grados,4)),
			--ROUND(SUM(CASE WHEN DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) = Dia THEN ROUND(BL_20C,4) ELSE BL_20C END),4),
			--SUM(ROUND(BL_20C,4)),
			--ROUND(SUM(CASE WHEN DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) = Dia THEN ROUND(M3_60F,4) ELSE M3_60F END),4),
			--SUM(ROUND(M3_60F,4)),
			--ROUND(SUM(CASE WHEN DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))) = Dia THEN ROUND(BL_60F,4) ELSE BL_60F END),4),
			--SUM(ROUND(BL_60F,4)),
			--DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)))
		FROM
			#Calculos	C
		--JOIN
		--	dbo.CO_PorcentajesContrato	P
		--	ON	C.IdContrato	=	P.idContrato
		GROUP BY
			CampoID

		UPDATE #Balance
			SET
				--Diferencia_M3_20 = VolMensual_M3_20 - VolDiario_M3_20,
				Diferencia_BL_20 = VolMensual_BL_20 - VolDiario_BL_20,
				--Diferencia_M3_60 = VolMensual_M3_60 - VolDiario_M3_60,
				Diferencia_BL_60 = VolMensual_BL_60 - VolDiario_BL_60


		UPDATE	C
		-- 3 DECIMALES
			--SET M3_20Grados	= CASE WHEN B.Diferencia_M3_20 <> 0 THEN ROUND(ROUND(C.M3_20Grados,3) + B.Diferencia_M3_20,3) ELSE C.M3_20Grados END,
			SET	BL_20C = CASE WHEN B.Diferencia_BL_20 <> 0 THEN ROUND(ROUND(C.BL_20C,3) + B.Diferencia_BL_20,3) ELSE C.BL_20C END,
			--	M3_60F = CASE WHEN B.Diferencia_M3_60 <> 0 THEN ROUND(ROUND(C.M3_60F,3) + B.Diferencia_M3_60,3) ELSE C.M3_60F END,
				BL_60F = CASE WHEN B.Diferencia_BL_60 <> 0 THEN ROUND(ROUND(C.BL_60F,3) + B.Diferencia_BL_60,3) ELSE C.BL_60F END
		-- 4 DECIMALES
			--SET M3_20Grados	= CASE WHEN B.Diferencia_M3_20 <> 0 THEN ROUND(ROUND(C.M3_20Grados,4) + B.Diferencia_M3_20,4) ELSE C.M3_20Grados END,
			--	BL_20C = CASE WHEN B.Diferencia_BL_20 <> 0 THEN ROUND(ROUND(C.BL_20C,4) + B.Diferencia_BL_20,4) ELSE C.BL_20C END,
			--	M3_60F = CASE WHEN B.Diferencia_M3_60 <> 0 THEN ROUND(ROUND(C.M3_60F,4) + B.Diferencia_M3_60,4) ELSE C.M3_60F END,
			--	BL_60F = CASE WHEN B.Diferencia_BL_60 <> 0 THEN ROUND(ROUND(C.BL_60F,4) + B.Diferencia_BL_60,4) ELSE C.BL_60F END
		FROM
			#Calculos	C
		JOIN
			#Balance	B
			ON	C.CampoID	=	B.CampoID
		WHERE
			C.Dia	=	B.UltimoDia

/*
		--SELECT * FROM #Balance
		-- SE BORRA LA INFORMACIÓN DE LA TABLA DE BALANCE PARA OBTENER LOS DATUS NUEVAMENTE, YA CON LOS AJUSTES REALIZADOS
		DELETE FROM #Balance

		INSERT INTO #Balance
		(
			CampoID,
			VolMensual_M3_20,
			VolDiario_M3_20,
			VolMensual_BL_20,
			VolDiario_BL_20,
			VolMensual_M3_60,
			VolDiario_M3_60,
			VolMensual_BL_60,
			VolDiario_BL_60,
			UltimoDia,
			VolDiario_PEP_M3_20,
			VolDiario_SOCIO_M3_20,
			VolDiario_PEP_BL_20	,
			VolDiario_SOCIO_BL_20,
			VolDiario_PEP_M3_60,
			VolDiario_SOCIO_M3_60,
			VolDiario_PEP_BL_60,
			VolDiario_SOCIO_BL_60
		)
		SELECT
		-- 3 DECIMALES
			--CampoID,
			--ROUND(SUM(ROUND(M3_20Grados,3)),3), 
			--SUM(ROUND(M3_20Grados,3)),
			--ROUND(SUM(ROUND(BL_20C,3)),3),
			--SUM(ROUND(BL_20C,3)),
			--ROUND(SUM(ROUND(M3_60F,3)),3),
			--SUM(ROUND(M3_60F,3)),
			--ROUND(SUM(ROUND(BL_60F,3)),3),
			--SUM(ROUND(BL_60F,3)),
			--DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))),
			--SUM(ROUND(ROUND(M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3)),
			--SUM(ROUND(ROUND(M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)),
			--SUM(ROUND(ROUND(BL_20C,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3)),
			--SUM(ROUND(ROUND(BL_20C,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)),
			--SUM(ROUND(ROUND(M3_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3)),
			--SUM(ROUND(ROUND(M3_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)),
			--SUM(ROUND(ROUND(BL_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3)),
			--SUM(ROUND(ROUND(BL_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3))
		-- 4 DECIMALES
			CampoID,
			ROUND(SUM(ROUND(M3_20Grados,4)),4), 
			SUM(ROUND(M3_20Grados,4)),
			ROUND(SUM(ROUND(BL_20C,4)),4),
			SUM(ROUND(BL_20C,4)),
			ROUND(SUM(ROUND(M3_60F,4)),4),
			SUM(ROUND(M3_60F,4)),
			ROUND(SUM(ROUND(BL_60F,4)),4),
			SUM(ROUND(BL_60F,4)),
			DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte))),
			SUM(ROUND(ROUND(M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4)),
			SUM(ROUND(ROUND(M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)),
			SUM(ROUND(ROUND(BL_20C,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4)),
			SUM(ROUND(ROUND(BL_20C,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)),
			SUM(ROUND(ROUND(M3_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4)),
			SUM(ROUND(ROUND(M3_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)),
			SUM(ROUND(ROUND(BL_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4)),
			SUM(ROUND(ROUND(BL_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4))
		FROM
			#Calculos	C
		JOIN
			dbo.CO_PorcentajesContrato	P
			ON	C.IdContrato	=	P.idContrato
		GROUP BY
			CampoID

		UPDATE #Balance
			SET
				Diferencia_M3_20 = ROUND(VolMensual_M3_20 - VolDiario_M3_20,4),
				Diferencia_BL_20 = ROUND(VolMensual_BL_20 - VolDiario_BL_20,4),
				Diferencia_M3_60 = ROUND(VolMensual_M3_60 - VolDiario_M3_60,4),
				Diferencia_BL_60 = ROUND(VolMensual_BL_60 - VolDiario_BL_60,4),
				SumaPorc_M3_20	= VolDiario_PEP_M3_20 + VolDiario_SOCIO_M3_20,
				SumaPorc_BL_20	= VolDiario_PEP_BL_20 + VolDiario_SOCIO_BL_20,
				SumaPorc_M3_60	= VolDiario_PEP_M3_60 + VolDiario_SOCIO_M3_60,
				SumaPorc_BL_60	= VolDiario_PEP_BL_60 + VolDiario_SOCIO_BL_60

		UPDATE #Balance
			SET
				Diferencia_Porc_M3_20	=	VolMensual_M3_20 - SumaPorc_M3_20,
				Diferencia_Porc_BL_20	=	VolMensual_BL_20 - SumaPorc_BL_20,
				Diferencia_Porc_M3_60	=	VolMensual_M3_60 - SumaPorc_M3_60,
				Diferencia_Porc_BL_60	=	VolMensual_BL_60 - SumaPorc_BL_60
				
		-- COMPARAMOS EL VOLUMEN ORIGINAL CONTRA LA SUMA DE LOS VOLUMENES DE PARTICIPACION PARA IGUALARLOS Y EVITAR LAS DIFERENCIAS POR DECIMALES		
		UPDATE C
			SET
		-- 3 DECIMALES
				--M3_20Grados	= CASE WHEN ROUND(C.M3_20Grados,3) - (ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia <> B.UltimoDia
				--				THEN ROUND(ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) + ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3),3)
				--			  WHEN ROUND(C.M3_20Grados,3) - (ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND((ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) + B.Diferencia_Porc_M3_20,3)
				--			  WHEN ROUND(C.M3_20Grados,3) - (ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.M3_20Grados,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) = 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND(ROUND(C.M3_20Grados,3) + B.Diferencia_Porc_M3_20,3)
				--			  ELSE ROUND(C.M3_20Grados,3)
				--			END,

				--BL_20C = CASE WHEN ROUND(C.BL_20C,3) - (ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia <> B.UltimoDia
				--				THEN ROUND(ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) + ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3),3)
				--			  WHEN ROUND(C.BL_20C,3) - (ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND((ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) + B.Diferencia_Porc_BL_20,3)
				--			  WHEN ROUND(C.BL_20C,3) - (ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.BL_20C,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) = 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND(ROUND(C.BL_20C,3) + B.Diferencia_Porc_BL_20,3)
				--			  ELSE ROUND(C.BL_20C,3)
				--			END,

				--M3_60F = CASE WHEN ROUND(C.M3_60F,3) - (ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia <> B.UltimoDia
				--				THEN ROUND(ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) + ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3),3)
				--			  WHEN ROUND(C.M3_60F,3) - (ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND((ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) + B.Diferencia_Porc_M3_60,3)
				--			  WHEN ROUND(C.M3_60F,3) - (ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.M3_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) = 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND(ROUND(C.M3_60F,3) + B.Diferencia_Porc_M3_60,3)
				--			  ELSE ROUND(C.M3_60F,3)
				--			END,

				--BL_60F = CASE WHEN ROUND(C.BL_60F,3) - (ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia <> B.UltimoDia
				--				THEN ROUND(ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) + ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3),3)
				--			  WHEN ROUND(C.BL_60F,3) - (ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND((ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) + B.Diferencia_Porc_BL_60,3)
				--			  WHEN ROUND(C.BL_60F,3) - (ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(ROUND(C.BL_60F,3)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) = 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND(ROUND(C.BL_60F,3) + B.Diferencia_Porc_BL_60,3)
				--			  ELSE ROUND(C.BL_60F,3)
				--			END
		-- 4 DECIMALES
			M3_20Grados	= CASE WHEN ROUND(C.M3_20Grados,4) - (ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia <> B.UltimoDia
								THEN ROUND(ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) + ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4),4)
							  WHEN ROUND(C.M3_20Grados,4) - (ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia = B.UltimoDia
								THEN ROUND((ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) + B.Diferencia_Porc_M3_20,4)
							  WHEN ROUND(C.M3_20Grados,4) - (ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.M3_20Grados,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) = 0 AND C.Dia = B.UltimoDia
								THEN ROUND(ROUND(C.M3_20Grados,4) + B.Diferencia_Porc_M3_20,4)
							  ELSE ROUND(C.M3_20Grados,4)
							END,

				BL_20C = CASE WHEN ROUND(C.BL_20C,4) - (ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia <> B.UltimoDia
								THEN ROUND(ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) + ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4),4)
							  WHEN ROUND(C.BL_20C,4) - (ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia = B.UltimoDia
								THEN ROUND((ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) + B.Diferencia_Porc_BL_20,4)
							  WHEN ROUND(C.BL_20C,4) - (ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.BL_20C,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) = 0 AND C.Dia = B.UltimoDia
								THEN ROUND(ROUND(C.BL_20C,4) + B.Diferencia_Porc_BL_20,4)
							  ELSE ROUND(C.BL_20C,4)
							END,

				M3_60F = CASE WHEN ROUND(C.M3_60F,4) - (ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia <> B.UltimoDia
								THEN ROUND(ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) + ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4),4)
							  WHEN ROUND(C.M3_60F,4) - (ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia = B.UltimoDia
								THEN ROUND((ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) + B.Diferencia_Porc_M3_60,4)
							  WHEN ROUND(C.M3_60F,4) - (ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.M3_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) = 0 AND C.Dia = B.UltimoDia
								THEN ROUND(ROUND(C.M3_60F,4) + B.Diferencia_Porc_M3_60,4)
							  ELSE ROUND(C.M3_60F,4)
							END,

				BL_60F = CASE WHEN ROUND(C.BL_60F,4) - (ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia <> B.UltimoDia
								THEN ROUND(ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) + ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4),4)
							  WHEN ROUND(C.BL_60F,4) - (ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia = B.UltimoDia
								THEN ROUND((ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) + B.Diferencia_Porc_BL_60,4)
							  WHEN ROUND(C.BL_60F,4) - (ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(ROUND(C.BL_60F,4)*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) = 0 AND C.Dia = B.UltimoDia
								THEN ROUND(ROUND(C.BL_60F,4) + B.Diferencia_Porc_BL_60,4)
							  ELSE ROUND(C.BL_60F,4)
							END
		FROM
			 #Calculos	C
		JOIN
			dbo.CO_PorcentajesContrato	P
			ON	C.IdContrato	=	P.idContrato
		JOIN
			#Balance	B
			ON	C.CampoID	=	B.CampoID
*/			
	END
END


-- SE BORRA LA INFORMACIÓN QUE YA EXISTA DEL CONTRATO - MES
DELETE
	SCOC_CalculoDiario_Petroleo
WHERE
	IdContrato	=	@IdContrato
	AND	MesReporte = @MesReporte

-- SE INSERTAN LOS DATOS CALCULADOS
INSERT INTO SCOC_CalculoDiario_Petroleo
(
	IdContrato,
	MesReporte,
	FechaReporte,
	FechaEntrega,
	Dia,
	CampoID,
	M3_20Grados,
	BL_20C,
	M3_60F,
	BL_60F,
	PorcDistEdo,
	PorcDistContra,
	Compensacion,
	DistEdo,
	DistContratista,
	Aplicada,
	Pendiente,
	CreadoPor,
	CreadoEn
)
SELECT
	IdContrato,
	MesReporte,
	FechaReporte,
	FechaEntrega,
	Dia,
	CampoID,
	(M3_20Grados),
	(BL_20C),
	(M3_60F),
	(BL_60F),
	PorcDistEdo,
	PorcDistContra,
	Compensacion,
	DistEdo,
	DistContratista,
	Aplicada,
	Pendiente,
	@Usuario,
	GETDATE()		
FROM
	#Calculos



IF @EsProduccionCompartida = 1
BEGIN

	SELECT
		MesReporte,
		FechaReporte,
		FechaEntrega,
		Dia,
		M3_20Grados	AS [M3 20° C],
		GradosAPI	AS [Grados API],
		PesoEspec	AS [Peso Espec.],
		AguaSedimento	AS [Agua y Sal],
		Sal,
		Azufre,
		@fConv_Vol_M3_Bl	AS [f Conv. Vol M3 a Bl],
		fConvTemp20_15		AS [f Conv. Temp 20° a 15.5° C],
		BL_20C		AS [Barriles 20° C],
		M3_60F		AS [M3 60° F],
		BL_60F		AS [Barriles 60° F],
		PorcDistEdo,
		PorcDistContra,
		DistEdo,
		DistContratista,
		Compensacion,
		Aplicada,
		Pendiente	
	FROM
		#Calculos
END
ELSE
BEGIN
	-- LICENCIA EN CONSORCIO CON PEMEX
	IF @EsLicencia = 1 AND @EsConsorcio = 1
	BEGIN
		SELECT
			CC.NombreCampo	AS [Campo],
			C.MesReporte,
			C.FechaReporte,
			C.FechaEntrega,
			C.Dia,
			C.M3_20Grados	AS [M3 20° C],
			C.GradosAPI	AS [Grados API],
			C.PesoEspec	AS [Peso Espec.],
			C.AguaSedimento	AS [Agua y Sal],
			C.Sal,
			C.Azufre,
			@fConv_Vol_M3_Bl	AS [f Conv. Vol M3 a Bl],
			C.fConvTemp20_15		AS [f Conv. Temp 20° a 15.5° C],
			C.BL_20C		AS [Barriles 20° C],
			C.M3_60F		AS [M3 60° F],
			C.BL_60F		AS [Barriles 60° F],
			ISNULL(P.PorcentajePemex,0)		AS [% Dist PEP],
			ISNULL(P.PorcentajeSocio,100)	AS [% Dist Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * ROUND(C.M3_60F,3)		AS [M3 60° F PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * ROUND(C.M3_60F,3)		AS [M3 60° F Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * ROUND(C.BL_60F,3)		AS [Barriles 60° F PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * ROUND(C.BL_60F,3)		AS [Barriles 60° F Socio]
		FROM
			#Calculos	C
		JOIN
			SCOC_Campo	CC
			ON	C.CampoID	=	CC.CampoID
		LEFT JOIN
			dbo.CO_PorcentajesContrato	P
			ON	C.IdContrato	=	P.idContrato
	END
    ELSE
	BEGIN
	-- LICENCIA SIN CONSORCIO CON PEMEX
		SELECT
			CC.NombreCampo	AS [Campo],
			C.MesReporte,
			C.FechaReporte,
			C.FechaEntrega,
			C.Dia,
			C.M3_20Grados	AS [M3 20° C],
			C.GradosAPI	AS [Grados API],
			C.PesoEspec	AS [Peso Espec.],
			C.AguaSedimento	AS [Agua y Sal],
			C.Sal,
			C.Azufre,
			@fConv_Vol_M3_Bl	AS [f Conv. Vol M3 a Bl],
			C.fConvTemp20_15		AS [f Conv. Temp 20° a 15.5° C],
			C.BL_20C		AS [Barriles 20° C],
			C.M3_60F		AS [M3 60° F],
			C.BL_60F		AS [Barriles 60° F]
		FROM
			#Calculos	C
		JOIN
			SCOC_Campo	CC
			ON	C.CampoID	=	CC.CampoID

	END
END

END
