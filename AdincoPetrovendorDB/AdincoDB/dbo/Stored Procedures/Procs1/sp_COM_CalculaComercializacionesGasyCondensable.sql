CREATE PROCEDURE dbo.sp_COM_CalculaComercializacionesGasyCondensable
    @IdContrato INT,
    @MesReporte    DATE,
	@Usuario	INT,
	@FechaLimite	DATETIME,
	@Debug		BIT
AS
BEGIN
-- =============================================
-- Author:		Barbara Arrañaga
-- Create date: 2018-03-07
-- Description:	Proceso para realizar el calculo de las comercializaciones de Gas de acuerdo a la hoja Cuadre GAS del Archivo Info Facturas
--				Calculo de la energia por punto de venta
-- Parametros de Entrada:	Numero de Contrato y Mes de Calculo
-- ----------------------------------------------------------------------------------
-- 20180507	BAAC	Se modifica para no borrar las comercializaciones que no sean de PEMEX
-- 20180513	BAAC	Se modifica para generar las comercializaciones de Condensable
-- =============================================
SET NOCOUNT ON
-- ------------------------------------------------------------------------------------
-- CREACION DE TABLAS
-- ------------------------------------------------------------------------------------
CREATE TABLE #Energias
(
    IdPtoExpedicionRecepcion INT,
    PuntoVenta               NVARCHAR (510),
    C1                       FLOAT,
    C2                       FLOAT,
    C3                       FLOAT,
    C4                       FLOAT,
	C5                       FLOAT,
    CTotal                   FLOAT,
    C1Entero                 INT,
    C2Entero                 INT,
    C3Entero                 INT,
    C4Entero                 INT,
	C5Entero                 INT,
    CTotalEntero             INT,
	PorcentajeC1			FLOAT,
	PorcentajeC2			FLOAT,
	PorcentajeC3			FLOAT,
	PorcentajeC4			FLOAT,
	PorcentajeC5			FLOAT,
	PRIMARY KEY(IdPtoExpedicionRecepcion)
)

CREATE TABLE #EnergiasPunto
(
    IdPtoExpedicionRecepcion INT,
    PuntoVenta               NVARCHAR (510),
    C1Punto                  FLOAT,
    C2Punto                  FLOAT,
    C3Punto                  FLOAT,
    C4Punto                  FLOAT,
	C5Punto                  FLOAT,
    CTotalPunto              FLOAT,
	PRIMARY KEY(IdPtoExpedicionRecepcion)
)

CREATE TABLE #ComponentesFacturados
(
    IdPtoExpedicionRecepcion INT,
    C1Facturado              FLOAT,
    C2Facturado              FLOAT,
    C3Facturado              FLOAT,
    C4Facturado              FLOAT,
	C5Facturado              FLOAT,
	PRIMARY KEY(IdPtoExpedicionRecepcion)
)

CREATE TABLE #Comercializaciones
(
	IdContrato					INT,
    IdFactura                     INT,
    IdPtoExpedicionRecepcion      INT,
    Factura                       VARCHAR (510),
    FechaFactura                  VARCHAR (100),
    FechaTimbrado                 VARCHAR (100),
    Denominación                  VARCHAR (510),
    Nombre1                       VARCHAR (510),
    CantidadFacturada             FLOAT,
    Energía                       FLOAT,
    EnergiaFactura                FLOAT,
    MMBTUFacturados               FLOAT,
    C1Facturado                   FLOAT,
    C2Facturado                   FLOAT,
    C3Facturado                   FLOAT,
    C4Facturado                   FLOAT,
	C5Facturado                   FLOAT,
    MMBTUC1Facturados             FLOAT,
    MMBTUC2Facturados             FLOAT,
    MMBTUC3Facturados             FLOAT,
    MMBTUC4Facturados             FLOAT,
	MMBTUC5Facturados             FLOAT,
    MMBTUC1FacturadosPorcentaje   FLOAT,
    MMBTUC2FacturadosPorcentaje   FLOAT,
    MMBTUC3FacturadosPorcentaje   FLOAT,
    MMBTUC4FacturadosPorcentaje   FLOAT,
	MMBTUC5FacturadosPorcentaje   FLOAT,
    MMBTUC1FacturadosBloque       FLOAT,
    MMBTUC2FacturadosBloque       FLOAT,
    MMBTUC3FacturadosBloque       FLOAT,
    MMBTUC4FacturadosBloque       FLOAT,
	MMBTUC5FacturadosBloque       FLOAT,
    MMBTUC1FacturadosBloqueEntero INT,
    MMBTUC2FacturadosBloqueEntero INT,
    MMBTUC3FacturadosBloqueEntero INT,
    MMBTUC4FacturadosBloqueEntero INT,
	MMBTUC5FacturadosBloqueEntero INT,
    Total                         MONEY,
    Moneda                        VARCHAR (100),
    TotalUSD                      MONEY,
    paridad                       FLOAT, --DECIMAL (12, 4),
    --UUID                          VARCHAR (MAX),
    FACTORC1                      FLOAT,
    FACTORC2                      FLOAT,
    FACTORC3                      FLOAT,
    FACTORC4                      FLOAT,
	FACTORC5                      FLOAT,
	PorcC5					FLOAT,
	--PRIMARY KEY(IdFactura,IdPtoExpedicionRecepcion)
)

CREATE TABLE #Ajustes
(
    IdPtoExpedicionRecepcion INT,
    Nombre1                  VARCHAR (510),
    C1Com                    INT,
    C1Obj                    INT,
    C1Ajuste                 INT,
    C2Com                    INT,
	C2Obj                    INT,
    C2Ajuste                 INT,
    C3Com                    INT,
    C3Obj                    INT,
    C3Ajuste                 INT,
    C4Com                    INT,
    C4Obj                    INT,
    C4Ajuste                 INT,
	C5Com                    INT,
    C5Obj                    INT,
    C5Ajuste                 INT,
	PRIMARY KEY(IdPtoExpedicionRecepcion)
)

CREATE TABLE #AjustesTotal
(
    Idfactura                INT,
    IdPtoExpedicionRecepcion INT,
    IdAjuste1                INT,
    IdAjuste2                INT,
    IdAjuste3                INT,
    IdAjuste4                INT,
	IdAjuste5                INT,
    MMBTUC1FacturadosBloque  FLOAT,
    MMBTUC2FacturadosBloque  FLOAT,
    MMBTUC3FacturadosBloque  FLOAT,
    MMBTUC4FacturadosBloque  FLOAT,
	MMBTUC5FacturadosBloque  FLOAT,
    C1Ajuste                 INT,
    C2Ajuste                 INT,
    C3Ajuste                 INT,
    C4Ajuste                 INT,
	C5Ajuste                 INT,
	--PRIMARY KEY(IdFactura,IdPtoExpedicionRecepcion)
)

CREATE TABLE #PreciosGas
(
    IdContrato                    INT,
    MesReporte                    DATE,
    FechaTransaccion              DATETIME,
    MMBTUC1FacturadosBloqueEntero INT,
    MMBTUC2FacturadosBloqueEntero INT,
    MMBTUC3FacturadosBloqueEntero INT,
    MMBTUC4FacturadosBloqueEntero INT,
	MMBTUC5FacturadosBloqueEntero INT,
    PrecioVentaUnitario           FLOAT,
    CostoUnitarioComercializacion FLOAT,
    PrecioPuntoMedicion           FLOAT,
    IdFactura                     INT,
    Activo                        INT,
    Divisor                       CHAR (1),
    FechaTimbrado                 DATETIME,
    FechaFactura                  VARCHAR (100),
    PuntoVenta                    VARCHAR (250),
    MPC                           FLOAT,
    MMPC                          FLOAT,
    MMPC60F                       FLOAT,
    Ingreso                       FLOAT, --MONEY,
    C1                            FLOAT,
    C2                            FLOAT,
    C3                            FLOAT,
    IC4                           FLOAT,
    NC4                           FLOAT,
    IC5                           FLOAT,
    NC5                           FLOAT,
    C6                            FLOAT,
    pcC1                          FLOAT,
    pcC2                          FLOAT,
    pcC3                          FLOAT,
    pcC4                          FLOAT,
    pcIC4                         FLOAT,
    pcC5mas                       FLOAT,
    pcMezcla                      FLOAT,
    Energia60F                    FLOAT,
	CO2							FLOAT,
	H2S							FLOAT,
	N2							FLOAT,
	PorcC5						FLOAT
)

CREATE TABLE #PreciosGas2
(
    IdContrato  INT,
    MesReporte                    DATE,
    FechaTransaccion              DATETIME,
    MMBTUC1FacturadosBloqueEntero INT,
    MMBTUC2FacturadosBloqueEntero INT,
    MMBTUC3FacturadosBloqueEntero INT,
    MMBTUC4FacturadosBloqueEntero INT,
	MMBTUC5FacturadosBloqueEntero INT,
    PrecioVentaUnitario           FLOAT,
    CostoUnitarioComercializacion FLOAT,
    PrecioPuntoMedicion           FLOAT,
    IdFactura                     INT,
    Activo                        INT,
    Divisor                       CHAR (1),
    FechaTimbrado DATETIME,
    FechaFactura   VARCHAR (100),
    PuntoVenta                    VARCHAR (250),
    MPC                           FLOAT,
    MMPC                          FLOAT,
    MMPC60F                       FLOAT,
    Ingreso                       FLOAT, --MONEY,
    C1                            FLOAT,
    C2                            FLOAT,
    C3                            FLOAT,
    IC4                           FLOAT,
    NC4                           FLOAT,
    IC5                           FLOAT,
    NC5                           FLOAT,
    C6                            FLOAT,
    pcC1                          FLOAT,
    pcC2                          FLOAT,
    pcC3                          FLOAT,
    pcC4                          FLOAT,
    pcIC4                         FLOAT,
    pcC5mas                       FLOAT,
    pcMezcla                      FLOAT,
    Energia60F                    FLOAT,
	CO2							FLOAT,
	H2S							FLOAT,
	N2							FLOAT,
	PorcC5		FLOAT,
    VolC1                         FLOAT,
    VolC2                         FLOAT,
    VolC3                         FLOAT,
    VolC4                         FLOAT,
    VolNC4                        FLOAT,
    VolC5                         FLOAT,
    EnerC1                        FLOAT,
    EnerC2                        FLOAT,
    EnerC3                        FLOAT,
    EnerC4                        FLOAT,
    EnerIC4                       FLOAT,
    EnerC5                        FLOAT,
    Total                         FLOAT,
	FactorVolumenC1				FLOAT,
	FactorVolumenC2				FLOAT,
	FactorVolumenC3				FLOAT,
	FactorVolumenC4				FLOAT,
	FactorVolumenC5				FLOAT,
	FactorVolumenPrecioC1		FLOAT,
	FactorVolumenPrecioC2		FLOAT,
	FactorVolumenPrecioC3		FLOAT,
	FactorVolumenPrecioC4		FLOAT,
	FactorVolumenPrecioC5		FLOAT,
	DescuentoPrecioBalanceoC1	 FLOAT,
	DescuentoPrecioBalanceoC2	 FLOAT,
	DescuentoPrecioBalanceoC3	 FLOAT,
	DescuentoPrecioBalanceoC4	 FLOAT,
	DescuentoPrecioBalanceoC5	 FLOAT
)

CREATE TABLE #CostoUnitarioComercializacion
(
	IdTipoHidrocarburo	INT,
	CostoUnitarioComercializacion	MONEY
)

CREATE TABLE #SumEner
(
	SUMEnerC1	FLOAT,
	SUMEnerC2	FLOAT,
	SUMEnerC3	FLOAT,
	SUMEnerC4	FLOAT,
	SUMEnerIC4	FLOAT,
	SUMEnerC5	FLOAT
)

CREATE TABLE #CalculoPreciosObjetivo
(
	IdFactura       INT,
	FechaTransaccion	DATETIME,
	MMBTUC5FacturadosBloqueEntero INT,
	BLC5Facturados	FLOAT,
	PrecioXEnerC1	FLOAT,
	PrecioXEnerC2	FLOAT,
	PrecioXEnerC3	FLOAT,
	PrecioXEnerC4	FLOAT,
	IngresoC1C4		FLOAT,
	IngresoC5		FLOAT,
	PropPrecioXEnerC1	FLOAT,
	PropPrecioXEnerC2	FLOAT,
	PropPrecioXEnerC3	FLOAT,
	PropPrecioXEnerC4	FLOAT,
	Q5					FLOAT,
	LCIdeal				FLOAT,
	Zmes				FLOAT,
	[LC_C5+]			FLOAT,
	[VolBIC5+]			FLOAT,
	PrecioEquivCondensado	FLOAT,
	Porcentaje			FLOAT,
	VolumenDistribucion	FLOAT,
	PorcC5		FLOAT,
	FactorVolumenC5	FLOAT,
	FactorVolumenPrecioC5	FLOAT,
	DescuentoPrecioBalanceoC5	FLOAT
)

CREATE TABLE #PrecioObjetivo
(
	PrecioC1_USD_MMBTU	FLOAT,
	PrecioC2_USD_MMBTU	FLOAT,
	PrecioC3_USD_MMBTU	FLOAT,
	PrecioC4_USD_MMBTU	FLOAT,
	PrecioEquivCondensado	FLOAT
)

CREATE TABLE #AjustesTotalc5
(
	IdFactura	INT,
	IdAjuste	INT,
	VolumenVendido	INT,
	Ajuste		INT
)
-- ------------------------------------------
-- Variables globales; poder caolirifico de los componentes del gas (segun GPA Standard 2145-09)
-- ------------------------------------------
DECLARE
    @FactorConversion           FLOAT, --DECIMAL (8, 6),
	@pcC1						FLOAT, --DECIMAL (8, 2),
	@pcC2						FLOAT, --DECIMAL (8, 2),
	@pcC3						FLOAT, --DECIMAL (8, 2),
	@pcC4						FLOAT, --DECIMAL (8, 2),
	@pcIC4						FLOAT, --DECIMAL (8, 2),
	@PC_iPentano				FLOAT, --DECIMAL (8, 2),
	@PC_nPentano				FLOAT, --DECIMAL (8, 2),
	@PC_nHexano					FLOAT, --DECIMAL (8, 2),
	@PC_nHeptano				FLOAT, --DECIMAL (8, 2),
	@PC_nOctano					FLOAT, --DECIMAL (8, 2),
	@Conversion60FaR			DECIMAL (8, 2),--FLOAT, --DECIMAL (8, 2),
	@Conversion20CaR			DECIMAL (8, 2),--FLOAT, --DECIMAL (8, 2),
	@NumError					INT,
	@MensajeError				VARCHAR(500),
	@Ft3IdealC5					FLOAT,
	@SumC1						FLOAT,
	@SumC2						FLOAT,
	@SumC3						FLOAT,
	@SumC4						FLOAT,
	@SumC5						FLOAT,
	@VolC1						FLOAT,
	@VolC2						FLOAT,
	@VolC3						FLOAT,
	@VolC4						FLOAT,
	@VolC5						FLOAT,
	@FechaInicioContrato		DATE,
	@EsPC			BIT,
	@PorcPemex		DECIMAL(6,4),
	@EsConsorcio	BIT,
	@VolTotalC1		INT,
	@VolTotalC2		INT,
	@VolTotalC3		INT,
	@VolTotalC4		INT,
	@VolTotalC5		INT,
	@distribuciontotalC5	FLOAT,
	@sumaC5			FLOAT,
	@SumEnerC5		FLOAT,
	@sumtotal		FLOAT,
	@TotalDistribuido	FLOAT

SELECT
    @FactorConversion              = 0.947817,
	@pcC1	=	1010,
	@pcC2	=	1769.7,
	@pcC3	=	2516.1,
	@pcC4	=	3262.3,
	@pcIC4	=	3251.9,
	@PC_iPentano = 4000.9,
	@PC_nPentano= 4008.7,
	@PC_nHexano=  4755.9,
	@PC_nHeptano=  5502.6,
	@PC_nOctano=  6249,
	@Conversion60FaR	=	519.67,
	@Conversion20CaR	=	527.67,
	@Ft3IdealC5	=	25.32

SELECT
	@FechaInicioContrato = InicioVigencia,
	@EsPC			=	IsPC,
	@EsConsorcio	=	IsConsorcio
FROM
	CO_Contrato
WHERE
	IdContrato	=	@IdContrato

SELECT
	@PorcPemex	=	PorcentajePemex / 100.00
FROM
	dbo.CO_PorcentajesContrato
WHERE
	IdContrato	=	@IdContrato

-- SE OBTIENE EL COSTO UNITARIO DEL HIDROCARBURO
INSERT INTO #CostoUnitarioComercializacion
(
	IdTipoHidrocarburo,
	CostoUnitarioComercializacion
)
SELECT
	IdTipoHidrocarburo,
	CostoUnitarioComercializacion
FROM	COM_CostoUnitarioHidrocarburo
WHERE
	IdContrato	=	@IdContrato
	AND	Mes		=	@MesReporte
	AND	IdTipoHidrocarburo	BETWEEN 10002 AND 10005

IF 4 > (SELECT COUNT(1) FROM #CostoUnitarioComercializacion)
BEGIN
    SELECT @MensajeError = 'Falta algun valor vigente para el Costo Unitario de Comercializacion'+CHAR(13)+'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas'
    GOTO ERROR
END
-- ------------------------------------------
--Energia total del bloque por punto de venta
-- ------------------------------------------
INSERT INTO #Energias
(
    IdPtoExpedicionRecepcion,
    PuntoVenta,
    C1,
    C2,
    C3,
    C4,
	C5,
    CTotal,
    C1Entero,
    C2Entero,
    C3Entero,
    C4Entero,
	C5Entero,
    CTotalEntero
)
SELECT
    EQ.IdPtoExpedicionRecepcion,
    VA.[PUNTO DE VENTA],
    SUM( CONVERT(FLOAT,[Energía C1]) )                              AS C1,
    SUM( CONVERT(FLOAT,[Energía C2]) )                              AS C2,
    SUM( CONVERT(FLOAT,[Energía C3]) )                              AS C3,
    SUM( CONVERT(FLOAT,[Energía IC4]) + CONVERT(FLOAT,[Energía NC4]) )             AS C4,
	SUM( CONVERT(FLOAT,[Energía C5+]) )                              AS C5,
    SUM( CONVERT(FLOAT,VA.[Energía Total]) )              AS CTotal,
    ROUND( SUM( CONVERT(FLOAT,[Energía C1]) ), 0 )                  AS C1Entero,
    ROUND( SUM( CONVERT(FLOAT,[Energía C2]) ), 0 )             AS C2Entero,
	ROUND( SUM( CONVERT(FLOAT,[Energía C3]) ), 0 )                  AS C3Entero,
    ROUND( SUM( CONVERT(FLOAT,[Energía IC4]) + CONVERT(FLOAT,[Energía NC4]) ), 0 ) AS C4Entero,
	ROUND( SUM( CONVERT(FLOAT,[Energía C5+]) ), 0 )                  AS C5Entero,
    ROUND( SUM( CONVERT(FLOAT,VA.[Energía Total]) ), 0 )            AS CTotalEntero
	--(([Energía C5+] / 1000) * (@Conversion60FaR / @Conversion20CaR)) * 1000 * ((((IC5+NC5+C6)/100*1000) * (1/25.32) * (14.696 / 14.696)) / 
	--(1- POWER(((C1/100)*0.0116) + ((C2/100)*0.0238) + ((C3/100)*0.0347) + ((NC4/100)*0.047) + ((IC4/100)*0.0441) + (((IC5+NC5+C6)/100)*0.072735) + ((CO2/100)*0.0195) + ((H2S/100)*0.0239) + ((N2/100)*0.00442) ,2)* 14.696)) / 42.00 AS [VolBIC5+],
FROM
    PC_VentasAsignacion       VA	(NOLOCK)
JOIN
	PC_EquivalenciaPuntoVenta EQ	(NOLOCK)
    ON EQ.puntoventaa     = VA.[PUNTO DE VENTA]
JOIN
	PC_Campo                  C		(NOLOCK)
    ON C.DescripcionCampo = VA.[CAMPO OFICIAL]
JOIN
	PC_ContratoCampo          CC	(NOLOCK)
    ON CC.IdCampo         = C.IdCampo
WHERE
    [PRODUCTO AGRUPA] = 'Gas'
	AND IdContrato        = @IdContrato --AND VA.ASIGNACIÓN = 'M2 - Santuario-El Golpe'
GROUP BY
    EQ.IdPtoExpedicionRecepcion,
    VA.[PUNTO DE VENTA]

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #Energias'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

SELECT
	@SumC1 = SUM(C1),
	@SumC2 = SUM(C2),
	@SumC3 = SUM(C3),
	@SumC4 = SUM(C4),
	@SumC5 = SUM(C5)
FROM #Energias

IF @Debug = 1
	SELECT @SumC1 AS [VolTotalC1], @SumC2 AS [VolTotalC2], @SumC3 AS [VolTotalC3], @SumC4 AS [VolTotalC4], @SumC5 AS [VolTotalC5]

UPDATE #Energias
	SET PorcentajeC1 = C1 / @SumC1,
		PorcentajeC2 = C2 / @SumC2,
		PorcentajeC3 = C3 / @SumC3,
		PorcentajeC4 = C4 / @SumC4,
		PorcentajeC5 = C5 / @SumC5

-- SE VALIDA SI EL CONTRATO ES DE PRODUCCION COMPARTIDA EN CONSORCIO PARA GENERAR LAS COMERCIALIZACIONES TOPANDO AL VOLUMEN QUE LE CORRESPONDE A PEMEX
IF @EsPC = 1 AND @EsConsorcio = 1 AND ISNULL(@PorcPemex,0) = 0
BEGIN
    SELECT @MensajeError = 'No se encontro el porcentaje correspondiente a PEMEX'+CHAR(13)+'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas'
    GOTO ERROR
END

SELECT
	@VolC1 = CASE	WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C1 % 2 = 1
						THEN (C1 * @PorcPemex) + 0.5
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C1 % 2 = 0
						THEN C1 * @PorcPemex
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex <> 0.5
						THEN C1 * @PorcPemex
					ELSE	C1
			END,
	@VolC2 = CASE	WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C2 % 2 = 1
						THEN (C2 * @PorcPemex) + 0.5
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C2 % 2 = 0
						THEN C2 * @PorcPemex
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex <> 0.5
						THEN C2 * @PorcPemex
					ELSE	C2
			END,
	@VolC3 = CASE	WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C3 % 2 = 1
						THEN (C3 * @PorcPemex) + 0.5
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C3 % 2 = 0
						THEN C3 * @PorcPemex
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex <> 0.5
						THEN C3 * @PorcPemex
					ELSE	C3
			END,
	@VolC4 = CASE	WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C4 % 2 = 1
						THEN (C4 * @PorcPemex) + 0.5
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C4 % 2 = 0
						THEN C4 * @PorcPemex
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex <> 0.5
						THEN C4 * @PorcPemex
					ELSE	C4
			END,
	@VolC5 = CASE	WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C5 % 2 = 1
						THEN (C5 * @PorcPemex) + 0.5
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C5 % 2 = 0
						THEN C5 * @PorcPemex
					WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex <> 0.5
						THEN C5 * @PorcPemex
					ELSE	C5
			END
FROM
	dbo.PC_Volumenes
WHERE
	IdContrato = @IdContrato
	AND Mes = @MesReporte

UPDATE #Energias
	SET	
	c1 = CASE WHEN @SumC1 > @VolC1	THEN @VolC1 * PorcentajeC1 ELSE C1 END,
	C2 = CASE WHEN @SumC2 > @VolC2	THEN @VolC2 * PorcentajeC2 ELSE C2 END,
	C3 = CASE WHEN @SumC3 > @VolC3	THEN @VolC3 * PorcentajeC3 ELSE C3 END,
	C4 = CASE WHEN @SumC4 > @VolC4	THEN @VolC4 * PorcentajeC4 ELSE C4 END
--	C5 = CASE WHEN @SumC5 > @VolC5	THEN @VolC5 * PorcentajeC5 ELSE C5 END

UPDATE #Energias
	SET
		CTotal = C1 + C2 + C3 + C4,
		C1Entero = ROUND(C1,0),
		C2Entero = ROUND(C2,0),
		C3Entero = ROUND(C3,0),
		C4Entero = ROUND(C4,0),
		CTotalEntero = ROUND(C1,0) + ROUND(C2,0) + ROUND(C3,0) + ROUND(C4,0)
 
IF @Debug = 1
BEGIN
	SELECT @VolC1 AS [VOLC1TOPE], @VolC2 AS [VOLC2TOPE], @VolC3 AS [VOLC3TOPE], @VolC4 AS [VOLC4TOPE], @VolC5 AS [VOLC5TOPEBLS]
	SELECT
		*
	FROM
		#Energias

	SELECT SUM(C1), SUM(C2), SUM(C3), SUM(C4), SUM(C5)
	FROM
		#Energias
END

-- ---------------------------------------------------
--Energia por componente del bloque por punto de venta
-- ---------------------------------------------------
INSERT INTO #EnergiasPunto
(
    IdPtoExpedicionRecepcion,
    PuntoVenta,
    C1Punto,
    C2Punto,
    C3Punto,
    C4Punto,
	C5Punto,
    CTotalPunto
)
SELECT
    EQ.IdPtoExpedicionRecepcion,
    VA.[PUNTO DE VENTA],
    SUM( CONVERT(FLOAT,[Energía C1]) )                  AS C1Punto,
    SUM( CONVERT(FLOAT,[Energía C2]) )                  AS C2Punto,
    SUM( CONVERT(FLOAT,[Energía C3]) )                  AS C3Punto,
    SUM( CONVERT(FLOAT,[Energía IC4]) + CONVERT(FLOAT,[Energía NC4]) ) AS C4Punto,
	SUM( CONVERT(FLOAT,[Energía C5+]) )                  AS C5Punto,
    SUM( CONVERT(FLOAT,VA.[Energía Total]) )            AS CTotalPunto
FROM
    PC_VentasAsignacion       VA
JOIN
	PC_EquivalenciaPuntoVenta EQ
    ON EQ.puntoventaa = VA.[PUNTO DE VENTA]
JOIN
	#Energias                 E
    ON VA.[PUNTO DE VENTA] = E.PuntoVenta
WHERE
    [PRODUCTO AGRUPA] = 'Gas'
GROUP BY
	EQ.IdPtoExpedicionRecepcion,
	VA.[PUNTO DE VENTA]

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #EnergiasPunto'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

IF @Debug = 1
BEGIN
	SELECT    'Energía del Area Contractual en los puntos de venta, Energia total de los puntos de venta, Factores'
	SELECT
		*,
		EP.C1Punto / EP.CTotalPunto AS FC1,
		EP.C2Punto / EP.CTotalPunto AS FC2,
		EP.C3Punto / EP.CTotalPunto AS FC3,
		EP.C4Punto / EP.CTotalPunto AS FC4,
		EP.C5Punto / EP.CTotalPunto AS FC5
	FROM
		#Energias      E
	JOIN
		#EnergiasPunto EP
		ON E.PuntoVenta = EP.PuntoVenta
END

-- ------------------------------------------------------
--Determinación de las facturas que jugaran en el calculo
-- ------------------------------------------------------
INSERT INTO #ComponentesFacturados
(
    IdPtoExpedicionRecepcion,
    C1Facturado,
    C2Facturado,
    C3Facturado,
    C4Facturado,
	C5Facturado
)
SELECT
    PER.IdPtoExpedicionRecepcion,
    SUM( FC.Cantidad * @FactorConversion * (EPP.C1Punto / EPP.CTotalPunto)) AS C1Facturado,
    SUM( FC.Cantidad * @FactorConversion * (EPP.C2Punto / EPP.CTotalPunto)) AS C2Facturado,
    SUM( FC.Cantidad * @FactorConversion * (EPP.C3Punto / EPP.CTotalPunto)) AS C3Facturado,
    SUM( FC.Cantidad * @FactorConversion * (EPP.C4Punto / EPP.CTotalPunto)) AS C4Facturado,
	SUM( FC.Cantidad * @FactorConversion * (EPP.C5Punto / EPP.CTotalPunto)) AS C5Facturado
FROM
    dbo.PC_Comercializacion_V2    R8
JOIN
	PC_PTI_V2                     PTI
    ON CONVERT(INT,PTI.Factura)                  = CONVERT(INT,R8.Referencia1)
JOIN
	dbo.FI_Factura                F
    ON RTRIM( PTI.UUID )            = RTRIM( F.UUID )
JOIN
	dbo.PC_EquivalenciaPuntoVenta EPV
    ON EPV.[Nombre 1]               = R8.Nombre1
JOIN
	dbo.PC_PtoExpedicionRecepcion PER
    ON PER.IdPtoExpedicionRecepcion = EPV.IdPtoExpedicionRecepcion
JOIN
	dbo.PC_PuntoVentaProducto     PVP
    ON PVP.IdPtoExpedicionRecepcion = EPV.IdPtoExpedicionRecepcion
JOIN
	dbo.PC_Material               M
    ON M.TextoBreve              = R8.Denominación
JOIN
	#EnergiasPunto                EPP
    ON EPP.IdPtoExpedicionRecepcion = PVP.IdPtoExpedicionRecepcion
JOIN
	dbo.FI_CFDIConcepto           FC
    ON FC.IdFactura                 = F.IdFactura
WHERE
    ( R8.factura LIKE '92%'   OR   R8.Factura LIKE '93%' ) --Filtro de solo las facturas que comienzan 92 y 93
    AND (R8.Denominación LIKE '%gas %') -- Filtro de solo gas
    AND MONTH( F.FechaTimbrado ) = MONTH( @MesReporte )
    AND YEAR( F.FechaTimbrado )  = YEAR( @MesReporte )
    --AND DATEFROMPARTS(ROUND(  SUBSTRING(r8.FechaFactura, 7, 4)), ROUND(  SUBSTRING(r8.FechaFactura, 4, 2)), ROUND(  SUBSTRING(r8.FechaFactura, 1, 2))) >= DATEFROMPARTS(2017, 12, 1)
  AND PVP.IdContrato           = @IdContrato
    AND PVP.Mes                  = @MesReporte
    AND PVP.IdMaterialPC         = M.IdMaterialPC
    AND PVP.Aplica               = 1
	AND DATEFROMPARTS( SUBSTRING( R8.FechaFactura, 7, 4 ), SUBSTRING( R8.FechaFactura, 4, 2 ), SUBSTRING( R8.FechaFactura, 1, 2 ) ) >= @FechaInicioContrato
GROUP BY
    PER.IdPtoExpedicionRecepcion

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #EnergiasPunto'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

INSERT INTO #Comercializaciones
(
	IdContrato,
    IdFactura,
    IdPtoExpedicionRecepcion,
    Factura,
    FechaFactura,
    FechaTimbrado,
    Denominación,
    Nombre1,
    CantidadFacturada,
    Energía,
    EnergiaFactura,
    MMBTUFacturados,
    C1Facturado,
    C2Facturado,
    C3Facturado,
    C4Facturado,
	C5Facturado,
    MMBTUC1Facturados,
    MMBTUC2Facturados,
    MMBTUC3Facturados,
    MMBTUC4Facturados,
	MMBTUC5Facturados,
    MMBTUC1FacturadosPorcentaje,
    MMBTUC2FacturadosPorcentaje,
    MMBTUC3FacturadosPorcentaje,
    MMBTUC4FacturadosPorcentaje,
	MMBTUC5FacturadosPorcentaje,
    MMBTUC1FacturadosBloque,
    MMBTUC2FacturadosBloque,
    MMBTUC3FacturadosBloque,
    MMBTUC4FacturadosBloque,
	MMBTUC5FacturadosBloque,
    MMBTUC1FacturadosBloqueEntero,
    MMBTUC2FacturadosBloqueEntero,
    MMBTUC3FacturadosBloqueEntero,
    MMBTUC4FacturadosBloqueEntero,
	MMBTUC5FacturadosBloqueEntero,
    Total,
    Moneda,
    TotalUSD,
    paridad,
    --UUID,
    FACTORC1,
    FACTORC2,
    FACTORC3,
    FACTORC4,
	FACTORC5,
	PorcC5
)
SELECT
	@IdContrato,
    F.IdFactura,
    PVP.IdPtoExpedicionRecepcion,
    R8.Factura,
    R8.FechaFactura,
    PTI.FechaTimbrado,
    R8.Denominación,
    R8.Nombre1,
    R8.CantidadFacturada,
    R8.Energía,
    FC.Cantidad                                                                                        AS EnergiaFactura,
    FC.Cantidad * @FactorConversion                                                                    AS MMBTUFacturados,
    COMP.C1Facturado,
    COMP.C2Facturado,
    COMP.C3Facturado,
    COMP.C4Facturado,
	COMP.C5Facturado,
    FC.Cantidad * @FactorConversion * (EPP.C1Punto / EPP.CTotalPunto)                                  AS MMBTUC1Facturados,
    FC.Cantidad * @FactorConversion * (EPP.C2Punto / EPP.CTotalPunto)                                  AS MMBTUC2Facturados,
    FC.Cantidad * @FactorConversion * (EPP.C3Punto / EPP.CTotalPunto)                                  AS MMBTUC3Facturados,
    FC.Cantidad * @FactorConversion * (EPP.C4Punto / EPP.CTotalPunto)                                  AS MMBTUC4Facturados,
	FC.Cantidad * @FactorConversion * (EPP.C5Punto / EPP.CTotalPunto)                                  AS MMBTUC5Facturados,
    ((FC.Cantidad * @FactorConversion * (EPP.C1Punto / EPP.CTotalPunto)) / COMP.C1Facturado) * 100     AS MMBTUC1FacturadosPorcentaje,
    ((FC.Cantidad * @FactorConversion * (EPP.C2Punto / EPP.CTotalPunto)) / COMP.C2Facturado) * 100     AS MMBTUC2FacturadosPorcentaje,
    ((FC.Cantidad * @FactorConversion * (EPP.C3Punto / EPP.CTotalPunto)) / COMP.C3Facturado) * 100     AS MMBTUC3FacturadosPorcentaje,
    ((FC.Cantidad * @FactorConversion * (EPP.C4Punto / EPP.CTotalPunto)) / COMP.C4Facturado) * 100     AS MMBTUC4FacturadosPorcentaje,
	((FC.Cantidad * @FactorConversion * (EPP.C5Punto / EPP.CTotalPunto)) / COMP.C5Facturado) * 100     AS MMBTUC5FacturadosPorcentaje,
    ENER.C1 * ((FC.Cantidad * @FactorConversion * (EPP.C1Punto / EPP.CTotalPunto)) / COMP.C1Facturado) AS MMBTUC1FacturadosBloque,
    ENER.C2 * ((FC.Cantidad * @FactorConversion * (EPP.C2Punto / EPP.CTotalPunto)) / COMP.C2Facturado) AS MMBTUC2FacturadosBloque,
    ENER.C3 * ((FC.Cantidad * @FactorConversion * (EPP.C3Punto / EPP.CTotalPunto)) / COMP.C3Facturado) AS MMBTUC3FacturadosBloque,
    ENER.C4 * ((FC.Cantidad * @FactorConversion * (EPP.C4Punto / EPP.CTotalPunto)) / COMP.C4Facturado) AS MMBTUC4FacturadosBloque,
	ENER.C5 * ((FC.Cantidad * @FactorConversion * (EPP.C5Punto / EPP.CTotalPunto)) / COMP.C5Facturado) AS MMBTUC5FacturadosBloque,
    ROUND(ENER.C1 * ((FC.Cantidad * @FactorConversion * (EPP.C1Punto / EPP.CTotalPunto)) / COMP.C1Facturado), 0)   AS MMBTUC1FacturadosBloqueEntero,
    ROUND( ENER.C2 * ((FC.Cantidad * @FactorConversion * (EPP.C2Punto / EPP.CTotalPunto)) / COMP.C2Facturado),0)   AS MMBTUC2FacturadosBloqueEntero,
	ROUND( ENER.C3 * ((FC.Cantidad * @FactorConversion * (EPP.C3Punto / EPP.CTotalPunto)) / COMP.C3Facturado),0)   AS MMBTUC3FacturadosBloqueEntero,
    ROUND( ENER.C4 * ((FC.Cantidad * @FactorConversion * (EPP.C4Punto / EPP.CTotalPunto)) / COMP.C4Facturado),0)	AS MMBTUC4FacturadosBloqueEntero,
	ROUND( ENER.C5 * ((FC.Cantidad * @FactorConversion * (EPP.C5Punto / EPP.CTotalPunto)) / COMP.C5Facturado),0)	AS MMBTUC5FacturadosBloqueEntero,
    PTI.Subtotal,	--PTI.Total, --F.SubTotal,-- --,
    PTI.Moneda,
    --CAST(F.SubTotal / TCD.TipoCambio AS MONEY),  --
	--CAST(PTI.Total / TCD.TipoCambio AS MONEY)                                                          AS TotalUSD,
	CAST(PTI.Subtotal / TCD.TipoCambio AS MONEY),
    TCD.TipoCambio                                                                                     AS paridad,
    --F.UUID,
    (ENER.C1 * ((FC.Cantidad * @FactorConversion * (EPP.C1Punto / EPP.CTotalPunto)) / COMP.C1Facturado))
    / (FC.Cantidad * @FactorConversion * (EPP.C1Punto / EPP.CTotalPunto))                              AS FACTORC1,
    (ENER.C2 * ((FC.Cantidad * @FactorConversion * (EPP.C2Punto / EPP.CTotalPunto)) / COMP.C2Facturado))
    / (FC.Cantidad * @FactorConversion * (EPP.C2Punto / EPP.CTotalPunto))                              AS FACTORC2,
    (ENER.C3 * ((FC.Cantidad * @FactorConversion * (EPP.C3Punto / EPP.CTotalPunto)) / COMP.C3Facturado))
    / (FC.Cantidad * @FactorConversion * (EPP.C3Punto / EPP.CTotalPunto))                              AS FACTORC3,
    (ENER.C4 * ((FC.Cantidad * @FactorConversion * (EPP.C4Punto / EPP.CTotalPunto)) / COMP.C4Facturado))
    / (FC.Cantidad * @FactorConversion * (EPP.C4Punto / EPP.CTotalPunto))                              AS FACTORC4,
	 (ENER.C5 * ((FC.Cantidad * @FactorConversion * (EPP.C5Punto / EPP.CTotalPunto)) / COMP.C5Facturado))
    / (FC.Cantidad * @FactorConversion * (EPP.C5Punto / EPP.CTotalPunto))                              AS FACTORC5,
	CASE WHEN @VolC5 = 0 THEN 0
		ELSE	(EPP.C5Punto / @VolC5)
	END		AS [PorcC5]
FROM
    dbo.PC_Comercializacion_V2    R8
JOIN
	PC_PTI_V2                     PTI
    ON CONVERT(INT,PTI.Factura)	= CONVERT(INT,R8.Referencia1)
JOIN
	dbo.FI_Factura                F
    ON RTRIM( PTI.UUID )             = RTRIM( F.UUID )
JOIN
	dbo.PC_EquivalenciaPuntoVenta EPV
    ON EPV.[Nombre 1]                = R8.Nombre1
JOIN
	dbo.PC_PtoExpedicionRecepcion PER
    ON PER.IdPtoExpedicionRecepcion  = EPV.IdPtoExpedicionRecepcion
JOIN
	dbo.PC_PuntoVentaProducto     PVP
    ON PVP.IdPtoExpedicionRecepcion  = EPV.IdPtoExpedicionRecepcion
JOIN
	dbo.PC_Material               M
    ON M.TextoBreve                  = R8.Denominación
JOIN
	#EnergiasPunto                EPP
    ON EPP.IdPtoExpedicionRecepcion  = PVP.IdPtoExpedicionRecepcion
JOIN
	dbo.FI_CFDIConcepto      FC
    ON FC.IdFactura                  = F.IdFactura
JOIN
	#Energias                     ENER
    ON ENER.IdPtoExpedicionRecepcion = EPP.IdPtoExpedicionRecepcion
JOIN
	dbo.CO_TipoCambioDiario       TCD
	--ON	CONVERT(DATE,SUBSTRING(PTI.FechaFactura,7,4)+SUBSTRING(PTI.FechaFactura,4,2)+SUBSTRING(PTI.FechaFactura,1,2),112)	=	TCD.Fecha
	ON	CONVERT(DATE,SUBSTRING(R8.FechaFactura,7,4)+SUBSTRING(R8.FechaFactura,4,2)+SUBSTRING(R8.FechaFactura,1,2),112)	=	TCD.Fecha
    --ON YEAR( F.FechaTimbrado )  = YEAR( TCD.Fecha )
    --AND MONTH( F.FechaTimbrado )      = MONTH( TCD.Fecha )
    --AND DAY( F.FechaTimbrado )        = DAY( TCD.Fecha )
    AND TCD.IdMoneda                  = F.IdMoneda
JOIN
	#ComponentesFacturados        COMP
    ON COMP.IdPtoExpedicionRecepcion = PER.IdPtoExpedicionRecepcion
JOIN
	COM_Equivalencias             E
    ON FC.Unidad                     = E.Unidad
WHERE
      ( R8.factura LIKE '92%'  OR   R8.Factura LIKE '93%'  )
    AND (R8.Denominación LIKE '%gas %')
	AND R8.CantidadFacturada > 0
    AND MONTH( F.FechaTimbrado ) = MONTH( @MesReporte )
    AND YEAR( F.FechaTimbrado )  = YEAR( @MesReporte )
    --AND DATEFROMPARTS(ROUND(  SUBSTRING(r8.FechaFactura, 7, 4)), ROUND(  SUBSTRING(r8.FechaFactura, 4, 2)), ROUND(  SUBSTRING(r8.FechaFactura, 1, 2))) >= DATEFROMPARTS(2017, 12, 18)
    AND PVP.IdContrato           = @IdContrato
    AND PVP.Mes                  = @MesReporte
    AND PVP.IdMaterialPC         = M.IdMaterialPC
    AND PVP.Aplica               = 1
	AND DATEFROMPARTS( SUBSTRING( R8.FechaFactura, 7, 4 ), SUBSTRING( R8.FechaFactura, 4, 2 ), SUBSTRING( R8.FechaFactura, 1, 2 ) ) >= @FechaInicioContrato

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #Comercializaciones'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

INSERT INTO #Ajustes
(
    IdPtoExpedicionRecepcion,
    Nombre1,
    C1Com,
    C1Obj,
    C1Ajuste,
    C2Com,
    C2Obj,
    C2Ajuste,
    C3Com,
    C3Obj,
    C3Ajuste,
    C4Com,
    C4Obj,
    C4Ajuste,
	C5Com,
    C5Obj,
    C5Ajuste
)
SELECT
    COM.IdPtoExpedicionRecepcion,
    COM.Nombre1,
    SUM( COM.MMBTUC1FacturadosBloqueEntero )              AS C1Com,
    E.C1Entero                                            AS C1Obj,
    E.C1Entero - SUM( COM.MMBTUC1FacturadosBloqueEntero ) AS C1Ajuste,
    SUM( COM.MMBTUC2FacturadosBloqueEntero )              AS C2Com,
    E.C2Entero                                            AS C2Obj,
    E.C2Entero - SUM( COM.MMBTUC2FacturadosBloqueEntero ) AS C2Ajuste,
    SUM( COM.MMBTUC3FacturadosBloqueEntero )              AS C3Com,
    E.C3Entero                                            AS C3Obj,
    E.C3Entero - SUM( COM.MMBTUC3FacturadosBloqueEntero ) AS C3Ajuste,
    SUM( COM.MMBTUC4FacturadosBloqueEntero )              AS C4Com,
    E.C4Entero                                            AS C4Obj,
    E.C4Entero - SUM( COM.MMBTUC4FacturadosBloqueEntero ) AS C4Ajuste,
	SUM( COM.MMBTUC5FacturadosBloqueEntero )              AS C5Com,
    E.C5Entero                                            AS C5Obj,
    E.C5Entero - SUM( COM.MMBTUC5FacturadosBloqueEntero ) AS C5Ajuste
FROM
    #Comercializaciones COM
JOIN
	#Energias           E
    ON E.IdPtoExpedicionRecepcion = COM.IdPtoExpedicionRecepcion
GROUP BY
    COM.IdPtoExpedicionRecepcion,
    COM.Nombre1,
    E.C1Entero,
    E.C2Entero,
    E.C3Entero,
    E.C4Entero,
	E.C5Entero

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #Ajustes'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

INSERT INTO #AjustesTotal
(
    Idfactura,
    IdPtoExpedicionRecepcion,
	  IdAjuste1,
	  IdAjuste2,
    IdAjuste3,
    IdAjuste4,
	IdAjuste5,
    MMBTUC1FacturadosBloque,
    MMBTUC2FacturadosBloque,
    MMBTUC3FacturadosBloque,
    MMBTUC4FacturadosBloque,
	MMBTUC5FacturadosBloque,
    C1Ajuste,
    C2Ajuste,
    C3Ajuste,
    C4Ajuste,
	C5Ajuste
)
SELECT
    IdFactura,
    c.IdPtoExpedicionRecepcion,
    ROW_NUMBER() OVER (PARTITION BY
                            c.IdPtoExpedicionRecepcion
                            ORDER BY
 c.MMBTUC1FacturadosBloque DESC
                       ) AS IdAjuste1,
    ROW_NUMBER() OVER (PARTITION BY
                            c.IdPtoExpedicionRecepcion
                            ORDER BY
                            c.MMBTUC2FacturadosBloque DESC
                        ) AS IdAjuste2,
    ROW_NUMBER() OVER (PARTITION BY
                            c.IdPtoExpedicionRecepcion
  ORDER BY
                    c.MMBTUC3FacturadosBloque DESC
                        ) AS IdAjuste3,
    ROW_NUMBER() OVER (PARTITION BY
                            c.IdPtoExpedicionRecepcion
                            ORDER BY
                            c.MMBTUC4FacturadosBloque DESC
                        ) AS IdAjuste4,
	ROW_NUMBER() OVER (PARTITION BY
                            c.IdPtoExpedicionRecepcion
                            ORDER BY
                            c.MMBTUC5FacturadosBloque DESC
                        ) AS IdAjuste5,
    c.MMBTUC1FacturadosBloque,
    c.MMBTUC2FacturadosBloque,
    c.MMBTUC3FacturadosBloque,
    c.MMBTUC4FacturadosBloque,
	c.MMBTUC5FacturadosBloque,
    a.C1Ajuste,
    a.C2Ajuste,
    a.C3Ajuste,
    a.C4Ajuste,
	a.C5Ajuste
FROM
    #Comercializaciones c
JOIN
	#Ajustes            a
    ON c.IdPtoExpedicionRecepcion = a.IdPtoExpedicionRecepcion

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #AjustesTotal'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

UPDATE    C
    SET
        MMBTUC1FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste1 <= A.C1Ajuste THEN
                                                C.MMBTUC1FacturadosBloqueEntero + 1
                                            ELSE C.MMBTUC1FacturadosBloqueEntero
                                        END,
        MMBTUC2FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste2 <= A.C2Ajuste THEN
                                                C.MMBTUC2FacturadosBloqueEntero + 1
                                            ELSE C.MMBTUC2FacturadosBloqueEntero
                                        END,
        MMBTUC3FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste3 <= A.C3Ajuste THEN
                                                C.MMBTUC3FacturadosBloqueEntero + 1
                                            ELSE C.MMBTUC3FacturadosBloqueEntero
                                        END,
        MMBTUC4FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste4 <= A.C4Ajuste THEN
                                                C.MMBTUC4FacturadosBloqueEntero + 1
                                            ELSE C.MMBTUC4FacturadosBloqueEntero
                                        END,
		MMBTUC5FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste5 <= A.C5Ajuste THEN
                                                C.MMBTUC5FacturadosBloqueEntero + 1
                                            ELSE C.MMBTUC5FacturadosBloqueEntero
                                        END
FROM
    #Comercializaciones C
JOIN
	#AjustesTotal       A
    ON C.IdFactura                = A.Idfactura
    AND C.IdPtoExpedicionRecepcion = A.IdPtoExpedicionRecepcion

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al actualizar en #Comercializaciones'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

-- SE REALIZA EL AJUSTE NEGATIVO A LOS VOLUMENES

UPDATE    C
    SET
         MMBTUC1FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste1 <= ABS(A.C1Ajuste) AND A.C1Ajuste < 0 THEN
                                                C.MMBTUC1FacturadosBloqueEntero -1
											ELSE C.MMBTUC1FacturadosBloqueEntero
                                        END,
        MMBTUC2FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste2 <= ABS(A.C2Ajuste) AND A.C2Ajuste < 0 THEN
                                                C.MMBTUC2FacturadosBloqueEntero -1
                                            ELSE C.MMBTUC2FacturadosBloqueEntero
                                        END,
        MMBTUC3FacturadosBloqueEntero = CASE
											WHEN A.IdAjuste3 <= ABS(A.C3Ajuste) AND A.C3Ajuste < 0 THEN
                                                C.MMBTUC3FacturadosBloqueEntero -1
                                            ELSE C.MMBTUC3FacturadosBloqueEntero
             END,
        MMBTUC4FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste4 <= ABS(A.C4Ajuste) AND A.C4Ajuste < 0 THEN
                                                C.MMBTUC4FacturadosBloqueEntero -1
                                            ELSE C.MMBTUC4FacturadosBloqueEntero
                                        END,
		MMBTUC5FacturadosBloqueEntero = CASE
                                            WHEN A.IdAjuste5 <= ABS(A.C5Ajuste) AND A.C5Ajuste < 0 THEN
                                                C.MMBTUC5FacturadosBloqueEntero -1
                                            ELSE C.MMBTUC5FacturadosBloqueEntero
                                        END
FROM
	#Comercializaciones C
JOIN
	#AjustesTotal       A
	ON C.IdFactura                = A.Idfactura
	AND C.IdPtoExpedicionRecepcion = A.IdPtoExpedicionRecepcion
WHERE
	(A.C1Ajuste < 0 OR A.C2Ajuste < 0 OR A.C3Ajuste < 0 OR A.C4Ajuste < 0 OR A.C5Ajuste < 0)


IF @Debug = 1
BEGIN
	SELECT '#Comercializaciones'
	SELECT    *
	FROM	#Comercializaciones
	ORDER BY IdFactura

	SELECT * FROM #Ajustes
END

--INSERT INTO #VolTotal
--(
--	C1,
--	C2,
--	C3,
--	C4
--)
SELECT
	@VolTotalC1	=	SUM(MMBTUC1FacturadosBloqueEntero),
    @VolTotalC2	=	SUM(MMBTUC2FacturadosBloqueEntero),
    @VolTotalC3	=	SUM(MMBTUC3FacturadosBloqueEntero),
    @VolTotalC4	=	SUM(MMBTUC4FacturadosBloqueEntero),
	@VolTotalC5	=	SUM(MMBTUC5FacturadosBloqueEntero)
FROM
	#Comercializaciones

	INSERT INTO #PreciosGas
	(
		IdContrato,
		MesReporte,
		FechaTransaccion,
		MMBTUC1FacturadosBloqueEntero,
		MMBTUC2FacturadosBloqueEntero,
		MMBTUC3FacturadosBloqueEntero,
		MMBTUC4FacturadosBloqueEntero,
		MMBTUC5FacturadosBloqueEntero,
		PrecioVentaUnitario,
		CostoUnitarioComercializacion,
		PrecioPuntoMedicion,
		IdFactura,
		Activo,
		--PVUAnterior,
		--PPMAnterior,
		Divisor,
		FechaTimbrado,
		FechaFactura,
		PuntoVenta,
		MPC,
		MMPC,
		MMPC60F,
		Ingreso,
		C1,
		C2,
		C3,
		IC4,
		NC4,
		IC5,
		NC5,
		C6,
		pcC1,
		pcC2,
		pcC3,
		pcC4,
		pcIC4,
		pcC5mas,
		pcMezcla,
		Energia60F,
		CO2	,
		H2S	,
		N2	,
		PorcC5
	)
	SELECT
		@IdContrato                                                AS IdContrato, --IdContrato
		@MesReporte                                                                         AS MesReporte, --MesReporte	@PERIODO
		F.Fecha                                                                              AS FechaTransaccion, --FechaTransaccion    
		COM.MMBTUC1FacturadosBloqueEntero, --VolumenVendido  
		COM.MMBTUC2FacturadosBloqueEntero,
		COM.MMBTUC3FacturadosBloqueEntero,
		COM.MMBTUC4FacturadosBloqueEntero,
		COM.MMBTUC5FacturadosBloqueEntero,
		((ValorUnitario / TCD.TipoCambio) * FC.Cantidad) / (FC.Cantidad * E.Factor)          AS PrecioVentaUnitario, --PrecioVentaUnitario
		0			AS CostoUnitarioComercializacion,	--@CostoUnitarioComercializacion       SE ACTUALIZARA MAS ADELANTE CON LA TALA DE COSTO UNITARIO
		0		AS	PrecioPuntoMedicion,	-- (((ValorUnitario / TCD.TipoCambio) * FC.Cantidad) / (FC.Cantidad * E.Factor)) - @CostoUnitarioComercializacion SE ACTUALIZARA MAS ADELANTE CON EL COSTO
		F.IdFactura,
		1                                                               AS Activo, ---Activo
		--0                                                                                    AS PVUAnterior,
		--0                                                                                    AS PPMAnterior,
		'|'                                                                                  AS Divisor,
		F.FechaTimbrado,
		R8.FechaFactura,
		R8.Nombre1                                                                           AS PuntoVenta,
		R8.CantidadFacturada                                                                 AS MPC,
		R8.CantidadFacturada / 1000                                      AS MMPC,
		(R8.CantidadFacturada / 1000) * (@Conversion60FaR / @Conversion20CaR)				 AS MMPC60F,
		PTI.Subtotal / TCD.TipoCambio          AS Ingreso,
		CONVERT( FLOAT, CRO.Presion_C1mol )                                                             AS C1,
		CONVERT( FLOAT, CRO.C2mol )                                                             AS C2,
		CONVERT( FLOAT, CRO.C3mol )                                                             AS C3,
		CONVERT( FLOAT, CRO.IC4mol )                                                            AS IC4,
		CONVERT( FLOAT, CRO.NC4mol )                                                            AS NC4,
		CONVERT( FLOAT, CRO.IC5mol )                                                            AS IC5,
		CONVERT( FLOAT, CRO.NC5mol )                                                            AS NC5,
		CONVERT( FLOAT, CRO.C6mol )                                                             AS C6,
		@pcC1                                                                                 AS pcC1, -- VALORES FIJOS
		@pcC2                            AS pcC2, -- VALORES FIJOS
		@pcC3                                                                               AS pcC3, -- VALORES FIJOS
		@pcC4                                                                               AS pcC4, -- VALORES FIJOS
		@pcIC4                                                                               AS pcIC4, -- VALORES FIJOS
		0.5 * ((@PC_iPentano + @PC_nPentano) / 2) + 0.3 * @PC_nHexano + 0.15 * @PC_nHeptano + 0.05 * @PC_nOctano       AS pcC5mas,
		((CONVERT( FLOAT, CRO.Presion_C1mol ) * @pcC1 ) + (CONVERT( FLOAT, CRO.C2mol ) * @pcC2)
		+ (CONVERT( FLOAT, CRO.C3mol ) * @pcC3) + (CONVERT( FLOAT, CRO.NC4mol ) * @pcC4)
		+ (CONVERT( FLOAT, CRO.IC4mol ) * @pcIC4)
		+ (CONVERT( FLOAT, CRO.IC5mol ) + CONVERT( FLOAT, CRO.NC5mol ) + CONVERT( FLOAT, CRO.C6mol ))
		* (0.5 * ((@PC_iPentano + @PC_nPentano) / 2) + 0.3 * @PC_nHexano + 0.15 * @PC_nHeptano + 0.05 * @PC_nOctano)) / 100  AS pcMezcla,
		(((CONVERT( FLOAT, CRO.Presion_C1mol ) * @pcC1) + (CONVERT( FLOAT, CRO.C2mol ) * @pcC2)
		+ (CONVERT( FLOAT, CRO.C3mol ) * @pcC3) + (CONVERT( FLOAT, CRO.NC4mol ) * @pcC4)
		+ (CONVERT( FLOAT, CRO.IC4mol ) * @pcIC4)
		+ (CONVERT( FLOAT, CRO.IC5mol ) + CONVERT( FLOAT, CRO.NC5mol ) + CONVERT( FLOAT, CRO.C6mol ))
		* (0.5 * ((@PC_iPentano + @PC_nPentano) / 2) + 0.3 * @PC_nHexano + 0.15 * @PC_nHeptano + 0.05 * @PC_nOctano)
		) / 100 ) * ((R8.CantidadFacturada / 1000) * (@Conversion60FaR / @Conversion20CaR))                AS Energia60F,
		CRO.Poder_CO2mol,
		CRO.Grav_H2Sppm,
		CRO.Temp_N2mol,
		COM.PorcC5
	FROM
		#Comercializaciones        COM
	JOIN
		dbo.FI_Factura             F	(NOLOCK)
		ON F.IdFactura              = COM.IdFactura
	JOIN
		dbo.FI_CFDIConcepto        FC	(NOLOCK)
		ON FC.IdFactura       = F.IdFactura
	JOIN
		COM_Equivalencias          E	(NOLOCK)
		ON FC.Unidad                = E.Unidad
	JOIN
		PC_PTI_V2  PTI			(NOLOCK)
		ON RTRIM( PTI.UUID )        = RTRIM( F.UUID )
	JOIN
		dbo.PC_Comercializacion_V2 R8	(NOLOCK)
		ON CONVERT(INT,PTI.Factura)              = CONVERT(INT,R8.Referencia1)
	JOIN
		dbo.CO_TipoCambioDiario    TCD	(NOLOCK)
		ON CONVERT(DATE,SUBSTRING(R8.FechaFactura,7,4)+SUBSTRING(R8.FechaFactura,4,2)+SUBSTRING(R8.FechaFactura,1,2),112) = TCD.Fecha
		AND F.IdMoneda     = TCD.IdMoneda
	JOIN
		PC_AnalisisCromatograficoGas	CRO	(NOLOCK)
		ON	--COM.IdContrato	=	CRO.IdContrato 		AND	
		COM.IdPtoExpedicionRecepcion	=	CRO.IdPtoExpedicionRecepcion
		AND	CONVERT(INT,SUBSTRING(R8.FechaFactura,7,4))	=	DATEPART(YEAR,CRO.MesReporte)
		AND	CONVERT(INT,SUBSTRING(R8.FechaFactura,4,2))	=	DATEPART(MONTH,CRO.MesReporte)
		AND CONVERT(INT,SUBSTRING(R8.FechaFactura,1,2)) = CRO.Dia
	WHERE
		( R8.factura LIKE '92%'  OR   R8.Factura LIKE '93%'  )
		AND (R8.Denominación LIKE '%gas %')
		AND R8.CantidadFacturada > 0

	SELECT @NumError = @@ERROR
	IF @NumError <> 0
	BEGIN
		SELECT @MensajeError = 'Error al insertar en #PreciosGas'+
		'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
		'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
		GOTO ERROR
	END	-- IF @NumError <> 0

INSERT INTO #PreciosGas2
(
    IdContrato,
    MesReporte,
    FechaTransaccion,
    MMBTUC1FacturadosBloqueEntero,
    MMBTUC2FacturadosBloqueEntero,
    MMBTUC3FacturadosBloqueEntero,
    MMBTUC4FacturadosBloqueEntero,
	MMBTUC5FacturadosBloqueEntero,
    PrecioVentaUnitario,
    CostoUnitarioComercializacion,
    PrecioPuntoMedicion,
    IdFactura,
    Activo,
    --PVUAnterior,
    --PPMAnterior,
    Divisor,
    FechaTimbrado,
    FechaFactura,
    PuntoVenta,
    MPC,
    MMPC,
    MMPC60F,
    Ingreso,
    C1,
    C2,
    C3,
    IC4,
    NC4,
    IC5,
    NC5,
    C6,
    pcC1,
    pcC2,
    pcC3,
    pcC4,
    pcIC4,
    pcC5mas,
    pcMezcla,
    Energia60F,
	CO2	,
	H2S	,
	N2	,
	PorcC5,
    VolC1,
    VolC2,
    VolC3,
    VolC4,
    VolNC4,
    VolC5,
    EnerC1,
    EnerC2,
    EnerC3,
    EnerC4,
    EnerIC4,
    EnerC5,
    Total
)
SELECT
    PG.*,
    PG.C1 * PG.MMPC60F / 100                                               AS VolC1,
    PG.C2 * PG.MMPC60F / 100                                               AS VolC2,
    PG.C3 * PG.MMPC60F / 100                                               AS VolC3,
    PG.IC4 * PG.MMPC60F / 100                                              AS VolC4,
    PG.NC4 * PG.MMPC60F / 100                                              AS VolNC4,
    (PG.IC5 + PG.NC5 + PG.C6) * PG.MMPC60F / 100                           AS VolC5,
    (PG.C1 * PG.MMPC60F / 100) * pcC1                                      AS EnerC1,
    (PG.C2 * PG.MMPC60F / 100) * pcC2                                      AS EnerC2,
    (PG.C3 * PG.MMPC60F / 100) * pcC3     AS EnerC3,
    (PG.NC4 * PG.MMPC60F / 100) * pcC4                                     AS EnerC4,
    (PG.IC4 * PG.MMPC60F / 100) * pcIC4                                    AS EnerIC4,
    ((PG.IC5 + PG.NC5 + PG.C6) * PG.MMPC60F / 100) * pcC5mas               AS EnerC5,
    ((PG.C1 * PG.MMPC60F / 100) * pcC1) * pcC1 + ((PG.C2 * PG.MMPC60F / 100) * pcC2) * pcC2
    + ((PG.C3 * PG.MMPC60F / 100) * pcC3) * pcC3 + ((PG.NC4 * PG.MMPC60F / 100) * pcC4) * pcC4
    + ((PG.IC4 * PG.MMPC60F / 100) * pcIC4) * pcIC4
    + (((PG.IC5 + PG.NC5 + PG.C6) * PG.MMPC60F / 100) * pcC5mas) * pcC5mas AS Total
FROM
    #PreciosGas PG
ORDER BY
    PG.PuntoVenta,
    PG.FechaTimbrado

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #PreciosGas2'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

INSERT INTO #SumEner
(
	SUMEnerC1,
	SUMEnerC2,
	SUMEnerC3,
	SUMEnerC4,
	SUMEnerIC4,
	SUMEnerC5
)
SELECT
	SUM(EnerC1)	AS SUMEnerC1,
	SUM(EnerC2)		AS SUMEnerC2,
	SUM(EnerC3)		AS SUMEnerC3,
	SUM(EnerC4)		AS SUMEnerC4,
	SUM(EnerIC4)	AS SUMenerIC4,
	SUM(EnerC5)		AS SUMEnerC5
FROM
	#PreciosGas2

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en ##SumEner'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

INSERT INTO #CalculoPreciosObjetivo
(
	IdFactura,
	FechaTransaccion,
	MMBTUC5FacturadosBloqueEntero,
	BLC5Facturados,
    PrecioXEnerC1,
    PrecioXEnerC2,
    PrecioXEnerC3,
    PrecioXEnerC4,
    IngresoC1C4,
    IngresoC5,
    PropPrecioXEnerC1,
    PropPrecioXEnerC2,
    PropPrecioXEnerC3,
    PropPrecioXEnerC4,
    Q5,
    LCIdeal,
    Zmes,
    [LC_C5+],
    [VolBIC5+],
    PrecioEquivCondensado,
	VolumenDistribucion,
	PorcC5
)
SELECT
	IdFactura,
	FechaTransaccion,
	MMBTUC5FacturadosBloqueEntero,
	((MMBTUC5FacturadosBloqueEntero / 1000) * (@Conversion60FaR / @Conversion20CaR)) * 1000 * ((((IC5+NC5+C6)/100*1000) * (1/CONVERT(FLOAT,25.32)) * (14.696 / 14.696)) / 
	(1- POWER(((C1/100)*0.0116) + ((C2/100)*0.0238) + ((C3/100)*0.0347) + ((NC4/100)*0.047) + ((IC4/100)*0.0441) + (((IC5+NC5+C6)/100)*0.072735) + ((CO2/100)*0.0195) + ((H2S/100)*0.0239) + ((N2/100)*0.00442) ,2)* 14.696)) / 42.00	AS [BLVTASASIG],
	EnerC1 * (pcC1 / Total * Ingreso)	AS [PrecioXEnerC1],
	EnerC2 * (pcC2 / Total * Ingreso )	AS [PrecioXEnerC2],
	EnerC3 * (pcC3 / Total * Ingreso) AS [PrecioXEnerC3],
	((EnerC4+EnerIc4) * (((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4 / Total * Ingreso * IC4)) / (NC4 + IC4))) AS [PrecioXEnerC4],
	(EnerC1 * (pcC1 / Total * Ingreso)) + (EnerC2 * (pcC2 / Total * Ingreso )) +
		(EnerC3 * (pcC3 / Total * Ingreso)) + ((EnerC4+EnerIc4) * (((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4 / Total * Ingreso * IC4)) / (NC4 + IC4)))	AS [IngresoC1C4],
	Ingreso - ((EnerC1 * (pcC1 / Total * Ingreso)) + (EnerC2 * (pcC2 / Total * Ingreso )) +
		(EnerC3 * (pcC3 / Total * Ingreso)) + ((EnerC4+EnerIc4) * (((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4 / Total * Ingreso * IC4)) / (NC4 + IC4)))) AS [IngresoC5],
	(EnerC1 * (pcC1 / Total * Ingreso)) / SUMEnerC1	AS [PropPrecioXEnerC1],
	(EnerC2 * (pcC2 / Total * Ingreso )) / SUMEnerC2 AS [PropPrecioXEnerC2],
	(EnerC3 * (pcC3 / Total * Ingreso)) / SUMEnerC3 AS [PropPrecioXEnerC3],
	((EnerC4+EnerIc4) * (((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4 / Total * Ingreso * IC4)) / (NC4 + IC4))) / (SUMEnerC4 + SUMenerIC4) AS [PropPrecioXEnerC4],
	(IC5+NC5+C6) AS [Q5],
	((IC5+NC5+C6)/100*1000) * (1/CONVERT(FLOAT,25.32)) * (14.696 / 14.696) AS [LCIdeal],
	1- POWER( ((C1/100)*0.0116) + ((C2/100)*0.0238) + ((C3/100)*0.0347) + ((NC4/100)*0.047) + ((IC4/100)*0.0441) + (((IC5+NC5+C6)/100)*0.072735) + ((CO2/100)*0.0195) + ((H2S/100)*0.0239) + ((N2/100)*0.00442) ,2) * 14.696 AS [ZMes],
	(((IC5+NC5+C6)/100*1000) * (1/CONVERT(FLOAT,25.32)) * (14.696 / 14.696)) / 
	(1- POWER(((C1/100)*0.0116) + ((C2/100)*0.0238) + ((C3/100)*0.0347) + ((NC4/100)*0.047) + ((IC4/100)*0.0441) + (((IC5+NC5+C6)/100)*0.072735) + ((CO2/100)*0.0195) + ((H2S/100)*0.0239) + ((N2/100)*0.00442),2)* 14.696) AS [LC_C5+],
--volumen en barriles de condensado
	MMPC60F * 1000 * ((((IC5+NC5+C6)/100*1000) * (1/CONVERT(FLOAT,25.32)) * (14.696 / 14.696)) / 
	(1- POWER(((C1/100)*CONVERT(FLOAT,0.0116)) + ((C2/100)*CONVERT(FLOAT,0.0238)) + ((C3/100)*CONVERT(FLOAT,0.0347)) + ((NC4/100)*CONVERT(FLOAT,0.047)) + ((IC4/100)*CONVERT(FLOAT,0.0441)) + (((IC5+NC5+C6)/100)*CONVERT(FLOAT,0.072735)) + ((CO2/100)*CONVERT(FLOAT,0.0195)) + ((H2S/100)*CONVERT(FLOAT,0.0239)) + ((N2/100)*CONVERT(FLOAT,0.00442)) ,2)* CONVERT(FLOAT,14.696))) / CONVERT(FLOAT,42.00) AS [VolBIC5+],
	(Ingreso - ((EnerC1 * (pcC1 / Total * Ingreso)) + (EnerC2 * (pcC2 / Total * Ingreso )) +
	(EnerC3 * (pcC3 / Total * Ingreso)) + ((EnerC4+EnerIC4) *(((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4/Total * Ingreso * IC4)) / (NC4 + IC4))))) / 
	(MMPC60F * 1000 * ((((IC5+NC5+C6)/100*1000) * (1/CONVERT(FLOAT,25.32)) * (14.696 / 14.696)) / 
	(1- POWER(((C1/100)*0.0116) + ((C2/100)*0.0238) + ((C3/100)*0.0347) + ((NC4/100)*0.047) + ((IC4/100)*0.0441) + (((IC5+NC5+C6)/100)*0.072735) + ((CO2/100)*0.0195) + ((H2S/100)*0.0239) + ((N2/100)*0.00442) ,2)* 14.696))/ 42.00),
	0,
	PorcC5
FROM
	#PreciosGas2
CROSS JOIN #SumEner

INSERT INTO #PrecioObjetivo
(
	PrecioC1_USD_MMBTU,
	PrecioC2_USD_MMBTU,
	PrecioC3_USD_MMBTU,
	PrecioC4_USD_MMBTU,
	PrecioEquivCondensado
)
SELECT
	SUM(PropPrecioXEnerC1),
	SUM(PropPrecioXEnerC2),
	SUM(PropPrecioXEnerC3),
	SUM(PropPrecioXEnerC4),
	SUM(IngresoC5)/SUM([VolBIC5+])
FROM
	#CalculoPreciosObjetivo

IF @Debug = 1
BEGIN
	SELECT
		*,
		pcC1 / Total * Ingreso                                                               AS PrecioC1,
		pcC2 / Total * Ingreso              AS PrecioC2,
		pcC3 / Total * Ingreso   AS PrecioC3,
		((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4 / Total * Ingreso * IC4)) / (NC4 + IC4) AS PrecioC4,
		EnerC1 * (pcC1 / Total * Ingreso)	AS [PrecioXEnerC1],
		EnerC2 * (pcC2 / Total * Ingreso )	AS [PrecioXEnerC2],
		EnerC3 * (pcC3 / Total * Ingreso) AS [PrecioXEnerC3],
		EnerC4 * (((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4 / Total * Ingreso * IC4)) / (NC4 + IC4)) AS [PrecioXEnerC4],
		(EnerC1 * (pcC1 / Total * Ingreso)) / SUMEnerC1	AS [PropPrecioXEnerC1],
		(EnerC2 * (pcC2 / Total * Ingreso )) / SUMEnerC2 AS [PropPrecioXEnerC2],
		(EnerC3 * (pcC3 / Total * Ingreso)) / SUMEnerC3 AS [PropPrecioXEnerC3],
		(EnerC4 * (((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4 / Total * Ingreso * IC4)) / (NC4 + IC4))) / SUMEnerC4 AS [PropPrecioXEnerC4],
		'PG2'
	FROM
		#PreciosGas2
	CROSS JOIN #SumEner

	SELECT	* FROM #PrecioObjetivo
	SELECT 'barriles c5'
	SELECT pti.Factura,com.Nombre1, c.*, (c.PorcC5 * [VolBIC5+]) AS Distribucion 
	FROM #CalculoPreciosObjetivo c
	JOIN dbo.FI_Factura f
		ON c.IdFactura = f.IdFactura
	JOIN PC_PTI_V2 pti
		ON f.uuid = pti.UUID
	JOIN dbo.PC_Comercializacion_V2	com
		ON pti.Factura = com.Referencia1
	JOIN #preciosgas2 pg
		ON	c.IdFactura = pg.IdFactura
	WHERE com.CantidadFacturada > 0
	SELECT SUM([VolBIC5+]) AS [TotalBarrilesC5+], @VolC5 AS [VolTopeC5] FROM #CalculoPreciosObjetivo
END

SELECT @sumtotal = SUM([VolBIC5+])
FROM #CalculoPreciosObjetivo

UPDATE #CalculoPreciosObjetivo
	SET	VolumenDistribucion	= 	[VolBIC5+] * PorcC5

--Sumatoria del volumen de condensado
SELECT
    @sumaC5 = SUM( VolumenDistribucion )
FROM
    #CalculoPreciosObjetivo

--Porcentaje Proporcional 
UPDATE    #CalculoPreciosObjetivo
    SET    Porcentaje = CASE WHEN @VolC5 = 0 THEN 0
							ELSE VolumenDistribucion / (@sumaC5)
						END 

--Calculo del volumen de condensado a vender basado en reparticion preliminar
SELECT
    @distribuciontotalC5 = CASE
								WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C5 % 2 = 1
								THEN (C5 * @PorcPemex) + 0.5
								WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND C5 % 2 = 0
								THEN C5 * @PorcPemex
								WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex <> 0.5
								THEN C5 * @PorcPemex
							ELSE	C5
						END
FROM
    PC_Volumenes
WHERE
    IdContrato = @IdContrato
    AND Mes     = @MesReporte


UPDATE #CalculoPreciosObjetivo
	SET	VolumenDistribucion	= CASE WHEN @distribuciontotalC5 > @sumaC5
									THEN	VolumenDistribucion
								ELSE	VolumenDistribucion * Porcentaje
							END

SELECT
    @sumaC5 = SUM( VolumenDistribucion )
FROM
    #CalculoPreciosObjetivo

UPDATE	#CalculoPreciosObjetivo
	SET Porcentaje = @VolC5 / @sumtotal 

-- SE CALCULA EL VOLUMEN REDONDEADO A ENTERO
UPDATE #CalculoPreciosObjetivo
	SET VolumenDistribucion = ROUND([VolBIC5+] * Porcentaje,0)

-- SE VALIDA SI EXISTEN DIFERENCIAS CON EL VOLUMEN PARA REALIZAR LOS AJUSTES
SELECT @TotalDistribuido	=	SUM(VolumenDistribucion)
FROM #CalculoPreciosObjetivo

IF ROUND(@VolC5,0) <> @TotalDistribuido
BEGIN
	INSERT INTO #AjustesTotalc5
	(
		IdFactura,
		IdAjuste,
		VolumenVendido,
		Ajuste
	)
	SELECT
		IdFactura,
		ROW_NUMBER() OVER (ORDER BY VolumenDistribucion DESC) AS IdAjuste,
		VolumenDistribucion,
		ROUND(@VolC5,0) - @TotalDistribuido
	FROM
		#CalculoPreciosObjetivo

	UPDATE    C
    SET  VolumenDistribucion = CASE	WHEN A.IdAjuste <= A.Ajuste THEN C.VolumenDistribucion + 1
								ELSE C.VolumenDistribucion
                          END
	FROM
		#CalculoPreciosObjetivo C
	JOIN
		#AjustesTotalc5       A
		ON C.IdFactura                = A.Idfactura


	-- SE REALIZA EL AJUSTE NEGATIVO A LOS VOLUMENES
	UPDATE    C
		SET
			 VolumenDistribucion = CASE	WHEN A.IdAjuste <= ABS(A.Ajuste) AND A.Ajuste < 0 THEN	C.VolumenDistribucion -1
									ELSE C.VolumenDistribucion
							END
	FROM
		#CalculoPreciosObjetivo C
	JOIN
		#AjustesTotalc5       A
		ON C.IdFactura                = A.Idfactura
	WHERE
		A.Ajuste < 0

END

IF @Debug = 1
BEGIN
	SELECT *
	FROM #CalculoPreciosObjetivo
END

-- YA QUE SE TIENEN LOS PRECIOS OBJETIVOS SE AJUSTA EL PRECIO DE VENTA UNITARIO PARA CADA COMERCIALIZACION
-- SE REUTILIZA LA TABLA #SumEner PARA GUARDAR EL FACTOR DE PRECIO PONDERADO
DELETE FROM #SumEner
-- SE REUTILIZAN LAS VARIABLES @SumC1, @SumC2, @SumC3, @SumC4 PARA GUARDAR LOS PRECIO OBJETIVOS
SELECT @SumC1 = 0, @SumC2 = 0, @SumC3 = 0, @SumC4 = 0, @SumC5 = 0
SELECT
	@SumC1 = ROUND(PrecioC1_USD_MMBTU,4),
	@SumC2 = ROUND(PrecioC2_USD_MMBTU,4),
	@SumC3 = ROUND(PrecioC3_USD_MMBTU,4),
	@SumC4 = ROUND(PrecioC4_USD_MMBTU,4),
	@SumC5 = ROUND(PrecioEquivCondensado,4)
FROM
	#PrecioObjetivo

SELECT
	@VolTotalC5	=	SUM(VolumenDistribucion)
FROM
	#CalculoPreciosObjetivo

IF @VolC5 = 0
BEGIN
	INSERT INTO #SumEner
	(
		SUMEnerC1,	--FactorC1
		SUMEnerC2,	-- FactorC2
		SUMEnerC3,	--FactorC3
		SUMEnerC4,	--FactorC4
		SUMEnerC5	--Factorc5
	)
	SELECT
		((((@SumC1 - SUM(((CONVERT(FLOAT,MMBTUC1FacturadosBloqueEntero) * ((pcC1/Total * Ingreso)))/@VolTotalC1))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC1FacturadosBloqueEntero) * ((pcC1/Total * Ingreso)))/@VolTotalC1))/100)),
		((((@SumC2 - SUM(((CONVERT(FLOAT,MMBTUC2FacturadosBloqueEntero) * ((pcC2/Total * Ingreso)))/@VolTotalC2))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC2FacturadosBloqueEntero) * ((pcC2/Total * Ingreso)))/@VolTotalC2))/100)),
		((((@SumC3 - SUM(((CONVERT(FLOAT,MMBTUC3FacturadosBloqueEntero) * ((pcC3/Total * Ingreso)))/@VolTotalC3))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC3FacturadosBloqueEntero) * ((pcC3/Total * Ingreso)))/@VolTotalC3))/100)),
		((((@SumC4 - SUM(((CONVERT(FLOAT,MMBTUC4FacturadosBloqueEntero) * ((pcC4/Total * Ingreso)))/@VolTotalC4))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC4FacturadosBloqueEntero) * ((pcC4/Total * Ingreso)))/@VolTotalC4))/100)),
		0
	FROM
		 #PreciosGas2	P

	SELECT
		@SumEnerC5	=	0

END
ELSE
BEGIN
	INSERT INTO #SumEner
	(
		SUMEnerC1,	--FactorC1
		SUMEnerC2,	-- FactorC2
		SUMEnerC3,	--FactorC3
		SUMEnerC4,	--FactorC4
		SUMEnerC5	--Factorc5
	)
	SELECT
		((((@SumC1 - SUM(((CONVERT(FLOAT,MMBTUC1FacturadosBloqueEntero) * ((pcC1/Total * Ingreso)))/@VolTotalC1))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC1FacturadosBloqueEntero) * ((pcC1/Total * Ingreso)))/@VolTotalC1))/100)),
		((((@SumC2 - SUM(((CONVERT(FLOAT,MMBTUC2FacturadosBloqueEntero) * ((pcC2/Total * Ingreso)))/@VolTotalC2))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC2FacturadosBloqueEntero) * ((pcC2/Total * Ingreso)))/@VolTotalC2))/100)),
		((((@SumC3 - SUM(((CONVERT(FLOAT,MMBTUC3FacturadosBloqueEntero) * ((pcC3/Total * Ingreso)))/@VolTotalC3))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC3FacturadosBloqueEntero) * ((pcC3/Total * Ingreso)))/@VolTotalC3))/100)),
		((((@SumC4 - SUM(((CONVERT(FLOAT,MMBTUC4FacturadosBloqueEntero) * ((pcC4/Total * Ingreso)))/@VolTotalC4))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC4FacturadosBloqueEntero) * ((pcC4/Total * Ingreso)))/@VolTotalC4))/100)),
		((((@SumC5 - SUM(((MMBTUC5FacturadosBloqueEntero * ((pcC5mas/Total * Ingreso)))/@VolTotalC5))) * 100)/SUM(((MMBTUC5FacturadosBloqueEntero * ((pcC5mas/Total * Ingreso)))/@VolTotalC5))/100))
	FROM
		 #PreciosGas2	P

	SELECT
		@SumEnerC5	=	((((@SumC5 - SUM(((P.VolumenDistribucion * ((PG.pcC5mas/PG.Total * PG.Ingreso)))/@VolTotalC5))) * 100)/SUM(((P.VolumenDistribucion * ((PG.pcC5mas/PG.Total * PG.Ingreso)))/@VolTotalC5))/100))
	FROM
		 #CalculoPreciosObjetivo	P
	JOIN
		#PreciosGas2	PG
		ON	P.IdFactura	=	PG.IdFactura
	WHERE
		P.VolumenDistribucion > 0
END

UPDATE	P
	SET FactorVolumenC1 = CONVERT(FLOAT,MMBTUC1FacturadosBloqueEntero)/CONVERT(FLOAT,@VolTotalC1),
		FactorVolumenC2 = CONVERT(FLOAT,MMBTUC2FacturadosBloqueEntero)/CONVERT(FLOAT,@VolTotalC2),
		FactorVolumenC3 = CONVERT(FLOAT,MMBTUC3FacturadosBloqueEntero)/CONVERT(FLOAT,@VolTotalC3),
		FactorVolumenC4 = CONVERT(FLOAT,MMBTUC4FacturadosBloqueEntero)/CONVERT(FLOAT,@VolTotalC4),
		FactorVolumenC5 = CASE WHEN @VolC5 = 0 THEN 0
							ELSE CONVERT(FLOAT,MMBTUC5FacturadosBloqueEntero)/CONVERT(FLOAT,@VolTotalC5)
						END
FROM
		#PreciosGas2	P
	--CROSS JOIN #VolTotal	VT

UPDATE #CalculoPreciosObjetivo
	SET FactorVolumenC5	=	CASE WHEN @VolC5 = 0 THEN 0
							ELSE VolumenDistribucion/@VolTotalC5
							END

UPDATE	P
	SET FactorVolumenPrecioC1 = CONVERT(FLOAT,SE.SUMEnerC1 * FactorVolumenC1),
		FactorVolumenPrecioC2 = CONVERT(FLOAT,SE.SUMEnerC2 * FactorVolumenC2),
		FactorVolumenPrecioC3 = CONVERT(FLOAT,SE.SUMEnerC3 * FactorVolumenC3),
		FactorVolumenPrecioC4 = CONVERT(FLOAT,SE.SUMEnerC4 * FactorVolumenC4),
		FactorVolumenPrecioC5 = CONVERT(FLOAT,SE.SUMEnerC5 * FactorVolumenC5)
FROM
		#PreciosGas2	P
	--CROSS JOIN
	--	#CostoUnitarioComercializacion		Tipo
	CROSS JOIN #SumEner	SE

UPDATE CPO
	SET FactorVolumenPrecioC5	=	CONVERT(FLOAT,@SumEnerC5 * FactorVolumenC5)
FROM
	#CalculoPreciosObjetivo	CPO


UPDATE	P
	SET DescuentoPrecioBalanceoC1 = CASE WHEN FactorVolumenC1 = 0 THEN 0
									ELSE FactorVolumenPrecioC1 * ((pcC1/Total*Ingreso)/FactorVolumenC1)
									END,
		DescuentoPrecioBalanceoC2 = CASE WHEN FactorVolumenC2 = 0 THEN 0
									ELSE FactorVolumenPrecioC2 * ((pcC2/Total*Ingreso)/FactorVolumenC2)
									END, 
		DescuentoPrecioBalanceoC3 = CASE WHEN FactorVolumenC3 = 0 THEN 0 
									ELSE FactorVolumenPrecioC3 * ((pcC3/Total*Ingreso)/FactorVolumenC3)
									END,
		DescuentoPrecioBalanceoC4 = CASE WHEN FactorVolumenC4 = 0 THEN 0
									ELSE FactorVolumenPrecioC4 * ((pcC4/Total*Ingreso)/FactorVolumenC4)
									END,
		DescuentoPrecioBalanceoC5 = CASE WHEN @VolC5 = 0 THEN 0
									WHEN FactorVolumenC5 = 0
										THEN 0
									ELSE FactorVolumenPrecioC5 * ((pcC5mas/Total*Ingreso)/FactorVolumenC5)
									END
FROM
		#PreciosGas2	P
--WHERE
--	 FactorVolumenC5 > 0
	--CROSS JOIN
	--	#CostoUnitarioComercializacion		Tipo

UPDATE CPO
	SET DescuentoPrecioBalanceoC5	=	CASE WHEN @VolC5 = 0 THEN 0
										WHEN CPO.FactorVolumenC5 = 0	THEN 0
										ELSE CPO.FactorVolumenPrecioC5 * ((P.pcC5mas/P.Total*P.Ingreso)/CPO.FactorVolumenC5)
										END
FROM
	#CalculoPreciosObjetivo	CPO
JOIN
	#PreciosGas2	P
	ON	CPO.IdFactura	=	P.IdFactura

-- SE VALIDA SI EL REPORTE GENERADO ES DEL MES ANTERIOR, EN CUYO CASO SE BORRA LA INFORMACIÓN, SI ES MAS ANTIGUO SOLO SE MUESTRA LA INFORMACION YA GENERADA
IF @FechaLimite >= GETDATE()
BEGIN
	IF @Debug = 1
	BEGIN
		SELECT DISTINCT 
			IdContrato,
			MesReporte,
			FechaTransaccion,
			Tipo.IdTipoHidrocarburo, --    IdTipoHidrocarburo     10002: Metano      10003: Etano       10004: Propano  10005: Butano
			CASE
				WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	MMBTUC1FacturadosBloqueEntero
				WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	MMBTUC2FacturadosBloqueEntero
				WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	MMBTUC3FacturadosBloqueEntero
				WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	MMBTUC4FacturadosBloqueEntero
			END							AS VolumenVendido,
			CASE
				WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	((pcC1/Total*Ingreso) + DescuentoPrecioBalanceoC1) + Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	((pcC2/Total*Ingreso) + DescuentoPrecioBalanceoC2) + Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	((pcC3/Total*Ingreso) + DescuentoPrecioBalanceoC3) + Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	((pcC4/Total*Ingreso) + DescuentoPrecioBalanceoC4) + Tipo.CostoUnitarioComercializacion
			END		AS PrecioVentaUnitario,
			Tipo.CostoUnitarioComercializacion,
			CASE
				WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	((pcC1/Total*Ingreso) + DescuentoPrecioBalanceoC1) - Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	((pcC2/Total*Ingreso) + DescuentoPrecioBalanceoC2) - Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	((pcC3/Total*Ingreso) + DescuentoPrecioBalanceoC3) - Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	((pcC4/Total*Ingreso) + DescuentoPrecioBalanceoC4) - Tipo.CostoUnitarioComercializacion
			END							AS	PrecioPuntoMedicion,
			IdFactura,
			Activo
		FROM
			#PreciosGas2	P
		CROSS JOIN
			#CostoUnitarioComercializacion		Tipo
		CROSS JOIN
			#SumEner	F
		WHERE
			( MMBTUC1FacturadosBloqueEntero > 0 OR MMBTUC2FacturadosBloqueEntero > 0 OR MMBTUC3FacturadosBloqueEntero > 0 OR MMBTUC4FacturadosBloqueEntero > 0 )

		SELECT 'COMERCIALIZACIONES DE CONDENSABLE'
		SELECT DISTINCT
			@IdContrato	AS	IdContrato,
			@MesReporte	AS	MesReporte,
			CP.FechaTransaccion,
			CU.IdTipoHidrocarburo, --    IdTipoHidrocarburo     10002: Metano      10003: Etano       10004: Propano  10005: Butano
			CP.VolumenDistribucion							AS VolumenVendido,
			((P.pcC5mas/Total*Ingreso) + CP.DescuentoPrecioBalanceoC5) + CU.CostoUnitarioComercializacion		AS PrecioVentaUnitario,
			CU.CostoUnitarioComercializacion,
			((P.pcC5mas/Total*Ingreso) + CP.DescuentoPrecioBalanceoC5) - CU.CostoUnitarioComercializacion		AS	PrecioPuntoMedicion,
			CP.IdFactura
		FROM
			#CalculoPreciosObjetivo	CP
		JOIN
			#PreciosGas2	P
			ON	CP.IdFactura	=	P.IdFactura
		CROSS JOIN	dbo.COM_CostoUnitarioHidrocarburo	CU
		CROSS JOIN	#SumEner	F
		WHERE	CU.IdContrato	=	@IdContrato
			AND	CU.Mes	=	@MesReporte
			AND	CU.IdTipoHidrocarburo	=	10001	-- CONDENSADO
			AND CP.VolumenDistribucion > 0
	END
	ELSE
	BEGIN

		DELETE FROM COM_PreciosObjetivosHidroCarburos
		WHERE
			IdContrato      = @IdContrato
			AND Mes         = @MesReporte
			AND IdTipoHidrocarburo BETWEEN	10001 AND 10005
			
		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al eliminar en COM_OperacionComercializacion'+
			'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
			'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
			GOTO ERROR
		END	-- IF @NumError <> 0

		INSERT INTO COM_PreciosObjetivosHidroCarburos
		(
			IdContrato,
			Mes,
			IdTipoHidrocarburo,
			PrecioUnitario,
			CreadoPor,
			CreadoEl
		)
		SELECT
			@IdContrato,
			@MesReporte,
			Tipo.IdTipoHidrocarburo,
		CASE
			WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	PrecioC1_USD_MMBTU
			WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	PrecioC2_USD_MMBTU
			WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	PrecioC3_USD_MMBTU
			WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	PrecioC4_USD_MMBTU
		END,
		@Usuario,
		GETDATE()
		FROM
			#PrecioObjetivo	P
		CROSS JOIN
			#CostoUnitarioComercializacion	Tipo

		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al eliminar en COM_OperacionComercializacion'+
			'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
			'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
			GOTO ERROR
		END	-- IF @NumError <> 0

		INSERT INTO COM_PreciosObjetivosHidroCarburos
		(
			IdContrato,
			Mes,
			IdTipoHidrocarburo,
			PrecioUnitario,
			CreadoPor,
			CreadoEl
		)
		SELECT
			@IdContrato,
			@MesReporte,
			10001,
			P.PrecioEquivCondensado,
			@Usuario,
			GETDATE()
		FROM
			#PrecioObjetivo	P
		

		DELETE OC
		FROM	COM_OperacionComercializacion	OC
		JOIN	dbo.FI_Factura	F
			ON	OC.IdFactura	=	F.IdFactura
		JOIN	dbo.FI_CFDIConcepto	C
			ON	F.IdFactura	=	C.IdFactura
		WHERE
			OC.IdContrato            = @IdContrato
			AND OC.MesReporte         = @MesReporte
			AND OC.IdTipoHidrocarburo BETWEEN	10001 AND 10005
			AND F.Receptor	<>	'PEP9207167XA'
			AND C.Descripcion LIKE '%GAS %'

		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al eliminar en COM_OperacionComercializacion'+
			'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
			'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
			GOTO ERROR
		END	-- IF @NumError <> 0

		INSERT INTO dbo.COM_OperacionComercializacion
		(
			IdContrato,
			MesReporte,
			FechaTransaccion,
			IdTipoHidrocarburo,
			VolumenVendido,
			PrecioVentaUnitario,
			CostoUnitarioComercializacion,
			PrecioPuntoMedicion,
			IdFactura,
			NumeroFolioPedimento,
			EPT,
			OperacionBajoReglasMercado,
			ClasificacionDocumentoSoporte,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl,
			Activo,
			PVUAnterior,
			PPMAnterior
		)
		SELECT DISTINCT
			IdContrato,
			MesReporte,
			FechaTransaccion,
			Tipo.IdTipoHidrocarburo, --    IdTipoHidrocarburo     10002: Metano      10003: Etano       10004: Propano  10005: Butano
			CASE
				WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	MMBTUC1FacturadosBloqueEntero
				WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	MMBTUC2FacturadosBloqueEntero
				WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	MMBTUC3FacturadosBloqueEntero
				WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	MMBTUC4FacturadosBloqueEntero
			END							AS VolumenVendido,
			CASE
				WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	((pcC1/Total*Ingreso) + DescuentoPrecioBalanceoC1) + Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	((pcC2/Total*Ingreso) + DescuentoPrecioBalanceoC2) + Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	((pcC3/Total*Ingreso) + DescuentoPrecioBalanceoC3) + Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	((pcC4/Total*Ingreso) + DescuentoPrecioBalanceoC4) + Tipo.CostoUnitarioComercializacion
			END							AS PrecioVentaUnitario,
			Tipo.CostoUnitarioComercializacion,
			CASE
				WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	((pcC1/Total*Ingreso) + DescuentoPrecioBalanceoC1) - Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	((pcC2/Total*Ingreso) + DescuentoPrecioBalanceoC2) - Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	((pcC3/Total*Ingreso) + DescuentoPrecioBalanceoC3) - Tipo.CostoUnitarioComercializacion
				WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	((pcC4/Total*Ingreso) + DescuentoPrecioBalanceoC4) - Tipo.CostoUnitarioComercializacion
			END							AS PrecioPuntoMedicion,
			IdFactura,
			'000000000000000'                         AS NumeroFolioPedimento, --NumeroFolioPedimento
			1                                         AS EPT, --EPT
			1                                         AS OperacionBajoReglasMercado, --OperacionBajoReglasMercado
			2                                         AS ClasificacionDocumentoSoporte, --ClasificacionDocumentoSoporte
			@Usuario,
			GETDATE(),
			NULL,
			NULL,
			Activo,
			0,	--PVUAnterior,
			0	--PPMAnterior
		FROM
			#PreciosGas2	P
		CROSS JOIN
			#CostoUnitarioComercializacion		Tipo
		CROSS JOIN
			#SumEner	F
		WHERE
		( MMBTUC1FacturadosBloqueEntero > 0 OR MMBTUC2FacturadosBloqueEntero > 0 OR MMBTUC3FacturadosBloqueEntero > 0 OR MMBTUC4FacturadosBloqueEntero > 0 )

		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al insertar en COM_OperacionComercializacion'+
			'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
			'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
			GOTO ERROR
		END	-- IF @NumError <> 0

	-- CONDENSADO

		INSERT INTO dbo.COM_OperacionComercializacion
		(
			IdContrato,
			MesReporte,
			FechaTransaccion,
			IdTipoHidrocarburo,
			VolumenVendido,
			PrecioVentaUnitario,
			CostoUnitarioComercializacion,
			PrecioPuntoMedicion,
			IdFactura,
			NumeroFolioPedimento,
			EPT,
			OperacionBajoReglasMercado,
			ClasificacionDocumentoSoporte,
			CreadoPor,
			CreadoEl,
			ModificadoPor,
			ModificadoEl,
			Activo,
			PVUAnterior,
			PPMAnterior
		)
		SELECT DISTINCT
			@IdContrato	AS	IdContrato,
			@MesReporte	AS	MesReporte,
			CP.FechaTransaccion,
			CU.IdTipoHidrocarburo, --    IdTipoHidrocarburo     10002: Metano      10003: Etano       10004: Propano  10005: Butano
			CP.VolumenDistribucion							AS VolumenVendido,
			((P.pcC5mas/Total*Ingreso) + CP.DescuentoPrecioBalanceoC5) + CU.CostoUnitarioComercializacion		AS PrecioVentaUnitario,
			CU.CostoUnitarioComercializacion,
			((P.pcC5mas/Total*Ingreso) + CP.DescuentoPrecioBalanceoC5) - CU.CostoUnitarioComercializacion		AS	PrecioPuntoMedicion,
			CP.IdFactura,
			'000000000000000'                         AS NumeroFolioPedimento, --NumeroFolioPedimento
			1                                         AS EPT, --EPT
			1                                         AS OperacionBajoReglasMercado, --OperacionBajoReglasMercado
			2                                         AS ClasificacionDocumentoSoporte, --ClasificacionDocumentoSoporte
			@Usuario,
			GETDATE(),
			NULL,
			NULL,
			Activo,
			0,	--PVUAnterior,
			0	--PPMAnterior
		FROM
			#CalculoPreciosObjetivo	CP
		JOIN
			#PreciosGas2	P
			ON	CP.IdFactura	=	P.IdFactura
		CROSS JOIN	dbo.COM_CostoUnitarioHidrocarburo	CU
		CROSS JOIN	#SumEner	F
		WHERE	CU.IdContrato	=	@IdContrato
			AND	CU.Mes	=	@MesReporte
			AND	CU.IdTipoHidrocarburo	=	10001	-- CONDENSADO
			AND CP.VolumenDistribucion > 0

	END --IF @Debug = 1
END -- IF @FechaLimite >= GETDATE()

GOTO FIN
-- -----------------------------------------------------------------------------------------
ERROR:
-- -----------------------------------------------------------------------------------------
RAISERROR(@MensajeError, 16, 1)
SELECT	'false' AS msj
--RETURN 1	    -- Error
-- -----------------------------------------------------------------------------------------
FIN:
SELECT	'true' AS msj
--RETURN 0
END
