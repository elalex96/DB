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
			@FechaFin DateTime

    CREATE TABLE #Tabla
    (
        SerieBanxico VARCHAR(50),
        FechaPago DATE
    )

	CREATE TABLE #TablaMesSeleccionado(Fecha DATE, IdMoneda INT DEFAULT 2)
	CREATE TABLE #FechaMinima(Fecha Datetime)

	INSERT INTO #FechaMinima(Fecha)
	SELECT MIN(FechaPago) FROM FI_Transfer (NOLOCK) WHERE IdContrato = @IdContrato
	INSERT INTO #FechaMinima(Fecha)
	SELECT MIN(FechaPago) FROM FI_PedimentoComprobante (NOLOCK) WHERE IdContrato = @IdContrato
	INSERT INTO #FechaMinima(Fecha)
	SELECT MIN(Fecha) FROM FI_Factura (NOLOCK) WHERE IdContrato = @IdContrato

	SELECT @FechaInicio = MIN(Fecha), @FechaFin = DATEADD(DAY, -1, GETDATE()) FROM #FechaMinima


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


	-- Pedimento Comprobante PE PI

	INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )

    select PV_TipoMoneda.SerieBanxico,
           FI_Transfer.FechaPago
    FROM dbo.CO_Registro WITH (NOLOCK)
        INNER JOIN dbo.FI_PedimentoComprobante WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
               AND FI_PedimentoComprobante.IdContrato = @IdContrato
               AND CO_Registro.IdEstado = @Aprobado
               AND CO_Registro.CvTipoDocFacturacion IN ( @TipoPedimentoImportacion, @TipoComprobanteExtranjero )
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON PV_TipoMoneda.IdMoneda = FI_PedimentoComprobante.IdMoneda
        INNER JOIN dbo.FI_TransferFactura WITH (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante
        JOIN dbo.FI_Transfer WITH (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
    WHERE DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Fecha
    GROUP BY PV_TipoMoneda.SerieBanxico,
             FI_Transfer.FechaPago

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
	INNER JOIN PV_TipoMoneda (NOLOCK)
        ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda 
		AND FI_PedimentoComprobante.IdContrato = @IdContrato
	LEFT JOIN CO_TipoCambioDiario (NOLOCK)
		ON FI_PedimentoComprobante.FechaPago = CO_TipoCambioDiario.Fecha
		AND FI_PedimentoComprobante.IdMoneda = CO_TipoCambioDiario.IdMoneda
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



	-- Se insertan los tipos de cambio en DLS si es que hacen falta en el contrato

	INSERT INTO CO_TipoCambioDiario(IdMoneda, Fecha, TipoCambio, IdUsuario, Activo, CreadoPor)
	SELECT @Dolar, #TablaMesSeleccionado.Fecha, 1, 1, 1, 1 
	FROM #TablaMesSeleccionado
	LEFT JOIN CO_TipoCambioDiario (NOLOCK)
		ON #TablaMesSeleccionado.Fecha	 = CO_TipoCambioDiario.Fecha
		AND #TablaMesSeleccionado.IdMoneda = CO_TipoCambioDiario.IdMoneda
	WHERE CO_TipoCambioDiario.IdTipoCambio IS NULL


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