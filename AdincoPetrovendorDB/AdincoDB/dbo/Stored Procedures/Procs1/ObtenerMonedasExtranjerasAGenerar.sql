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


	-- El mes Actual por en caso de que no vaya
    INSERT INTO #Tabla
    (
        SerieBanxico,
        FechaPago
    )
    SELECT SerieBanxico,
           @Fecha
    FROM PV_TipoMoneda (NOLOCK)
    WHERE IdMoneda = 1




	-- Se insertan los tipos de cambio en DLS si es que hacen falta
	INSERT INTO CO_TipoCambioDiario(IdMoneda, Fecha, TipoCambio, IdUsuario, Activo, CreadoPor)
	SELECT 2, FechaPago, 1, 1, 1, 1
	FROM #Tabla
	LEFT JOIN CO_TipoCambioDiario (NOLOCK)
		ON #Tabla.FechaPago = CO_TipoCambioDiario.Fecha
		AND CO_TipoCambioDiario.IdMoneda = 2
	WHERE SerieBanxico IS NULL AND CO_TipoCambioDiario.IdTipoCambio IS NULL
	GROUP BY FechaPago



	-- Se retorna al usuario los tipos de cambio que hacen falta dar de alta excepto DLS
    SELECT #Tabla.SerieBanxico,
           DATEFROMPARTS(YEAR(#Tabla.FechaPago), MONTH(#Tabla.FechaPago), 1) FechaPago
    FROM #Tabla
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON #Tabla.SerieBanxico = PV_TipoMoneda.SerieBanxico
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON #Tabla.FechaPago = CAST(CO_TipoCambioDiario.Fecha AS DATE)
               AND PV_TipoMoneda.IdMoneda = CO_TipoCambioDiario.IdMoneda
    WHERE CO_TipoCambioDiario.IdTipoCambio IS NULL
    GROUP BY #Tabla.SerieBanxico,
             DATEFROMPARTS(YEAR(#Tabla.FechaPago), MONTH(#Tabla.FechaPago), 1)

END