CREATE PROCEDURE dbo.SP_PC_GenerarComercializacionesCondensado
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
-- Description:	Proceso para realizar el calculo de las comercializaciones de Condensado
-- Parametros de Entrada:	Numero de Contrato y Mes de Calculo
-- =============================================
-- 20180824	BAAC	Se modifica para generar las comercializaciones con el precio calculado del hidrocarburo
-- =============================================
SET NOCOUNT ON
-- =============================================
CREATE TABLE #DistConde
(
    IdPtoExpedicionRecepcion INT,
    IdMaterialPC             INT,
    VolumenBloque            FLOAT,
    Porcentaje               FLOAT,
    VolumenDistribucion      FLOAT,
    VolumenFacturado         FLOAT,
    FactorDistribucion       FLOAT
)

CREATE TABLE #VolumenFacturadoConde
(
    IdPtoExpedicionRecepcion INT,
    IdMaterialPC             INT,
    VolumenFacturado         FLOAT
)

CREATE TABLE #PC_FacturasConde
(
	Factura	nvarchar(510),
	UUID	nvarchar(510)
)

CREATE TABLE #PC_FacturasConde2
(
	IdFactura		INT,
	IdPtoExpedicionRecepcion	INT,
	IdMaterialPC	INT,
	cantidad	FLOAT,
	factor	FLOAT
)

CREATE TABLE #ComercializacionesConde
(
	FechaTransaccion	DATETIME,
	VolumenVendido		INT,
	PrecioVentaUnitario	MONEY,
	IdFactura		INT,
	FactorVolumen	FLOAT,
	FactorVolumenPrecio FLOAT,
	DescuentoPrecioBalanceo	FLOAT
)

CREATE TABLE #AjustesTotalConde
(
	IdFactura	INT,
	IdAjuste	INT,
	VolumenVendido	INT,
	Ajuste		INT
)

DECLARE
	@sumaconde AS FLOAT,
	@distribuciontotalconde AS FLOAT,
	@Param	DECIMAL(8,4),
	@CostoUnitarioComercializacion	MONEY,
	@NumError	INT,
	@MensajeError	VARCHAR(500),
	@FechaInicioContrato		DATE,
	@EsPC			BIT,
	@PorcPemex		DECIMAL(6,4),
	@EsConsorcio	BIT,
	@TotalADistribuir	INT,
	@TotalDistribuido	INT,
	@Precio			FLOAT,
	@SumEner		FLOAT

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

SELECT 	@Param = 6.2898

-- SE OBTIENE EL COSTO UNITARIO DEL HIDROCARBURO
SELECT @CostoUnitarioComercializacion = CostoUnitarioComercializacion
FROM	COM_CostoUnitarioHidrocarburo
WHERE
	IdContrato	=	@IdContrato
	AND	Mes		=	@MesReporte
	AND	IdTipoHidrocarburo	=	10001

IF(@CostoUnitarioComercializacion IS NULL)
BEGIN
    SELECT @MensajeError = 'No se encontro valor vigente para el Costo Unitario de Comercializacion'+CHAR(13)+'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado'
    GOTO ERROR
END
----================================================================================
----    Distribucion Volumetrica Condensado
----================================================================================
--Se seleccionan de la distribucion de ingresos los registros de los puntos de venta elegido, pertenecientes a crudo, de los campos del contrato
INSERT INTO #DistConde
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
    SUM( DI.DistribucionVolumetrica )          AS VolumenBloque,
    CAST(0.0000000000000000000000000 AS FLOAT) AS Porcentaje,
    CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenDistribucion,
    CAST(0.0000000000000000000000000 AS FLOAT) AS VolumenFacturado,
    CAST(0.0000000000000000000000000 AS FLOAT) AS FactorDistribucion
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
    PVP.Aplica			= 1
    AND CC.IdContrato	= @IdContrato
    AND DI.IdMaterialPC IN ( 10011, 10012 )
	AND DATEFROMPARTS( SUBSTRING( DI.MesReporte, 7, 4 ), SUBSTRING( DI.MesReporte, 4, 2 ), 1 ) = @MesReporte
    AND PVP.Mes                                                                                = @MesReporte
GROUP BY
    PVP.IdPtoExpedicionRecepcion,
    DI.IdMaterialPC

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al isertar en #DistConde'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

IF @Debug = 1
	SELECT   *
	FROM    #DistConde


--Sumatoria del volumen de condensado
SELECT
    @sumaconde = SUM( VolumenBloque )
FROM
    #DistConde

IF @Debug = 1
	SELECT	@sumaconde AS VolumenTotalCondeDI ---comentar para web

IF(ISNULL(@sumaconde,0) = 0)
BEGIN
    SELECT @MensajeError = 'No se encontro Volumen del Condensado'+CHAR(13)+'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado'
    GOTO ERROR
END

--Porcentaje Proporcional 
UPDATE    #DistConde
    SET    Porcentaje = VolumenBloque / (@sumaconde)

-- SE VALIDA SI EL CONTRATO ES DE PRODUCCION COMPARTIDA EN CONSORCIO PARA GENERAR LAS COMERCIALIZACIONES TOPANDO AL VOLUMEN QUE LE CORRESPONDE A PEMEX
IF @EsPC = 1 AND @EsConsorcio = 1 AND ISNULL(@PorcPemex,0) = 0
BEGIN
    SELECT @MensajeError = 'No se encontro el porcentaje correspondiente a PEMEX'+CHAR(13)+'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado'
    GOTO ERROR
END

--Calculo del volumen de condensado a vender basado en reparticion preliminar
SELECT
    @distribuciontotalconde = CASE	WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND Condensado % 2 = 1
								THEN (Condensado * @PorcPemex) + 0.5
								WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex = 0.5 AND Condensado % 2 = 0
								THEN Condensado * @PorcPemex
								WHEN @EsPC = 1 AND @EsConsorcio = 1  AND @PorcPemex <> 0.5
								THEN Condensado * @PorcPemex
						ELSE	Condensado
						END
FROM
    PC_Volumenes
WHERE
    IdContrato = @IdContrato
    AND Mes     = @MesReporte

IF @Debug = 1
	SELECT    @distribuciontotalconde AS VolumenDistribucionFMP ---para ver el volumen que se va a distribuir

IF(ISNULL(@distribuciontotalconde,0) = 0)
BEGIN
    SELECT @MensajeError = 'No se encontro Volumen del Condensado'+CHAR(13)+'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado'
    GOTO ERROR
END

UPDATE #DistConde
	SET	VolumenDistribucion	= CASE WHEN @sumaconde < @distribuciontotalconde --VolumenBloque < VolumenDistribucion
									THEN	VolumenBloque
								ELSE	@distribuciontotalconde * Porcentaje
							END

INSERT INTO #PC_FacturasConde
(
    Factura,
    UUID
)
SELECT
    Factura,
    UUID
FROM
    dbo.PC_PMI_V2
UNION
SELECT
    Factura,
    UUID
FROM
    PC_PTI_V2

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al isertar en #PC_FacturasConde'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

INSERT INTO #PC_FacturasConde2
(
    IdFactura,
    IdPtoExpedicionRecepcion,
    IdMaterialPC,
    cantidad,
    factor
)
SELECT
    CFDI.IdFactura,
    EPV.IdPtoExpedicionRecepcion               AS IdPtoExpedicionRecepcion,
    DI.IdMaterialPC                            AS IdMaterialPC,
    C.Cantidad,
    CAST(0.0000000000000000000000000 AS FLOAT) AS Factor
FROM
    PC_DistribucionIngresos   DI
JOIN
    PC_Material               M
    ON M.IdMaterialPC       = DI.IdMaterialPC
JOIN
    PC_Comercializacion_V2       RC
    ON M.TextoBreve                 = RC.Denominación
JOIN
    PC_EquivalenciaPuntoVenta EPV
    ON EPV.IdPtoExpedicionRecepcion = DI.IdPtoExpedicionRecepcion
    AND EPV.[Nombre 1]               = RC.Nombre1	--[Nombre 1]
LEFT JOIN
    #PC_FacturasConde         F
    ON CONVERT(INT,RC.Factura )   = CONVERT(INT,F.Factura)
JOIN
    FI_Factura                CFDI
    ON F.UUID                       = CFDI.UUID
JOIN
    FI_CFDIConcepto           C
    ON C.IdFactura                  = CFDI.IdFactura
JOIN
    PC_ContratoCampo          CC
    ON CC.IdCampo                   = DI.IdCampo
JOIN
    PC_PuntoVentaProducto     PVP
    ON PVP.IdContrato               = CC.IdContrato
    AND PVP.IdPtoExpedicionRecepcion = DI.IdPtoExpedicionRecepcion
    AND PVP.IdMaterialPC             = DI.IdMaterialPC
WHERE
    RC.CantidadFacturada > 0--[Cantidad facturada] > 0
    AND RC.[Importe]         > 0
    AND PVP.Aplica           = 1
    AND CC.IdContrato        = @IdContrato
    AND DI.IdMaterialPC IN ( 10011, 10012 )
    AND MONTH( CFDI.Fecha )  = MONTH( @MesReporte )
    AND YEAR( CFDI.Fecha )   = YEAR( @MesReporte )
	AND ( RC.factura LIKE '92%'   OR   RC.Factura LIKE '93%' )
	AND DATEFROMPARTS( SUBSTRING( RC.[Fechafactura], 7, 4 ), SUBSTRING( RC.[Fechafactura], 4, 2 ), SUBSTRING( RC.[Fechafactura], 1, 2 ) ) >= @FechaInicioContrato
GROUP BY
    CFDI.IdFactura,
    EPV.IdPtoExpedicionRecepcion,
    DI.IdMaterialPC,
    C.Cantidad

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al isertar en #PC_FacturasConde2'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

IF @Debug = 1
BEGIN
	SELECT '#PC_FacturasConde2'
	SELECT   *
	FROM    #PC_FacturasConde2

	-- PRECIO
	SELECT
		F.Fecha			AS [FechaTransaccion],
		--ROUND( C.Cantidad * E.Factor * DC.FactorDistribucion, 0 )	AS [VolumenVendido],
		((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)		AS [PrecioVentaUnitario],
		F.IdFactura
	FROM
		#PC_FacturasConde2    FC
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

END

INSERT INTO #VolumenFacturadoConde
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
    #PC_FacturasConde2
GROUP BY
    IdPtoExpedicionRecepcion,
    IdMaterialPC

SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al isertar en #VolumenFacturadoConde'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

IF @Debug = 1
BEGIN
	SELECT '#VolumenFacturadoConde'
	SELECT   *
	FROM    #VolumenFacturadoConde
END

-- SE ACTUALIZA PARA NO REALIZAR LA CONVERSION DE UNIDADES YA QUE AHORA SE FACTURA EN OTRA UNIDAD * REPORTE DE MAYO 2020 *
UPDATE    DC
    SET    VolumenFacturado = VF.VolumenFacturado , --* @Param,
		FactorDistribucion = DC.VolumenDistribucion / (VF.VolumenFacturado) -- * @Param)
FROM
    #DistConde             DC
JOIN
    #VolumenFacturadoConde VF
    ON DC.IdPtoExpedicionRecepcion = VF.IdPtoExpedicionRecepcion
    AND DC.IdMaterialPC             = VF.IdMaterialPC -- FECHA FACTURA PARA PEMEX
	
SELECT @NumError = @@ERROR
IF @NumError <> 0
BEGIN
	SELECT @MensajeError = 'Error al actualizar en #DistConde'+
	'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado '+
	'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
	GOTO ERROR
END	-- IF @NumError <> 0

IF @Debug = 1
BEGIN
	SELECT   *
	FROM    #DistConde ---comentar para web
END

INSERT INTO #ComercializacionesConde
(
	FechaTransaccion,
	VolumenVendido,
	PrecioVentaUnitario,
	IdFactura
)
SELECT
	F.Fecha			AS [FechaTransaccion],
	ROUND( C.Cantidad * E.Factor * DC.FactorDistribucion, 0 )	AS [VolumenVendido],
	((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)		AS [PrecioVentaUnitario],
	F.IdFactura
FROM
	#PC_FacturasConde2    FC
JOIN
	#DistConde          DC
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
	ROUND( C.Cantidad * E.Factor * DC.FactorDistribucion, 0 ) > 0


SELECT @TotalADistribuir = SUM(VolumenDistribucion)
FROM	#DistConde

SELECT @TotalDistribuido	=	SUM(VolumenVendido)
FROM #ComercializacionesConde

IF @TotalADistribuir <> @TotalDistribuido
BEGIN
	INSERT INTO #AjustesTotalConde
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
		#ComercializacionesConde

	UPDATE    C
    SET  VolumenVendido = CASE	WHEN A.IdAjuste <= A.Ajuste THEN C.VolumenVendido + 1
								ELSE C.VolumenVendido
                          END
	FROM
		#ComercializacionesConde C
	JOIN
		#AjustesTotalConde       A
		ON C.IdFactura                = A.Idfactura

	-- SE REALIZA EL AJUSTE NEGATIVO A LOS VOLUMENES
	UPDATE    C
		SET
			 VolumenVendido = CASE	WHEN A.IdAjuste <= ABS(A.Ajuste) AND A.Ajuste < 0 THEN	C.VolumenVendido -1
									ELSE C.VolumenVendido
							END
	FROM
		#ComercializacionesConde C
	JOIN
		#AjustesTotalConde       A
		ON C.IdFactura                = A.Idfactura
	WHERE
		A.Ajuste < 0
END

SELECT @TotalDistribuido	=	SUM(VolumenVendido)
FROM #ComercializacionesConde

IF @IdContrato <> 10028 -- MISIÓN
BEGIN
	/***************     SE BUSCA EL PRECIO CALCULADO DEL CONDENSADO PARA GENERAR LAS COMERCIALIZACIONES CON EL PRECIO YA CORRECTO           *************/
	SELECT
		@Precio	=	ISNULL(PrecioUnitario,0)
	FROM
		dbo.COM_PreciosObjetivosHidroCarburos
	WHERE
		IdContrato	=	@IdContrato
		AND IdTipoHidrocarburo	=	10001	-- CONDENSADO
		AND Mes	=	@MesReporte

	-- SI NO HAY PRECIO, SE EJECUTA EL SP DE GENERACION DE COMERCIALIZACIONES DE GAS Y SE VUELVE A OBTENER EL PRECIO
	IF ISNULL(@Precio,0)	=	0
	BEGIN
		-- SE EJECUTA EL CALCULO DE COMERCIALIZACIONES PARA COMPONENTE DEL GAS
		EXEC dbo.sp_COM_CalculaComercializacionesGasyCondensable @IdContrato, @MesReporte, @Usuario, @FechaLimite, 0 --@Debug

		SELECT
			@Precio	=	ISNULL(PrecioUnitario,0)
		FROM
			dbo.COM_PreciosObjetivosHidroCarburos
		WHERE
			IdContrato	=	@IdContrato
			AND IdTipoHidrocarburo	=	10001	-- CONDENSADO
			AND Mes	=	@MesReporte

	END


	UPDATE #ComercializacionesConde
		SET	FactorVolumen	=	CONVERT(FLOAT,VolumenVendido)/CONVERT(FLOAT,@TotalDistribuido)


	-- SI SE PUDO CALCULAR EL PRECIO DEL CONDENSADO, SE AJUSTAN LAS COMERCIALIZACIONES PARA QUE AL PONDERAR EL PRECIO, DE EL MISMO
	IF @Precio <> 0
	BEGIN

		SELECT
			@SumEner	=	((((@Precio - SUM(((CONVERT(FLOAT,VolumenVendido) * (PrecioVentaUnitario))/@TotalDistribuido))) * 100)/SUM(((CONVERT(FLOAT,VolumenVendido) * (PrecioVentaUnitario))/@TotalDistribuido))/100))
		FROM
			#ComercializacionesConde

		UPDATE CC
			SET FactorVolumenPrecio	=	CONVERT(FLOAT,@SumEner * FactorVolumen)
		FROM
			#ComercializacionesConde	CC

		UPDATE CC
			SET DescuentoPrecioBalanceo	=	
											CASE WHEN @distribuciontotalconde = 0 THEN 0
												WHEN FactorVolumen = 0	THEN 0
												ELSE FactorVolumenPrecio * (PrecioVentaUnitario/FactorVolumen)
											END
		FROM
			#ComercializacionesConde	CC

	END

END
ELSE
BEGIN

	UPDATE	#ComercializacionesConde
		SET DescuentoPrecioBalanceo = 0
END

IF @Debug = 1
BEGIN
	SELECT   *
	FROM    #ComercializacionesConde ---comentar para web
END

-- SE VALIDA SI EL REPORTE GENERADO ES DEL MES ANTERIOR, EN CUYO CASO SE BORRA LA INFORMACIÓN, SI ES MAS ANTIGUO SOLO SE MUESTRA LA INFORMACION YA GENERADA
IF @FechaLimite >= GETDATE()
BEGIN
	IF @Debug = 1
	BEGIN
		SELECT
			@IdContrato		AS [IdContrato],
			@MesReporte		AS [MesReporte],
			FechaTransaccion			AS [FechaTransaccion],
			10001			AS [IdTipoHidrocarburo],
			VolumenVendido,	--ROUND( C.Cantidad * E.Factor * DC.FactorDistribucion, 0 )	AS [VolumenVendido],
--			C.PrecioVentaUnitario,	--((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)		AS [PrecioVentaUnitario],
			CASE WHEN @IdContrato <> 10028 THEN (PrecioVentaUnitario + DescuentoPrecioBalanceo) + @CostoUnitarioComercializacion
				ELSE PrecioVentaUnitario
			END				AS [PrecioVentaUnitario],
			--(PrecioVentaUnitario + DescuentoPrecioBalanceo) + @CostoUnitarioComercializacion		AS [PrecioVentaUnitario],
			@CostoUnitarioComercializacion			AS [CostoUnitarioComercializacion],
			C.PrecioVentaUnitario - @CostoUnitarioComercializacion	AS [PrecioPuntoMedicion], --(((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)) - @CostoUnitarioComercializacion
			--CASE WHEN @IdContrato <> 10028 THEN (PrecioVentaUnitario + DescuentoPrecioBalanceo) - @CostoUnitarioComercializacion		
			--	ELSE PrecioVentaUnitario - @CostoUnitarioComercializacion
			--END						AS [PrecioPuntoMedicion],
			IdFactura
		FROM
			#ComercializacionesConde	C
    END
    ELSE
    BEGIN
		DELETE OC
		FROM	COM_OperacionComercializacion	OC
		JOIN	dbo.FI_Factura	F
			ON	OC.IdFactura	=	F.IdFactura
		JOIN	dbo.FI_CFDIConcepto	C
			ON	F.IdFactura	=	C.IdFactura
		WHERE
			OC.IdContrato            = @IdContrato
			AND OC.MesReporte         = @MesReporte
			AND IdTipoHidrocarburo = 10001
			AND F.Receptor	<>	'PEP9207167XA'
			AND	C.Descripcion LIKE '%CONDENSADO%'

		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al eliminar en COM_OperacionComercializacion'+
			'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado '+
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
			FechaTransaccion,
			10001,    --     IdTipoHidrocarburo     PETROLEO: 10000     CONDENSADO: 10001
			VolumenVendido,	--ROUND( C.Cantidad * E.Factor * DC.FactorDistribucion, 0 ),
			--C.PrecioVentaUnitario,	--((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor),
			--(PrecioVentaUnitario + DescuentoPrecioBalanceo) + @CostoUnitarioComercializacion,
			CASE WHEN @IdContrato <> 10028 THEN (PrecioVentaUnitario + DescuentoPrecioBalanceo) + @CostoUnitarioComercializacion
				ELSE PrecioVentaUnitario
			END,
			@CostoUnitarioComercializacion,
			--C.PrecioVentaUnitario - @CostoUnitarioComercializacion, --(((ValorUnitario / T.TipoCambio) * C.Cantidad) / (C.Cantidad * E.Factor)) - @CostoUnitarioComercializacion,
			(PrecioVentaUnitario + DescuentoPrecioBalanceo) - @CostoUnitarioComercializacion,
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
			#ComercializacionesConde	C
		--	#PC_FacturasConde2    FC
		--JOIN
		--	#DistConde          DC
		--	ON FC.IdPtoExpedicionRecepcion = DC.IdPtoExpedicionRecepcion
		--	AND FC.IdMaterialPC             = DC.IdMaterialPC
		--JOIN
		--	FI_Factura          F (NOLOCK)
		--	ON F.IdFactura                 = FC.IdFactura
		--JOIN
		--	FI_CFDIConcepto     C (NOLOCK)
		--	ON F.IdFactura                 = C.IdFactura
		--JOIN
		--	COM_Equivalencias   E
		--	ON C.Unidad                    = E.Unidad
		--JOIN
		--	CO_TipoCambioDiario T
		--	ON F.IdMoneda                  = T.IdMoneda
		--	AND CONVERT( DATE, F.Fecha )    = T.Fecha
		--WHERE
		--	ROUND( C.Cantidad * E.Factor * DC.FactorDistribucion, 0 ) > 0

		SELECT @NumError = @@ERROR
		IF @NumError <> 0
		BEGIN
			SELECT @MensajeError = 'Error al insertar en COM_OperacionComercializacion'+
			'En el Stored Procedure: dbo.SP_PC_GenerarComercializacionesCondensado '+
			'Núm. Error en SQL Server:'+CHAR(9)+LTRIM(STR(@NumError, 10, 0));
			GOTO ERROR
		END	-- IF @NumError <> 0

    END -- IF @Debug = 1
END --IF @FechaLimite >= GETDATE()

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
