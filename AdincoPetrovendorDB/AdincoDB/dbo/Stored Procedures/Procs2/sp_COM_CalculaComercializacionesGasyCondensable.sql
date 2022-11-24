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

--IF @Debug = 1
--BEGIN
--	SELECT    'Energía del Area Contractual en los puntos de venta, Energia total de los puntos de venta, Factores'
--	SELECT
--		*,
--		EP.C1Punto / EP.CTotalPunto AS FC1,
--		EP.C2Punto / EP.CTotalPunto AS FC2,
--		EP.C3Punto / EP.CTotalPunto AS FC3,
--		EP.C4Punto / EP.CTotalPunto AS FC4,
--		EP.C5Punto / EP.CTotalPunto AS FC5
--	FROM
--		#Energias      E
--	JOIN
--		#EnergiasPunto EP
--		ON E.PuntoVenta = EP.PuntoVenta
--END

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
AND R8.Factura NOT IN ('92390553','92390550','92390705','92390556','92390546','92390693','92390681','92390669',
'92390809','92390548','92390905','92390929','92390565','92390856','92390881','92390544','92390559','92390568','92390562','92390582','92390586','92390574','92390588','92390576',
'92390545','92390584','92390598','92390580','92390590','92390670','92390572','92390600','92390596','92390602','92390592','92390594','92390547','92390906','92390554','92390706',
'92390834','92390694','92390549','92390682','92390566','92390557','92390569','92390857','92390563','92390560','92390810','92390577','92390585','92390571','92390587','92390589',
'92390575','92390573','92390581','92390601','92391072','92390591','92390595','92390599','92390597','92390417','92390409','92390387','92390371','92390379','92390402','92390395',
'92390431','92390355','92390438','92390304','92390363','92390289','92390446','92390296','92390334','92390320','92390341','92390453','92390460','92390282','92390495','92390468',
'92390481','92390502','92390979','92391043','92391001','92391023','92391064','92390868','92390821','92390961','92390893','92390917','92390941','92390677','92390713','92390701',
'92390657','92390689','92390916','92391000','92390867','92390978','92391042','92390960','92390844','92391022','92390892','92390940','92390833','92390714','92390702','92390781',
'92390792','92390803','92390826','92390873','92390898','92390850','92390922','92390946','92391006','92390982','92391069','92390658','92391070','92390827','92390851','92390793',
'92390804','92390983','92390965','92390690','92390947','92390874','92390261','92390247','92390253','92390274','92390242','92390269','92390578','92390279','92390923','92390899',
'92390570','92390930','92390426','92390396','92390388','92390410','92390328','92390283','92390403','92390882','92390482','92391045','92390418','92390342','92390349','92390551',
'92391066','92390313','92390447','92390469','92390439','92390503','92390372','92390321','92390364','92390335','92390305','92390511','92390380','92390496','92390432','92390297',
'92390783','92390794','92390805','92390828','92390875','92390900','92390852','92390924','92390579','92390823','92390984','92391003','92390966','92390907','92390883','92390858',
'92390931','92390847','92390973','92390991','92390895','92391013','92391033','92391054','92390605','92390607','92390593','92390963','92390603','92390611','92390625','92390615',
'92390613','92390617','92390583','92391048','92390270','92390870','92391007','92390943','92390425','92390327','92390348','92390312','92390517','92390510','92391055','92391034',
'92391014','92390259','92390251','92390267','92390272','92390277','92390275','92390812','92390992','92390836','92390845','92390974','92390822','92390846','92390869','92390918',
'92390894','92390909','92390885','92390860','92390837','92390933','92390254','92390962','92390957','92391044','92390980','92391024','92391065','92390975','92390993','92391015',
'92391035','92391056','92390908','92390262','92390932','92390884','92390800','92390789','92390762','92390770','92390778','92390754','92390746','92390688','92390819','92390730',
'92390738','92390866','92390891','92390915','92390700','92390712','92390722','92390939','92390843','92390656','92390676','92390859','92390632','92390640','92390648','92390666',
'92390473','92390999','92390486','92391021','92391041','92391062','92390280','92390956','92390248','92390820','92391063','92390608','92390621','92390243','92390614','92390626',
'92390606','92390678','92390610','92390273','92390268','92390964','92390278','92390260','92390618','92390782','92390534','92390535','92390532','92390536','92390541','92390537',
'92390533','92390538','92390526','92390529','92390530','92390542','92390528','92390525','92390527','92390523','92390540','92390543','92390539','92390524','92390644','92391058',
'92390959','92390784','92390628','92390814','92390725','92390662','92390683','92390635','92390695','92390773','92390995','92390707','92390671','92390741','92390838','92390765',
'92390757','92390627','92390672','92390651','92390733','92390717','92390976','92390708','92391036','92390934','92391057','92390796','92391016','92390652','92390643','92390958',
'92390886','92390861','92390910','92390977','92390935','92390887','92390684','92391017','92390774','92390766','92390415','92390696','92390911','92390862','92390604','92390742',
'92390466','92390310','92390377','92390290','92390750','92390461','92390531','92391025','92390636','92390356','92390518','92390726','92390454','92390753','92390493','92390745',
'92390948','92390737','92390729','92391071','92390797','92390786','92390759','92390767','92390775','92390751','92390743','92390685',
'92390816','92390735','92390863','92390888','92390912','92390840','92390697','92390709','92390653','92390936','92390673','92390629','92390637','92390645','92390663','92390470',
'92390996','92391038','92391018','92390811','92390835','92390955','92391040','92390761','92390609','92390711','92390620','92390777','92390699','92391061','92391020','92390639',
'92390842','92390631','92390721','92390369','92390675','92390818','92390508','92390423','92390444','92390361','92390665','92390485','92390849','92390788','92390472','92390318',
'92390998','92391005','92390655','92390938','92390981','92390815','92390919','92390825','92390914','92390890','92390865','92390490','92390748','92390477','92390294','92390817',
'92391068','92390756','92391027','92390839','92390740','92390339','92390780','92390732','92390802','92390414',
'92390791','92391019','92390872','92390451','92390945','92390692','92390680','92390764','92390841','92390724','92390768','92390392','92390360','92390752','92390465','92391039',
'92390997','92390704','92390728','92390668','92390660','92390646','92390484','92390787','92391060','92390744','92390736','92390317','92390698','92390864','92390798','92390309',
'92390760','92390813','92390942','92390638','92391002','92390686','92390937','92390889','92390325','92390522','92390720','92390492','92390471','92390422','92390507','92390913',
'92390710','92391047','92390664','92390921','92390674','92390630','92390407','92390384','92390654','92390801','92390790','92390763','92390771','92390779','92390755','92390747',
'92390691','92390824','92390731','92390739','92390871','92390896','92390920','92390703','92390715','92390723','92390944','92390848','92390659','92390679','92390633','92390641',
'92390649','92390667','92390476','92391004','92390489','92391026','92391046','92391067','92390332','92390772','92390832','92390808','92390368','92390612','92390880','92390928',
'92390904','92390716','92390500','92390400','92390421','92390413','92390391','92390399','92390406','92390383','92390375','92390331','92390359','92390367','92390442',
'92390450','92390457','92390338','92390345','92390352','92390464','92390435','92390308','92390324','92390286','92390293','92390300','92390316','92390478','92390499','92390491',
'92390458','92390506','92390514','92390521','92390616','92390301','92390252','92390376','92390642','92390436','92390353','92390795','92390661','92390346','92390758','92390785',
'92391037','92390734','92390718','92390429','92390727','92390719','92391059','92390769','92390419','92390411','92390389','92390397','92390404','92390381','92390373','92390329',
'92390427','92390357','92390365','92390440','92390448','92390455','92390336','92390343','92390350','92390462','92390433','92390306','92390322','92390284','92390291','92390298',
'92390314','92390474','92390497','92390487','92390504','92390512','92390519','92390393','92390302','92390799','92390515','92390323','92390647','92390330','92390366',
'92390449','92390344','92390441','92390315','92390405','92390475','92390434','92390420','92390520','92390456','92390382','92390390','92390488','92390412','92390428','92390897',
'92390287','92390374','92390498','92390358','92390285','92390351','92390463','92390505','92390292','92390307','92390337','92390299','92390855','92390634','92390443','92390479',
'92390749','92390994','92390483','92390687','92390385','92390776','92390398','92390513','92390650','92390954','92391032','92390972')

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #Comercializaciones'+
	'En el Stored Procedure: dbo.sp_COM_CalculaComercializacionesGas '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

IF @MesReporte = '20220201' AND @IdContrato = 10051
BEGIN
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
    CASE WHEN E.C4Entero = 0 THEN 1 END                   AS C4Obj,
    CASE WHEN E.C4Entero = 0 THEN 1 END - SUM( COM.MMBTUC4FacturadosBloqueEntero ) AS C4Ajuste,
	SUM( COM.MMBTUC5FacturadosBloqueEntero )              AS C5Com,
    CASE WHEN E.C5Entero = 0 THEN 1 END                   AS C5Obj,
    CASE WHEN E.C5Entero = 0 THEN 1 END - SUM( COM.MMBTUC5FacturadosBloqueEntero ) AS C5Ajuste
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
    CASE WHEN E.C4Entero = 0 THEN 1 END,
	CASE WHEN E.C5Entero = 0 THEN 1 END
END
ELSE
BEGIN
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
END
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


--IF @Debug = 1
--BEGIN
--	SELECT '#Comercializaciones'
--	SELECT    *
--	FROM	#Comercializaciones
--	ORDER BY IdFactura

--	SELECT * FROM #Ajustes
--END

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
		CONVERT( FLOAT, CRO.C6mol )                                   AS C6,
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
	(EnerC3 * (pcC3 / Total * Ingreso)) + ((EnerC4+EnerIC4) *(((((pcC4 / Total) * Ingreso) * NC4) + (pcIC4/Total * Ingreso * IC4)) / (NC4 + IC4))))) / 	(MMPC60F * 1000 * ((((IC5+NC5+C6)/100*1000) * (1/CONVERT(FLOAT,25.32)) * (14.696 / 14.696)) / 
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

IF @Debug = 1
BEGIN
SELECT 'ANTES CALCULOPRECIOSBJETIVOS'
	SELECT *, @TotalDistribuido AS '@TotalDistribuido', @VolC5 AS '@VolC5'
	FROM #CalculoPreciosObjetivo

END

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
SELECT 'CALCULOPRECIOSBJETIVOS'
	SELECT *
	FROM #CalculoPreciosObjetivo

	SELECT * FROM #AjustesTotalc5
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

IF @Debug = 1
BEGIN
SELECT 'ESTE'
	SELECT @SumC1 AS '@SumC1', @SumC2 AS '@SumC2', @SumC3, @SumC4, @SumC5 AS '@SumC5' , 
	*
	FROM
		 #PreciosGas2	P
END

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
		((((@SumC5 - SUM(((CONVERT(FLOAT,MMBTUC5FacturadosBloqueEntero) * ((pcC5mas/Total * Ingreso)))/@VolTotalC5))) * 100)/SUM(((CONVERT(FLOAT,MMBTUC5FacturadosBloqueEntero) * ((pcC5mas/Total * Ingreso)))/@VolTotalC5))/100))
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

IF @Debug = 1
BEGIN
SELECT '#SumEner'
SELECT * FROM #SumEner
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

IF @MesReporte IN ( '20211001', '20211101', '20211201', '20220101', '2022-04-01', '2022-05-01', '2022-06-01')
	SELECT @FechaLimite = '20221001 23:59'

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
				WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	((pcC1/Total*Ingreso) + DescuentoPrecioBalanceoC1) 
				WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	((pcC2/Total*Ingreso) + DescuentoPrecioBalanceoC2) 
				WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	((pcC3/Total*Ingreso) + DescuentoPrecioBalanceoC3) 
				WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	((pcC4/Total*Ingreso) + DescuentoPrecioBalanceoC4) 
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
			((P.pcC5mas/Total*Ingreso) + CP.DescuentoPrecioBalanceoC5) 		AS	PrecioPuntoMedicion,
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
				WHEN	Tipo.IdTipoHidrocarburo  = 10002	THEN	((pcC1/Total*Ingreso) + DescuentoPrecioBalanceoC1) 
				WHEN	Tipo.IdTipoHidrocarburo  = 10003	THEN	((pcC2/Total*Ingreso) + DescuentoPrecioBalanceoC2) 
				WHEN	Tipo.IdTipoHidrocarburo  = 10004	THEN	((pcC3/Total*Ingreso) + DescuentoPrecioBalanceoC3) 
				WHEN	Tipo.IdTipoHidrocarburo  = 10005	THEN	((pcC4/Total*Ingreso) + DescuentoPrecioBalanceoC4) 
			END							AS PrecioPuntoMedicion,
			IdFactura,
			'000000000000000'                         AS NumeroFolioPedimento, --NumeroFolioPedimento
			1                             AS EPT, --EPT
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
			((P.pcC5mas/Total*Ingreso) + CP.DescuentoPrecioBalanceoC5)		AS	PrecioPuntoMedicion,
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
