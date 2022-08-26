CREATE PROCEDURE [dbo].[SP_CO_ReporteOverhead]  
    @ContratoId INT,
    @UsuarioId INT,
    @MesInicio DATE,
    @MesFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    --
    IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
        DROP TABLE #Facturas;
    IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPPD', 'U') IS NOT NULL
        DROP TABLE #MontosTotalTransferenciaPPD;
    IF OBJECT_ID('tempdb..#MontosTotalTransferenciaPUE', 'U') IS NOT NULL
        DROP TABLE #MontosTotalTransferenciaPUE;
    IF OBJECT_ID('tempdb..#MontosConvertidosPedimentosCom', 'U') IS NOT NULL
        DROP TABLE #MontosConvertidosPedimentosCom;
    IF OBJECT_ID('tempdb..#SumaDePagosDolaresBase', 'U') IS NOT NULL
        DROP TABLE #SumaDePagosDolaresBase;
    IF OBJECT_ID('tempdb..#SumaDePagosDolares', 'U') IS NOT NULL
        DROP TABLE #SumaDePagosDolares;
    IF OBJECT_ID('tempdb..#ResultadosOverhead', 'U') IS NOT NULL
        DROP TABLE #ResultadosOverhead
    --
    DECLARE @GastosConFacturaPPD INT,
            @GastosConFacturaPUE INT,
            @GastosConPedCom INT
    --
    CREATE TABLE #SumaDePagosDolares
    (
        UUID VARCHAR(500),
        Idfactura INT,
        TipoComprobante VARCHAR(50),
        MontoDolares FLOAT,
        MetodoPago VARCHAR(50),
        TipoCambio FLOAT,
        Fecha DATE,
        IdMoneda INT
    );
    CREATE TABLE #SumaDePagosDolaresBase
    (
        UUID VARCHAR(500),
        Idfactura INT,
        TipoComprobante VARCHAR(50),
        MontoDolares FLOAT,
        MetodoPago VARCHAR(50),
        TipoCambio FLOAT,
        Fecha DATE,
        IdMoneda INT,
        MonedaTran INT,
        IdTransferencia INT,
    );
    CREATE TABLE #Facturas
    (
        IdRegistro INT,
        UUID VARCHAR(500),
        Idfactura INT,
        MontoRegistro FLOAT,
        TipoComprobante VARCHAR(50),
        RC2903 FLOAT,
        MetodoPago VARCHAR(50),
        Fecha DATETIME,
        IdMoneda INT,
        MesPresentacion DATE
    );
    CREATE TABLE #MontosTotalTransferenciaPPD
    (
        IdFacturaCP INT,
        UUIDCP VARCHAR(500),
        FormaPagoCP VARCHAR(50),
        MontoCP FLOAT,
        TipoCambioCP FLOAT,
        MonedaCP VARCHAR(50),
        MontoPesos FLOAT,
        MontoDolares FLOAT,
        TipoComprobante VARCHAR(50),
        MontoRegistro FLOAT,
        IdRegistro INT
    );
    CREATE TABLE #MontosTotalTransferenciaPUE
    (
        IdRegistro INT,
        UUID NVARCHAR(500),
        Idfactura INT,
        MontoRegistro FLOAT,
        TipoComprobante NVARCHAR(50),
        RC2903 FLOAT,
        MetodoPago NVARCHAR(50),
        TCD FLOAT,
        FechaTCD DATE,
        IdMoneda INT
    );
    CREATE TABLE #MontosConvertidosPedimentosCom
    (
        IdRegistro INT,
        IdPedimentoComprobante INT,
        MontoRegistro FLOAT,
        RC2903 FLOAT,
        TCD FLOAT
    );
    CREATE TABLE #ResultadosOverhead
    (
        [RF_00] VARCHAR(100),
        [RI_00] VARCHAR(100),
        [RF01_01] VARCHAR(200),
        [RC29_00] INT NULL,
        [RC29_01] INT NULL,
        [RC29_02] VARCHAR(200),
        [RC29_03] FLOAT NULL,
        PresupuestoId INT NULL
    );
    --
    INSERT INTO #Facturas
    (
        IdRegistro,
        UUID,
        Idfactura,
        MontoRegistro,
        TipoComprobante,
        RC2903,
        MetodoPago,
        Fecha,
        IdMoneda,
        MesPresentacion
    )
    SELECT CO_Registro.IdRegistro,
           ISNULL(FI_Factura.UUID, 'NÚMERO NO REGISTRADO') AS UUID,
           FI_Factura.IdFactura,
           CO_Registro.MontoRegistro,
           CASE
               WHEN FI_Factura.TipoComprobante LIKE '%ingreso%'
                    OR FI_Factura.TipoComprobante LIKE 'I%' THEN
                   'I'
               WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                    OR FI_Factura.TipoComprobante LIKE 'E%' THEN
                   'E'
               WHEN (FI_Factura.TipoComprobante) LIKE '%traslado%'
                    OR FI_Factura.TipoComprobante LIKE 'T%' THEN
                   'T'
               WHEN (FI_Factura.TipoComprobante) LIKE '%nómina%'
                    OR FI_Factura.TipoComprobante LIKE 'N%' THEN
                   'N'
               WHEN (FI_Factura.TipoComprobante) LIKE '%pago%'
                    OR FI_Factura.TipoComprobante LIKE 'P%' THEN
                   'P'
               ELSE
                   'NA'
           END AS TipoComprobante,
           SUM(   CASE
                      WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                          CAST(ROUND((ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE
                          0
                  END
              ) AS [RC21_22],
           CASE
               WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                    OR FI_Factura.MetodoPago LIKE '%PUE%'
                    OR FI_Factura.FormaPago LIKE '%exhibi%'
                    OR FI_Factura.FormaPago LIKE '%PUE%' THEN
                   'PUE'
               WHEN FI_Factura.MetodoPago LIKE '%parcia%'
                    OR FI_Factura.MetodoPago LIKE '%dife%'
                    OR FI_Factura.MetodoPago LIKE '%PPD%'
                    OR FI_Factura.FormaPago LIKE '%parcia%'
                    OR FI_Factura.FormaPago LIKE '%dife%'
                    OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                   'PPD'
               WHEN FI_Factura.TipoComprobante = 'P' THEN
                   'PPD'
           END AS MetodoPago,
           FI_Factura.Fecha,
           FI_Factura.IdMoneda,
           CO_Registro.MesPresentacion
    FROM CO_Registro (NOLOCK)
        JOIN FI_Factura (NOLOCK)
            ON CO_Registro.IdFactura = FI_Factura.IdFactura
               AND CO_Registro.IdEstado = 10004
               AND CO_Registro.CvTipoDocFacturacion = 1
        JOIN CO_Contrato (NOLOCK)
            ON CO_Contrato.IdContrato = FI_Factura.IdContrato
        JOIN CO_LineaPresupuestoMes (NOLOCK)
            ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
        JOIN CO_Servicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CO_TipoCambioDiario.IdMoneda = FI_Factura.IdMoneda
               AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Factura.Fecha)
               AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Factura.Fecha)
               AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Factura.Fecha)
    WHERE CO_Contrato.IdContrato = @ContratoId
          AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)
          BETWEEN @MesInicio AND @MesFin
          AND CO_Registro.IdEstado = 10004
          AND CO_Registro.CvTipoDocFacturacion = 1
          AND CO_Servicio.NombreServicio LIKE '%overhead%'
          AND CO_LineaPresupuestoMes.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
    GROUP BY CO_Registro.IdRegistro,
             ISNULL(FI_Factura.UUID, 'NÚMERO NO REGISTRADO'),
             FI_Factura.IdFactura,
             CO_Registro.MontoRegistro,
             CASE
                 WHEN FI_Factura.TipoComprobante LIKE '%ingreso%'
                      OR FI_Factura.TipoComprobante LIKE 'I%' THEN
                     'I'
                 WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                      OR FI_Factura.TipoComprobante LIKE 'E%' THEN
                     'E'
                 WHEN (FI_Factura.TipoComprobante) LIKE '%traslado%'
                      OR FI_Factura.TipoComprobante LIKE 'T%' THEN
                     'T'
                 WHEN (FI_Factura.TipoComprobante) LIKE '%nómina%'
                      OR FI_Factura.TipoComprobante LIKE 'N%' THEN
                     'N'
                 WHEN (FI_Factura.TipoComprobante) LIKE '%pago%'
                      OR FI_Factura.TipoComprobante LIKE 'P%' THEN
                     'P'
                 ELSE
                     'NA'
             END,
             CASE
                 WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                      OR FI_Factura.MetodoPago LIKE '%PUE%'
                      OR FI_Factura.FormaPago LIKE '%exhibi%'
                      OR FI_Factura.FormaPago LIKE '%PUE%' THEN
                     'PUE'
                 WHEN FI_Factura.MetodoPago LIKE '%parcia%'
                      OR FI_Factura.MetodoPago LIKE '%dife%'
                      OR FI_Factura.MetodoPago LIKE '%PPD%'
                      OR FI_Factura.FormaPago LIKE '%parcia%'
                      OR FI_Factura.FormaPago LIKE '%dife%'
                      OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                     'PPD'
                 WHEN FI_Factura.TipoComprobante = 'P' THEN
                     'PPD'
             END,
             FI_Factura.Fecha,
             FI_Factura.IdMoneda,
             CO_Registro.MesPresentacion;
    /*Facturas Con Tipo de Cambio de Transferencia*/
    INSERT INTO #MontosTotalTransferenciaPPD
    (
        IdFacturaCP,
        UUIDCP,
        FormaPagoCP,
        MontoCP,
        TipoCambioCP,
        MonedaCP,
        MontoPesos,
        MontoDolares,
        TipoComprobante,
        MontoRegistro,
        IdRegistro
    )
    SELECT FI_Factura.IdFactura AS IdFacturaCP,
           FI_Factura.UUID AS UUIDCP,
           FI_ComplementoDePago.FormaDePagoP AS FormaPagoCP,
           SUM(FI_CPDocRelacionado.ImpPagado) AS MontoCP,
           CO_TipoCambioDiario.TipoCambio AS TipoCambioCP,
           FI_ComplementoDePago.MonedaP AS MonedaCP,
           CAST(SUM(FI_CPDocRelacionado.ImpPagado) AS DECIMAL(15, 2)) AS MontoPesos,
           CAST(SUM(   CASE
                           WHEN PV_TipoMoneda.IdMoneda = 1 THEN
                               FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                           ELSE
                               FI_CPDocRelacionado.ImpPagado
                       END
                   ) AS DECIMAL(15, 2)) AS MontoDolares,
           FI_Factura.TipoComprobante,
           CAST(#Facturas.MontoRegistro / CO_TipoCambioDiario.TipoCambio AS DECIMAL(15, 2)) AS MontoRegistro,
           #Facturas.IdRegistro #fa
    FROM FI_Transfer (NOLOCK)
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
               AND FI_TransferFactura.CvTipoDocFacturacion = 6
        JOIN FI_ComplementoDePago (NOLOCK)
            ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
        JOIN FI_Factura (NOLOCK)
            ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
        JOIN FI_CPDocRelacionado (NOLOCK)
            ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
        JOIN FI_Factura FI_Factura_CPDR (NOLOCK)
            ON FI_CPDocRelacionado.IdDocumento = FI_Factura_CPDR.UUID
               AND FI_Factura.IdContrato = FI_Factura_CPDR.IdContrato
               AND FI_Factura.IdContrato = FI_Transfer.IdContrato
        JOIN PV_TipoMoneda (NOLOCK)
            ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
        JOIN #Facturas
            ON #Facturas.Idfactura = FI_Factura_CPDR.IdFactura
               AND #Facturas.MetodoPago = 'PPD'
               AND #Facturas.TipoComprobante = 'I'
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda
               AND CO_TipoCambioDiario.IdMoneda = FI_Factura_CPDR.IdMoneda
               AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
               AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
               AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
    WHERE #Facturas.MetodoPago = 'PPD'
          AND #Facturas.TipoComprobante = 'I'
          AND FI_TransferFactura.CvTipoDocFacturacion = 6
          AND CO_TipoCambioDiario.IdMoneda = FI_Factura_CPDR.IdMoneda
    GROUP BY FI_Factura.IdFactura,
             FI_Factura.UUID,
             FI_ComplementoDePago.FormaDePagoP,
             CO_TipoCambioDiario.TipoCambio,
             FI_ComplementoDePago.MonedaP,
             FI_Factura.TipoComprobante,
             CAST(#Facturas.MontoRegistro / CO_TipoCambioDiario.TipoCambio AS DECIMAL(15, 2)),
             #Facturas.IdRegistro
    UNION
    SELECT FI_Factura.IdFactura AS IdFacturaCP,
           FI_Factura.UUID AS UUIDCP,
           FI_ComplementoDePago.FormaDePagoP AS FormaPagoCP,
           SUM(FI_CPDocRelacionado.ImpPagado) AS MontoCP,
           1 AS TipoCambioCP,
           FI_ComplementoDePago.MonedaP AS MonedaCP,
           CAST((SUM(FI_CPDocRelacionado.ImpPagado * CO_TipoCambioDiario.TipoCambio)) AS DECIMAL(15, 2)) AS MontoPesos,
           CAST((SUM(   CASE
                            WHEN PV_TipoMoneda.IdMoneda = 2 THEN
                                FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                            ELSE
                                FI_CPDocRelacionado.ImpPagado
                        END
                    )
                ) AS DECIMAL(15, 2)) AS MontoDolares,
           FI_Factura.TipoComprobante,
           CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro,
           #Facturas.IdRegistro
    FROM FI_Transfer (NOLOCK)
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
               AND FI_TransferFactura.CvTipoDocFacturacion = 6
        JOIN FI_ComplementoDePago (NOLOCK)
            ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
        JOIN FI_Factura (NOLOCK)
            ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
        JOIN FI_CPDocRelacionado (NOLOCK)
            ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
        JOIN FI_Factura FI_Factura_CPDR (NOLOCK)
            ON FI_CPDocRelacionado.IdDocumento = FI_Factura_CPDR.UUID
               AND FI_Factura.IdContrato = FI_Factura_CPDR.IdContrato
               AND FI_Factura.IdContrato = FI_Transfer.IdContrato
        JOIN PV_TipoMoneda (NOLOCK)
            ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
        JOIN #Facturas
            ON #Facturas.Idfactura = FI_Factura_CPDR.IdFactura
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CO_TipoCambioDiario.IdMoneda = PV_TipoMoneda.IdMoneda
               AND CO_TipoCambioDiario.IdMoneda <> FI_Factura_CPDR.IdMoneda
               AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
               AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
               AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
    WHERE #Facturas.MetodoPago = 'PPD'
          AND #Facturas.TipoComprobante = 'I'
          AND FI_TransferFactura.CvTipoDocFacturacion = 6
          AND FI_Transfer.IdMoneda <> PV_TipoMoneda.IdMoneda
          AND PV_TipoMoneda.IdMoneda = FI_Factura_CPDR.IdMoneda
    GROUP BY FI_Factura.IdFactura,
             FI_Factura.UUID,
             FI_ComplementoDePago.FormaDePagoP,
             FI_ComplementoDePago.MonedaP,
             FI_Factura.TipoComprobante,
             CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),
             #Facturas.IdRegistro
	--
    UNION
    --Se agrego para los casos donde el complemento es igual a la moneda de la transferencia (USD = USD) 
    --y la factura ppd es igual a la moneada del documento relacionado (MXN = MXN) 
    SELECT FI_Factura.IdFactura AS IdFacturaCP,
           FI_Factura.UUID AS UUIDCP,
           FI_ComplementoDePago.FormaDePagoP AS FormaPagoCP,
           SUM(FI_CPDocRelacionado.ImpPagado) AS MontoCP,
           1,
           FI_ComplementoDePago.MonedaP AS MonedaCP,
           CAST((SUM(   CASE
                            WHEN PV_TipoMoneda.IdMoneda = 2
                                 AND FI_Factura_CPDR.IdMoneda = 1 THEN
                                FI_CPDocRelacionado.ImpPagado * 1
                        END
                    )
                ) AS DECIMAL(15, 2)) AS MontoPesos,
           CAST((SUM(   CASE
                            WHEN PV_TipoMoneda.IdMoneda = 2
                                 AND FI_Factura_CPDR.IdMoneda = 1 THEN
                                FI_CPDocRelacionado.ImpPagado / CO_TipoCambioDiario.TipoCambio
                            ELSE
                                FI_CPDocRelacionado.ImpPagado
                        END
                    )
                ) AS DECIMAL(15, 2)) AS MontoDolares,
           FI_Factura.TipoComprobante,
           CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)) AS MontoRegistro,
           #Facturas.IdRegistro
    FROM FI_Transfer (NOLOCK)
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
               AND FI_TransferFactura.CvTipoDocFacturacion = 6
        JOIN FI_ComplementoDePago (NOLOCK)
            ON FI_TransferFactura.IdFactura = FI_ComplementoDePago.IdFactura
        JOIN FI_Factura (NOLOCK)
            ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
        JOIN FI_CPDocRelacionado (NOLOCK)
            ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
        JOIN FI_Factura FI_Factura_CPDR (NOLOCK)
            ON FI_CPDocRelacionado.IdDocumento = FI_Factura_CPDR.UUID
               AND FI_Factura.IdContrato = FI_Factura_CPDR.IdContrato
               AND FI_Factura.IdContrato = FI_Transfer.IdContrato
        JOIN PV_TipoMoneda (NOLOCK)
            ON FI_ComplementoDePago.MonedaP = PV_TipoMoneda.TipoMonedaCorto
        JOIN #Facturas
            ON #Facturas.Idfactura = FI_Factura_CPDR.IdFactura
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CO_TipoCambioDiario.IdMoneda <> PV_TipoMoneda.IdMoneda
               AND CO_TipoCambioDiario.IdMoneda = FI_Factura_CPDR.IdMoneda
               AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
               AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
               AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
    WHERE #Facturas.MetodoPago = 'PPD'
          AND #Facturas.TipoComprobante = 'I'
          AND FI_TransferFactura.CvTipoDocFacturacion = 6
          AND FI_Transfer.IdMoneda = PV_TipoMoneda.IdMoneda
          AND PV_TipoMoneda.IdMoneda <> FI_Factura_CPDR.IdMoneda
    GROUP BY FI_Factura.IdFactura,
             FI_Factura.UUID,
             FI_ComplementoDePago.FormaDePagoP,
             FI_ComplementoDePago.MonedaP,
             FI_Factura.TipoComprobante,
             CAST(#Facturas.MontoRegistro AS DECIMAL(15, 2)),
             #Facturas.IdRegistro;

    INSERT INTO #SumaDePagosDolaresBase
    (
        UUID,
        Idfactura,
        TipoComprobante,
        MontoDolares,
        MetodoPago,
        TipoCambio,
        Fecha,
        IdMoneda,
        MonedaTran,
        IdTransferencia
    )
    SELECT DISTINCT
        #Facturas.UUID,
        #Facturas.Idfactura,
        #Facturas.TipoComprobante,
        CASE
            WHEN ISNULL(FI_TransferFactura.MontoPagado, 0) <> 0 THEN
                CAST(ROUND((ISNULL(FI_TransferFactura.MontoPagado, 0) / CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(15, 2))
            ELSE
                0
        END AS MontoDolares,
        #Facturas.MetodoPago,
        CO_TipoCambioDiario.TipoCambio AS TipoCambio,
        CO_TipoCambioDiario.Fecha,
        #Facturas.IdMoneda,
        FI_Transfer.IdMoneda AS MonedaTran,
        FI_Transfer.IdTransferencia
    FROM FI_Transfer (NOLOCK)
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
        JOIN #Facturas
            ON FI_TransferFactura.IdFactura = #Facturas.Idfactura
               AND #Facturas.MetodoPago = 'PUE'
               AND #Facturas.TipoComprobante = 'I'
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CO_TipoCambioDiario.IdMoneda = #Facturas.IdMoneda
               AND CO_TipoCambioDiario.IdMoneda = FI_Transfer.IdMoneda
               AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
               AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
               AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
    WHERE #Facturas.MetodoPago = 'PUE'
          AND #Facturas.TipoComprobante = 'I'
          AND CO_TipoCambioDiario.IdMoneda = #Facturas.IdMoneda;
    INSERT INTO #SumaDePagosDolares
    (
        UUID,
        Idfactura,
        TipoComprobante,
        MontoDolares,
        MetodoPago,
        TipoCambio,
        Fecha,
        IdMoneda
    )
    SELECT UUID,
           Idfactura,
           TipoComprobante,
           SUM(MontoDolares) AS MontoDolares,
           MetodoPago,
           MAX(TipoCambio) AS TipoCambio,
           MAX(Fecha) AS Fecha,
           IdMoneda
    FROM #SumaDePagosDolaresBase
    GROUP BY UUID,
             Idfactura,
             TipoComprobante,
             MetodoPago,
             IdMoneda;

    INSERT INTO #MontosTotalTransferenciaPUE
    (
        IdRegistro,
        UUID,
        Idfactura,
        MontoRegistro,
        TipoComprobante,
        RC2903,
        MetodoPago,
        TCD,
        FechaTCD,
        IdMoneda
    )
    SELECT DISTINCT
        #Facturas.IdRegistro,
        #Facturas.UUID,
        #Facturas.Idfactura,
        #Facturas.MontoRegistro,
        #Facturas.TipoComprobante,
        #SumaDePagosDolares.MontoDolares,
        #Facturas.MetodoPago,
        #SumaDePagosDolares.TipoCambio,
        #SumaDePagosDolares.Fecha,
        #Facturas.IdMoneda
    FROM #Facturas
        JOIN #SumaDePagosDolares
            ON #Facturas.Idfactura = #SumaDePagosDolares.Idfactura
    WHERE #Facturas.MetodoPago = 'PUE'
          AND #Facturas.TipoComprobante = 'I';
    /*PEDIMENTO COMPROBANTE*/
    INSERT INTO #MontosConvertidosPedimentosCom
    (
        IdRegistro,
        IdPedimentoComprobante,
        MontoRegistro,
        RC2903,
        TCD
    )
    SELECT CO_Registro.IdRegistro,
           FI_PedimentoComprobante.IdPedimentoComprobante,
           CO_Registro.MontoRegistro,
           SUM(   CASE
                      WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN
                          CAST(ROUND((ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioDiario.TipoCambio), 2) AS DECIMAL(15, 2))
                      ELSE
                          0
                  END
              ) AS [RC21_22],
           CO_TipoCambioDiario.TipoCambio
    FROM CO_Registro (NOLOCK)
        JOIN FI_PedimentoComprobante (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
               AND CO_Registro.IdEstado = 10004
               AND CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
               AND FI_PedimentoComprobante.IdContrato = @ContratoId
        JOIN CO_Contrato (NOLOCK)
            ON FI_PedimentoComprobante.IdContrato = CO_Contrato.IdContrato
               AND CO_Contrato.IdContrato = @ContratoId
        JOIN CO_LineaPresupuestoMes (NOLOCK)
            ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
        JOIN CO_Servicio (NOLOCK)
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        JOIN FI_TransferFactura (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_TransferFactura.IdPedimentoComprobante
        JOIN FI_Transfer (NOLOCK)
            ON FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
        LEFT JOIN CO_TipoCambioDiario (NOLOCK)
            ON CO_TipoCambioDiario.IdMoneda = FI_PedimentoComprobante.IdMoneda
               AND DAY(CO_TipoCambioDiario.Fecha) = DAY(FI_Transfer.FechaPago)
               AND MONTH(CO_TipoCambioDiario.Fecha) = MONTH(FI_Transfer.FechaPago)
               AND YEAR(CO_TipoCambioDiario.Fecha) = YEAR(FI_Transfer.FechaPago)
    WHERE CO_Contrato.IdContrato = @ContratoId
          AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)
          BETWEEN @MesInicio AND @MesFin
          AND CO_Registro.IdEstado = 10004
          AND CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
          AND CO_Servicio.NombreServicio LIKE '%overhead%'
    GROUP BY CO_Registro.IdRegistro,
             FI_PedimentoComprobante.IdPedimentoComprobante,
             CO_Registro.MontoRegistro,
             CO_TipoCambioDiario.TipoCambio;
    --
    SELECT @GastosConFacturaPPD = COUNT(IdRegistro)
    FROM #MontosTotalTransferenciaPPD;
    -- 
    SELECT @GastosConFacturaPUE = COUNT(IdRegistro)
    FROM #MontosTotalTransferenciaPUE;
    -- 
    SELECT @GastosConPedCom = COUNT(IdRegistro)
    FROM #MontosConvertidosPedimentosCom;
    --
    IF (
           @GastosConFacturaPPD > 0
           OR @GastosConFacturaPUE > 0
           OR @GastosConPedCom > 0
       )
    BEGIN
        INSERT INTO #ResultadosOverhead
        (
            [RF_00],
            [RI_00],
            [RF01_01],
            [RC29_00],
            [RC29_01],
            [RC29_02],
            [RC29_03],
            PresupuestoId
        )
        SELECT LTRIM(RTRIM(CO_Contratista.IDSIPAC)) AS [RF_00],
               LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)) AS [RI_00],
               CO_Contrato.NumeroContrato AS [RF01_01],
               MONTH(CO_Registro.MesPresentacion) AS [RC29_00],
               YEAR(CO_Registro.MesPresentacion) AS [RC29_01],
               SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10) AS [RC21_02],
               SUM(   CASE
                          WHEN ISNULL(#MontosTotalTransferenciaPUE.MontoRegistro, 0) <> 0
                               AND #MontosTotalTransferenciaPUE.TipoComprobante IN ( 'I', 'N', 'P' ) THEN
                              CAST((#MontosTotalTransferenciaPUE.MontoRegistro / #MontosTotalTransferenciaPUE.TCD)
                                   * (#MontosTotalTransferenciaPUE.RC2903
                                      / (FI_Factura_F.MontoConIva / #MontosTotalTransferenciaPUE.TCD)
                                     ) AS DECIMAL(15, 2))
                          ELSE
                              0
                      END
                  ) AS [RC29_03],
               ISNULL(CO_Presupuesto.IdPresupuesto, 0) PresupuestoId
        FROM CO_Registro (NOLOCK)
            JOIN FI_Factura FI_Factura_F (NOLOCK)
                ON CO_Registro.IdFactura = FI_Factura_F.IdFactura
                   AND CO_Registro.IdEstado = 10004
            JOIN #MontosTotalTransferenciaPUE
                ON #MontosTotalTransferenciaPUE.Idfactura = CO_Registro.IdFactura
                   AND #MontosTotalTransferenciaPUE.IdRegistro = CO_Registro.IdRegistro
                   AND #MontosTotalTransferenciaPUE.MetodoPago = 'PUE'
            JOIN CO_LineaPresupuestoMes (NOLOCK)
                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
            JOIN CO_Presupuesto (NOLOCK)
                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
            JOIN CO_AnioContractual (NOLOCK)
                ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                   AND CO_AnioContractual.IdContrato = @ContratoId
            JOIN CO_Contrato (NOLOCK)
                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
                   AND CO_Contrato.IdContrato = @ContratoId
            JOIN CO_Contratista (NOLOCK)
                ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
            JOIN CO_ActividadPetroleraCNH (NOLOCK)
                ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
            JOIN CO_SubactividadPetrolera (NOLOCK)
                ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
            JOIN CO_TareaPetrolera (NOLOCK)
                ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
            JOIN CO_Instalacion (NOLOCK)
                ON CO_Registro.IdInstalacion = CO_Instalacion.IdInstalacion
            JOIN CO_Servicio (NOLOCK)
                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                   AND CO_Contrato.IdContrato = CO_Servicio.IdContrato
        WHERE CO_Contrato.IdContrato = @ContratoId
              AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)
              BETWEEN @MesInicio AND @MesFin
              AND CO_Registro.IdEstado = 10004
              AND CO_Registro.CvTipoDocFacturacion = 1
              AND ISNULL(CONVERT(INT, FI_Factura_F.ProcesadoSIPAC), 0) = 0
              AND CO_Servicio.NombreServicio LIKE '%overhead%'
              AND #MontosTotalTransferenciaPUE.MetodoPago = 'PUE'
              AND CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        GROUP BY LTRIM(RTRIM(CO_Contratista.IDSIPAC)),
                 LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),
                 CO_Contrato.NumeroContrato,
                 MONTH(CO_Registro.MesPresentacion),
                 YEAR(CO_Registro.MesPresentacion),
                 SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10),
                 ISNULL(CO_Presupuesto.IdPresupuesto, 0)
        -- 
		UNION
        -- 
        SELECT LTRIM(RTRIM(CO_Contratista.IDSIPAC)) AS [RF_00],
               LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)) AS [RI_00],
               CO_Contrato.NumeroContrato AS [RF01_01],
               MONTH(CO_Registro.MesPresentacion) AS [RC29_00],
               YEAR(CO_Registro.MesPresentacion) AS [RC29_01],
               SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10) AS [RC21_02],
               SUM(   CASE
                          WHEN ISNULL(#MontosTotalTransferenciaPPD.MontoRegistro, 0) <> 0
                               AND #MontosTotalTransferenciaPPD.TipoComprobante IN ( 'I', 'N', 'P' ) THEN
                              CAST(#MontosTotalTransferenciaPPD.MontoRegistro
                                   * (#MontosTotalTransferenciaPPD.MontoDolares
                                      / (FI_Factura_F.MontoConIva / #MontosTotalTransferenciaPPD.TipoCambioCP)
                                     ) AS DECIMAL(15, 2))
                          ELSE
                              0
                      END
                  ) AS [RC29_03],
               ISNULL(CO_Presupuesto.IdPresupuesto, 0) PresupuestoId
        FROM CO_Registro (NOLOCK)
            JOIN FI_Factura FI_Factura_F (NOLOCK)
                ON CO_Registro.IdFactura = FI_Factura_F.IdFactura
                   AND CO_Registro.IdEstado = 10004
                   AND CO_Registro.CvTipoDocFacturacion = 1
            JOIN FI_CPDocRelacionado (NOLOCK)
                ON FI_Factura_F.UUID = FI_CPDocRelacionado.IdDocumento
            JOIN FI_ComplementoDePago (NOLOCK)
                ON FI_CPDocRelacionado.IdComplementoDePago = FI_ComplementoDePago.IdComplementoDePago
            JOIN #MontosTotalTransferenciaPPD
                ON FI_ComplementoDePago.IdFactura = #MontosTotalTransferenciaPPD.IdFacturaCP
                   AND CO_Registro.IdRegistro = #MontosTotalTransferenciaPPD.IdRegistro
            JOIN FI_Factura (NOLOCK)
                ON #MontosTotalTransferenciaPPD.IdFacturaCP = FI_Factura.IdFactura
            JOIN CO_LineaPresupuestoMes (NOLOCK)
                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
            JOIN CO_Presupuesto (NOLOCK)
                ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
            JOIN CO_AnioContractual (NOLOCK)
                ON CO_Presupuesto.IdAnioContractual = CO_AnioContractual.IdAnioContractual
                   AND CO_AnioContractual.IdContrato = @ContratoId
            JOIN CO_Contrato (NOLOCK)
                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
                   AND CO_Contrato.IdContrato = @ContratoId
            JOIN CO_Contratista (NOLOCK)
                ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
            JOIN CO_ActividadPetroleraCNH APCNH (NOLOCK)
                ON CO_LineaPresupuestoMes.IdActividadPetrolera = APCNH.IdActividadPetrolera
            JOIN CO_SubactividadPetrolera (NOLOCK)
                ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
            JOIN CO_TareaPetrolera (NOLOCK)
                ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
            JOIN CO_Instalacion (NOLOCK)
                ON CO_Registro.IdInstalacion = CO_Instalacion.IdInstalacion
            JOIN CO_Servicio (NOLOCK)
                ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
                   AND CO_Contrato.IdContrato = CO_Servicio.IdContrato
        WHERE CO_Contrato.IdContrato = @ContratoId
              AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)
              BETWEEN @MesInicio AND @MesFin
              AND CO_Registro.IdEstado = 10004
              AND CO_Registro.CvTipoDocFacturacion = 1
              AND ISNULL(CONVERT(INT, FI_Factura_F.ProcesadoSIPAC), 0) = 0
              AND CO_Servicio.NombreServicio LIKE '%overhead%'
              AND FI_Factura.UUID NOT IN (
                                             SELECT ControlF.UUID
                                             FROM FI_ControlPPDComplementos ControlF
                                             WHERE ControlF.IdContrato = @ContratoId
                                         )
              AND CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        GROUP BY LTRIM(RTRIM(CO_Contratista.IDSIPAC)),
                 LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),
                 CO_Contrato.NumeroContrato,
                 MONTH(CO_Registro.MesPresentacion),
                 YEAR(CO_Registro.MesPresentacion),
                 SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10),
                 ISNULL(CO_Presupuesto.IdPresupuesto, 0)
        -- 
		UNION
        -- 
        SELECT LTRIM(RTRIM(CO_Contratista.IDSIPAC)) AS [RF_00],
               LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)) AS [RI_00],
               CO_Contrato.NumeroContrato AS [RF01_01],
               MONTH(CO_Registro.MesPresentacion) AS [RC29_00],
               YEAR(CO_Registro.MesPresentacion) AS [RC29_01],
               SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10) AS [RC29_02],
               SUM(   CASE
                          WHEN ISNULL(#MontosConvertidosPedimentosCom.MontoRegistro, 0) <> 0 THEN
                              #MontosConvertidosPedimentosCom.RC2903
                          ELSE
                              0
                      END
                  ) AS [RC29_03],
               ISNULL(CO_Presupuesto.IdPresupuesto, 0) PresupuestoId
        FROM FI_Transfer (NOLOCK)
            JOIN FI_TransferFactura (NOLOCK)
                ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
            JOIN FI_PedimentoComprobante (NOLOCK)
                ON FI_TransferFactura.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
                   AND FI_Transfer.IdContrato = FI_PedimentoComprobante.IdContrato
            JOIN CO_Registro (NOLOCK)
                ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
                   AND CO_Registro.IdEstado = 10004
                   AND CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
            JOIN CO_LineaPresupuestoMes (NOLOCK)
                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
            JOIN CO_Presupuesto (NOLOCK)
                ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
            JOIN CO_AnioContractual (NOLOCK)
                ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual
            JOIN CO_Contrato (NOLOCK)
                ON CO_AnioContractual.IdContrato = CO_Contrato.IdContrato
                   AND CO_Contrato.IdContrato = @ContratoId
            JOIN CO_Contratista (NOLOCK)
                ON CO_Contrato.IdContratista = CO_Contratista.IdContratista
            JOIN CO_ActividadPetroleraCNH (NOLOCK)
                ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
            JOIN CO_SubactividadPetrolera (NOLOCK)
                ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
            JOIN CO_TareaPetrolera (NOLOCK)
                ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
            JOIN CO_Instalacion (NOLOCK)
                ON CO_Registro.IdInstalacion = CO_Instalacion.IdInstalacion
            JOIN CO_Servicio (NOLOCK)
                ON CO_Servicio.IdServicio = CO_LineaPresupuestoMes.IdServicio
                   AND CO_Contrato.IdContrato = CO_Servicio.IdContrato
            JOIN #MontosConvertidosPedimentosCom
                ON #MontosConvertidosPedimentosCom.IdRegistro = CO_Registro.IdRegistro
                   AND #MontosConvertidosPedimentosCom.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
        WHERE CO_Contrato.IdContrato = @ContratoId
              AND DATEFROMPARTS(YEAR(CO_Registro.MesPresentacion), MONTH(CO_Registro.MesPresentacion), 1)
              BETWEEN @MesInicio AND @MesFin
              AND CO_Registro.IdEstado = 10004
              AND CO_Registro.CvTipoDocFacturacion IN ( 2, 3 )
              AND ISNULL(CONVERT(INT, FI_PedimentoComprobante.ProcesadoSIPAC), 0) = 0
              AND CO_Servicio.NombreServicio LIKE '%overhead%'
              AND ISNULL(FI_PedimentoComprobante.EsnotaCredito, 0) <> 1
              AND CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        GROUP BY LTRIM(RTRIM(CO_Contratista.IDSIPAC)),
                 LTRIM(RTRIM(CO_Contrato.IDRegFiducidiario)),
                 CO_Contrato.NumeroContrato,
                 MONTH(CO_Registro.MesPresentacion),
                 YEAR(CO_Registro.MesPresentacion),
                 SUBSTRING(CO_Presupuesto.IdPresupuestoCNH, 22, 10),
                 ISNULL(CO_Presupuesto.IdPresupuesto, 0)
				 SELECT [RF_00],
               [RI_00],
               [RF01_01],
               [RC29_00],
               [RC29_01],
               [RC29_02],
               SUM([RC29_03]) AS [RC29_03]
        FROM #ResultadosOverhead
        GROUP BY [RF_00],
                 [RI_00],
                 [RF01_01],
                 [RC29_00],
                 [RC29_01],
                 [RC29_02],
                 PresupuestoId
        ORDER BY [RC29_01] ASC,
                 [RC29_00] ASC,
                 [RC29_02] ASC
    END;
	
END;