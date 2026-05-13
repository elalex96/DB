IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE object_id = OBJECT_ID(N'[dbo].[USP_SEL_CO_ResumenGastosElegiblesCertificados]')
          AND type = 'P'
)
BEGIN
    DROP PROCEDURE [dbo].[USP_SEL_CO_ResumenGastosElegiblesCertificados];
END
GO

CREATE PROCEDURE dbo.USP_SEL_CO_ResumenGastosElegiblesCertificados
(
    @IdPresupuesto INT,
    @Anio INT,
    @Mes INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;

    DECLARE @CGEAprobadoPemex VARCHAR(10);
    DECLARE @FechaInicioPeriodo DATE;
    DECLARE @FechaFinPeriodo DATE;

    SET @FechaInicioPeriodo = DATEFROMPARTS(@Anio, @Mes, 1);
    SET @FechaFinPeriodo = DATEADD(MONTH, 1, @FechaInicioPeriodo);

    SET @CGEAprobadoPemex =
        CAST(@Anio AS VARCHAR(4)) + ' - ' + RIGHT('00' + CAST(@Mes AS VARCHAR(2)), 2);

    CREATE TABLE #BaseReporte
    (
        IdRegistro INT,
        [Plan] VARCHAR(500),
        Periodo VARCHAR(10),
        MesPresentacion DATE,
        TipoDeServicio VARCHAR(500),
        Actividad VARCHAR(500),
        Comentarios VARCHAR(MAX),
        Subcontratista VARCHAR(500),
        Numero VARCHAR(200),
        FechaDocumento DATE,
        Moneda VARCHAR(50),
        MontoRegistro DECIMAL(18,2),
        TipoCambio DECIMAL(19,4),
        ImporteEstimadoParcialUSD DECIMAL(18,2)
    );

    CREATE TABLE #GastosElegibles
    (
        IdRegistro INT,
        [Plan] VARCHAR(500),
        Periodo VARCHAR(10),
        Clasificacion VARCHAR(500),
        Actividad VARCHAR(500),
        Servicio VARCHAR(MAX),
        Subcontratista VARCHAR(500),
        SerieFolio VARCHAR(200),
        FechaFactura DATE,
        Moneda VARCHAR(50),
        MontoRegistro DECIMAL(18,2),
        TipoCambio DECIMAL(19,4),
        ImporteEstimadoParcialUSD DECIMAL(18,2),
        MesPresentacion DATE
    );

    CREATE TABLE #SaldosAnteriores
    (
        IdRegistro INT,
        [Plan] VARCHAR(500),
        Periodo VARCHAR(10),
        Clasificacion VARCHAR(500),
        Actividad VARCHAR(500),
        Servicio VARCHAR(MAX),
        Subcontratista VARCHAR(500),
        SerieFolio VARCHAR(200),
        FechaFactura DATE,
        Moneda VARCHAR(50),
        MontoRegistro DECIMAL(18,2),
        TipoCambio DECIMAL(19,4),
        ImporteEstimadoParcialUSD DECIMAL(18,2),
        MesPresentacion DATE
    );

    INSERT INTO #BaseReporte
    (
        IdRegistro,
        [Plan],
        Periodo,
        MesPresentacion,
        TipoDeServicio,
        Actividad,
        Comentarios,
        Subcontratista,
        Numero,
        FechaDocumento,
        Moneda,
        MontoRegistro,
        TipoCambio,
        ImporteEstimadoParcialUSD
    )
    SELECT
        V.IdRegistro,
        V.Presupuesto,
        V.[CGE Aprobado Pemex],
        V.MesPresentacion,
        V.TipoDeServicio,
        V.Actividad,
        V.Comentarios,

        CASE
            WHEN RF.IdFacturaHijo IS NOT NULL THEN 'Lumex Operaciones'
            ELSE V.Subcontratista
        END AS Subcontratista,

        CASE
            WHEN RF.IdFacturaHijo IS NOT NULL THEN
                LTRIM(RTRIM(ISNULL(FP.Serie, '') + ' ' + ISNULL(FP.Folio, '')))
            ELSE
                V.Numero
        END AS Numero,

        CASE
            WHEN RF.IdFacturaHijo IS NOT NULL THEN FP.Fecha
            ELSE V.FechaDocumento
        END AS FechaDocumento,

        CASE
            WHEN RF.IdFacturaHijo IS NOT NULL THEN TMH.TipoMonedaCorto
            ELSE V.Moneda
        END AS Moneda,

        CAST(V.MontoRegistro AS DECIMAL(18,2)),
        CAST(V.TipoCambio AS DECIMAL(19,4)),
        CAST(V.ImporteEstimadoParcialUSD AS DECIMAL(18,2))
    FROM dbo.GastosAmatitlan2020 V WITH (NOLOCK)
        LEFT JOIN dbo.CO_Registro R WITH (NOLOCK)
            ON R.IdRegistro = V.IdRegistro
        LEFT JOIN dbo.FI_RelacionRefacturas RF WITH (NOLOCK)
            ON RF.idFacturaHijo = R.IdFactura
        LEFT JOIN dbo.FI_Factura FP WITH (NOLOCK)
            ON FP.IdFactura = RF.idFacturaPadre
        LEFT JOIN dbo.PV_TipoMoneda TMH WITH (NOLOCK)
            ON TMH.IdMoneda = FP.IdMoneda
    WHERE V.IdPresupuesto = @IdPresupuesto
      AND V.[CGE Aprobado Pemex] = @CGEAprobadoPemex
      AND V.[Estatus Certificado] = 'Certificado GE Aprobado CACI';

    INSERT INTO #GastosElegibles
    (
        IdRegistro,
        [Plan],
        Periodo,
        Clasificacion,
        Actividad,
        Servicio,
        Subcontratista,
        SerieFolio,
        FechaFactura,
        Moneda,
        MontoRegistro,
        TipoCambio,
        ImporteEstimadoParcialUSD,
        MesPresentacion
    )
    SELECT
        IdRegistro,
        [Plan],
        Periodo,
        TipoDeServicio,
        Actividad,
        Comentarios,
        Subcontratista,
        Numero,
        FechaDocumento,
        Moneda,
        MontoRegistro,
        TipoCambio,
        ImporteEstimadoParcialUSD,
        MesPresentacion
    FROM #BaseReporte
    WHERE MesPresentacion >= @FechaInicioPeriodo
      AND MesPresentacion < @FechaFinPeriodo;

    INSERT INTO #SaldosAnteriores
    (
        IdRegistro,
        [Plan],
        Periodo,
        Clasificacion,
        Actividad,
        Servicio,
        Subcontratista,
        SerieFolio,
        FechaFactura,
        Moneda,
        MontoRegistro,
        TipoCambio,
        ImporteEstimadoParcialUSD,
        MesPresentacion
    )
    SELECT
        IdRegistro,
        [Plan],
        Periodo,
        TipoDeServicio,
        Actividad,
        Comentarios,
        Subcontratista,
        Numero,
        FechaDocumento,
        Moneda,
        MontoRegistro,
        TipoCambio,
        ImporteEstimadoParcialUSD,
        MesPresentacion
    FROM #BaseReporte
    WHERE MesPresentacion < @FechaInicioPeriodo;

    SELECT
        [Plan] = MAX([Plan]),
        Periodo = @CGEAprobadoPemex,
        PeriodoTexto = 
            UPPER(LEFT(DATENAME(MONTH, DATEFROMPARTS(@Anio, @Mes, 1)), 1)) +
            LOWER(SUBSTRING(DATENAME(MONTH, DATEFROMPARTS(@Anio, @Mes, 1)), 2, LEN(DATENAME(MONTH, DATEFROMPARTS(@Anio, @Mes, 1))))) +
            '/' +
            CAST(@Anio AS VARCHAR(4)),

        GastosElegiblesAprobados =
            CAST(ISNULL((SELECT SUM(ISNULL(ImporteEstimadoParcialUSD, 0)) FROM #GastosElegibles), 0) AS DECIMAL(18,2)),

        SaldoPendientesMesesAnterioresAprobados =
            CAST(ISNULL((SELECT SUM(ISNULL(ImporteEstimadoParcialUSD, 0)) FROM #SaldosAnteriores), 0) AS DECIMAL(18,2)),

        GastosElegiblesCertificarMes =
            CAST(
                ISNULL((SELECT SUM(ISNULL(ImporteEstimadoParcialUSD, 0)) FROM #GastosElegibles), 0)
                +
                ISNULL((SELECT SUM(ISNULL(ImporteEstimadoParcialUSD, 0)) FROM #SaldosAnteriores), 0)
            AS DECIMAL(18,2))
    FROM #BaseReporte;

    SELECT
        IdRegistro,
        [Plan],
        Periodo,
        Clasificacion,
        Actividad,
        Servicio,
        Subcontratista,
        SerieFolio,
        FechaFactura,
        Moneda,
        MontoRegistro,
        TipoCambio,
        ImporteEstimadoParcialUSD
    FROM #GastosElegibles
    ORDER BY FechaFactura, SerieFolio;

    SELECT
        IdRegistro,
        [Plan],
        Periodo,
        Clasificacion,
        Actividad,
        Servicio,
        Subcontratista,
        SerieFolio,
        FechaFactura,
        Moneda,
        MontoRegistro,
        TipoCambio,
        ImporteEstimadoParcialUSD
    FROM #SaldosAnteriores
    ORDER BY MesPresentacion, FechaFactura, SerieFolio;
END;
GO