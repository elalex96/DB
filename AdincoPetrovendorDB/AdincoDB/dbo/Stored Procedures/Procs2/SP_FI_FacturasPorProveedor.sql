IF EXISTS
(
    SELECT 1
    FROM sysobjects
    WHERE name = 'SP_FI_FacturasPorProveedor'
)
    DROP PROCEDURE SP_FI_FacturasPorProveedor;
GO

-- =============================================
-- Author:      Marcos Garcia
-- Create date: 05-12-2019
-- Description: Seleccion de Facturas por Proveedor
--				de los Contratos de el Mismo Contratista.   
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturasPorProveedor]
    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @Relacion INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    IF OBJECT_ID('tempdb..#ContratosTempo', 'U') IS NOT NULL
        DROP TABLE #ContratosTempo;

    IF OBJECT_ID('tempdb..#Contrato', 'U') IS NOT NULL
        DROP TABLE #Contrato;

    IF OBJECT_ID('tempdb..#ContratosFacturas', 'U') IS NOT NULL
        DROP TABLE #ContratosFacturas;

    IF OBJECT_ID('tempdb..#TemporalFacturas', 'U') IS NOT NULL
        DROP TABLE #TemporalFacturas

    IF OBJECT_ID('tempdb..#TemporalFacturasLigadas', 'U') IS NOT NULL
        DROP TABLE #TemporalFacturasLigadas

    --
    CREATE TABLE #ContratosTempo
    (
        IdContrato INT,
        NumeroContrato NVARCHAR(50)
    );

    --
    CREATE TABLE #Contrato
    (
        IdFactura INT,
        IdContrato INT,
        NumeroContrato VARCHAR(200)
    );

    --
    CREATE TABLE #ContratosFacturas
    (
        IdFactura INT,
        NumeroContrato VARCHAR(8000)
    );

    --
    CREATE TABLE #TemporalFacturas
    (
        IdFactura INT NULL,
        NumeroContrato VARCHAR(200) NULL,
        Serie VARCHAR(200) NULL,
        Folio VARCHAR(200) NULL,
        Fecha DATETIME NULL,
        FormaPago VARCHAR(200) NULL,
        SubTotal MONEY NULL,
        Moneda VARCHAR(200) NULL,
        MontoConIva MONEY NULL,
        TipoComprobante VARCHAR(200) NULL,
        MetodoPago VARCHAR(200) NULL,
        LugarExpedicion VARCHAR(200) NULL,
        UUID VARCHAR(200) NULL,
        FechaRecepcion DATETIME NULL,
        RazonSocial VARCHAR(200) NULL,
        Emisor VARCHAR(200) NULL
    )

    --
    CREATE TABLE #TemporalFacturasLigadas
    (
        IdFactura INT NULL,
        NumeroContrato VARCHAR(8000) NULL,
        UUID VARCHAR(200) NULL
    )

    --
    DECLARE @IdContratista INT;

    --
    SET @IdContratista =
    (
        SELECT IdContratista
        FROM CO_Contrato (NOLOCK)
        WHERE IdContrato = @IdContrato
    );

    /**/
    --Contratistas Jaguar
    IF (@IdContratista = 10005 OR @IdContratista = 10006)
    BEGIN
        INSERT INTO #ContratosTempo
        (
            IdContrato,
            NumeroContrato
        )
        SELECT IdContrato,
               NumeroContrato
        FROM CO_Contrato (NOLOCK)
        WHERE IdContratista IN ( 10005, 10006 )
              AND ISNULL(Activo, 0) = 1;
    END;
    /**/
    --Todos los demas Contratista
    ELSE
    BEGIN
        INSERT INTO #ContratosTempo
        (
            IdContrato,
            NumeroContrato
        )
        SELECT IdContrato,
               NumeroContrato
        FROM CO_Contrato (NOLOCK)
        WHERE IdContratista = @IdContratista
              AND ISNULL(Activo, 0) = 1;
    END;

    /*Selección  de Facturas de Todos los Contratos Relacionados*/
    IF (@Relacion = 0)
    BEGIN
        INSERT INTO #TemporalFacturas
        (
            IdFactura,
            NumeroContrato,
            Serie,
            Folio,
            Fecha,
            FormaPago,
            SubTotal,
            Moneda,
            MontoConIva,
            TipoComprobante,
            MetodoPago,
            LugarExpedicion,
            UUID,
            FechaRecepcion,
            RazonSocial,
            Emisor
        )
        SELECT FI_Factura.IdFactura,
               #ContratosTempo.NumeroContrato,
               FI_Factura.Serie,
               FI_Factura.Folio,
               FI_Factura.Fecha,
               CASE
                   WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                        OR FI_Factura.MetodoPago LIKE '%PUE%' THEN
                       FI_Factura.FormaPago
                   WHEN FI_Factura.FormaPago LIKE '%exhibi%'
                        OR FI_Factura.FormaPago LIKE '%PUE%' THEN
                       FI_Factura.MetodoPago
               END FormaPago,
               FI_Factura.SubTotal,
               FI_Factura.Moneda,
               FI_Factura.MontoConIva,
               FI_Factura.TipoComprobante,
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
               END AS MetodoPago,
               SUBSTRING(FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
               FI_Factura.UUID,
               FI_Factura.FechaRecepcion,
               PV_Subcontratista.RazonSocial,
               FI_Factura.Emisor
        FROM #ContratosTempo
            JOIN FI_Factura (NOLOCK)
                ON #ContratosTempo.IdContrato = FI_Factura.IdContrato
                   AND FI_Factura.IdSubcontratista = @IdProveedor
                   AND FI_Factura.TipoComprobante <> 'P'
                   AND (
                           FI_Factura.MetodoPago LIKE '%exhibi%'
                           OR FI_Factura.MetodoPago LIKE '%PUE%'
                           OR FI_Factura.FormaPago LIKE '%exhibi%'
                           OR FI_Factura.FormaPago LIKE '%PUE%'
                       )
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
        GROUP BY FI_Factura.IdFactura,
                 #ContratosTempo.NumeroContrato,
                 FI_Factura.Serie,
                 FI_Factura.Folio,
                 FI_Factura.Fecha,
                 CASE
                     WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                          OR FI_Factura.MetodoPago LIKE '%PUE%' THEN
                         FI_Factura.FormaPago
                     WHEN FI_Factura.FormaPago LIKE '%exhibi%'
                          OR FI_Factura.FormaPago LIKE '%PUE%' THEN
                         FI_Factura.MetodoPago
                 END,
                 FI_Factura.SubTotal,
                 FI_Factura.Moneda,
                 FI_Factura.MontoConIva,
                 FI_Factura.TipoComprobante,
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
                 END,
                 SUBSTRING(FI_Factura.LugarExpedicion, 0, 15),
                 FI_Factura.UUID,
                 FI_Factura.FechaRecepcion,
                 PV_Subcontratista.RazonSocial,
                 FI_Factura.Emisor

        INSERT INTO #TemporalFacturas
        (
            IdFactura,
            NumeroContrato,
            Serie,
            Folio,
            Fecha,
            FormaPago,
            SubTotal,
            Moneda,
            MontoConIva,
            TipoComprobante,
            MetodoPago,
            LugarExpedicion,
            UUID,
            FechaRecepcion,
            RazonSocial,
            Emisor
        )
        SELECT FI_Factura.IdFactura,
               #ContratosTempo.NumeroContrato,
               FI_Factura.Serie,
               FI_Factura.Folio,
               FI_Factura.Fecha,
               CASE
                   WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                        OR FI_Factura.MetodoPago LIKE '%PUE%'
                        OR FI_Factura.MetodoPago LIKE '%parcia%'
                        OR FI_Factura.MetodoPago LIKE '%dife%'
                        OR FI_Factura.MetodoPago LIKE '%PPD%' THEN
                       FI_Factura.FormaPago
                   WHEN FI_Factura.FormaPago LIKE '%exhibi%'
                        OR FI_Factura.FormaPago LIKE '%PUE%'
                        OR FI_Factura.FormaPago LIKE '%parcia%'
                        OR FI_Factura.FormaPago LIKE '%dife%'
                        OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                       FI_Factura.MetodoPago
               END FormaPago,
               FI_Factura.SubTotal,
               FI_Factura.Moneda,
               FI_Factura.MontoConIva,
               FI_Factura.TipoComprobante,
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
               END AS MetodoPago,
               SUBSTRING(FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
               FI_Factura.UUID,
               FI_Factura.FechaRecepcion,
               PV_Subcontratista.RazonSocial,
               FI_Factura.Emisor
        FROM #ContratosTempo
            JOIN FI_Factura (NOLOCK)
                ON #ContratosTempo.IdContrato = FI_Factura.IdContrato
                   AND FI_Factura.IdSubcontratista = @IdProveedor
                   AND FI_Factura.TipoComprobante <> 'P'
                   AND (
                           FI_Factura.MetodoPago LIKE '%parcia%'
                           OR FI_Factura.MetodoPago LIKE '%dife%'
                           OR FI_Factura.MetodoPago LIKE '%PPD%'
                           OR FI_Factura.FormaPago LIKE '%parcia%'
                           OR FI_Factura.FormaPago LIKE '%dife%'
                           OR FI_Factura.FormaPago LIKE '%PPD%'
                       )
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
        GROUP BY FI_Factura.IdFactura,
                 #ContratosTempo.NumeroContrato,
                 FI_Factura.Serie,
                 FI_Factura.Folio,
                 FI_Factura.Fecha,
                 CASE
                     WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                          OR FI_Factura.MetodoPago LIKE '%PUE%'
                          OR FI_Factura.MetodoPago LIKE '%parcia%'
                          OR FI_Factura.MetodoPago LIKE '%dife%'
                          OR FI_Factura.MetodoPago LIKE '%PPD%' THEN
                         FI_Factura.FormaPago
                     WHEN FI_Factura.FormaPago LIKE '%exhibi%'
                          OR FI_Factura.FormaPago LIKE '%PUE%'
                          OR FI_Factura.FormaPago LIKE '%parcia%'
                          OR FI_Factura.FormaPago LIKE '%dife%'
                          OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                         FI_Factura.MetodoPago
                 END,
                 FI_Factura.SubTotal,
                 FI_Factura.Moneda,
                 FI_Factura.MontoConIva,
                 FI_Factura.TipoComprobante,
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
                 END,
                 SUBSTRING(FI_Factura.LugarExpedicion, 0, 15),
                 FI_Factura.UUID,
                 FI_Factura.FechaRecepcion,
                 PV_Subcontratista.RazonSocial,
                 FI_Factura.Emisor

        INSERT INTO #TemporalFacturas
        (
            IdFactura,
            NumeroContrato,
            Serie,
            Folio,
            Fecha,
            FormaPago,
            SubTotal,
            Moneda,
            MontoConIva,
            TipoComprobante,
            MetodoPago,
            LugarExpedicion,
            UUID,
            FechaRecepcion,
            RazonSocial,
            Emisor
        )
        SELECT FI_Factura.IdFactura,
               #ContratosTempo.NumeroContrato,
               FI_Factura.Serie,
               FI_Factura.Folio,
               FI_Factura.Fecha,
               CASE
                   WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                        OR FI_Factura.MetodoPago LIKE '%PUE%'
                        OR FI_Factura.MetodoPago LIKE '%parcia%'
                        OR FI_Factura.MetodoPago LIKE '%dife%'
                        OR FI_Factura.MetodoPago LIKE '%PPD%' THEN
                       FI_Factura.FormaPago
                   WHEN FI_Factura.FormaPago LIKE '%exhibi%'
                        OR FI_Factura.FormaPago LIKE '%PUE%'
                        OR FI_Factura.FormaPago LIKE '%parcia%'
                        OR FI_Factura.FormaPago LIKE '%dife%'
                        OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                       FI_Factura.MetodoPago
               END ormaPago,
               FI_Factura.SubTotal,
               FI_Factura.Moneda,
               FI_Factura.MontoConIva,
               FI_Factura.TipoComprobante,
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
               END AS MetodoPago,
               SUBSTRING(FI_Factura.LugarExpedicion, 0, 15) AS LugarExpedicion,
               FI_Factura.UUID,
               FI_Factura.FechaRecepcion,
               PV_Subcontratista.RazonSocial,
               FI_Factura.Emisor
        FROM #ContratosTempo
            JOIN FI_Factura (NOLOCK)
                ON #ContratosTempo.IdContrato = FI_Factura.IdContrato
                   AND FI_Factura.IdSubcontratista = @IdProveedor
                   AND FI_Factura.TipoComprobante <> 'P'
                   AND (
                           FI_Factura.MetodoPago LIKE '%parcia%'
                           OR FI_Factura.MetodoPago LIKE '%dife%'
                           OR FI_Factura.MetodoPago LIKE '%PPD%'
                           OR FI_Factura.FormaPago LIKE '%parcia%'
                           OR FI_Factura.FormaPago LIKE '%dife%'
                           OR FI_Factura.FormaPago LIKE '%PPD%'
                       )
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
        GROUP BY FI_Factura.IdFactura,
                 #ContratosTempo.NumeroContrato,
                 FI_Factura.Serie,
                 FI_Factura.Folio,
                 FI_Factura.Fecha,
                 CASE
                     WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                          OR FI_Factura.MetodoPago LIKE '%PUE%'
                          OR FI_Factura.MetodoPago LIKE '%parcia%'
                          OR FI_Factura.MetodoPago LIKE '%dife%'
                          OR FI_Factura.MetodoPago LIKE '%PPD%' THEN
                         FI_Factura.FormaPago
                     WHEN FI_Factura.FormaPago LIKE '%exhibi%'
                          OR FI_Factura.FormaPago LIKE '%PUE%'
                          OR FI_Factura.FormaPago LIKE '%parcia%'
                          OR FI_Factura.FormaPago LIKE '%dife%'
                          OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                         FI_Factura.MetodoPago
                 END,
                 FI_Factura.SubTotal,
                 FI_Factura.Moneda,
                 FI_Factura.MontoConIva,
                 FI_Factura.TipoComprobante,
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
                 END,
                 SUBSTRING(FI_Factura.LugarExpedicion, 0, 15),
                 FI_Factura.UUID,
                 FI_Factura.FechaRecepcion,
                 PV_Subcontratista.RazonSocial,
                 FI_Factura.Emisor;

        /*Eliminación de Facturas que ya encuentran en varios contratos*/
        DELETE #TemporalFacturas
        FROM #TemporalFacturas
            INNER JOIN FI_FacturaContrato
                ON #TemporalFacturas.IdFactura = FI_FacturaContrato.IdFactura

        /*Select Final*/
        SELECT IdFactura,
               ISNULL(LTRIM(RTRIM(NumeroContrato)), '') NumeroContrato,
               ISNULL(LTRIM(RTRIM(Serie)), '') Serie,
               ISNULL(LTRIM(RTRIM(Folio)), '') Folio,
               Fecha,
               ISNULL(LTRIM(RTRIM(FormaPago)), '') FormaPago,
               SubTotal,
               ISNULL(LTRIM(RTRIM(Moneda)), '') Moneda,
               MontoConIva,
               ISNULL(LTRIM(RTRIM(TipoComprobante)), '') TipoComprobante,
               ISNULL(LTRIM(RTRIM(MetodoPago)), '') MetodoPago,
               ISNULL(LTRIM(RTRIM(LugarExpedicion)), '') LugarExpedicion,
               ISNULL(LTRIM(RTRIM(UUID)), '') UUID,
               FechaRecepcion,
               ISNULL(LTRIM(RTRIM(RazonSocial)), '') RazonSocial,
               ISNULL(LTRIM(RTRIM(Emisor)), '') Emisor
        FROM #TemporalFacturas
        GROUP BY IdFactura,
                 ISNULL(LTRIM(RTRIM(NumeroContrato)), ''),
                 ISNULL(LTRIM(RTRIM(Serie)), ''),
                 ISNULL(LTRIM(RTRIM(Folio)), ''),
                 Fecha,
                 ISNULL(LTRIM(RTRIM(FormaPago)), ''),
                 SubTotal,
                 ISNULL(LTRIM(RTRIM(Moneda)), ''),
                 MontoConIva,
                 ISNULL(LTRIM(RTRIM(TipoComprobante)), ''),
                 ISNULL(LTRIM(RTRIM(MetodoPago)), ''),
                 ISNULL(LTRIM(RTRIM(LugarExpedicion)), ''),
                 ISNULL(LTRIM(RTRIM(UUID)), ''),
                 FechaRecepcion,
                 ISNULL(LTRIM(RTRIM(RazonSocial)), ''),
                 ISNULL(LTRIM(RTRIM(Emisor)), '')
        ORDER BY MetodoPago,
                 Fecha DESC
    END;

    IF (@Relacion <> 0)
    BEGIN
        IF (@IdContratista = 10005 OR @IdContratista = 10006)
        BEGIN
            INSERT INTO #Contrato
            (
                IdFactura,
                IdContrato,
                NumeroContrato
            )
            SELECT FI_FacturaContrato.IdFactura,
                   CO_Contrato.IdContrato,
                   CO_Contrato.NumeroContrato
            FROM FI_FacturaContrato (NOLOCK)
                JOIN CO_Contrato (NOLOCK)
                    ON FI_FacturaContrato.IdContrato = CO_Contrato.IdContrato
                       AND CO_Contrato.IdContratista IN ( 10005, 10006 )
            GROUP BY FI_FacturaContrato.IdFactura,
                     CO_Contrato.IdContrato,
                     CO_Contrato.NumeroContrato
        END;
        ELSE
        BEGIN
            INSERT INTO #Contrato
            (
                IdFactura,
                IdContrato,
                NumeroContrato
            )
            SELECT FI_FacturaContrato.IdFactura,
                   CO_Contrato.IdContrato,
                   CO_Contrato.NumeroContrato
            FROM FI_FacturaContrato (NOLOCK)
                JOIN CO_Contrato (NOLOCK)
                    ON FI_FacturaContrato.IdContrato = CO_Contrato.IdContrato
                       AND CO_Contrato.IdContratista = @IdContratista
        END;

        --
        INSERT INTO #ContratosFacturas
        (
            IdFactura,
            NumeroContrato
        )
        SELECT B.IdFactura,
               STUFF(
               (
                   SELECT ' | ' + ISNULL(RTRIM(LTRIM(U.NumeroContrato)), '')
                   FROM #Contrato U
                   WHERE B.IdFactura = U.IdFactura
                   FOR XML PATH('')
               ),
               1,
               2,
               ''
                    )
        FROM #Contrato B
        GROUP BY B.IdFactura;

        --------------------
        INSERT INTO #TemporalFacturasLigadas
        (
            IdFactura,
            NumeroContrato,
            UUID
        )
        SELECT FI_Factura.IdFactura,
               ('Contrato Principal: ' + ISNULL(LTRIM(RTRIM(CO_Contrato.NumeroContrato)), '-')
                + ' | Contrato(s) Relacionado(s): ' + ISNULL(LTRIM(RTRIM(#ContratosFacturas.NumeroContrato)), '-')
               ) AS NumeroContrato,
               FI_Factura.UUID
        FROM #ContratosTempo
            JOIN FI_Factura (NOLOCK)
                ON #ContratosTempo.IdContrato = FI_Factura.IdContrato
                   AND FI_Factura.TipoComprobante <> 'P'
                   AND FI_Factura.IdSubcontratista = @IdProveedor
                   AND (
                           FI_Factura.MetodoPago LIKE '%exhibi%'
                           OR FI_Factura.MetodoPago LIKE '%PUE%'
                           OR FI_Factura.FormaPago LIKE '%exhibi%'
                           OR FI_Factura.FormaPago LIKE '%PUE%'
                       )
            JOIN #ContratosFacturas
                ON FI_Factura.IdFactura = #ContratosFacturas.IdFactura
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
            JOIN CO_Contrato (NOLOCK)
                ON FI_Factura.IdContrato = CO_Contrato.IdContrato
            JOIN FI_FacturaContrato (NOLOCK)
                ON FI_Factura.IdFactura = FI_FacturaContrato.IdFactura
        GROUP BY ('Contrato Principal: ' + ISNULL(LTRIM(RTRIM(CO_Contrato.NumeroContrato)), '-')
                  + ' | Contrato(s) Relacionado(s): ' + ISNULL(LTRIM(RTRIM(#ContratosFacturas.NumeroContrato)), '-')
                 ),
                 FI_Factura.IdFactura,
                 FI_Factura.UUID

        --
        INSERT INTO #TemporalFacturasLigadas
        (
            IdFactura,
            NumeroContrato,
            UUID
        )
        SELECT FI_Factura.IdFactura,
               ('Contrato Principal: ' + ISNULL(LTRIM(RTRIM(CO_Contrato.NumeroContrato)), '-')
                + ' | Contrato(s) Relacionado(s): ' + ISNULL(LTRIM(RTRIM(#ContratosFacturas.NumeroContrato)), '-')
               ) AS NumeroContrato,
               FI_Factura.UUID
        FROM #ContratosTempo
            JOIN FI_Factura (NOLOCK)
                ON #ContratosTempo.IdContrato = FI_Factura.IdContrato
                   AND FI_Factura.IdSubcontratista = @IdProveedor
                   AND FI_Factura.TipoComprobante <> 'P'
                   AND (
                           FI_Factura.MetodoPago LIKE '%parcia%'
                           OR FI_Factura.MetodoPago LIKE '%dife%'
                           OR FI_Factura.MetodoPago LIKE '%PPD%'
                           OR FI_Factura.FormaPago LIKE '%parcia%'
                           OR FI_Factura.FormaPago LIKE '%dife%'
                           OR FI_Factura.FormaPago LIKE '%PPD%'
                       )
            JOIN #ContratosFacturas
                ON FI_Factura.IdFactura = #ContratosFacturas.IdFactura
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
            JOIN CO_Contrato (NOLOCK)
                ON FI_Factura.IdContrato = CO_Contrato.IdContrato
            JOIN FI_FacturaContrato (NOLOCK)
                ON FI_Factura.IdFactura = FI_FacturaContrato.IdFactura
        GROUP BY ('Contrato Principal: ' + ISNULL(LTRIM(RTRIM(CO_Contrato.NumeroContrato)), '-')
                  + ' | Contrato(s) Relacionado(s): ' + ISNULL(LTRIM(RTRIM(#ContratosFacturas.NumeroContrato)), '-')
                 ),
                 FI_Factura.IdFactura,
                 FI_Factura.UUID

        --
        INSERT INTO #TemporalFacturasLigadas
        (
            IdFactura,
            NumeroContrato,
            UUID
        )
        SELECT FI_Factura.IdFactura,
               ('Contrato Principal: ' + ISNULL(LTRIM(RTRIM(CO_Contrato.NumeroContrato)), '-')
                + ' | Contrato(s) Relacionado(s): ' + ISNULL(LTRIM(RTRIM(#ContratosFacturas.NumeroContrato)), '-')
               ) AS NumeroContrato,
               FI_Factura.UUID
        FROM #ContratosTempo
            JOIN FI_Factura (NOLOCK)
                ON #ContratosTempo.IdContrato = FI_Factura.IdContrato
                   AND FI_Factura.IdSubcontratista = @IdProveedor
                   AND FI_Factura.TipoComprobante <> 'P'
                   AND (
                           FI_Factura.MetodoPago LIKE '%parcia%'
                           OR FI_Factura.MetodoPago LIKE '%dife%'
                           OR FI_Factura.MetodoPago LIKE '%PPD%'
                           OR FI_Factura.FormaPago LIKE '%parcia%'
                           OR FI_Factura.FormaPago LIKE '%dife%'
                           OR FI_Factura.FormaPago LIKE '%PPD%'
                       )
            JOIN #ContratosFacturas
                ON FI_Factura.IdFactura = #ContratosFacturas.IdFactura
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
            JOIN CO_Contrato (NOLOCK)
                ON FI_Factura.IdContrato = CO_Contrato.IdContrato
            JOIN FI_FacturaContrato (NOLOCK)
                ON FI_Factura.IdFactura = FI_FacturaContrato.IdFactura
        GROUP BY ('Contrato Principal: ' + ISNULL(LTRIM(RTRIM(CO_Contrato.NumeroContrato)), '-')
                  + ' | Contrato(s) Relacionado(s): ' + ISNULL(LTRIM(RTRIM(#ContratosFacturas.NumeroContrato)), '-')
                 ),
                 FI_Factura.IdFactura,
                 FI_Factura.UUID;

        /*Select Final*/
        SELECT IdFactura,
               ISNULL(LTRIM(RTRIM(NumeroContrato)), '') NumeroContrato,
               ISNULL(LTRIM(RTRIM(UUID)), '') UUID
        FROM #TemporalFacturasLigadas
        GROUP BY IdFactura,
                 ISNULL(LTRIM(RTRIM(NumeroContrato)), ''),
                 ISNULL(LTRIM(RTRIM(UUID)), '')
        ORDER BY IdFactura
    END;
END;