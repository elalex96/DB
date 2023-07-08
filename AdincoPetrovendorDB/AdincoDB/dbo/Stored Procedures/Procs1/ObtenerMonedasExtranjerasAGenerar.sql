CREATE PROCEDURE [dbo].[ObtenerMonedasExtranjerasAGenerar] 
    @Fecha DATETIME,
    @IdContrato INT
AS
BEGIN
    DECLARE @Aprobado INT = 10004
    DECLARE @DiaMaximo INT = 0

    CREATE TABLE #Tabla
    (
        SerieBanxico VARCHAR(50),
        FechaPago DATETIME
    )

    CREATE TABLE #TablaVerificacion
    (
        IdMoneda INT,
        SerieBanxico VARCHAR(50),
        FechaPago DATETIME,
        Dias INT
    )

    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT PV_TipoMoneda.SerieBanxico,
           DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1) AS FechaPago
    FROM FI_PedimentoComprobante (NOLOCK)
        INNER JOIN FI_TransferFactura (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante
        INNER JOIN FI_Transfer (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
        INNER JOIN CO_Registro (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
               AND FI_PedimentoComprobante.IdContrato = @IdContrato
               AND CO_Registro.IdEstado = @Aprobado
               AND (CAST(CO_Registro.MesPresentacion AS DATE) = CAST(@Fecha AS DATE))
               AND FI_PedimentoComprobante.IdMoneda <> 1
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CAST(CO_TipoCambioDiario.Fecha AS DATE) = CAST(FI_Transfer.FechaPago AS DATE)
               AND FI_PedimentoComprobante.IdMoneda = CO_TipoCambioDiario.IdMoneda
               AND CO_TipoCambioDiario.IdMoneda <> 1
    WHERE CO_TipoCambioDiario.Fecha IS NULL
          AND PV_TipoMoneda.SerieBanxico IS NOT NULL
          AND (CAST(CO_Registro.MesPresentacion AS DATE) = CAST(@Fecha AS DATE))
    GROUP BY PV_TipoMoneda.SerieBanxico,
             DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)

    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT PV_TipoMoneda.SerieBanxico,
           DATEFROMPARTS(YEAR(FI_PedimentoComprobante.FechaPago), MONTH(FI_PedimentoComprobante.FechaPago), 1) AS FechaPago
    FROM FI_PedimentoComprobante (NOLOCK)
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
        INNER JOIN CO_Registro (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
               AND FI_PedimentoComprobante.IdContrato = @IdContrato
               AND CO_Registro.IdEstado = @Aprobado
               AND (CAST(CO_Registro.MesPresentacion AS DATE) = CAST(@Fecha AS DATE))
               AND FI_PedimentoComprobante.IdMoneda <> 1
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CAST(CO_TipoCambioDiario.Fecha AS DATE) = CAST(FI_PedimentoComprobante.FechaPago AS DATE)
               AND FI_PedimentoComprobante.IdMoneda = CO_TipoCambioDiario.IdMoneda
               AND CO_TipoCambioDiario.IdMoneda <> 1
    WHERE CO_TipoCambioDiario.Fecha IS NULL
          AND PV_TipoMoneda.SerieBanxico IS NOT NULL
          AND (CAST(CO_Registro.MesPresentacion AS DATE) = CAST(@Fecha AS DATE))
    GROUP BY PV_TipoMoneda.SerieBanxico,
             DATEFROMPARTS(YEAR(FI_PedimentoComprobante.FechaPago), MONTH(FI_PedimentoComprobante.FechaPago), 1)

    -- Facturas PUE
    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT PV_TipoMoneda.SerieBanxico,
           DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)
    FROM FI_Factura (NOLOCK)
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON FI_Factura.IdContrato = @IdContrato
               AND FI_Factura.IdMoneda = PV_TipoMoneda.IdMoneda
               AND (
                       FI_Factura.MetodoPago LIKE '%exhibi%'
                       OR FI_Factura.MetodoPago LIKE '%PUE%'
                       OR FI_Factura.FormaPago LIKE '%exhibi%'
                       OR FI_Factura.FormaPago LIKE '%PUE%'
                   )
        INNER JOIN FI_TransferFactura (NOLOCK)
            ON FI_Factura.IdFactura = FI_TransferFactura.IdFactura
        INNER JOIN FI_Transfer (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
        INNER JOIN CO_Registro (NOLOCK)
            ON FI_Factura.IdFactura = CO_Registro.IdFactura
               AND CO_Registro.IdEstado = @Aprobado
               AND (CAST(CO_Registro.MesPresentacion AS DATE) = CAST(@Fecha AS DATE))
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CAST(CO_TipoCambioDiario.Fecha AS DATE) = CAST(FI_Transfer.FechaPago AS DATE)
               AND FI_Factura.IdMoneda = CO_TipoCambioDiario.IdMoneda
               AND CO_TipoCambioDiario.IdMoneda <> 1
    WHERE CO_TipoCambioDiario.Fecha IS NULL
          AND PV_TipoMoneda.SerieBanxico IS NOT NULL
          AND (CAST(CO_Registro.MesPresentacion AS DATE) = CAST(@Fecha AS DATE))
          AND CO_Registro.CvTipoDocFacturacion = 1
          AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0
    GROUP BY PV_TipoMoneda.SerieBanxico,
             DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)

    -- Facturas PPD
    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT PV_TipoMoneda.SerieBanxico,
           DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)
    FROM dbo.FI_Transfer (NOLOCK)
        JOIN dbo.FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
               AND FI_TransferFactura.CvTipoDocFacturacion = 6
               AND FI_Transfer.IdContrato = @IdContrato
        JOIN dbo.FI_ComplementoDePago (NOLOCK)
            ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
        JOIN dbo.FI_CPDocRelacionado (NOLOCK)
            ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
        JOIN dbo.FI_Factura (NOLOCK)
            ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
        JOIN FI_Factura FCPDR (NOLOCK)
            ON FI_CPDocRelacionado.IdDocumento = FCPDR.UUID
               AND FI_Factura.IdContrato = FCPDR.IdContrato
               AND (
                       FI_Factura.MetodoPago LIKE '%parcia%'
                       OR FI_Factura.MetodoPago LIKE '%dife%'
                       OR FI_Factura.MetodoPago LIKE '%PPD%'
                       OR FI_Factura.FormaPago LIKE '%parcia%'
                       OR FI_Factura.FormaPago LIKE '%dife%'
                       OR FI_Factura.FormaPago LIKE '%PPD%'
                       OR FI_Factura.TipoComprobante = 'P'
                   )
        JOIN dbo.PV_TipoMoneda (NOLOCK)
            ON FI_Transfer.idmoneda = PV_TipoMoneda.idmoneda
        INNER JOIN CO_Registro
            ON FCPDR.IdFactura = CO_Registro.IdFactura
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CAST(CO_TipoCambioDiario.Fecha AS DATE) = CAST(FI_Transfer.FechaPago AS DATE)
               AND FI_Factura.IdMoneda = CO_TipoCambioDiario.IdMoneda
               AND CO_TipoCambioDiario.IdMoneda <> 1
    WHERE CO_TipoCambioDiario.Fecha IS NULL
          AND PV_TipoMoneda.SerieBanxico IS NOT NULL
          AND (CAST(CO_Registro.MesPresentacion AS DATE) = CAST(@Fecha AS DATE))
          AND CO_Registro.CvTipoDocFacturacion = 1
          AND ISNULL(CONVERT(INT, FI_Factura.ProcesadoSIPAC), 0) = 0
    GROUP BY PV_TipoMoneda.SerieBanxico,
             DATEFROMPARTS(YEAR(FI_Transfer.FechaPago), MONTH(FI_Transfer.FechaPago), 1)

    SELECT @DiaMaximo = DAY(EOMONTH(@Fecha))

    INSERT INTO #TablaVerificacion
    (
        IdMoneda,
        SerieBanxico,
        FechaPago,
        Dias
    )
    SELECT PV_TipoMoneda.IdMoneda,
           PV_TipoMoneda.SerieBanxico,
           DATEFROMPARTS(YEAR(#Tabla.FechaPago), MONTH(#Tabla.FechaPago), 1),
           0
    FROM PV_TipoMoneda (NOLOCK)
        LEFT JOIN #Tabla
            ON ISNULL(PV_TipoMoneda.Eliminado, 0) = 0
               AND PV_TipoMoneda.SerieBanxico IS NOT NULL
    WHERE PV_TipoMoneda.SerieBanxico NOT IN ( #Tabla.SerieBanxico )

    UPDATE #TablaVerificacion
    SET #TablaVerificacion.Dias =
        (
            SELECT count(IdMoneda)
            FROM CO_TipoCambioDiario (NOLOCK)
            WHERE #TablaVerificacion.IdMoneda = CO_TipoCambioDiario.IdMoneda
                  AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(@Fecha)
                  AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(@Fecha)
        )

    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT #TablaVerificacion.SerieBanxico,
           #TablaVerificacion.FechaPago
    FROM #TablaVerificacion
    WHERE #TablaVerificacion.Dias <> @DiaMaximo
	
    SELECT #Tabla.SerieBanxico,
           DATEFROMPARTS(YEAR(#Tabla.FechaPago), MONTH(#Tabla.FechaPago), 1) AS FechaPago
    FROM #Tabla
    GROUP BY SerieBanxico,
             DATEFROMPARTS(YEAR(FechaPago), MONTH(FechaPago), 1)
END