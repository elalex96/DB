CREATE PROCEDURE [dbo].[sp_SCOC_CalculoTemplate_Gas]
	@IdContrato	INT,
	@MesReporte		DATE,
	@Usuario		INT,
	@IdContratista INT
AS
BEGIN
SET NOCOUNT ON
-- ============================================================
-- Modulo:			SCOC - Calculo de Volumenes de Gas
--------------------------------------------------------------
-- 20181004		BAAC	Creación de SP
-- ============================================================
CREATE TABLE #Calculos
(
    IdContrato    INT NOT NULL,
    MesReporte    DATE NOT NULL,
    FechaReporte    DATE NOT NULL,
    FechaEntrega    DATE NOT NULL,
    Dia        INT NOT NULL,
	CampoID		INT NOT NULL,
    M3_20Grados    FLOAT,
	Volumen15Grados	FLOAT,
    MMPC_NoAprov_20Grados    FLOAT,
    H2S    FLOAT,
    CO2 FLOAT,
    N2 FLOAT,
    C1 FLOAT,
    C2 FLOAT,
    C3 FLOAT,
    IC4     FLOAT,
    NC4 FLOAT, 
    IC5 FLOAT,
    NC5 FLOAT,
    C6 FLOAT,
	C7	FLOAT,
	C8	FLOAT,
	C9	FLOAT,
	C10	FLOAT,
    PM FLOAT,
    PoderCalBTU FLOAT,   
	PorcMolarTotal	FLOAT,
	PresionParcial_C1	FLOAT,
	PresionParcial_C2	FLOAT,
	PresionParcial_C3	FLOAT,
	PresionParcial_nC4	FLOAT,
	PresionParcial_iC4	FLOAT,
	PresionParcial_nC5	FLOAT,
	PresionParcial_iC5	FLOAT,
	PresionParcial_C6Mas	FLOAT,
	PresionParcial_C7	FLOAT,
	PresionParcial_C8	FLOAT,
	PresionParcial_C9	FLOAT,
	PresionParcial_C10	FLOAT,
	PresionParcial_CO2	FLOAT,
	PresionParcial_H2S	FLOAT,
	PresionParcial_N2	FLOAT,
	Zmes_FactorCompresion	FLOAT,
-- LC Contenido de Liquido por Componente "Teorico" Gas Ideal
	LCid_C1		FLOAT,
	LCid_C2		FLOAT,
	LCid_C3		FLOAT,
	LCid_nC4		FLOAT,
	LCid_iC4		FLOAT,
	LCid_nC5		FLOAT,
	LCid_iC5		FLOAT,
	LCid_C6		FLOAT,
	LCid_C7		FLOAT,
	LCid_C8		FLOAT,
	LCid_C9		FLOAT,
	LCid_C10		FLOAT,
	LCid_CO2		FLOAT,
	LCid_H2S		FLOAT,
	LCid_N2		FLOAT,
-- LC Contenido de Liquido por Componente (Volumen de Gas Real)
	LCi_C1		FLOAT,
	LCi_C2		FLOAT,
	LCi_C3		FLOAT,
	LCi_nC4		FLOAT,
	LCi_iC4		FLOAT,
	LCi_nC5		FLOAT,
	LCi_iC5		FLOAT,
	LCi_C6		FLOAT,
	LCi_C7		FLOAT,
	LCi_C8		FLOAT,
	LCi_C9		FLOAT,
	LCi_C10		FLOAT,
	LCi_CO2		FLOAT,
	LCi_H2S		FLOAT,
	LCi_N2		FLOAT,
	VolBarriles_C1	FLOAT,
	VolBarriles_C2	FLOAT,
	VolBarriles_C3	FLOAT,
	VolBarriles_nC4	FLOAT,
	VolBarriles_iC4	FLOAT,
	VolBarriles_nC5	FLOAT,
	VolBarriles_iC5	FLOAT,
	VolBarriles_C6	FLOAT,
	VolBarriles_C7	FLOAT,
	VolBarriles_C8	FLOAT,
	VolBarriles_C9	FLOAT,
	VolBarriles_C10	FLOAT,
	VolBarriles_CO2	FLOAT,
	VolBarriles_H2S	FLOAT,
	VolBarriles_N2	FLOAT,
	BarrilesC5_Equiv	FLOAT,
	M3_20C_GasNoAprov	FLOAT,
	M3_20C_GasEntregado	FLOAT,
	MMPC_20C_GasEntregado	FLOAT,
	MMPC_60F_Gas	FLOAT,
	MPC_60_F	FLOAT,
	MPC_20_C	FLOAT,
	M3_60_F		FLOAT,
	MMBTU_60F	FLOAT,
	MMBTU_C1	FLOAT,
	MMBTU_C2	FLOAT,
	MMBTU_C3	FLOAT,
	MMBTU_C4	FLOAT,
	MMBTU_C5	FLOAT,
	PorcDistEdo	FLOAT,
	PorcDistContra	FLOAT,
	Compensacion_C1 FLOAT,
	Compensacion_C2 FLOAT,
	Compensacion_C3 FLOAT,
	Compensacion_C4 FLOAT,
	Compensacion_C5 FLOAT,
	Compensacion_Barriles FLOAT,
	DistEdo_C1	FLOAT,
	DistEdo_C2	FLOAT,
	DistEdo_C3	FLOAT,
	DistEdo_C4	FLOAT,
	DistEdo_C5	FLOAT,
	DistBarriles	FLOAT,
	Aplicada_C1	FLOAT,
	Aplicada_C2	FLOAT,
	Aplicada_C3	FLOAT,
	Aplicada_C4	FLOAT,
	Aplicada_C5	FLOAT,
	Aplicada_Barriles	FLOAT,
	Pendiente_C1	FLOAT,
	Pendiente_C2	FLOAT,
	Pendiente_C3	FLOAT,
	Pendiente_C4	FLOAT,
	Pendiente_C5	FLOAT,
	Pendiente_Barriles	FLOAT,
	TotalMMBTU_Edo	FLOAT,
	TotalMMBTUEdo_C1C4	FLOAT,
	TotalMMBTUEdo_C5	FLOAT,
	Edo_MMPC_C5		FLOAT,
	Edo_MMPC_C1C4	FLOAT,
	IdUnidadMedida	INT,
	DistContra_C1	FLOAT,
	DistContra_C2	FLOAT,
	DistContra_C3	FLOAT,
	DistContra_C4	FLOAT,
	DistContra_C5	FLOAT,
	DistContra_Barriles	FLOAT,
	AplicadaContra_C1	FLOAT,
	AplicadaContra_C2	FLOAT,
	AplicadaContra_C3	FLOAT,
	AplicadaContra_C4	FLOAT,
	AplicadaContra_C5	FLOAT,
	AplicadaContra_Barriles	FLOAT,
	TotalMMBTU_Contra	FLOAT,
	TotalMMBTUContra_C1C4	FLOAT,
	TotalMMBTUContra_C5	FLOAT,
	Contra_MMPC_C5		FLOAT,
	Contra_MMPC_C1C4	FLOAT,
	PRIMARY KEY (IdContrato, MesReporte, Dia, CampoID)
)

CREATE TABLE #CompPendientes
(
	Pendiente_C1	FLOAT,
	Pendiente_C2	FLOAT,
	Pendiente_C3	FLOAT,
	Pendiente_C4	FLOAT,
	Pendiente_C5	FLOAT,
	Pendiente_Barriles	FLOAT
)

CREATE TABLE #Balance
(
	CampoID	INT,
	VolMensual_MMPC20	FLOAT,
	VolPorcPEP_MMPC20	FLOAT,
	VolPorcSOCIO_MMPC20	FLOAT,
	SumaPorc_MMPC20	FLOAT,
	DiferenciaPorc_MMPC20	FLOAT,
	VolMensual_M320	FLOAT,
	VolPorcPEP_M320	FLOAT,
	VolPorcSOCIO_M320	FLOAT,
	SumaPorc_M320	FLOAT,
	DiferenciaPorc_M320	FLOAT,
	UltimoDia	INT,

	VolMensual_MMPC60	FLOAT,
	VolPorcPEP_MMPC60	FLOAT,
	VolPorcSOCIO_MMPC60	FLOAT,
	SumaPorc_MMPC60	FLOAT,
	DiferenciaPorc_MMPC60	FLOAT,
	VolMensual_M360	FLOAT,
	VolPorcPEP_M360	FLOAT,
	VolPorcSOCIO_M360	FLOAT,
	SumaPorc_M360	FLOAT,
	DiferenciaPorc_M360	FLOAT,
)

 DECLARE
	@FactorConvM3ft3	FLOAT = 35.31467,
	@FactorConv20c15_5	FLOAT = 1.015394385,
	--@FactorConv20c15_5		FLOAT = 1.01539438482,
	@FactorCorreccionTemp	FLOAT,
	@ConstanteBll	FLOAT = 42,
	@EsProduccionCompartida	BIT,
	@NumeroContrato	VARCHAR(100),
	@FechaCorte	DATE,
	@EsConsorcio	BIT,
	@EsLicencia		BIT,
	@FechaCompensacion	DATE,
	@Dias			INT	= 1,
	@IdUniMedidaM3	INT,
	@ConvMMft3M3	FLOAT = 28316.846600,
	@AplicaFactorCompresibilidad	BIT	=	0,
	@PorcDefault FLOAT = 100

SELECT	@FactorCorreccionTemp = ROUND(519.67/527.67,8)

SELECT	@EsProduccionCompartida = CASE 
								WHEN IdTipoContrato = 2	THEN 1
							ELSE 0 END,
		@EsLicencia		=	CASE 
								WHEN IdTipoContrato = 3	THEN 1
							ELSE 0 END,
		@NumeroContrato	=	NumeroContrato,
		@EsConsorcio	=	ISNULL(IsConsorcio,0)
FROM
	dbo.CO_Contrato
WHERE
	IdContrato	=	@IdContrato

SELECT
	@AplicaFactorCompresibilidad	=	ISNULL(AplicaFactorCompresibilidad,0)
FROM
	dbo.SCOC_Contrato
WHERE
	IdContrato	=	@IdContrato

SELECT @IdUniMedidaM3 =	idUnidadMedida
FROM dbo.CO_UnidadMedida
WHERE Abreviatura = 'M3'

INSERT INTO #Calculos
 (
	IdContrato,
	MesReporte,
	FechaReporte,
	FechaEntrega,
	Dia,
	CampoID,
	M3_20Grados,
--	Volumen15Grados,
	MMPC_NoAprov_20Grados,
	H2S,
	CO2,
	N2,
	C1,
	C2,
	C3,
	IC4,
	NC4,
	IC5,
	NC5,
	C6,
	C7,
	C8,
	C9,
	C10,
	PM,
	PoderCalBTU,
	PorcMolarTotal,
	MMPC_20C_GasEntregado,
	IdUnidadMedida
)
SELECT
	IdContrato,
	MesReporte,
	FechaReporte,
	FechaEntrega,
	Dia,
	CampoID,
	CASE WHEN IdUnidadMedida = 	@IdUniMedidaM3 AND Temperatura = 20
		THEN M3_20Grados
		WHEN IdUnidadMedida = 	@IdUniMedidaM3 AND Temperatura = 15.56
		THEN Volumen15Grados * @FactorConv20c15_5	-- Convertir de 15.56 a 20°
		WHEN IdUnidadMedida <> 	@IdUniMedidaM3 AND Temperatura = 15.56
		THEN (Volumen15Grados * @ConvMMft3M3) * @FactorConv20c15_5	-- CONVERTIR DE MMPC A M3 Y DESPUES DE 15.56° A 20°
		WHEN IdUnidadMedida <> 	@IdUniMedidaM3 AND Temperatura = 20
		THEN M3_20Grados * @ConvMMft3M3
	END,
	MMPC_NoAprov_20Grados,
	H2S,
	CO2,
	N2,
	C1,
	C2,
	C3,
	IC4,
	NC4,
	IC5,
	NC5,
	C6,
	C7,
	C8,
	C9,
	C10,
	PM,
	PoderCalBTU ,
	CO2 + H2S + N2 + C1 + C2 + C3 + IC4 + NC4 + IC5 + NC5 + C6 + ISNULL(C7,0) + ISNULL(C8,0) + ISNULL(C9,0) + ISNULL(C10,0),
	CASE WHEN IdUnidadMedida <> @IdUniMedidaM3 AND MMPC_NoAprov_20Grados = 0 AND Temperatura = 20
		THEN M3_20Grados
		ELSE 0
	END,
	IdUnidadMedida
FROM
	SCOC_ReporteDiarioGas
WHERE
	IdContrato	=	@IdContrato
	AND
	MesReporte	=	@MesReporte

/*
IF @EsProduccionCompartida = 0 AND @EsConsorcio = 1
BEGIN

	INSERT INTO #Balance
	(
		CampoID,
		VolMensual_MMPC20,
		VolPorcPEP_MMPC20,
		VolPorcSOCIO_MMPC20,
		VolMensual_M320,
		VolPorcPEP_M320,
		VolPorcSOCIO_M320,
		UltimoDia
	)
	SELECT
	-- 3 DECIMALES
		--C.CampoID,
		--ROUND(SUM(C.MMPC_20C_GasEntregado),3),
		--SUM(ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3)),
		--SUM(ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)),
		--ROUND(SUM(C.M3_20Grados),3),
		--SUM(ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3)),
		--SUM(ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)),
		--DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)))
	-- 4 DECIMALES
		C.CampoID,
		ROUND(SUM(C.MMPC_20C_GasEntregado),4),
		SUM(ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4)),
		SUM(ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)),
		ROUND(SUM(C.M3_20Grados),4),
		SUM(ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4)),
		SUM(ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)),
		DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)))
	FROM
		#Calculos	C
	JOIN
		dbo.CO_PorcentajesContrato	P
		ON C.IdContrato	=	P.idContrato
	GROUP BY
		C.CampoID

	UPDATE	#Balance
		SET
			SumaPorc_MMPC20	=	VolPorcPEP_MMPC20 + VolPorcSOCIO_MMPC20,
			SumaPorc_M320	=	VolPorcPEP_M320 + VolPorcSOCIO_M320

	UPDATE #Balance
		SET
			DiferenciaPorc_MMPC20	=	VolMensual_MMPC20 - SumaPorc_MMPC20,
			DiferenciaPorc_M320		=	VolMensual_M320 - SumaPorc_M320

	-- COMPARAMOS EL VOLUMEN ORIGINAL CONTRA LA SUMA DE LOS VOLUMENES DE PARTICIPACION PARA IGUALARLOS Y EVITAR LAS DIFERENCIAS POR DECIMALES		
		UPDATE C
			SET
			-- 3 DECIMALES
				--MMPC_20C_GasEntregado	= CASE WHEN ROUND(C.MMPC_20C_GasEntregado,3) - (ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia <> B.UltimoDia
				--				THEN ROUND(ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) + ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3),3)
				--			  WHEN ROUND(C.MMPC_20C_GasEntregado,3) - (ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND((ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) + B.DiferenciaPorc_MMPC20,3)
				--			  WHEN ROUND(C.MMPC_20C_GasEntregado,3) - (ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--												ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) = 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND(ROUND(C.MMPC_20C_GasEntregado,3) + B.DiferenciaPorc_MMPC20,3)
				--			  ELSE ROUND(C.MMPC_20C_GasEntregado,3)
				--			END,
				--M3_20Grados = CASE WHEN ROUND(C.M3_20Grados,3) - (ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--											ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia <> B.UltimoDia
				--				THEN ROUND(ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) + ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3),3)
				--			  WHEN ROUND(C.M3_20Grados,3) - (ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--											ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND((ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--											ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) + B.DiferenciaPorc_M320,3)
				--			  WHEN ROUND(C.M3_20Grados,3) - (ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
				--											ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) = 0 AND C.Dia = B.UltimoDia
				--				THEN ROUND(ROUND(C.M3_20Grados,3) + B.DiferenciaPorc_M320,3)
				--			  ELSE ROUND(C.M3_20Grados,3)
				--			END
			-- 4 DECIMALES
				MMPC_20C_GasEntregado	= CASE WHEN ROUND(C.MMPC_20C_GasEntregado,4) - (ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia <> B.UltimoDia
								THEN ROUND(ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) + ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4),4)
							  WHEN ROUND(C.MMPC_20C_GasEntregado,4) - (ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia = B.UltimoDia
								THEN ROUND((ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) + B.DiferenciaPorc_MMPC20,4)
							  WHEN ROUND(C.MMPC_20C_GasEntregado,4) - (ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
																ROUND(C.MMPC_20C_GasEntregado*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) = 0 AND C.Dia = B.UltimoDia
								THEN ROUND(ROUND(C.MMPC_20C_GasEntregado,4) + B.DiferenciaPorc_MMPC20,4)
							  ELSE ROUND(C.MMPC_20C_GasEntregado,4)
							END,
				M3_20Grados = CASE WHEN ROUND(C.M3_20Grados,4) - (ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
															ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia <> B.UltimoDia
								THEN ROUND(ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) + ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4),4)
							  WHEN ROUND(C.M3_20Grados,4) - (ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
															ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia = B.UltimoDia
								THEN ROUND((ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
															ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) + B.DiferenciaPorc_M320,4)
							  WHEN ROUND(C.M3_20Grados,4) - (ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
															ROUND(C.M3_20Grados*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) = 0 AND C.Dia = B.UltimoDia
								THEN ROUND(ROUND(C.M3_20Grados,4) + B.DiferenciaPorc_M320,4)
							  ELSE ROUND(C.M3_20Grados,4)
							END
		FROM
			 #Calculos	C
		JOIN
			dbo.CO_PorcentajesContrato	P
			ON	C.IdContrato	=	P.idContrato
		JOIN
			#Balance	B
			ON	C.CampoID	=	B.CampoID
	
	--SELECT
	--	MMPC_20C_GasEntregado,
	--	CASE WHEN (ROUND(MMPC_20C_GasEntregado,3) * 1000) % 2 = 1
	--		THEN 
	--FROM
	--		 #Calculos	C
	--	JOIN
	--		dbo.CO_PorcentajesContrato	P
	--		ON	C.IdContrato	=	P.idContrato
END 
*/
UPDATE	C
	SET
		PresionParcial_C1	= ROUND(GPA.Metano_C1 * (C.C1/100),6),
		PresionParcial_C2	= ROUND(GPA.Etano_C2 * (C.C2/100),6),
		PresionParcial_C3	= ROUND(GPA.Propano_C3 * (C.C3/100),6),
		PresionParcial_nC4	= ROUND(GPA.Butano_nC4 * (C.NC4/100),6),
		PresionParcial_iC4	= ROUND(GPA.Butano_iC4 * (C.IC4/100),6),
		PresionParcial_nC5	= ROUND(GPA.Pentano_nC5 * (C.NC5/100),6),
		PresionParcial_iC5	= ROUND(GPA.Pentano_iC5 * (C.IC5/100),6),
		PresionParcial_C6Mas	= ROUND(GPA.Hexano_C6 * (C.C6/100),6),
		PresionParcial_C7	= ROUND(GPA.Heptano_C7 * (C.C7/100),6),
		PresionParcial_C8	= ROUND(GPA.Octano_C8 * (C.C8/100),6),
		PresionParcial_C9	= ROUND(GPA.Nonano_C9 * (C.C9/100),6),
		PresionParcial_C10	= ROUND(GPA.Decano_C10 * (C.C10/100),6),
		PresionParcial_CO2	= ROUND(GPA.CO2 * (C.CO2/100),6),
		PresionParcial_H2S	= ROUND(GPA.H2S * (C.H2S/100),6),
		PresionParcial_N2	= ROUND(GPA.Nitrogeno_N2 * (C.N2/100),6)
FROM
	#Calculos	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	5	-- bi Presión Base
	AND	C.FechaReporte	BETWEEN IdFecIniVigencia AND FecFinVigencia

UPDATE #Calculos
	SET Zmes_FactorCompresion = ROUND(1 - 14.696  * POWER(PresionParcial_C1 + PresionParcial_C2 + PresionParcial_C3 + PresionParcial_nC4 +
									PresionParcial_iC4 + PresionParcial_nC5 + PresionParcial_iC5 + PresionParcial_C6Mas +
									PresionParcial_C7 + PresionParcial_C8 + PresionParcial_C9 + PresionParcial_C10 +
									PresionParcial_CO2 + PresionParcial_H2S + PresionParcial_N2, 2),6) 


UPDATE C
	SET
	LCid_C1		=	ROUND((C.C1/100) * 1000 * (1/GPA.Metano_C1) * (14.696/14.696),6),
	LCid_C2		=	ROUND((C.C2/100) * 1000 * (1/GPA.Etano_C2)* (14.696/14.696),6),
	LCid_C3		=	ROUND((C.C3/100) * 1000 * (1/GPA.Propano_C3)* (14.696/14.696),6),
	LCid_nC4	=	ROUND((C.NC4/100) * 1000 * (1/GPA.Butano_nC4)* (14.696/14.696),6),
	LCid_iC4	=	ROUND((C.IC4/100) * 1000 * (1/GPA.Butano_iC4)* (14.696/14.696),6),
	LCid_nC5	=	ROUND((C.NC5/100) * 1000 * (1/GPA.Pentano_nC5)* (14.696/14.696),6),
	LCid_iC5	=	ROUND((C.IC5/100) * 1000 * (1/GPA.Pentano_iC5)* (14.696/14.696),6),
	LCid_C6		=	ROUND((C.C6/100) * 1000 * (1/GPA.Hexano_C6)* (14.696/14.696),6),
	LCid_C7		=	ROUND((C.C7/100) * 1000 * (1/GPA.Heptano_C7)* (14.696/14.696),6),
	LCid_C8		=	ROUND((C.C8/100) * 1000 * (1/GPA.Octano_C8)* (14.696/14.696),6),
	LCid_C9		=	ROUND((C.C9/100) * 1000 * (1/GPA.Nonano_C9)* (14.696/14.696),6),
	LCid_C10	=	ROUND((C.C10/100) * 1000 * (1/GPA.Decano_C10)* (14.696/14.696),6),
	LCid_CO2	=	ROUND((C.CO2/100) * 1000 * (1/GPA.CO2)* (14.696/14.696),6),
	LCid_H2S	=	ROUND((C.H2S/100) * 1000 * (1/GPA.H2S)* (14.696/14.696),6),
	LCid_N2		=	ROUND((C.N2/100) * 1000 * (1/GPA.Nitrogeno_N2)* (14.696/14.696),6)
FROM
	#Calculos	C
CROSS JOIN
	SCOC_ValoresEstandaresGPA_2145	GPA
WHERE
	GPA.IdComponente	=	4	-- ft3 ideal gas/gal liquid
	AND	C.FechaReporte	BETWEEN IdFecIniVigencia AND FecFinVigencia

UPDATE #Calculos
	SET
		LCi_C1		= ROUND(LCid_C1 / Zmes_FactorCompresion,6),
		LCi_C2		= ROUND(LCid_C2 / Zmes_FactorCompresion,6),
		LCi_C3		= ROUND(LCid_C3 / Zmes_FactorCompresion,6),
		LCi_nC4		= ROUND(LCid_nC4 / Zmes_FactorCompresion,6),
		LCi_iC4		= ROUND(LCid_iC4 / Zmes_FactorCompresion,6),
		LCi_nC5		= ROUND(LCid_nC5 / Zmes_FactorCompresion,6),
		LCi_iC5		= ROUND(LCid_iC5 / Zmes_FactorCompresion,6),
		LCi_C6		= ROUND(LCid_C6 / Zmes_FactorCompresion,6),
		LCi_C7		= ROUND(LCid_C7 / Zmes_FactorCompresion,6),
		LCi_C8		= ROUND(LCid_C8 / Zmes_FactorCompresion,6),
		LCi_C9		= ROUND(LCid_C9 / Zmes_FactorCompresion,6),
		LCi_C10		= ROUND(LCid_C10 / Zmes_FactorCompresion,6),
		LCi_CO2		= ROUND(LCid_CO2 / Zmes_FactorCompresion,6),
		LCi_H2S		= ROUND(LCid_H2S / Zmes_FactorCompresion,6),
		LCi_N2		= ROUND(LCid_N2 / Zmes_FactorCompresion,6)

UPDATE #Calculos
	SET M3_20C_GasNoAprov = ROUND((ROUND(MMPC_NoAprov_20Grados,6)/@FactorConvM3ft3)*1000000,3)

UPDATE #Calculos
	SET M3_20C_GasEntregado	=	CASE WHEN @EsProduccionCompartida = 1 THEN ROUND(M3_20Grados - M3_20C_GasNoAprov,3)
								ELSE M3_20Grados - M3_20C_GasNoAprov
								END

UPDATE #Calculos
	SET MMPC_20C_GasEntregado = CASE WHEN IdUnidadMedida <> @IdUniMedidaM3 AND MMPC_NoAprov_20Grados = 0 --AND @EsProduccionCompartida = 1
									THEN MMPC_20C_GasEntregado
									WHEN IdUnidadMedida = @IdUniMedidaM3 AND MMPC_NoAprov_20Grados = 0 AND @EsConsorcio = 0
									THEN ROUND((M3_20C_GasEntregado*@FactorConvM3ft3)/1000000,6)
									ELSE (M3_20C_GasEntregado*@FactorConvM3ft3)/1000000
								END

UPDATE #Calculos
	SET	MMPC_60F_Gas = CASE WHEN @EsProduccionCompartida = 1 
							THEN ROUND(MMPC_20C_GasEntregado/@FactorConv20c15_5,6)
						ELSE MMPC_20C_GasEntregado/@FactorConv20c15_5
					END
	--SET	MMPC_60F_Gas = MMPC_20C_GasEntregado/@FactorConv20c15_5
/*
IF @EsProduccionCompartida = 0 AND @EsConsorcio = 1
BEGIN
	DELETE FROM #Balance

	INSERT INTO #Balance
	(
		CampoID,
		VolMensual_MMPC60,
		VolPorcPEP_MMPC60,
		VolPorcSOCIO_MMPC60,
		UltimoDia
	)
	SELECT
		C.CampoID,
		ROUND(SUM(C.MMPC_60F_Gas),6),
		SUM(ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),6)),
		SUM(ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),6)),
		DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)))
	FROM
		#Calculos	C
	JOIN
		dbo.CO_PorcentajesContrato	P
		ON C.IdContrato	=	P.idContrato
	GROUP BY
		C.CampoID
	
	UPDATE	#Balance
		SET
			SumaPorc_MMPC60	=	VolPorcPEP_MMPC60 + VolPorcSOCIO_MMPC60

	UPDATE #Balance
		SET
			DiferenciaPorc_MMPC60	=	VolMensual_MMPC60 - SumaPorc_MMPC60

	-- COMPARAMOS EL VOLUMEN ORIGINAL CONTRA LA SUMA DE LOS VOLUMENES DE PARTICIPACION PARA IGUALARLOS Y EVITAR LAS DIFERENCIAS POR DECIMALES		
		        UPDATE C
            SET
                MMPC_60F_Gas    = CASE WHEN ROUND(C.MMPC_60F_Gas,6) - (ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),6) +
                                                                ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),6)) <> 0 AND C.Dia <> B.UltimoDia
                                THEN ROUND(ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),6) + ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),6),6)
                              WHEN ROUND(C.MMPC_60F_Gas,6) - (ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),6) +
                                                         ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),6)) <> 0 AND C.Dia = B.UltimoDia
                                THEN ROUND((ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),6) +
                                                                ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),6)) + B.DiferenciaPorc_MMPC60,6)
                              WHEN ROUND(C.MMPC_60F_Gas,6) - (ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),6) +
                                                                ROUND(C.MMPC_60F_Gas*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),6)) = 0 AND C.Dia = B.UltimoDia
                                THEN ROUND(ROUND(C.MMPC_60F_Gas,6) + B.DiferenciaPorc_MMPC60,6)
                              ELSE ROUND(C.MMPC_60F_Gas,6)
                            END
		FROM
			 #Calculos	C
		JOIN
			dbo.CO_PorcentajesContrato	P
			ON	C.IdContrato	=	P.idContrato
		JOIN
			#Balance	B
			ON	C.CampoID	=	B.CampoID

END 
*/

UPDATE #Calculos
	SET
		VolBarriles_C1	= ROUND((MMPC_60F_Gas * 1000 * LCi_C1)/@ConstanteBll,3),
		VolBarriles_C2	= ROUND((MMPC_60F_Gas * 1000 * LCi_C2)/@ConstanteBll,3),
		VolBarriles_C3	= ROUND((MMPC_60F_Gas * 1000 * LCi_C3)/@ConstanteBll,3),
		VolBarriles_nC4	= ROUND((MMPC_60F_Gas * 1000 * LCi_nC4)/@ConstanteBll,3),
		VolBarriles_iC4	= ROUND((MMPC_60F_Gas * 1000 * LCi_iC4)/@ConstanteBll,3),
		VolBarriles_nC5	= ROUND((MMPC_60F_Gas * 1000 * LCi_nC5)/@ConstanteBll,3),
		VolBarriles_iC5	= ROUND((MMPC_60F_Gas * 1000 * LCi_iC5)/@ConstanteBll,3),
		VolBarriles_C6	= ROUND((MMPC_60F_Gas * 1000 * LCi_C6)/@ConstanteBll,3),
		VolBarriles_C7	= ROUND((MMPC_60F_Gas * 1000 * LCi_C7)/@ConstanteBll,3),
		VolBarriles_C8	= ROUND((MMPC_60F_Gas * 1000 * LCi_C8)/@ConstanteBll,3),
		VolBarriles_C9	= ROUND((MMPC_60F_Gas * 1000 * LCi_C9)/@ConstanteBll,3),
		VolBarriles_C10	= ROUND((MMPC_60F_Gas * 1000 * LCi_C10)/@ConstanteBll,3),
		VolBarriles_CO2	= ROUND((MMPC_60F_Gas * 1000 * LCi_CO2)/@ConstanteBll,3),
		VolBarriles_H2S	= ROUND((MMPC_60F_Gas * 1000 * LCi_H2S)/@ConstanteBll,3),
		VolBarriles_N2	= ROUND((MMPC_60F_Gas * 1000 * LCi_N2)/@ConstanteBll,3)

UPDATE #Calculos
	SET	BarrilesC5_Equiv = VolBarriles_nC5 + VolBarriles_iC5 + VolBarriles_C6 + VolBarriles_C7 +
							VolBarriles_C8 + VolBarriles_C9 + VolBarriles_C10

UPDATE #Calculos
	SET
		MPC_60_F	=	CASE WHEN @EsProduccionCompartida = 1 THEN ROUND(MMPC_60F_Gas * 1000,3)
							ELSE MMPC_60F_Gas * 1000
						END,
		MPC_20_C	=	CASE WHEN @EsProduccionCompartida = 1 THEN ROUND(MMPC_20C_GasEntregado*1000,3)
							ELSE MMPC_20C_GasEntregado*1000
						END,
		M3_60_F	=	 CASE WHEN @EsProduccionCompartida = 1 THEN ROUND(M3_20C_GasEntregado/@FactorConv20c15_5,3)
						ELSE M3_20C_GasEntregado/@FactorConv20c15_5
					 END
/*
IF @EsProduccionCompartida = 0 AND @EsConsorcio = 1
BEGIN
	DELETE FROM #Balance

	INSERT INTO #Balance
	(
		CampoID,
		VolMensual_M360,
		VolPorcPEP_M360,
		VolPorcSOCIO_M360,
		UltimoDia
	)
	SELECT
	-- 3 DECIMALES
		--C.CampoID,
		--ROUND(SUM(C.M3_60_F),3),
		--SUM(ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3)),
		--SUM(ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)),
		--DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)))
	-- 4 DECIMALES
		C.CampoID,
		ROUND(SUM(C.M3_60_F),4),
		SUM(ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4)),
		SUM(ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)),
		DAY(DATEADD(DAY, -1, DATEADD(MONTH, 1, @MesReporte)))
	FROM
		#Calculos	C
	JOIN
		dbo.CO_PorcentajesContrato	P
		ON C.IdContrato	=	P.idContrato
	GROUP BY
		C.CampoID

	UPDATE	#Balance
		SET	SumaPorc_M360	=	VolPorcPEP_M360 + VolPorcSOCIO_M360

	UPDATE #Balance
		SET	DiferenciaPorc_M360		=	VolMensual_M360 - SumaPorc_M360
	
	-- COMPARAMOS EL VOLUMEN ORIGINAL CONTRA LA SUMA DE LOS VOLUMENES DE PARTICIPACION PARA IGUALARLOS Y EVITAR LAS DIFERENCIAS POR DECIMALES		
		UPDATE C
		-- 3 DECIMALES
			--SET	M3_60_F = CASE WHEN ROUND(C.M3_60_F,3) - (ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
			--												ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia <> B.UltimoDia
			--					THEN ROUND(ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) + ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3),3)
			--				  WHEN ROUND(C.M3_60_F,3) - (ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
			--												ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) <> 0 AND C.Dia = B.UltimoDia
			--					THEN ROUND((ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
			--												ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) + B.DiferenciaPorc_M360,3)
			--				  WHEN ROUND(C.M3_60_F,3) - (ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),3) +
			--												ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),3)) = 0 AND C.Dia = B.UltimoDia
			--					THEN ROUND(ROUND(C.M3_60_F,3) + B.DiferenciaPorc_M360,3)
			--				  ELSE ROUND(C.M3_60_F,3)
			--				END
		-- 4 DECIMALES
			SET	M3_60_F = CASE WHEN ROUND(C.M3_60_F,4) - (ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
															ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia <> B.UltimoDia
								THEN ROUND(ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) + ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4),4)
							  WHEN ROUND(C.M3_60_F,4) - (ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
															ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) <> 0 AND C.Dia = B.UltimoDia
								THEN ROUND((ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
															ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) + B.DiferenciaPorc_M360,4)
							  WHEN ROUND(C.M3_60_F,4) - (ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajePemex)/@PorcDefault),4) +
															ROUND(C.M3_60_F*(CONVERT(FLOAT,P.PorcentajeSocio)/@PorcDefault),4)) = 0 AND C.Dia = B.UltimoDia
								THEN ROUND(ROUND(C.M3_60_F,4) + B.DiferenciaPorc_M360,4)
							  ELSE ROUND(C.M3_60_F,4)
							END
		FROM
			 #Calculos	C
		JOIN
			dbo.CO_PorcentajesContrato	P
			ON	C.IdContrato	=	P.idContrato
		JOIN
			#Balance	B
			ON	C.CampoID	=	B.CampoID
	
END 
*/

IF @AplicaFactorCompresibilidad = 0
BEGIN
	UPDATE C
		SET
			MMBTU_60F	=	ROUND(C.MPC_60_F * C.PoderCalBTU / 1000,3),
			MMBTU_C1	=	ROUND(C.MPC_60_F * (C.C1/100) * GPA.Metano_C1 /1000,3),
			MMBTU_C2	=	ROUND(C.MPC_60_F * (C.C2/100) * GPA.Etano_C2 /1000,3),
			MMBTU_C3	=	ROUND(C.MPC_60_F * (C.C3/100) * GPA.Propano_C3 /1000,3),
			MMBTU_C4	=	ROUND(C.MPC_60_F * (C.iC4/100) * GPA.Butano_iC4 /1000,3) + ROUND(C.MPC_60_F * (C.nC4/100) * GPA.Butano_nC4 /1000,3)
	FROM
		#Calculos	C
	CROSS JOIN
		SCOC_ValoresEstandaresGPA_2145	GPA
	WHERE
		GPA.IdComponente	=	2
		AND	C.FechaReporte	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia
END
ELSE
BEGIN
	UPDATE C
		SET
			MMBTU_60F	=	ROUND(C.MMPC_60F_Gas * C.PoderCalBTU,6),
			MMBTU_C1	=	ROUND(C.MMPC_60F_Gas * ROUND(ROUND((GPA.Metano_C1*C.C1)/100,3)/ROUND(C.Zmes_FactorCompresion,4),3),6),
			MMBTU_C2	=	ROUND(C.MMPC_60F_Gas * ROUND(ROUND((GPA.Etano_C2*C.C2)/100,3)/ROUND(C.Zmes_FactorCompresion,4),3),6),
			MMBTU_C3	=	ROUND(C.MMPC_60F_Gas * ROUND(ROUND((GPA.Propano_C3*C.C3)/100,3)/ROUND(C.Zmes_FactorCompresion,4),3),6),
			MMBTU_C4	=	ROUND(C.MMPC_60F_Gas * ROUND(ROUND((GPA.Butano_nC4*C.nC4)/100,3)/ROUND(C.Zmes_FactorCompresion,4),3),6) +
							ROUND(C.MMPC_60F_Gas * ROUND(ROUND((GPA.Butano_iC4*C.iC4)/100,3)/ROUND(C.Zmes_FactorCompresion,4),3),6)
	FROM
		#Calculos	C
	CROSS JOIN
		SCOC_ValoresEstandaresGPA_2145	GPA
	WHERE
		GPA.IdComponente	=	2
		AND	C.FechaReporte	BETWEEN GPA.IdFecIniVigencia AND GPA.FecFinVigencia
END

UPDATE #Calculos
	SET	MMBTU_C5	=	ROUND(MMBTU_60F - (MMBTU_C1 + MMBTU_C2 + MMBTU_C3 + MMBTU_C4),3)

-- SI ES UN CONTRATO DE PRODUCCION COMPARTIDA, SE CALCULAN LOS PORCENTAJES DE DISTRIBUCION PARA EL ESTADO CON LAS COMPENSACIONES
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
			Compensacion_C1	=	0,
			Compensacion_C2	=	0,
			Compensacion_C3	=	0,
			Compensacion_C4	=	0,
			Compensacion_C5	=	0,
			Compensacion_Barriles = 0,
			Aplicada_C1	=	0,
			Aplicada_C2	=	0,
			Aplicada_C3 =	0,
			Aplicada_C4	=	0,
			Aplicada_C5	=	0,
			Aplicada_Barriles	=	0,
			Pendiente_C1	=	0,
			Pendiente_C2	=	0,
			Pendiente_C3	=	0,
			Pendiente_C4	=	0,
			Pendiente_C5	=	0,
			Pendiente_Barriles = 0,
			AplicadaContra_C1	=	0,
			AplicadaContra_C2	=	0,
			AplicadaContra_C3	=	0,
			AplicadaContra_C4	=	0,
			AplicadaContra_C5	=	0,
			AplicadaContra_Barriles	=	0
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
			Compensacion_C1 = CASE WHEN C.FechaReporte = DATEADD(DAY,1,@FechaCorte)
									THEN CONVERT(FLOAT,REPLACE(RM53.[Compensaciones volumétricas: Nuevo saldo acumulado de metano a f],',',''))
								ELSE 0 END,
			Compensacion_C2 = CASE WHEN C.FechaReporte = DATEADD(DAY,1,@FechaCorte)
									THEN CONVERT(FLOAT,REPLACE(RM53.[Compensaciones volumétricas: Nuevo saldo acumulado de etano a fa],',',''))
								ELSE 0 END,
			Compensacion_C3 = CASE WHEN C.FechaReporte = DATEADD(DAY,1,@FechaCorte)
									THEN CONVERT(FLOAT,REPLACE(RM53.[Compensaciones volumétricas: Nuevo saldo acumulado de propano a ],',',''))
								ELSE 0 END,
			Compensacion_C4 = CASE WHEN C.FechaReporte = DATEADD(DAY,1,@FechaCorte)
									THEN CONVERT(FLOAT,REPLACE(RM53.[Compensaciones volumétricas: Nuevo saldo acumulado de butano a f],',',''))
								ELSE 0 END,
			Compensacion_Barriles = 	CASE WHEN C.FechaReporte = DATEADD(DAY,1,@FechaCorte)
									THEN CONVERT(FLOAT,REPLACE(RM53.[Compensaciones volumétricas: Nuevo saldo acumulado de condensado],',',''))
								ELSE 0 END,
			Compensacion_C5 = CASE WHEN C.FechaReporte = DATEADD(DAY,1,@FechaCorte) AND ISNULL(C.BarrilesC5_Equiv,1) <> 0
									THEN  ROUND((CONVERT(FLOAT,REPLACE(RM53.[Compensaciones volumétricas: Nuevo saldo acumulado de condensado],',','')) * C.MMBTU_C5)/ISNULL(C.BarrilesC5_Equiv,1),3) 
								ELSE 0 END,
			Aplicada_C1	=	0,
			Aplicada_C2	=	0,
			Aplicada_C3 =	0,
			Aplicada_C4	=	0,
			Aplicada_C5	=	0,
			Aplicada_Barriles	=	0,
			Pendiente_C1	=	0,
			Pendiente_C2	=	0,
			Pendiente_C3	=	0,
			Pendiente_C4	=	0,
			Pendiente_C5	=	0,
			Pendiente_Barriles = 0,
			AplicadaContra_C1	=	0,
			AplicadaContra_C2	=	0,
			AplicadaContra_C3	=	0,
			AplicadaContra_C4	=	0,
			AplicadaContra_C5	=	0,
			AplicadaContra_Barriles	=	0
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
				DistEdo_C1	=	ROUND(MMBTU_C1 * (PorcDistEdo/100),3),
				DistEdo_C2	=	ROUND(MMBTU_C2 * (PorcDistEdo/100),3),
				DistEdo_C3	=	ROUND(MMBTU_C3 * (PorcDistEdo/100),3),
				DistEdo_C4	=	ROUND(MMBTU_C4 * (PorcDistEdo/100),3),
				DistEdo_C5	=	ROUND(MMBTU_C5 * (PorcDistEdo/100),3),
				DistBarriles	=	ROUND(BarrilesC5_Equiv * (PorcDistEdo/100),3),
				DistContra_C1	=	ROUND(MMBTU_C1 * (PorcDistContra/100),3),
				DistContra_C2	=	ROUND(MMBTU_C2 * (PorcDistContra/100),3),
				DistContra_C3	=	ROUND(MMBTU_C3 * (PorcDistContra/100),3),
				DistContra_C4	=	ROUND(MMBTU_C4 * (PorcDistContra/100),3),
				DistContra_C5	=	ROUND(MMBTU_C5 * (PorcDistContra/100),3),
				DistContra_Barriles	=	ROUND(BarrilesC5_Equiv * (PorcDistContra/100),3)

	-- SE ACTUALIZA LA COMPENSACION APLICADA PARA VER SI EN EL MISMO DIA DE PUEDE CONPENSAR
	UPDATE #Calculos
		SET	Aplicada_C1	= CASE WHEN DistEdo_C1 + Compensacion_C1 > 0 THEN DistEdo_C1 + Compensacion_C1
								ELSE DistEdo_C1
							END,
			AplicadaContra_C1	=	CASE WHEN DistContra_C1 + Compensacion_C1 > 0 THEN DistContra_C1 + Compensacion_C1
								ELSE DistContra_C1
							END,
			Aplicada_C2	=	CASE WHEN DistEdo_C2 + Compensacion_C2 > 0 THEN DistEdo_C2 + Compensacion_C2
								ELSE DistEdo_C2
							END,
			AplicadaContra_C2	=	CASE WHEN DistContra_C2 + Compensacion_C2 > 0 THEN DistContra_C2 + Compensacion_C2
								ELSE DistContra_C2
							END,
			Aplicada_C3	=	CASE WHEN DistEdo_C3 + Compensacion_C3 > 0 THEN DistEdo_C3 + Compensacion_C3
								ELSE DistEdo_C3
							END,
			AplicadaContra_C3	=	CASE WHEN DistContra_C3 + Compensacion_C3 > 0 THEN DistContra_C3 + Compensacion_C3
								ELSE DistContra_C3
							END,
			Aplicada_C4	=	CASE WHEN DistEdo_C4 + Compensacion_C4 > 0 THEN DistEdo_C4 + Compensacion_C4
								ELSE DistEdo_C4
							END,
			AplicadaContra_C4 = CASE WHEN DistContra_C4 + Compensacion_C4 > 0 THEN DistContra_C4 + Compensacion_C4
								ELSE DistContra_C4
							END,
			Aplicada_C5	=	CASE WHEN DistEdo_C5 + Compensacion_C5 > 0 THEN DistEdo_C5 + Compensacion_C5
								ELSE DistEdo_C5
							END,
			AplicadaContra_C5	=	CASE WHEN DistContra_C5 + Compensacion_C5 > 0 THEN DistContra_C5 + Compensacion_C5
								ELSE DistContra_C5
							END,
			Aplicada_Barriles = CASE WHEN DistBarriles + Compensacion_Barriles > 0 THEN DistBarriles + Compensacion_Barriles
								ELSE DistBarriles
							END,
			AplicadaContra_Barriles	=	CASE WHEN DistContra_Barriles + Compensacion_Barriles > 0 THEN DistContra_Barriles + Compensacion_Barriles
								ELSE DistContra_Barriles
							END,
			Pendiente_C1	= CASE WHEN DistEdo_C1 + Compensacion_C1 > 0 THEN 0
								ELSE DistEdo_C1 + Compensacion_C1
							END,
			Pendiente_C2	= CASE WHEN DistEdo_C2 + Compensacion_C2 > 0 THEN 0
								ELSE DistEdo_C2 + Compensacion_C2
							END,
			Pendiente_C3	= CASE WHEN DistEdo_C3 + Compensacion_C3 > 0 THEN 0
								ELSE DistEdo_C3 + Compensacion_C3
							END,
			Pendiente_C4	= CASE WHEN DistEdo_C4 + Compensacion_C4 > 0 THEN 0
								ELSE DistEdo_C4 + Compensacion_C4
							END,
			Pendiente_C5	= CASE WHEN DistEdo_C5 + Compensacion_C5 > 0 THEN 0
								ELSE DistEdo_C5 + Compensacion_C5
							END,
			Pendiente_Barriles	= CASE WHEN DistBarriles + Compensacion_Barriles > 0 THEN 0
								ELSE DistBarriles + Compensacion_Barriles
							END
		WHERE
			FechaReporte	= DATEADD(DAY,1,@FechaCorte)


			-- HACER EL ACARREO DE LA COMPENSACION A LOS SIGUIENTES DIAS
		IF 0 <> (SELECT SUM(ABS ((Pendiente_C1 + Pendiente_C2 + Pendiente_C3 + Pendiente_C4 + Pendiente_C5 + Pendiente_Barriles)))
				FROM #Calculos
				WHERE FechaReporte	= DATEADD(DAY,@Dias,@FechaCorte))
		BEGIN
			WHILE 0 <> (SELECT SUM(ABS(Pendiente_C1) + ABS(Pendiente_C2) + ABS(Pendiente_C3) + ABS(Pendiente_C4) + ABS(Pendiente_C5) + ABS(Pendiente_Barriles))
						FROM #Calculos
						WHERE FechaReporte	= DATEADD(DAY,@Dias,@FechaCorte))
			BEGIN
				INSERT INTO #CompPendientes
				(
					Pendiente_C1,
					Pendiente_C2,
					Pendiente_C3,
					Pendiente_C4,
					Pendiente_C5,
					Pendiente_Barriles
				)
				SELECT
					Pendiente_C1,
					Pendiente_C2,
					Pendiente_C3,
					Pendiente_C4,
					Pendiente_C5,
					Pendiente_Barriles
				FROM
					#Calculos
				WHERE 
					FechaReporte = DATEADD(DAY,@Dias,@FechaCorte)

				SELECT @Dias = @Dias + 1

				UPDATE C
					SET	Aplicada_C1	= CASE 
										WHEN P.Pendiente_C1 = 0 THEN 0
										WHEN P.Pendiente_C1 <> 0 AND C.DistEdo_C1 + P.Pendiente_C1 > 0 THEN C.DistEdo_C1 + P.Pendiente_C1
										ELSE C.DistEdo_C1
									END,
					Aplicada_C2	=	CASE WHEN P.Pendiente_C2 = 0 THEN 0 
										WHEN P.Pendiente_C2 <> 0 AND C.DistEdo_C2 + P.Pendiente_C2 > 0 THEN C.DistEdo_C2 + P.Pendiente_C2
										ELSE C.DistEdo_C2
									END,
					Aplicada_C3	=	CASE WHEN P.Pendiente_C3 = 0 THEN 0 
										WHEN P.Pendiente_C3 <> 0 AND C.DistEdo_C3 + P.Pendiente_C3 > 0 THEN C.DistEdo_C3 + P.Pendiente_C3
										ELSE C.DistEdo_C3
									END,
					Aplicada_C4	=	CASE WHEN P.Pendiente_C4 = 0 THEN 0 
										WHEN P.Pendiente_C4 <> 0 AND C.DistEdo_C4 + P.Pendiente_C4 > 0 THEN C.DistEdo_C4 + P.Pendiente_C4
										ELSE C.DistEdo_C4
									END,
					Aplicada_C5	=	CASE WHEN P.Pendiente_C5 = 0 THEN 0 
										WHEN P.Pendiente_C5 <> 0 AND C.DistEdo_C5 + P.Pendiente_C5 > 0 THEN C.DistEdo_C5 + P.Pendiente_C5
										ELSE C.DistEdo_C5
									END,
					Aplicada_Barriles = CASE WHEN P.Pendiente_Barriles = 0 THEN 0
										WHEN P.Pendiente_Barriles <> 0 AND C.DistBarriles + P.Pendiente_Barriles > 0 THEN C.DistBarriles + P.Pendiente_Barriles
										ELSE C.DistBarriles
									END,
					Pendiente_C1	= CASE WHEN P.Pendiente_C1 = 0 THEN 0
										WHEN P.Pendiente_C1 <> 0 AND C.DistEdo_C1 + P.Pendiente_C1 > 0 THEN 0
										ELSE C.DistEdo_C1 + P.Pendiente_C1
									END,
					Pendiente_C2	= CASE WHEN P.Pendiente_C2 = 0 THEN 0
										 WHEN P.Pendiente_C2 <> 0 AND C.DistEdo_C2 + P.Pendiente_C2 > 0 THEN 0
										ELSE C.DistEdo_C2 + P.Pendiente_C2
									END,
					Pendiente_C3	= CASE WHEN P.Pendiente_C3 = 0 THEN 0
										 WHEN P.Pendiente_C3 <> 0 AND C.DistEdo_C3 + P.Pendiente_C3 > 0 THEN 0
										ELSE C.DistEdo_C3 + P.Pendiente_C3
									END,
					Pendiente_C4	= CASE WHEN P.Pendiente_C4 = 0 THEN 0
										 WHEN P.Pendiente_C4 <> 0 AND C.DistEdo_C4 + P.Pendiente_C4 > 0 THEN 0
										ELSE C.DistEdo_C4 + P.Pendiente_C4
									END,
					Pendiente_C5	= CASE WHEN P.Pendiente_C5 = 0 THEN 0
										 WHEN P.Pendiente_C5 <> 0 AND C.DistEdo_C5 + P.Pendiente_C5 > 0 THEN 0
										ELSE C.DistEdo_C5 + P.Pendiente_C5
									END,
					Pendiente_Barriles	= CASE WHEN P.Pendiente_Barriles = 0 THEN 0
										WHEN P.Pendiente_Barriles <> 0 AND C.DistBarriles + P.Pendiente_Barriles > 0 THEN 0
										ELSE C.DistBarriles + P.Pendiente_Barriles
									END
				FROM
					#Calculos	C
				CROSS JOIN
					#CompPendientes	P
				WHERE
					C.FechaReporte	= DATEADD(DAY,@Dias,@FechaCorte)

				DELETE FROM #CompPendientes
			END
		END

	UPDATE #Calculos
		SET TotalMMBTU_Edo = (CASE WHEN Aplicada_C1 <> 0 THEN Aplicada_C1 ELSE DistEdo_C1 END) + (CASE WHEN Aplicada_C2 <> 0 THEN Aplicada_C2 ELSE DistEdo_C2 END) + 
							(CASE WHEN Aplicada_C3 <> 0 THEN Aplicada_C3 ELSE DistEdo_C3 END) + (CASE WHEN Aplicada_C4 <> 0 THEN Aplicada_C4 ELSE DistEdo_C4 END) + 
							(CASE WHEN Aplicada_C5 <> 0 THEN Aplicada_C5 ELSE DistEdo_C5 END),
			TotalMMBTUEdo_C1C4 = (CASE WHEN Aplicada_C1 <> 0 THEN Aplicada_C1 ELSE DistEdo_C1 END) + (CASE WHEN Aplicada_C2 <> 0 THEN Aplicada_C2 ELSE DistEdo_C2 END) + 
							(CASE WHEN Aplicada_C3 <> 0 THEN Aplicada_C3 ELSE DistEdo_C3 END) + (CASE WHEN Aplicada_C4 <> 0 THEN Aplicada_C4 ELSE DistEdo_C4 END),
			TotalMMBTU_Contra = (CASE WHEN AplicadaContra_C1 <> 0 THEN AplicadaContra_C1 ELSE DistContra_C1 END) + (CASE WHEN AplicadaContra_C2 <> 0 THEN AplicadaContra_C2 ELSE DistContra_C2 END) + 
							(CASE WHEN AplicadaContra_C3 <> 0 THEN AplicadaContra_C3 ELSE DistContra_C3 END) + (CASE WHEN AplicadaContra_C4 <> 0 THEN AplicadaContra_C4 ELSE DistContra_C4 END) + 
							(CASE WHEN AplicadaContra_C5 <> 0 THEN AplicadaContra_C5 ELSE DistContra_C5 END),
			TotalMMBTUContra_C1C4 = (CASE WHEN AplicadaContra_C1 <> 0 THEN AplicadaContra_C1 ELSE DistContra_C1 END) + (CASE WHEN AplicadaContra_C2 <> 0 THEN AplicadaContra_C2 ELSE DistContra_C2 END) + 
							(CASE WHEN AplicadaContra_C3 <> 0 THEN AplicadaContra_C3 ELSE DistContra_C3 END) + (CASE WHEN AplicadaContra_C4 <> 0 THEN AplicadaContra_C4 ELSE DistContra_C4 END)

	UPDATE #Calculos
		SET TotalMMBTUEdo_C5 = ROUND(TotalMMBTU_Edo - TotalMMBTUEdo_C1C4,3),
			TotalMMBTUContra_C5 = ROUND(TotalMMBTU_Contra - TotalMMBTUContra_C1C4,3)
		
	UPDATE #Calculos
		SET Edo_MMPC_C5 = ROUND(TotalMMBTUEdo_C5 / PoderCalBTU,6),
			Edo_MMPC_C1C4 = ROUND(TotalMMBTUEdo_C1C4 / PoderCalBTU,6),
			Contra_MMPC_C5 = ROUND(TotalMMBTUContra_C5 / PoderCalBTU,6),
			Contra_MMPC_C1C4 = ROUND(TotalMMBTUContra_C1C4 / PoderCalBTU,6)
END -- @EsProduccionCompartida = 1


-- SE BORRA LA INFORMACIÓN YA EXISTENTE PARA ESE CONTRATO - MES
DELETE
	SCOC_CalculoDiario_Gas
WHERE
	IdContrato = @IdContrato 
	AND MesReporte = @MesReporte
	
-- SE INSERTAN LOS DATOS CALCULADOS
INSERT INTO SCOC_CalculoDiario_Gas
(
	IdContrato,
	MesReporte,
	FechaReporte,
	FechaEntrega,
	Dia,
	CampoID,
	M3_20Grados,
	MMPC_NoAprov_20Grados,
	BarrilesC5_Equiv,
	M3_20C_GasEntregado,
	MMPC_20C_GasEntregado,
	MPC_20_C,
	M3_60_F,
	MMPC_60F_Gas,
	MPC_60_F,
	MMBTU_60F,
	MMBTU_C1,
	MMBTU_C2,
	MMBTU_C3,
	MMBTU_C4,
	MMBTU_C5,
	PorcDistEdo,
	PorcDistContra,
	Compensacion_C1,
	Compensacion_C2,
	Compensacion_C3,
	Compensacion_C4,
	Compensacion_C5,
	Compensacion_Barriles,
	DistEdo_C1,
	DistEdo_C2,
	DistEdo_C3,
	DistEdo_C4,
	DistEdo_C5,
	DistBarriles,
	DistContra_C1,
	DistContra_C2,
	DistContra_C3,
	DistContra_C4,
	DistContra_C5,
	DistContra_Barriles,
	Aplicada_C1,
	Aplicada_C2,
	Aplicada_C3,
	Aplicada_C4,
	Aplicada_C5,
	Aplicada_Barriles,
	Pendiente_C1,
	Pendiente_C2,
	Pendiente_C3,
	Pendiente_C4,
	Pendiente_C5,
	Pendiente_Barriles,
	TotalMMBTU_Edo,
	TotalMMBTUEdo_C1C4,
	TotalMMBTUEdo_C5,
	Edo_MMPC_C5,
	Edo_MMPC_C1C4,
	TotalMMBTU_Contra,
	TotalMMBTUContra_C1C4,
	TotalMMBTUContra_C5,
	Contra_MMPC_C5,
	Contra_MMPC_C1C4,
	FactorCompresibilidad,
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
	M3_20Grados, 
	MMPC_NoAprov_20Grados, 
	BarrilesC5_Equiv,
	M3_20C_GasEntregado,
	MMPC_20C_GasEntregado,
	MPC_20_C,
	M3_60_F,
	MMPC_60F_Gas,
	MPC_60_F,
	MMBTU_60F,
	MMBTU_C1,
	MMBTU_C2,
	MMBTU_C3,
	MMBTU_C4,
	MMBTU_C5,
	PorcDistEdo,
	PorcDistContra,
	Compensacion_C1,
	Compensacion_C2,
	Compensacion_C3,
	Compensacion_C4,
	Compensacion_C5,
	Compensacion_Barriles,
	DistEdo_C1,
	DistEdo_C2,
	DistEdo_C3,
	DistEdo_C4,
	DistEdo_C5,
	DistBarriles,
	DistContra_C1,
	DistContra_C2,
	DistContra_C3,
	DistContra_C4,
	DistContra_C5,
	DistContra_Barriles,
	Aplicada_C1,
	Aplicada_C2,
	Aplicada_C3,
	Aplicada_C4,
	Aplicada_C5,
	Aplicada_Barriles,
	Pendiente_C1,
	Pendiente_C2,
	Pendiente_C3,
	Pendiente_C4,
	Pendiente_C5,
	Pendiente_Barriles,
	TotalMMBTU_Edo,
	TotalMMBTUEdo_C1C4,
	TotalMMBTUEdo_C5,
	Edo_MMPC_C5,
	Edo_MMPC_C1C4,
	TotalMMBTU_Contra,
	TotalMMBTUContra_C1C4,
	TotalMMBTUContra_C5,
	Contra_MMPC_C5,
	Contra_MMPC_C1C4,
	Zmes_FactorCompresion,
	@Usuario,
	GETDATE()
FROM
	#Calculos

IF @EsProduccionCompartida = 1
BEGIN

	SELECT
		FechaReporte, 
		FechaEntrega, 
		Dia,
		M3_20Grados				AS [M3 20° C], 
		MMPC_NoAprov_20Grados	AS [MMPC 20° Gas No Aprovechado], 
		@FactorConvM3ft3		AS [f Conv. Vol m3 >> ft3],
		@FactorConv20c15_5		AS [f Conv. Temp 20C >> 15.5C],
		Zmes_FactorCompresion	AS [Zmes],
		BarrilesC5_Equiv		AS [Barriles C5],
		M3_20C_GasEntregado		AS [M3 20° C Entregado],
		MMPC_20C_GasEntregado	AS [MMPC 20° C],
		MPC_20_C				AS [MPC 20° C],
		M3_60_F					AS [M3 60° F],
		MMPC_60F_Gas			AS [MMPC 60° F],
		MMBTU_60F				AS [MMBTU 60° F],
		MMBTU_C1				AS [MMBTU C1],
		MMBTU_C2				AS [MMBTU C2],
		MMBTU_C3				AS [MMBTU C3],
		MMBTU_C4				AS [MMBTU C4],
		MMBTU_C5				AS [MMBTU C5],
		PorcDistEdo				AS [% Dist Edo],
		PorcDistContra			AS [% Dist Contrat],
		Compensacion_C1			AS [Comp C1],
		Compensacion_C2			AS [Comp C2],
		Compensacion_C3			AS [Comp C3],
		Compensacion_C4			AS [Comp C4],
		Compensacion_C5			AS [Comp C5],
		Compensacion_Barriles	AS [Comp Blls],
		DistEdo_C1				AS [Dist Edo C1],
		DistEdo_C2				AS [Dist Edo C2],
		DistEdo_C3				AS [Dist Edo C3],
		DistEdo_C4				AS [Dist Edo C4],
		DistEdo_C5				AS [Dist Edo C5],
		DistBarriles			AS [Dist Edo Blls],
		DistContra_C1			AS [Dist Contratista C1],
		DistContra_C2			AS [Dist Contratista C2],
		DistContra_C3			AS [Dist Contratista C3],
		DistContra_C4			AS [Dist Contratista C4],
		DistContra_C5			AS [Dist Contratista C5],
		DistContra_Barriles		AS [Dist Contratista Blls],
		Aplicada_C1,
		Aplicada_C2,
		Aplicada_C3,
		Aplicada_C4,
		Aplicada_C5,
		Aplicada_Barriles,
		Pendiente_C1,
		Pendiente_C2,
		Pendiente_C3,
		Pendiente_C4,
		Pendiente_C5,
		Pendiente_Barriles,
		TotalMMBTU_Edo,
		TotalMMBTUEdo_C1C4,
		TotalMMBTUEdo_C5,
		Edo_MMPC_C5,
		Edo_MMPC_C1C4,
		TotalMMBTU_Contra,
		TotalMMBTUContra_C1C4,
		TotalMMBTUContra_C5,
		Contra_MMPC_C5,
		Contra_MMPC_C1C4
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
			C.FechaReporte, 
			C.FechaEntrega, 
			C.Dia, 
			C.M3_20Grados				AS [M3 20° C], 
			C.MMPC_NoAprov_20Grados	AS [MMPC 20° Gas No Aprovechado], 
			@FactorConvM3ft3		AS [f Conv. Vol m3 >> ft3],
			@FactorConv20c15_5		AS [f Conv. Temp 20C >> 15.5C],
			C.Zmes_FactorCompresion	AS [Zmes],
			C.BarrilesC5_Equiv		AS [Barriles C5],
			C.M3_20C_GasEntregado		AS [M3 20° C Entregado],
			C.MMPC_20C_GasEntregado	AS [MMPC 20° C],
			C.MPC_20_C				AS [MPC 20° C],
			C.M3_60_F				AS	[M3 60° F],
			C.MMPC_60F_Gas			AS [MMPC 60° F],
			C.MMBTU_60F				AS [MMBTU 60° F],
			C.MMBTU_C1				AS [MMBTU C1],
			C.MMBTU_C2				AS [MMBTU C2],
			C.MMBTU_C3				AS [MMBTU C3],
			C.MMBTU_C4				AS [MMBTU C4],
			C.MMBTU_C5				AS [MMBTU C5],
			ISNULL(P.PorcentajePemex,0)		AS [% Dist PEP],
			ISNULL(P.PorcentajeSocio,100)	AS [% Dist Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * C.M3_60_F			AS	[M3 60° F PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * C.M3_60_F			AS	[M3 60° F Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * C.MMPC_60F_Gas			AS [MMPC 60° F PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * C.MMPC_60F_Gas		AS [MMPC 60° F Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * C.MMBTU_60F				AS [MMBTU 60° F PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * C.MMBTU_60F			AS [MMBTU 60° F Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * C.MMBTU_C1				AS [MMBTU C1 PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * C.MMBTU_C1			AS [MMBTU C1 Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * C.MMBTU_C2				AS [MMBTU C2 PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * C.MMBTU_C2			AS [MMBTU C2 Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * C.MMBTU_C3				AS [MMBTU C3 PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * C.MMBTU_C3			AS [MMBTU C3 Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * C.MMBTU_C4				AS [MMBTU C4 PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * C.MMBTU_C4			AS [MMBTU C4 Socio],
			(ISNULL(P.PorcentajePemex,0)/100) * C.MMBTU_C5				AS [MMBTU C5 PEP],
			(ISNULL(P.PorcentajeSocio,100)/100) * C.MMBTU_C5			AS [MMBTU C5 Socio]
		FROM
			#Calculos	C
		JOIN
			dbo.SCOC_Campo	CC
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
			C.FechaReporte, 
			C.FechaEntrega, 
			C.Dia, 
			C.M3_20Grados				AS [M3 20° C], 
			C.MMPC_NoAprov_20Grados	AS [MMPC 20° Gas No Aprovechado], 
			@FactorConvM3ft3		AS [f Conv. Vol m3 >> ft3],
			@FactorConv20c15_5		AS [f Conv. Temp 20C >> 15.5C],
			C.Zmes_FactorCompresion	AS [Zmes],
			C.BarrilesC5_Equiv		AS [Barriles C5],
			C.M3_20C_GasEntregado		AS [M3 20° C Entregado],
			C.MMPC_20C_GasEntregado	AS [MMPC 20° C],
			C.MPC_20_C				AS [MPC 20° C],
			C.M3_60_F				AS	[M3 60° F],
			C.MMPC_60F_Gas			AS [MMPC 60° F],
			C.MMBTU_60F				AS [MMBTU 60° F],
			C.MMBTU_C1				AS [MMBTU C1],
			C.MMBTU_C2				AS [MMBTU C2],
			C.MMBTU_C3				AS [MMBTU C3],
			C.MMBTU_C4				AS [MMBTU C4],
			C.MMBTU_C5				AS [MMBTU C5]
		FROM
			#Calculos	C
		JOIN
			dbo.SCOC_Campo	CC
			ON	C.CampoID	=	CC.CampoID
	END
END

END
