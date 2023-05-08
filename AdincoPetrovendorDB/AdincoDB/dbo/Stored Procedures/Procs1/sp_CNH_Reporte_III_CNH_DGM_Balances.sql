CREATE PROCEDURE dbo.sp_CNH_Reporte_III_CNH_DGM_Balances
	@Contrato		INT,
	@MesReporte		VARCHAR(25),	
	@IdUsuario		INT
AS
BEGIN
-- =============================================
-- Description:	Reporte de CNH II_CNH_DGM_VHPM (Producción Diaria y Mensual por Instalación)
-- -------------------------------------------------
-- FECHA	MODIFICÓ	COMENTARIO
-- -------------------------------------------------
-- 20180503	BAAC		Creación de sp
-- 20180821	BAAC		Se modifica para mostrar todos los contratos relacionados
-- 20190129	BAAC	Se modifica para buscar la calidad del petroleo del mes anterior, si no hay en el mes a consultar
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #Contratos
(
	IdContrato	INT PRIMARY KEY,
	RegionFiscal	VARCHAR(3000)
)

CREATE TABLE #GradosAPI
(
	IdContrato	INT,
	PuntoEntregaID	INT,
	GradosAPI	FLOAT,
	KgM3		FLOAT,
	Alfa		FLOAT,
	CTL			FLOAT,
	KgM3_Condensado	FLOAT,
	Alfa_Condensado	FLOAT,
	CTL_Condensado	FLOAT,
	SinCalidad		BIT
)

DECLARE
	@VolExtraidoPetroleo	DECIMAL(24,8),
	@VolExtraidoCondensado	DECIMAL(24,8),
	@VolIngresoPetroleo		DECIMAL(24,8),
	@VolIngresoCondensado	DECIMAL(24,8),
	@Region					VARCHAR(300) = '',
	@Mes					DATE,
	@IdRelacionado			INT,
	@60F_R         FLOAT = 519.67, -- 60 grados Fahrenheit a rankine
	@68F_R         FLOAT = 527.67 --68  grados Fahrenheit a rankine

SELECT @Mes = DATEFROMPARTS( SUBSTRING( @MesReporte, 7, 4 ), SUBSTRING( @MesReporte, 4, 2 ), SUBSTRING( @MesReporte, 1, 2 ) )

--SELECT
--	@IdRelacionado	=	REL.IdRelacionado
--FROM
--	dbo.CO_Contrato	C
--JOIN
--	CO_ContratistaRelacionado	REL
--	ON	C.IdContratista	=	REL.IdContratista
--WHERE
--	C.IdContrato = @Contrato

---- SI NO HAY CONTRATISTAS RELACIONADOS, SE INSERTAN TODOS LOS CONTRATOS DEL MISMO SUBCONTRATISTA	
--IF ISNULL(@IdRelacionado,0) = 0
--BEGIN
	INSERT INTO #Contratos
	(
	    IdContrato
	)
	SELECT
		C2.IdContrato
	FROM
		dbo.CO_Contrato	C
	JOIN
		dbo.CO_Contrato	C2
		ON	C.IdContratista	=	C2.IdContratista
	WHERE
		C.IdContrato	=	@Contrato
--END
--ELSE
--BEGIN
--	INSERT INTO #Contratos
--	(
--	    IdContrato
--	)
--	SELECT
--		C.IdContrato
--	FROM
--		dbo.CO_Contrato	C
--	JOIN
--		CO_ContratistaRelacionado	REL
--		ON	C.IdContratista	=	REL.IdContratista
--	WHERE
--		REL.IdRelacionado	=	@IdRelacionado
--END

-- GRADOS API POR CAMPO PARA CONVERSION DE TEMPERATURA
INSERT INTO #GradosAPI
(
	IdContrato,
	PuntoEntregaID,
	GradosAPI,
	SinCalidad
)
SELECT
	T.IdContrato,
	PEC.PuntoEntregaID,
	ISNULL(CROMA.GradosAPI,0),
	CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
	END
FROM
	#Contratos	T
JOIN
	dbo.CO_Contrato	C
	ON	T.IdContrato	=	C.IdContrato
JOIN
	dbo.CO_Instalacion	I
	ON	C.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id
JOIN
	dbo.PR_Campo	CPO
	ON	P.Campo	=	CPO.Id
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	C.IdContrato	=	PEC.idContrato
	AND P.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN	
	dbo.CO_Cromatografia	CR
	ON PEC.IdContrato	=	CR.IdContrato
	AND	YEAR(@Mes) = CR.Anio
	AND	MONTH(@Mes)	=	CR.Mes
LEFT JOIN
	CO_CromatografiaValores	CROMA
	ON	CR.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
GROUP BY
	T.IdContrato,
	PEC.PuntoEntregaID,
	ISNULL(CROMA.GradosAPI,0),
	CASE WHEN CROMA.IdCromatografiaValor IS NULL THEN  1
			ELSE 0
	END

UPDATE #GradosAPI
	SET SinCalidad = 0
WHERE
	SinCalidad IS NULL

-- SE BUSCA LA CALIDAD DEL MES ANTERIOR
UPDATE	API
	SET	GradosAPI	=	ISNULL(CROMA.GradosAPI,0)
FROM
	#GradosAPI		API
JOIN
	dbo.CO_PuntosdeEntregaContrato	PEC
	ON	API.IdContrato	=	PEC.idContrato
	AND API.PuntoEntregaID	=	PEC.PuntoEntregaID
LEFT JOIN	
	dbo.CO_Cromatografia	CR
	ON PEC.IdContrato	=	CR.IdContrato
	AND	YEAR(DATEADD(MONTH, -1,@Mes)) = CR.Anio
	AND	MONTH(DATEADD(MONTH, -1,@Mes))	=	CR.Mes
LEFT JOIN
	CO_CromatografiaValores	CROMA
	ON	CR.IdCromatografia	=	CROMA.IdCromatografia
	AND	PEC.PuntoEntregaContratoID	=	CROMA.IdPuntoEntregaContrato
WHERE
	API.SinCalidad	=	1

UPDATE #GradosAPI
	SET KgM3 = (141.5 / (GradosAPI + 131.5)) * 999.012,
		KgM3_Condensado	=	(141.5 / (0 + 131.5)) * 999.012	-- 0 --> Grados API del Condensado

UPDATE #GradosAPI
	SET Alfa	=	(341.0957 / POWER( KgM3, 2 )),
		Alfa_Condensado	=	(341.0957 / POWER( KgM3_Condensado, 2 ))

UPDATE #GradosAPI
	SET	CTL	=	EXP( -Alfa * 8 * (1 + 0.8 * Alfa * 8)),
		CTL_Condensado	=	EXP( -Alfa_Condensado * 8 * (1 + 0.8 * Alfa_Condensado * 8))



UPDATE CO
	SET	RegionFiscal	=	P.RegionFiscal
FROM
	#Contratos	CO
JOIN
	dbo.CO_Contrato	C
	ON	CO.IdContrato	=	C.IdContrato
JOIN
	CO_AreaContractual	AC
	ON	C.IdAreaContractual	=	AC.IdAreaContractual
JOIN
	CO_Instalacion	I
	ON	AC.IdAreaContractual	=	I.IdAreaContractual
JOIN
	dbo.PR_Pozo	P
	ON	I.WelIID	=	P.Id


	/*************************** HOJA 1 : PETROLEO ***************************/
	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		CO.RegionFiscal		AS [Región Fiscal],
		--@Region				AS [Región Fiscal],
		CA.Nombre			AS [Nombre del Campo],
		PE.Nombre			AS [Punto de Medición],
		@Mes				AS [Fecha],
		ROUND(BM.InventarioInicial * ISNULL(API.CTL,0),3)	AS [InventarioInicial],
		ROUND(BM.VolumenExtraidoHidrocarburo * ISNULL(API.CTL,0),3)	AS [Volumen Extraído de Petróleo],
		BM.VolumenExtraidoAgua	AS [Volumen Extraído de Agua],
		ROUND(BM.VolumenIncorporado * ISNULL(API.CTL,0),3)		AS [Volumen de Petróleo Incorporado],
		ROUND(BM.Desempaque * ISNULL(API.CTL,0),3)				AS [Desempaque],
		ROUND(BM.AlmacenadoTanques * ISNULL(API.CTL,0),3)		AS [AlmacenadoTanques],
		ROUND(BM.AlmacenadoRecipientes * ISNULL(API.CTL,0),3)	AS [AlmacenadoRecipientes],
		ROUND(BM.VolOtrasEntradas * ISNULL(API.CTL,0),3)		AS [VolOtrasEntradas],
		BM.ComentariosEntradas,
		ROUND(BM.MermasEvaporacion * ISNULL(API.CTL,0),3)		AS [MermasEvaporacion],
		ROUND(BM.MermasFugas * ISNULL(API.CTL,0),3)				AS [MermasFugas],
		ROUND(BM.VolEmpaque * ISNULL(API.CTL,0),3)				AS [VolEmpaque],
		ROUND(BM.VolEncogimientoTransporte * ISNULL(API.CTL,0),3)	AS [VolEncogimientoTransporte],
		BM.FactorEncogimientoTransporte,
		ROUND(BM.VolEncogimientoImpurezas * ISNULL(API.CTL,0),3)	AS [VolEncogimientoImpurezas],
		BM.FactorEncogimientoImpurezas,
		ROUND(BM.VolTraspaso * ISNULL(API.CTL,0),3)				AS [VolTraspaso],
		ROUND(BM.VolEntregadoPtoMedicion * ISNULL(API.CTL,0),3)	AS [Volumen Entregado en Punto de Medición],
		ROUND(BM.VolAutoconsumo * ISNULL(API.CTL,0),3)			AS [VolAutoconsumo],
		ROUND(BM.InventarioFinal * ISNULL(API.CTL,0),3)			AS [InventarioFinal],
		ROUND(BM.VolPerdidasNoIdentificadas * ISNULL(API.CTL,0),3)	AS [VolPerdidasNoIdentificadas],
		ROUND(BM.VolOtrasSalidas * ISNULL(API.CTL,0),3)			AS [VolOtrasSalidas],
		CASE WHEN ISNULL(BM.ComentariosBalance,'') = '' THEN 'N/A'
			ELSE BM.ComentariosBalance
		END		AS	[ComentariosBalance]
	FROM
		#Contratos	CO
	JOIN
		dbo.CO_Contrato	C
		ON	CO.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_Campo	CA
		ON	P.Campo	=	CA.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_BalanceMensual	BM
		ON	PEC.idContrato	=	BM.IdContrato
		AND	PE.PuntoEntregaID	=	BM.PuntoEntregaID
		AND BM.Fecha		=	@Mes
	LEFT JOIN
		#GradosAPI	API
		ON	BM.IdContrato	=	API.IdContrato
		AND	BM.PuntoEntregaID	=	API.PuntoEntregaID
	WHERE
		BM.TipoHidrocarburo	=	1001	--'PETROLEO'	REFERENCIA CON TABLA CO_ClasificacionProductoNominacion
	GROUP BY
		C.NumeroContrato,
		CO.RegionFiscal,
		CA.Nombre,
		PE.Nombre,
		ROUND(BM.InventarioInicial * ISNULL(API.CTL,0),3),
		ROUND(BM.VolumenExtraidoHidrocarburo * ISNULL(API.CTL,0),3),
		BM.VolumenExtraidoAgua,
		ROUND(BM.VolumenIncorporado * ISNULL(API.CTL,0),3),
		ROUND(BM.Desempaque * ISNULL(API.CTL,0),3),
		ROUND(BM.AlmacenadoTanques * ISNULL(API.CTL,0),3),
		ROUND(BM.AlmacenadoRecipientes * ISNULL(API.CTL,0),3),
		ROUND(BM.VolOtrasEntradas * ISNULL(API.CTL,0),3),
		BM.ComentariosEntradas,
		ROUND(BM.MermasEvaporacion * ISNULL(API.CTL,0),3),
		ROUND(BM.MermasFugas * ISNULL(API.CTL,0),3),
		ROUND(BM.VolEmpaque * ISNULL(API.CTL,0),3),
		ROUND(BM.VolEncogimientoTransporte * ISNULL(API.CTL,0),3),
		BM.FactorEncogimientoTransporte,
		ROUND(BM.VolEncogimientoImpurezas * ISNULL(API.CTL,0),3),
		BM.FactorEncogimientoImpurezas,
		ROUND(BM.VolTraspaso * ISNULL(API.CTL,0),3),
		ROUND(BM.VolEntregadoPtoMedicion * ISNULL(API.CTL,0),3),
		ROUND(BM.VolAutoconsumo * ISNULL(API.CTL,0),3),
		ROUND(BM.InventarioFinal * ISNULL(API.CTL,0),3),
		ROUND(BM.VolPerdidasNoIdentificadas * ISNULL(API.CTL,0),3),
		ROUND(BM.VolOtrasSalidas * ISNULL(API.CTL,0),3),
		CASE WHEN ISNULL(BM.ComentariosBalance,'') = '' THEN 'N/A'
			ELSE BM.ComentariosBalance
		END

	/*************************** HOJA 2 : CONDENSADO ***************************/
	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		CO.RegionFiscal		AS [Región Fiscal],
		CA.Nombre			AS [Nombre del Campo],
		PE.Nombre			AS [Punto de Medición],
		@Mes				AS [Fecha],
		ROUND(BM.InventarioInicial * ISNULL(API.CTL_Condensado,0),3)	AS [InventarioInicial],
		ROUND(BM.VolumenExtraidoHidrocarburo * ISNULL(API.CTL_Condensado,0),3)	AS [Volumen Extraído de Condensado],
		BM.VolumenExtraidoAgua		AS [Volumen Extraído de Agua],
		ROUND(BM.VolumenIncorporado * ISNULL(API.CTL_Condensado,0),3)		AS [Volumen de Condensado Incorporado],
		ROUND(BM.AlmacenadoTanques * ISNULL(API.CTL_Condensado,0),3)		AS [AlmacenadoTanques],
		ROUND(BM.AlmacenadoRecipientes * ISNULL(API.CTL_Condensado,0),3)	AS [AlmacenadoRecipientes],
		ROUND(BM.VolOtrasEntradas * ISNULL(API.CTL_Condensado,0),3)			AS [VolOtrasEntradas],
		BM.ComentariosEntradas,
		ROUND(BM.MermasEvaporacion * ISNULL(API.CTL_Condensado,0),3)		AS [MermasEvaporacion],
		ROUND(BM.MermasFugas * ISNULL(API.CTL_Condensado,0),3)				AS [MermasFugas],
		ROUND(BM.VolEncogimientoTransporte * ISNULL(API.CTL_Condensado,0),3)	AS [VolEncogimientoTransporte],
		BM.FactorEncogimientoTransporte,
		ROUND(BM.VolEncogimientoImpurezas * ISNULL(API.CTL_Condensado,0),3)	AS [VolEncogimientoImpurezas],
		BM.FactorEncogimientoImpurezas,
		ROUND(BM.VolTraspaso * ISNULL(API.CTL_Condensado,0),3)				AS [VolTraspaso],
		ROUND(BM.VolEntregadoPtoMedicion * ISNULL(API.CTL_Condensado,0),3)	AS [Volumen Entregado en Punto de Medición],
		ROUND(BM.VolAutoconsumo * ISNULL(API.CTL_Condensado,0),3)			AS [VolAutoconsumo],
		ROUND(BM.InventarioFinal * ISNULL(API.CTL_Condensado,0),3)			AS [InventarioFinal],
		ROUND(BM.VolPerdidasNoIdentificadas * ISNULL(API.CTL_Condensado,0),3)	AS [VolPerdidasNoIdentificadas],
		ROUND(BM.VolOtrasSalidas * ISNULL(API.CTL_Condensado,0),3)	AS [VolOtrasSalidas],
		CASE WHEN ISNULL(BM.ComentariosBalance,'') = '' THEN 'N/A'
			ELSE BM.ComentariosBalance
		END		AS	[ComentariosBalance]
	FROM
		#Contratos	CO
	JOIN
		dbo.CO_Contrato	C
		ON	CO.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_Campo	CA
		ON	P.Campo	=	CA.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_BalanceMensual	BM
		ON	PEC.idContrato	=	BM.IdContrato
		AND	PE.PuntoEntregaID	=	BM.PuntoEntregaID
		AND BM.Fecha		=	@Mes
	LEFT JOIN
		#GradosAPI	API
		ON	BM.IdContrato	=	API.IdContrato
		AND	BM.PuntoEntregaID	=	API.PuntoEntregaID
	WHERE
		BM.TipoHidrocarburo	=	1002	--	'CONDENSADO'	--REFERENCIA CON TABLA CO_ClasificacionProductoNominacion
	GROUP BY
		C.NumeroContrato,
		CO.RegionFiscal,
		CA.Nombre,
		PE.Nombre,
		ROUND(BM.InventarioInicial * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.VolumenExtraidoHidrocarburo * ISNULL(API.CTL_Condensado,0),3),
		BM.VolumenExtraidoAgua,
		ROUND(BM.VolumenIncorporado * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.AlmacenadoTanques * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.AlmacenadoRecipientes * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.VolOtrasEntradas * ISNULL(API.CTL_Condensado,0),3),
		BM.ComentariosEntradas,
		ROUND(BM.MermasEvaporacion * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.MermasFugas * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.VolEncogimientoTransporte * ISNULL(API.CTL_Condensado,0),3),
		BM.FactorEncogimientoTransporte,
		ROUND(BM.VolEncogimientoImpurezas * ISNULL(API.CTL_Condensado,0),3),
		BM.FactorEncogimientoImpurezas,
		ROUND(BM.VolTraspaso * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.VolEntregadoPtoMedicion * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.VolAutoconsumo * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.InventarioFinal * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.VolPerdidasNoIdentificadas * ISNULL(API.CTL_Condensado,0),3),
		ROUND(BM.VolOtrasSalidas * ISNULL(API.CTL_Condensado,0),3),
		CASE WHEN ISNULL(BM.ComentariosBalance,'') = '' THEN 'N/A'
			ELSE BM.ComentariosBalance
		END

	/*************************** HOJA 2 : GAS ***************************/
	SELECT
		C.NumeroContrato	AS [ID Contrato o Asignación],
		CO.RegionFiscal		AS [Región Fiscal],
		--@Region				AS [Región Fiscal],
		CA.Nombre			AS [Nombre del Campo],
		PE.Nombre			AS [Punto de Medición],
		@Mes				AS [Fecha],
		ROUND(BM.InventarioInicial * (@60F_R/@68F_R),3)				AS [InventarioInicial],
		ROUND(BM.VolumenExtraidoImpurezas * (@60F_R/@68F_R),3)		AS [Volumen Extraído de Impurezas],
		ROUND(BM.VolumenExtraidoHidrocarburo * (@60F_R/@68F_R),3)	AS [Volumen Extraído de Gas Natural],
		ROUND(BM.VolumenGasResidual * (@60F_R/@68F_R),3)			AS [Volumen de Gas Residual],
		ROUND(BM.VolumenIncorporado * (@60F_R/@68F_R),3)			AS [Volumen de Gas Incorporado],
		ROUND(BM.Desempaque * (@60F_R/@68F_R),3)					AS [Desempaque],
		ROUND(BM.AlmacenadoTanques * (@60F_R/@68F_R),3)				AS [AlmacenadoTanques],
		ROUND(BM.AlmacenadoRecipientes * (@60F_R/@68F_R),3)			AS [AlmacenadoRecipientes],
		ROUND(BM.VolOtrasEntradas * (@60F_R/@68F_R),3)				AS [VolOtrasEntradas],
		BM.ComentariosEntradas,
		ROUND(BM.VolGasVenteado * (@60F_R/@68F_R),3)				AS [VolGasVenteado],
		ROUND(BM.VolGasQuemado * (@60F_R/@68F_R),3)					AS [VolGasQuemado],
		ROUND(BM.VolGasTraspasado * (@60F_R/@68F_R),3)				AS [VolGasTraspasado],
		ROUND(BM.VolGasBN * (@60F_R/@68F_R),3)						AS [VolGasBN],
		ROUND(BM.VolGasCombustible * (@60F_R/@68F_R),3)				AS [VolGasCombustible],
		ROUND(BM.VolGasYacimientos * (@60F_R/@68F_R),3)				AS [VolGasYacimientos],
		ROUND(BM.VolEmpaque * (@60F_R/@68F_R),3)					AS [VolEmpaque],
		ROUND(BM.VolEncogimientoTransporte * (@60F_R/@68F_R),3)		AS [VolEncogimientoTransporte],
		ROUND(BM.VolEncogimientoImpurezas * (@60F_R/@68F_R),3)		AS [VolEncogimientoImpurezas],
		ROUND(BM.VolEncogimientoEficiencia * (@60F_R/@68F_R),3)		AS [VolEncogimientoEficiencia],
		ROUND(BM.VolEncogimientoLiquidos * (@60F_R/@68F_R),3)		AS [VolEncogimientoLiquidos],
		BM.FactorEncogimientoTransporte,
		BM.FactorEncogimientoImpurezas,
		BM.FactorEncogimientoEficiencia,
		BM.FactorEncogimientoLiquidos,
		ROUND(BM.VolEntregadoPtoMedicion * (@60F_R/@68F_R),3)	AS [Volumen Entregado en Punto de Medición],
		ROUND(BM.InventarioFinal * (@60F_R/@68F_R),3)			AS [InventarioFinal],
		ROUND(BM.VolPerdidasNoIdentificadas * (@60F_R/@68F_R),3)	AS [VolPerdidasNoIdentificadas],
		ROUND(BM.VolOtrasSalidas * (@60F_R/@68F_R),3)			AS [VolOtrasSalidas],
		CASE WHEN ISNULL(BM.ComentariosBalance,'') = '' THEN 'N/A'
			ELSE BM.ComentariosBalance
		END														AS	[ComentariosBalance]
	FROM
		#Contratos	CO
	JOIN
		dbo.CO_Contrato	C
		ON	CO.IdContrato	=	C.IdContrato
	JOIN
		CO_Instalacion	I
		ON	C.IdAreaContractual	=	I.IdAreaContractual
	JOIN
		dbo.PR_Pozo	P
		ON	I.WelIID	=	P.Id
	JOIN
		dbo.PR_Campo	CA
		ON	P.Campo	=	CA.Id
	JOIN
		dbo.CO_PuntosdeEntregaContrato	PEC
		ON	C.IdContrato	=	PEC.idContrato
	JOIN
		dbo.CO_PuntosdeEntrega	PE
		ON	PEC.PuntoEntregaID	=	PE.PuntoEntregaID
	JOIN
		dbo.PR_BalanceMensual	BM
		ON	PEC.idContrato	=	BM.IdContrato
		AND	PE.PuntoEntregaID	=	BM.PuntoEntregaID
		AND BM.Fecha		=	@Mes
	WHERE
		BM.TipoHidrocarburo	=	1000	--'GAS'	-- --REFERENCIA CON TABLA CO_ClasificacionProductoNominacion
	GROUP BY
		C.NumeroContrato,
		CO.RegionFiscal,
		CA.Nombre,
		PE.Nombre,
		ROUND(BM.InventarioInicial * (@60F_R/@68F_R),3),
		ROUND(BM.VolumenExtraidoImpurezas * (@60F_R/@68F_R),3),
		ROUND(BM.VolumenExtraidoHidrocarburo * (@60F_R/@68F_R),3),
		ROUND(BM.VolumenGasResidual * (@60F_R/@68F_R),3),
		ROUND(BM.VolumenIncorporado * (@60F_R/@68F_R),3),
		ROUND(BM.Desempaque * (@60F_R/@68F_R),3),
		ROUND(BM.AlmacenadoTanques * (@60F_R/@68F_R),3),
		ROUND(BM.AlmacenadoRecipientes * (@60F_R/@68F_R),3),
		ROUND(BM.VolOtrasEntradas * (@60F_R/@68F_R),3),
		BM.ComentariosEntradas,
		ROUND(BM.VolGasVenteado * (@60F_R/@68F_R),3),
		ROUND(BM.VolGasQuemado * (@60F_R/@68F_R),3),
		ROUND(BM.VolGasTraspasado * (@60F_R/@68F_R),3),
		ROUND(BM.VolGasBN * (@60F_R/@68F_R),3),
		ROUND(BM.VolGasCombustible * (@60F_R/@68F_R),3),
		ROUND(BM.VolGasYacimientos * (@60F_R/@68F_R),3),
		ROUND(BM.VolEmpaque * (@60F_R/@68F_R),3),
		ROUND(BM.VolEncogimientoTransporte * (@60F_R/@68F_R),3),
		ROUND(BM.VolEncogimientoImpurezas * (@60F_R/@68F_R),3),
		ROUND(BM.VolEncogimientoEficiencia * (@60F_R/@68F_R),3),
		ROUND(BM.VolEncogimientoLiquidos * (@60F_R/@68F_R),3),
		BM.FactorEncogimientoTransporte,
		BM.FactorEncogimientoImpurezas,
		BM.FactorEncogimientoEficiencia,
		BM.FactorEncogimientoLiquidos,
		ROUND(BM.VolEntregadoPtoMedicion * (@60F_R/@68F_R),3),
		ROUND(BM.InventarioFinal * (@60F_R/@68F_R),3),
		ROUND(BM.VolPerdidasNoIdentificadas * (@60F_R/@68F_R),3),
		ROUND(BM.VolOtrasSalidas * (@60F_R/@68F_R),3),
		CASE WHEN ISNULL(BM.ComentariosBalance,'') = '' THEN 'N/A'
			ELSE BM.ComentariosBalance
		END

END

