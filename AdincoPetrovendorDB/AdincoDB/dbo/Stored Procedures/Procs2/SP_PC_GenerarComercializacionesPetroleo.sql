CREATE PROCEDURE dbo.SP_PC_GenerarComercializacionesPetroleo
    @IdContrato INT,
    @MesReporte DATE,
	@Usuario	INT,
	@FechaLimite	DATETIME,
	@Debug		BIT
AS
BEGIN 
-- =============================================
-- Author:		Barbara Arrañaga
-- Create date: 2018-03-07
-- Description:	Proceso para realizar el calculo de las comercializaciones de Petroleo
-- Parametros de Entrada:	Numero de Contrato y Mes de Calculo
-- ----------------------------------------------------------------------------------
-- 20180507	BAAC	Se modifica para no borrar las comercializaciones que no sean de PEMEX
-- 20180530	BAAC	Se modifica para ajustar el volumen perdido por el redondeo
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #DistCrudo
(
	IdPtoExpedicionRecepcion	INT,
	IdMaterialPC				INT,
	VolumenBloque				FLOAT,
	Porcentaje					FLOAT,
	VolumenDistribucion			FLOAT,
	VolumenFacturado			FLOAT,
	FactorDistribucion			FLOAT
)

CREATE TABLE #PC_Facturas
(
	Factura	VARCHAR(510),
	UUID	VARCHAR(510)
)

CREATE TABLE #PC_FacturasCrudo
(
	IdFactura	int,
	IdPtoExpedicionRecepcion	int,
	IdMaterialPC	INT,
	cantidad	float,
	factor	float
)

CREATE TABLE #VolumenFacturado
(
    IdPtoExpedicionRecepcion INT,
    IdMaterialPC             INT,
    VolumenFacturado         FLOAT
)

CREATE TABLE #Comercializaciones
(
	FechaTransaccion	DATETIME,
	VolumenVendido		INT,
	PrecioVentaUnitario	MONEY,
	IdFactura		INT,
	VolumenVendido01	FLOAT,
	VolumenVendido02	FLOAT,
	Tarifa01	FLOAT,
	Tarifa02	FLOAT
)

CREATE TABLE #AjustesTotal
(
	IdFactura	INT,
	IdAjuste	INT,
	VolumenVendido	INT,
	Ajuste		INT
)

DECLARE
	@sumacrudo AS FLOAT,
	@distribuciontotalp FLOAT,
	@CostoUnitarioComercializacion MONEY,
	@NumError	INT,
	@MensajeError	VARCHAR(500),
	@FechaInicioContrato		DATE,
	@EsPC			BIT,
	@PorcPemex		FLOAT,
	@EsConsorcio	BIT,
	@TotalADistribuir	FLOAT,
	@TotalDistribuido	FLOAT,
	@VolumenTotalTarifas	FLOAT,
	@Prop01		FLOAT,
	@Prop02		FLOAT,
	@Tarifa01		FLOAT,
	@Tarifa02		FLOAT

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
SELECT @CostoUnitarioComercializacion = CostoUnitarioComercializacion
FROM	COM_CostoUnitarioHidrocarburo
WHERE
	IdContrato	=	@IdContrato
	AND	Mes		=	@MesReporte
	AND	IdTipoHidrocarburo	=	10000

IF(@CostoUnitarioComercializacion IS NULL) -- AND @IdContrato <> 10051)
BEGIN
    SELECT @MensajeError = 'No se encontro valor vigente para el Costo Unitario de Comercializacion'+CHAR(13)+'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo'
    GOTO ERROR
END
--================================================================================
--    Distribucion Volumetrica Crudo
--================================================================================
--Se seleccionan de la distribucion de ingresos los registros de los puntos de venta elegido, 
--pertenecientes a crudo, de los campos del contrato
INSERT INTO #DistCrudo
(
    IdPtoExpedicionRecepcion,
    IdMaterialPC,
    VolumenBloque,
    Porcentaje,
    VolumenDistribucion,
    VolumenFacturado,
    FactorDistribucion
)
SELECT
    PVP.IdPtoExpedicionRecepcion,
    DI.IdMaterialPC,
    SUM( DI.DistribucionVolumetrica ) AS VolumenBloque,
    CAST(0.0000 AS FLOAT)             AS Porcentaje,
    CAST(0.0000 AS FLOAT)             AS VolumenDistribucion,
    CAST(0.0000 AS FLOAT)             AS VolumenFacturado,
    CAST(0.0000 AS FLOAT)             AS FactorDistribucion
FROM
    PC_DistribucionIngresos DI
JOIN
    PC_ContratoCampo        CC
    ON CC.IdCampo                   = DI.IdCampo
JOIN
    PC_PuntoVentaProducto   PVP
    ON PVP.IdContrato               = CC.IdContrato
    AND PVP.IdPtoExpedicionRecepcion = DI.IdPtoExpedicionRecepcion
    AND PVP.IdMaterialPC             = DI.IdMaterialPC
WHERE
    PVP.Aplica                     = 1 --El punto de venta esta selccionado
    AND CC.IdContrato                                                                          = @IdContrato --Los campos ligados al contrato
    AND DI.IdMaterialPC IN ( 10000, 10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009,
            10010, 10016, 10019, 10020
                            ) -- Lista de productos que son crudo
    AND DATEFROMPARTS( SUBSTRING( DI.MesReporte, 7, 4 ), SUBSTRING( DI.MesReporte, 4, 2 ), 1 ) = @MesReporte
    AND PVP.Mes                                                                                = @MesReporte
GROUP BY
    PVP.IdPtoExpedicionRecepcion,
    DI.IdMaterialPC

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #DistCrudo'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0
--================================================================================		
--Sumatoria del volumen de crudo de los puntos de venta seleccionados en el paso anterior
--================================================================================
SELECT	@sumacrudo = SUM( VolumenBloque )
FROM
    #DistCrudo

IF @Debug = 1
	SELECT    @sumacrudo AS VolumenTotalCrudoDI ---comentar para web

IF(ISNULL(@sumacrudo,0) = 0)
BEGIN
    SELECT @MensajeError = 'No se encontro volumen de crudo en los puntos de venta'+CHAR(13)+'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo'
    GOTO ERROR
END

--Porcentaje Proporcional de cada volumen entre el total del contrato
UPDATE    #DistCrudo
    SET    Porcentaje = CONVERT( FLOAT, (VolumenBloque / (@sumacrudo)))


IF @Debug = 1
	SELECT    *
	FROM    #DistCrudo

-- SE VALIDA SI EL CONTRATO ES DE PRODUCCION COMPARTIDA EN CONSORCIO PARA GENERAR LAS COMERCIALIZACIONES TOPANDO AL VOLUMEN QUE LE CORRESPONDE A PEMEX
IF @EsPC = 1 AND @EsConsorcio = 1 AND ISNULL(@PorcPemex,0) = 0
BEGIN
    SELECT @MensajeError = 'No se encontro el porcentaje correspondiente a PEMEX'+CHAR(13)+'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo'
    GOTO ERROR
END

-- SE VALIDA SI EL PORCENTAJE ES DEL 50% Y EL VOLUMEN ES UN NUMERO IMPAR, EN SESE CASO SE AGREGA UN BARRIL A LA DISTRIBUCION DE PEMEX
--Se toma el volumen de petroleo a distribuir antes calculado
SELECT
    @distribuciontotalp = CASE	WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND Petroleo % 2 = 1
								THEN (Petroleo * @PorcPemex) + 0.5
								WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND Petroleo % 2 = 0
								THEN Petroleo * @PorcPemex
								WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex <> 0.5
								THEN Petroleo * @PorcPemex
						ELSE	Petroleo
						END
FROM
    dbo.PC_Volumenes
WHERE
    IdContrato = @IdContrato
    AND Mes     = @MesReporte

IF @Debug = 1
	SELECT    @distribuciontotalp AS VolumenDistribucionFMP ---para ver el volumen que se va a distribuir

IF(@distribuciontotalp IS NULL)
BEGIN
    SELECT @MensajeError = 'No se encontro volumen de crudo a distribuir'+CHAR(13)+'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo'
    GOTO ERROR
END

--Se actualiza el volumen por cada punto de venta - producto
-- SE TOPA AL VALOR MAXIMO DE PRODUCCION
UPDATE    #DistCrudo
	SET VolumenDistribucion	=	CASE WHEN @sumacrudo <	@distribuciontotalp --VolumenBloque < VolumenDistribucion
									THEN	VolumenBloque
									ELSE	@distribuciontotalp * Porcentaje
								END

--Se seleccionan las facturas de PMI y PTI que pertenecen al mes reporte
INSERT INTO #PC_Facturas
(
    Factura,
    UUID
)
SELECT
    RF.Factura,
	RF.UUID
FROM
    dbo.PC_PMI_V2  RF
JOIN
    dbo.FI_Factura F
    ON F.UUID = RF.UUID
WHERE
    DATEFROMPARTS( YEAR( F.FechaTimbrado ), MONTH( F.FechaTimbrado ), 1 ) = @MesReporte
UNION
SELECT
    RF.Factura,
	RF.UUID
FROM
    dbo.PC_PTI_V2  RF
JOIN
    dbo.FI_Factura F
    ON F.UUID = RF.UUID
WHERE
    DATEFROMPARTS( YEAR( F.FechaTimbrado ), MONTH( F.FechaTimbrado ), 1 ) = @MesReporte

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #PC_Facturas'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0


IF @Debug = 1
	SELECT   *	FROM	#PC_Facturas

--Se insertan solo aquellas facturas que cumplen con el criterio
INSERT INTO #PC_FacturasCrudo
(
    IdFactura,
    IdPtoExpedicionRecepcion,
    IdMaterialPC,
    cantidad,
    factor
)
SELECT
    CFDI.IdFactura,
    EPV.IdPtoExpedicionRecepcion AS IdPtoExpedicionRecepcion,
    DI.IdMaterialPC              AS IdMaterialPC,
    C.Cantidad,
    CAST(0.0000 AS FLOAT)        AS Factor
FROM
    PC_DistribucionIngresos    DI
JOIN
    PC_Material                M
    ON M.IdMaterialPC               = DI.IdMaterialPC
JOIN
    dbo.PC_Comercializacion_V2 RC
    ON M.TextoBreve                 = RC.Denominación
JOIN
    PC_EquivalenciaPuntoVenta  EPV
    ON EPV.IdPtoExpedicionRecepcion = DI.IdPtoExpedicionRecepcion
    AND EPV.[Nombre 1]               = RC.[Nombre1]
JOIN
    #PC_Facturas               F
    ON CONCAT( '00', RC.Factura )   = F.Factura
JOIN
    FI_Factura                 CFDI
    ON F.UUID                       = CFDI.UUID
JOIN
    FI_CFDIConcepto            C
    ON C.IdFactura                  = CFDI.IdFactura
JOIN
    PC_ContratoCampo           CC
ON CC.IdCampo                   = DI.IdCampo
JOIN
    PC_PuntoVentaProducto      PVP
    ON PVP.IdContrato               = CC.IdContrato
    AND PVP.IdPtoExpedicionRecepcion = DI.IdPtoExpedicionRecepcion
    AND PVP.IdMaterialPC             = DI.IdMaterialPC
WHERE
    RC.[CantidadFacturada] > 0 --La factura debe tener un volumen a facturar
    AND RC.[Importe]        > 0 --El importe no puede ser cero o negativo (nota de credito)
    AND PVP.Aplica          = 1 --La factura de acuerdo a comercializacion pertenece a un punto de venta seleccionado
    AND CC.IdContrato       = @IdContrato
    AND DI.IdMaterialPC IN ( 10000, 10001, 10002, 10003, 10004, 10005, 10006, 10007, 10008, 10009,
                            10010, 10016, 10019, 10020) --El producto facturado es algun petroleo
    AND MONTH( CFDI.Fecha ) = MONTH( @MesReporte )
    AND YEAR( CFDI.Fecha )  = YEAR( @MesReporte )
	AND ( RC.factura LIKE '92%'   OR   RC.Factura LIKE '93%' )
	AND DATEFROMPARTS( SUBSTRING( RC.FechaFactura, 7, 4 ), SUBSTRING( RC.FechaFactura, 4, 2 ), SUBSTRING( RC.FechaFactura, 1, 2 ) ) >= @FechaInicioContrato
GROUP BY
    CFDI.IdFactura,
    EPV.IdPtoExpedicionRecepcion,
    DI.IdMaterialPC,
    C.Cantidad

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #PC_FacturasCrudo'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

IF @Debug = 1
	SELECT   *
	FROM    #PC_FacturasCrudo

--Basado en las facturas antes seleccionadas se calcula el volumen facturado por cada punto de venta
INSERT INTO #VolumenFacturado
(
    IdPtoExpedicionRecepcion,
    IdMaterialPC,
    VolumenFacturado
)
SELECT
    IdPtoExpedicionRecepcion,
    IdMaterialPC,
    SUM( cantidad ) AS VolumenFacturado
FROM
    #PC_FacturasCrudo
GROUP BY
    IdPtoExpedicionRecepcion,
    IdMaterialPC

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al insertar en #VolumenFacturado'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

--Se actualiza la tabla de distribucion con los volumenes calculados en el paso anterior
UPDATE    DC
    SET
		VolumenFacturado = VF.VolumenFacturado,
		FactorDistribucion = DC.VolumenDistribucion / VF.VolumenFacturado
FROM
    #DistCrudo        DC
JOIN
    #VolumenFacturado VF
    ON DC.IdPtoExpedicionRecepcion = VF.IdPtoExpedicionRecepcion
    AND DC.IdMaterialPC             = VF.IdMaterialPC -- FECHA FACTURA PARA PEMEX 

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al actualizar en #DistCrudo'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

IF @Debug = 1
BEGIN
	SELECT   *
	FROM    #DistCrudo ---comentar para web

	--SELECT * FROM #VolumenFacturado
END

-- SE GENERARN LAS COMERCIALIZACIONES EN TABLA DE PASO PARA VALIDAR SI NO FALTAN BARRILES POR REPARTIR
INSERT INTO #Comercializaciones
(
	FechaTransaccion,
	VolumenVendido,
	PrecioVentaUnitario,
	IdFactura
)
SELECT
	F.Fecha			AS [FechaTransaccion],
	ROUND(C.Cantidad * E.Factor * DC.FactorDistribucion,0)	AS [VolumenVendido],
	((CONVERT( DECIMAL (12, 4), C.ValorUnitario ) / T.TipoCambio) * C.Cantidad)	/ (C.Cantidad * E.Factor)	AS [PrecioVentaUnitario],
	F.IdFactura
FROM
	#PC_FacturasCrudo    FC
JOIN
	#DistCrudo          DC
	ON FC.IdPtoExpedicionRecepcion = DC.IdPtoExpedicionRecepcion
	AND FC.IdMaterialPC             = DC.IdMaterialPC
JOIN
	FI_Factura          F (NOLOCK)
	ON F.IdFactura                 = FC.IdFactura
JOIN
	FI_CFDIConcepto     C (NOLOCK)
	ON F.IdFactura                 = C.IdFactura
JOIN
	COM_Equivalencias   E
	ON C.Unidad                    = E.Unidad
JOIN
	CO_TipoCambioDiario T
	ON F.IdMoneda                  = T.IdMoneda
	AND CONVERT( DATE, F.Fecha )    = T.Fecha
WHERE
	ROUND(C.Cantidad * E.Factor * DC.FactorDistribucion,0)	> 0

SELECT @TotalADistribuir = ROUND(SUM(VolumenDistribucion),0)
FROM	#DistCrudo

SELECT @TotalDistribuido	=	SUM(VolumenVendido)
FROM #Comercializaciones

IF @Debug = 1
BEGIN
	SELECT @TotalADistribuir AS [TotalADistribuir], @TotalDistribuido AS [TotalDistribuido]
END

IF @TotalADistribuir <> @TotalDistribuido
BEGIN
	INSERT INTO #AjustesTotal
	(
		IdFactura,
		IdAjuste,
		VolumenVendido,
		Ajuste
	)
	SELECT
		IdFactura,
		ROW_NUMBER() OVER (ORDER BY VolumenVendido DESC) AS IdAjuste,
		VolumenVendido,
		@TotalADistribuir - @TotalDistribuido
	FROM
		#Comercializaciones

	UPDATE    C
    SET  VolumenVendido = CASE	WHEN A.IdAjuste <= A.Ajuste THEN C.VolumenVendido + 1
								ELSE C.VolumenVendido
                          END
	FROM
		#Comercializaciones C
	JOIN
		#AjustesTotal       A
		ON C.IdFactura                = A.Idfactura

		IF @Debug = 1
		BEGIN
			SELECT * FROM #AjustesTotal
        end
	-- SE REALIZA EL AJUSTE NEGATIVO A LOS VOLUMENES
	UPDATE    C
		SET
			 VolumenVendido = CASE	WHEN A.IdAjuste <= ABS(A.Ajuste) AND A.Ajuste < 0 THEN	C.VolumenVendido -1
									ELSE C.VolumenVendido
							END
	FROM
		#Comercializaciones C
	JOIN
		#AjustesTotal       A
		ON C.IdFactura                = A.Idfactura
	WHERE
		A.Ajuste < 0

END

/*
-- SE HACE AJUSTE PARA CASO MIQUETLA
IF @IdContrato = 10051
BEGIN

--DECLARE @VolumenTotalTarifas FLOAT
	-- SE OBTIENEN LAS DIFERENTES TARIFAS
	SELECT	@VolumenTotalTarifas = SUM(Volumen)
	FROM  SCOC_VolumenPorTarifa
	WHERE IdContrato = @IdContrato
	AND MesReporte = @MesReporte
	AND IdTipoHidrocarburo = 10000

	SELECT TOP 1
		@Prop01	=	Volumen/@VolumenTotalTarifas,
		@Tarifa01	=	Tarifa
	FROM
		SCOC_VolumenPorTarifa
	WHERE
		IdContrato = @IdContrato
		AND MesReporte = @MesReporte
		AND IdTipoHidrocarburo = 10000
	ORDER BY
		IdTarifa ASC

	SELECT TOP 1
		@Prop02	=	Volumen/@VolumenTotalTarifas,
		@Tarifa02	=	Tarifa
	FROM
		SCOC_VolumenPorTarifa
	WHERE
		IdContrato = @IdContrato
		AND MesReporte = @MesReporte
		AND IdTipoHidrocarburo = 10000
	ORDER BY
		IdTarifa DESC

	SELECT
		@Prop01		FLOAT,
		@Prop02		FLOAT,
		@Tarifa01		FLOAT,
		@Tarifa02		FLOAT

	UPDATE	#Comercializaciones
		SET
			VolumenVendido01	=	VolumenVendido * @Prop01,
			Tarifa01		=	 @Tarifa01,
			VolumenVendido02	=	VolumenVendido * @Prop02,
			Tarifa02		=	@Tarifa02

END

IF @Debug = 1
BEGIN
	SELECT * FROM #Comercializaciones
END
*/

-- SE VALIDA SI EL REPORTE GENERADO ES DEL MES ANTERIOR, EN CUYO CASO SE BORRA LA INFORMACIÓN, SI ES MAS ANTIGUO SOLO SE MUESTRA LA INFORMACION YA GENERADA
IF @FechaLimite >= GETDATE()
BEGIN
	IF @Debug = 1
	BEGIN
		SELECT
			@IdContrato		AS [IdContrato],
			@MesReporte		AS [MesReporte],
			FechaTransaccion	AS [FechaTransaccion],
			10000			AS [IdTipoHidrocarburo],
			VolumenVendido	AS [VolumenVendido],
			PrecioVentaUnitario		AS [PrecioVentaUnitario],
			@CostoUnitarioComercializacion	AS [CostoUnitarioComercializacion],
			PrecioVentaUnitario	- @CostoUnitarioComercializacion		AS [PrecioPuntoMedicion],
			IdFactura,
			'000000000000000'	AS [NumeroFolioPedimento],
			1				AS [EPT],
			1				AS [OperacionBajoReglasMercado],
			2				AS [ClasificacionDocumentoSoporte],
			@Usuario		AS [CreadoPor],
			GETDATE()		AS [CreadoEl],
			@Usuario		AS [ModificadoPor],
			GETDATE()		AS [ModificadoEl],
			1				AS [Activo],
			0				AS [PVUAnterior],
			0				AS [PPMAnterior]
		FROM
			#Comercializaciones

	END
	ELSE
	BEGIN
		--Se borran las comercializaciones anteriores por si ya habia alguna generada con anterioridad de petroleo del mes y del contrato QUE CORRESPONDAN A PEMEX
		DELETE OC
		FROM	COM_OperacionComercializacion	OC
		JOIN	dbo.FI_Factura	F
			ON	OC.IdFactura	=	F.IdFactura
		WHERE
			OC.IdContrato            = @IdContrato
			AND OC.MesReporte         = @MesReporte
			AND OC.IdTipoHidrocarburo = 10000
			AND F.Receptor	<>	'PEP9207167XA'

		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al eliminar en COM_OperacionComercializacion'+
			'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo '+
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
		SELECT
			@IdContrato,
			@MesReporte,
			--F.Fecha,
			FechaTransaccion,
			10000,		--     IdTipoHidrocarburo     PETROLEO: 10000     CONDENSADO: 10001
			VolumenVendido,
			PrecioVentaUnitario,
			@CostoUnitarioComercializacion,
			PrecioVentaUnitario - @CostoUnitarioComercializacion,
			IdFactura,
			'000000000000000',
			1,
			1,
			2,
			@Usuario,
			GETDATE(),
			@Usuario,
			GETDATE(),
			1, ---Activo
			0,
			0
		FROM
			#Comercializaciones

		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al isertar en COM_OperacionComercializacion'+
			'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesPetroleo '+
			'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
			GOTO ERROR
		END	-- IF @NumError <> 0
	END	-- IF @Debug = 1
END	-- IF @FechaLimite >= GETDATE()

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


