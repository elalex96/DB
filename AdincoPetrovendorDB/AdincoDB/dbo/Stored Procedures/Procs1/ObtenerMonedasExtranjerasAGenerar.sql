IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'ObtenerMonedasExtranjerasAGenerar'
)
    DROP PROCEDURE ObtenerMonedasExtranjerasAGenerar
GO

CREATE proc [dbo].ObtenerMonedasExtranjerasAGenerar
    @Fecha DATE,
    @IdContrato INT
AS
BEGIN
    DECLARE @Aprobado INT = 10004,
            @TipoPedimentoImportacion INT = 2,
            @TipoComprobanteExtranjero INT = 3,
            @TipoFactura INT = 1

    CREATE TABLE #Tabla
    (
        SerieBanxico VARCHAR(50),
        FechaPago DATE
    )

    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    select PV_TipoMoneda.SerieBanxico,
           DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)
    FROM dbo.CO_Registro (NOLOCK)
        INNER JOIN dbo.FI_PedimentoComprobante (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
               AND FI_PedimentoComprobante.IdContrato = @IdContrato
               AND CO_Registro.IdEstado = @Aprobado
               AND CO_Registro.CvTipoDocFacturacion IN ( @TipoPedimentoImportacion, @TipoComprobanteExtranjero )
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON PV_TipoMoneda.IdMoneda = FI_PedimentoComprobante.IdMoneda
        INNER JOIN dbo.FI_TransferFactura (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante
        JOIN dbo.FI_Transfer (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CAST(CO_TipoCambioDiario.Fecha AS DATE) = CAST(FI_Transfer.FechaPago AS DATE)
               AND FI_PedimentoComprobante.IdMoneda = CO_TipoCambioDiario.IdMoneda
    WHERE DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Fecha
          AND PV_TipoMoneda.SerieBanxico IS NOT NULL
    GROUP BY PV_TipoMoneda.SerieBanxico,
             DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)


    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    select PV_TipoMoneda.SerieBanxico,
           DATEFROMPARTS(YEAR(FI_Factura.Fecha), MONTH(FI_Factura.Fecha), 1)
    FROM dbo.CO_Registro (NOLOCK)
        INNER JOIN dbo.FI_Factura (NOLOCK)
            ON CO_Registro.IdFactura = FI_Factura.IdFactura
               AND FI_Factura.IdContrato = @IdContrato
               AND CO_Registro.CvTipoDocFacturacion = @TipoFactura
               AND CO_Registro.IdEstado = @Aprobado
               AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON FI_Factura.IdMoneda = PV_TipoMoneda.IdMoneda
        LEFT JOIN dbo.CO_TipoCambioDiario (NOLOCK)
            ON FI_Factura.IdMoneda = CO_TipoCambioDiario.IdMoneda
               AND CAST(FI_Factura.Fecha AS DATE) = CAST(CO_TipoCambioDiario.Fecha AS DATE)
    WHERE DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1) = @Fecha
          AND PV_TipoMoneda.SerieBanxico IS NOT NULL
    GROUP BY PV_TipoMoneda.SerieBanxico,
             DATEFROMPARTS(YEAR(FI_Factura.Fecha), MONTH(FI_Factura.Fecha), 1)

    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT PV_TipoMoneda.SerieBanxico,
           DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)
    FROM FI_Transfer (NOLOCK)
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
    WHERE DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1) = @Fecha
          AND FI_Transfer.IdContrato = @IdContrato
          AND PV_TipoMoneda.SerieBanxico IS NOT NULL
    GROUP BY PV_TipoMoneda.SerieBanxico,
             DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)


    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT SerieBanxico,
           @Fecha
    FROM PV_TipoMoneda
    WHERE IdMoneda = 1



    SELECT #Tabla.SerieBanxico,
           #Tabla.FechaPago
    FROM #Tabla
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON #Tabla.SerieBanxico = PV_TipoMoneda.SerieBanxico
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON #Tabla.FechaPago = DATEFROMPARTS(YEAR(CO_TipoCambioDiario.Fecha), MONTH(CO_TipoCambioDiario.Fecha), 1)
               AND PV_TipoMoneda.IdMoneda = CO_TipoCambioDiario.IdMoneda
    WHERE CO_TipoCambioDiario.IdTipoCambio IS NULL
    GROUP BY #Tabla.SerieBanxico,
             #Tabla.FechaPago

END