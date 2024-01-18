IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'ObtenerMonedasExtranjerasAGenerar'
)
    DROP PROCEDURE ObtenerMonedasExtranjerasAGenerar
GO

CREATE proc [dbo].[ObtenerMonedasExtranjerasAGenerar]
    @Fecha DATE,
    @IdContrato INT
AS
BEGIN
    DECLARE @Aprobado INT = 10004,
            @TipoPedimentoImportacion INT = 2,
            @TipoComprobanteExtranjero INT = 3,
            @TipoFactura INT = 1,
			@Dolar INT = 2,
			@FechaInicio DateTime,
			@FechaFin DateTime,
			@Peso INT = 1

    CREATE TABLE #Tabla
    (
        SerieBanxico VARCHAR(50),
        FechaPago DATE
    )
	CREATE TABLE #TablaMesSeleccionado(Fecha DATE, IdMoneda INT DEFAULT 1)


	SELECT @FechaInicio = @Fecha, @FechaFin = EOMONTH(@Fecha);

	-- Pedimento Comprobante PE PI
	
	-- Se insertan todos los comprobantes tanto PE como PI que esten pendientes de
	-- Fecha de tipo de cambio
	INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
	SELECT PV_TipoMoneda.SerieBanxico,
			FI_PedimentoComprobante.FechaPago
	FROM FI_PedimentoComprobante (NOLOCK)
	LEFT JOIN CO_TipoCambioDiario (NOLOCK)
			ON FI_PedimentoComprobante.FechaPago = CO_TipoCambioDiario.Fecha
			AND CO_TipoCambioDiario.IdMoneda = @Peso
	INNER JOIN PV_TipoMoneda (NOLOCK)
            ON PV_TipoMoneda.IdMoneda = FI_PedimentoComprobante.IdMoneda
	WHERE CO_TipoCambioDiario.IdTipoCambio IS NULL AND SerieBanxico IS NOT NULL
	AND FI_PedimentoComprobante.IdContrato = @IdContrato
	GROUP BY PV_TipoMoneda.SerieBanxico,
			FI_PedimentoComprobante.FechaPago

	-- PUE, PPD
    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    select PV_TipoMoneda.SerieBanxico,
           FI_Factura.Fecha
    FROM dbo.CO_Registro WITH (NOLOCK)
        INNER JOIN dbo.FI_Factura WITH (NOLOCK)
            ON CO_Registro.IdFactura = FI_Factura.IdFactura
               AND FI_Factura.IdContrato = @IdContrato
               AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
               AND CO_Registro.IdEstado = @Aprobado
               AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON FI_Factura.IdMoneda = PV_TipoMoneda.IdMoneda
    WHERE DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Fecha
    GROUP BY PV_TipoMoneda.SerieBanxico,
             FI_Factura.Fecha

	-- Transferencias
    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT PV_TipoMoneda.SerieBanxico,
           FI_Transfer.FechaPago
    FROM FI_Transfer (NOLOCK)
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
    WHERE DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1) = @Fecha
          AND FI_Transfer.IdContrato = @IdContrato
    GROUP BY PV_TipoMoneda.SerieBanxico,
             FI_Transfer.FechaPago
	

	;WITH FECHAS(fecha) AS (
	SELECT @FechaInicio fecha
	UNION ALL
	SELECT DATEADD(day, 1, fecha) fecha
	FROM FECHAS
	WHERE fecha < @FechaFin
	)
	INSERT INTO #TablaMesSeleccionado(Fecha)
	select fecha from FECHAS 
	option (maxrecursion 0)


	-- El mes Actual por en caso de que no vaya
    INSERT INTO #Tabla(SerieBanxico, FechaPago)
	SELECT SerieBanxico, #TablaMesSeleccionado.Fecha 
	FROM PV_TipoMoneda (NOLOCK)
	INNER JOIN #TablaMesSeleccionado
		ON PV_TipoMoneda.IdMoneda = #TablaMesSeleccionado.IdMoneda




	-- Se insertan los tipos de cambio en DLS si es que hacen falta
	INSERT INTO CO_TipoCambioDiario(IdMoneda, Fecha, TipoCambio, IdUsuario, Activo, CreadoPor)
	SELECT 2, FechaPago, 1, 1, 1, 1
	FROM #Tabla
	LEFT JOIN CO_TipoCambioDiario (NOLOCK)
		ON #Tabla.FechaPago = CO_TipoCambioDiario.Fecha
		AND CO_TipoCambioDiario.IdMoneda = @Dolar
	WHERE SerieBanxico IS NULL AND CO_TipoCambioDiario.IdTipoCambio IS NULL
	GROUP BY FechaPago
	
	-- Insertar dls de PPD
	INSERT INTO CO_TipoCambioDiario(IdMoneda, Fecha, TipoCambio, IdUsuario, Activo, CreadoPor)
	SELECT @Dolar, FI_Transfer.FechaPago, 1, 1, 1, 1
	FROM FI_Transfer (NOLOCK)
	INNER JOIN FI_TransferFactura (NOLOCK)
		ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
		AND FI_Transfer.IdMoneda = @Dolar
		AND FI_Transfer.IdContrato = @IdContrato
	INNER JOIN FI_ComplementoDePago (NOLOCK)
		ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
	INNER JOIN FI_CPDocRelacionado (NOLOCK)
		ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
	INNER JOIN FI_Factura (NOLOCK)
		ON FI_CPDocRelacionado.IdDocumento = FI_Factura.UUID
		AND FI_Factura.IdContrato = @IdContrato
	INNER JOIN CO_Registro (NOLOCK)
		ON FI_Factura.IdFactura = CO_Registro.IdFactura
		AND CO_Registro.MesPresentacion = @Fecha
	LEFT JOIN CO_TipoCambioDiario (NOLOCK)
		ON FI_Transfer.FechaPago = CO_TipoCambioDiario.Fecha
		AND CO_TipoCambioDiario.IdMoneda = @Dolar
	WHERE CO_TipoCambioDiario.IdTipoCambio IS NULL
	GROUP BY FI_Transfer.FechaPago


	-- Insertar DLS de PUE
	INSERT INTO CO_TipoCambioDiario(IdMoneda, Fecha, TipoCambio, IdUsuario, Activo, CreadoPor)
	SELECT @Dolar, FI_Transfer.FechaPago, 1, 1, 1, 1
	FROM FI_Transfer (NOLOCK)
	INNER JOIN FI_TransferFactura (NOLOCK)
		ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
		AND FI_Transfer.IdContrato = @IdContrato
		AND FI_Transfer.IdMoneda = @Dolar
	INNER JOIN CO_Registro (NOLOCK)
		ON FI_TransferFactura.IdFactura = CO_Registro.IdFactura
	LEFT JOIN CO_TipoCambioDiario (NOLOCK)
			ON FI_Transfer.FechaPago = CO_TipoCambioDiario.Fecha
			AND CO_TipoCambioDiario.IdMoneda = @Dolar
	WHERE CO_Registro.MesPresentacion = @Fecha AND CO_TipoCambioDiario.IdTipoCambio IS NULL
	GROUP BY FI_Transfer.FechaPago

	-- Se retorna al usuario los tipos de cambio que hacen falta dar de alta excepto DLS
    SELECT #Tabla.SerieBanxico, DATEFROMPARTS(YEAR(#Tabla.FechaPago), MONTH(#Tabla.FechaPago), 1) FechaPago
	FROM #Tabla
	INNER JOIN PV_TipoMoneda
		ON #Tabla.SerieBanxico = PV_TipoMoneda.SerieBanxico
	LEFT JOIN CO_TipoCambioDiario
		ON #Tabla.FechaPago = CAST(CO_TipoCambioDiario.Fecha as date) 
		AND PV_TipoMoneda.IdMoneda = CO_TipoCambioDiario.IdMoneda
	WHERE CO_TipoCambioDiario.IdTipoCambio IS NULL
	GROUP BY #Tabla.SerieBanxico, DATEFROMPARTS(YEAR(#Tabla.FechaPago), MONTH(#Tabla.FechaPago), 1) 

END