CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContratoGastos]
    @IdContrato INT      = 0,
    @IdUsuario  INT      = 0,
    @Del        DateTime = NULL,
    @Al         DateTime = NULL
AS
    -- =============================================
    -- Author: Miguel Gomez
    -- Create date: 14-01-2017
    -- Description: Lista las facturas de un contrato
    -- =============================================
    -- Modifier: Neri del Angel
    -- Modifier date: 24-06-2021
    -- Description: Update tipo comprobante cuando tipo comprobante is null y uuid is null
    -- =============================================
	-- Modifier: Reyna Olvera
    -- Modifier date: 28-03-2023
    -- Description: Se modifica para que todas las operadoras puedan visualizar su s facturas de nomina 
    -- =============================================
    BEGIN

        SET NOCOUNT ON;
        SET LANGUAGE spanish;
  
        CREATE TABLE #CartasProcura
            (
                IdFacutra INT,
                UUID      VARCHAR(5000)
            );
        /**/
        CREATE TABLE #Facturas
            (
                IdFactura        INT,
                NombreEmisor     VARCHAR(5000),
                RFC_Emisor       VARCHAR(5000),
                Fecha            DATETIME,
                Serie            VARCHAR(5000),
                Folio            VARCHAR(5000),
                SubTotal         FLOAT,
                Descuento        FLOAT,
                TipoCambio       FLOAT,
                Total            FLOAT,
                Moneda           VARCHAR(5000),
                TipoComprobante  VARCHAR(5000),
                MetodoPago       VARCHAR(5000),
                LugarExpedicion  VARCHAR(5000),
                NumCtaPago       VARCHAR(5000),
                RFC_Receptor     VARCHAR(5000),
                UUID             VARCHAR(5000),
                FechaTimbrado    DATETIME,
                SelloCFD         VARCHAR(5000),
                NoCertificadoSAT VARCHAR(5000),
                SelloSAT         VARCHAR(5000),
                Tipo             VARCHAR(5000),
                FechaRecepcion   DATETIME,
                Año              INT,
                Mes              VARCHAR(5000),
                NombreReceptor   VARCHAR(5000),
                TieneArchivo     BIT,
                IVA              FLOAT,
                IdContrato       INT,
                CCN              BIT,
                CRCCN            VARCHAR(5000),
                EsDePetrovendor  BIT
            );

        CREATE TABLE #COMPRA_DIRECTA (UUID VARCHAR(5000))

		DECLARE @NombreAreaContractual VARCHAR(5000) = '', @IdTipoDocumentoFactura INT = 1, @IdTipoOperacionPetrovendor INT = 14, @IdEstatusArchivoPetro INT = 2;

        SELECT TOP 1
            @NombreAreaContractual = ISNULL(CO_AreaContractual.NombreAreaContractual, '')
        FROM
            CO_Contrato
            JOIN
                CO_AreaContractual
                    ON CO_Contrato.IdContrato = @IdContrato
                       AND CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual
        /**/

        INSERT INTO #CartasProcura
            (
                IdFacutra,
                UUID
            )
                    SELECT DISTINCT
                        FP.IdFactura,
                        FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
                    FROM
                        Petrovendor.dbo.MM_AceptacionCartaPCN    AS AC (NOLOCK)
                        JOIN
                            Petrovendor.dbo.S_Documento_S3       AS D (NOLOCK)
                                ON D.IdDocumento = AC.IdDocumento
                                   AND AC.IdEstatus = @IdEstatusArchivoPetro
                                   AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                        JOIN
                            Petrovendor.dbo.MM_AceptacionPedido  AS AP (NOLOCK)
                                ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                        JOIN
                            Petrovendor.dbo.MM_Pedido            AS P (NOLOCK)
                                ON P.IdPedido = AP.IdPedido
                                   AND P.IdContrato = @IdContrato
                        JOIN
                            Petrovendor.dbo.S_Proveedor          AS PR (NOLOCK)
                                ON PR.IdProveedor = P.IdSubcontratista
                        JOIN
                            Petrovendor.dbo.S_TipoValidacionDoc  AS TD (NOLOCK)
                                ON TD.IdTipoValidacionDoc = AC.IdEstatus
                        JOIN
                            Petrovendor.dbo.MM_Pedidos           AS PG (NOLOCK)
                                ON P.IdPedido = PG.IdIdentificador
                        LEFT JOIN
                            Petrovendor.dbo.MM_TipoPedido        AS TP (NOLOCK)
                                ON TP.IdTipoPedido = PG.IdTipoPedido
                        LEFT JOIN
                            Petrovendor.dbo.MM_AceptacionFactura AF (NOLOCK)
                                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                        LEFT JOIN
                            Petrovendor.dbo.FI_Factura           FP (NOLOCK)
                                ON FP.IdFactura = AF.IdFactura
                    WHERE
                        AC.IdEstatus = @IdEstatusArchivoPetro
                        AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                        AND P.IdContrato = @IdContrato
                        AND FP.UUID IS NOT NULL
                        AND FP.Activa = 1
                        AND ISNULL(FP.IsEliminado, 0) <> 1; --*******
        /**/
        IF @IdContrato = 10007 --AMATITLAN
            BEGIN
                INSERT INTO #Facturas
                    (
                        IdFactura,
                        NombreEmisor,
                        RFC_Emisor,
                        Fecha,
                        Serie,
                        Folio,
                        SubTotal,
                        Descuento,
                        TipoCambio,
                        Total,
                        Moneda,
                        TipoComprobante,
                        MetodoPago,
                        LugarExpedicion,
                        NumCtaPago,
                        RFC_Receptor,
                        UUID,
                        FechaTimbrado,
                        SelloCFD,
                        NoCertificadoSAT,
                        SelloSAT,
                        Tipo,
                        FechaRecepcion,
                        Año,
                        Mes,
                        NombreReceptor,
                        TieneArchivo,
                        IVA,
                        IdContrato,
                        CCN,
                        CRCCN,
                        EsDePetrovendor
                    )
                            SELECT
                                F.IdFactura,
                                S.RazonSocial                       AS NombreEmisor,
                                S.RFC                               AS RFC_Emisor,
                                F.Fecha,
                                F.Serie,
                                F.Folio,
                                F.SubTotal,
                                F.Descuento,
                                F.TipoCambio,
                                F.MontoConIva                       AS Total,
                                M.TipoMonedaCorto                   AS Moneda,
                                SUBSTRING(F.TipoComprobante, 1, 1)  AS TipoComprobante,
                                F.MetodoPago,
                                SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
                                F.NumCtaPago,
                                CC.RFC                              AS Receptor,
                                F.UUID,
                                F.FechaTimbrado,
                                F.SelloCFD,
                                F.NoCertificadoSAT,
                                F.SelloSAT,
                                F.Tipo,
                                F.FechaRecepcion,
                                YEAR(F.Fecha)                       AS Año,
                                CONCAT(
                                          RIGHT('00' + CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ',
                                          DATENAME(MONTH, F.Fecha)
                                      )                             AS Mes,
                                CC.RazonSocial                      AS Receptor,
                                TieneArchivo                        = CAST(CASE
                                                                               WHEN D.DocumentoByte IS NULL
                                                                                   THEN 0
                                                                               ELSE
                                                                                   1
                                                                           END AS BIT),
                                ISNULL((F.MontoConIva * .16), 0)    AS IVA,
                                C.IdContrato,
                                CASE
                                    WHEN WAD.IdDocAwsDocAdinco IS NULL
                                        THEN 0
                                    ELSE
                                        1
                                END                                 AS CCN,
                                NULL                                AS CRCCN,
                                0
                            FROM
                                dbo.FI_Factura              AS F (NOLOCK)
                                JOIN
                                    dbo.PV_Subcontratista   AS S (NOLOCK)
                                        ON F.IdSubcontratista = S.IdSubcontratista
                                           AND F.IdContrato = @IdContrato
                                JOIN
                                    dbo.CO_Contrato         C (NOLOCK)
                                        ON F.IdContrato = C.IdContrato
                                JOIN
                                    dbo.CO_Contratista      CC (NOLOCK)
                                        ON C.IdContratista = CC.IdContratista
                                JOIN
                                    dbo.PV_TipoMoneda       M (NOLOCK)
                                        ON M.IdMoneda = F.IdMoneda
                                LEFT JOIN
                                    dbo.FI_Documento        D (NOLOCK)
                                        ON F.IdFactura = D.IdFactura
                                           AND D.IdTipoDocumento = @IdTipoDocumentoFactura
                                           AND ISNULL(D.IsEliminado, 0) = 0
                                LEFT JOIN
                                    dbo.AWS_DocAwsDocAdinco WAD (NOLOCK)
                                        ON F.IdFactura = WAD.IdDocAdinco
                            WHERE
                                F.IdContrato = @IdContrato
                                AND (
                                        (
                                            (
                                                @Del IS NOT NULL
                                                AND @Al IS NOT NULL
                                            )
                                            AND CONVERT(VARCHAR, F.Fecha, 112)
                                BETWEEN CONVERT(VARCHAR, @Del, 112) AND CONVERT(VARCHAR, @Al, 112)
                                        )
                                        OR (
                                               @Del IS NULL
                                               OR @Al IS NULL
                                           )
                                    )
                            ORDER BY
                                F.IdFactura DESC;
            END;

        ELSE
            BEGIN
                INSERT INTO #Facturas
                    (
                        IdFactura,
                        NombreEmisor,
                        RFC_Emisor,
                        Fecha,
                        Serie,
                        Folio,
                        SubTotal,
                        Descuento,
                        TipoCambio,
                        Total,
                        Moneda,
                        TipoComprobante,
                        MetodoPago,
                        LugarExpedicion,
                        NumCtaPago,
                        RFC_Receptor,
                        UUID,
                        FechaTimbrado,
                        SelloCFD,
                        NoCertificadoSAT,
                        SelloSAT,
                        Tipo,
                        FechaRecepcion,
                        Año,
                        Mes,
                        NombreReceptor,
                        TieneArchivo,
                        IVA,
                        IdContrato,
                        CCN,
                        CRCCN,
                        EsDePetrovendor
                    )
                            SELECT DISTINCT
                                F.IdFactura,
                                S.RazonSocial                       AS NombreEmisor,
                                S.RFC                               AS RFC_Emisor,
                                F.Fecha,
                                F.Serie,
                                F.Folio,
                                F.SubTotal,
                                F.Descuento,
                                F.TipoCambio,
                                F.MontoConIva                       AS Total,
                                M.TipoMonedaCorto                   AS Moneda,
                                SUBSTRING(F.TipoComprobante, 1, 1)  AS TipoComprobante,
                                F.MetodoPago,
                                SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
                                F.NumCtaPago,
                                CC.RFC                              AS Receptor,
                                F.UUID,
                                F.FechaTimbrado,
                                F.SelloCFD,
                                F.NoCertificadoSAT,
                                F.SelloSAT,
                                F.Tipo,
                                F.FechaRecepcion,
                                YEAR(F.Fecha)                       AS Año,
                                CONCAT(
                                          RIGHT('00' + CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ',
                                          DATENAME(MONTH, F.Fecha)
                                      )                             AS Mes,
                                CC.RazonSocial                      AS Receptor,
                                TieneArchivo                        = CAST(CASE
                                                                               WHEN D.DocumentoByte IS NULL
                                                                                   THEN 0
                                                                               ELSE
                                                                                   1
                                                                           END AS BIT),
                                ISNULL((F.MontoConIva * .16), 0)    AS IVA,
                                C.IdContrato,
                                CASE
                                    WHEN WAD.IdDocAwsDocAdinco IS NULL
                                        THEN 0
                                    ELSE
                                        1
                                END                                 AS CCN,
                                NULL                                AS CRCCN,
                                0
                            FROM
                                dbo.FI_Factura              AS F (NOLOCK)
                                JOIN
                                    dbo.PV_Subcontratista   AS S (NOLOCK)
                                        ON F.IdSubcontratista = S.IdSubcontratista
                                           AND F.IdContrato = @IdContrato
                                JOIN
                                    dbo.CO_Contrato         C (NOLOCK)
                                        ON F.IdContrato = C.IdContrato
                                JOIN
                                    dbo.CO_Contratista      CC (NOLOCK)
                                        ON C.IdContratista = CC.IdContratista
                                JOIN
                                    dbo.PV_TipoMoneda       M (NOLOCK)
                                        ON M.IdMoneda = F.IdMoneda
                                LEFT JOIN
                                    dbo.FI_Documento        D (NOLOCK)
                                        ON F.IdFactura = D.IdFactura
                                           AND D.IdTipoDocumento = @IdTipoDocumentoFactura
                                           AND ISNULL(D.IsEliminado, 0) = 0
                                LEFT JOIN
                                    dbo.AWS_DocAwsDocAdinco WAD	(NOLOCK)
                                        ON F.IdFactura = WAD.IdDocAdinco
                            WHERE
                                F.IdContrato = @IdContrato
                                AND (
                                        (
                                            (
                                                @Del IS NOT NULL
                                                AND @Al IS NOT NULL
                                            )
                                            AND CONVERT(VARCHAR, F.Fecha, 112)
                                BETWEEN CONVERT(VARCHAR, @Del, 112) AND CONVERT(VARCHAR, @Al, 112)
                                        )
                                        OR (
                                               @Del IS NULL
                                               OR @Al IS NULL
                                           )
                                    )
                            UNION
                            SELECT DISTINCT
                                F.IdFactura,
                                S.RazonSocial                       AS NombreEmisor,
                                S.RFC                               AS RFC_Emisor,
                                F.Fecha,
                                F.Serie,
                                F.Folio,
                                F.SubTotal,
                                F.Descuento,
                                F.TipoCambio,
                                F.MontoConIva                       AS Total,
                                M.TipoMonedaCorto                   AS Moneda,
                                SUBSTRING(F.TipoComprobante, 1, 1)  AS TipoComprobante,
                                F.MetodoPago,
                                SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
                                F.NumCtaPago,
                                CC.RFC                              AS Receptor,
                                F.UUID,
                                F.FechaTimbrado,
                                F.SelloCFD,
                                F.NoCertificadoSAT,
                                F.SelloSAT,
                                F.Tipo,
                                F.FechaRecepcion,
                                YEAR(F.Fecha)                       AS Año,
                                CONCAT(
                                          RIGHT('00' + CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ',
                                          DATENAME(MONTH, F.Fecha)
                                      )                             AS Mes,
                                CC.RazonSocial                      AS Receptor,
                                TieneArchivo                        = CAST(CASE
                                                                               WHEN D.DocumentoByte IS NULL
                                                                                   THEN 0
                                                                               ELSE
                                                                                   1
                                                                           END AS BIT),
                                ISNULL((F.MontoConIva * .16), 0)    AS IVA,
                                F.IdContrato,
                                CASE
                                    WHEN WAD.IdDocAwsDocAdinco IS NULL
                                        THEN 0
                                    ELSE
                                        1
                                END                                 AS CCN,
                                NULL                                AS CRCCN,
                                0
                            FROM
								dbo.FI_Factura              AS F (NOLOCK)
                            JOIN
                                dbo.FI_FacturaContrato  FC (NOLOCK)
                                    ON F.IdFactura = FC.IdFactura
                                        AND FC.IdContrato = @IdContrato
                            JOIN
                                dbo.PV_Subcontratista   AS S (NOLOCK)
                                    ON F.IdSubcontratista = S.IdSubcontratista
                            JOIN
                                dbo.CO_Contrato         C (NOLOCK)
                                    ON FC.IdContrato = C.IdContrato
                            JOIN
                                dbo.CO_Contratista      CC (NOLOCK)
                                    ON C.IdContratista = CC.IdContratista
                            JOIN
                                dbo.PV_TipoMoneda       M (NOLOCK)
                                    ON M.IdMoneda = F.IdMoneda
                            LEFT JOIN
                                dbo.FI_Documento        D (NOLOCK)
                                    ON F.IdFactura = D.IdFactura
                                        AND D.IdTipoDocumento = @IdTipoDocumentoFactura
                                        AND ISNULL(D.IsEliminado, 0) = 0
                            LEFT JOIN
                                dbo.AWS_DocAwsDocAdinco WAD (NOLOCK)
                                    ON F.IdFactura = WAD.IdDocAdinco
                            WHERE
                                FC.IdContrato = @IdContrato
                                AND (
                                        (
                                            (
                                                @Del IS NOT NULL
                                                AND @Al IS NOT NULL
                                            )
                                            AND CONVERT(VARCHAR, F.Fecha, 112)
                                BETWEEN CONVERT(VARCHAR, @Del, 112) AND CONVERT(VARCHAR, @Al, 112)
                                        )
                                        OR (
                                               @Del IS NULL
                                               OR @Al IS NULL
                                           )
                                    )
                            ORDER BY
                                F.IdFactura DESC;
            END;

        UPDATE
            #Facturas
        SET
            CCN = 0

        UPDATE
            #Facturas
        SET
            CCN = 1
        FROM
            #Facturas          F
            JOIN
                #CartasProcura CP
                    ON CP.UUID = F.UUID
        WHERE
            F.UUID = CP.UUID;

        /**/

        UPDATE
            #Facturas
        SET
            CCN = 1
        FROM
            #Facturas
            JOIN
                FI_Factura	(NOLOCK)
                    ON #Facturas.UUID = FI_Factura.UUID
            JOIN
                AWS_DocAwsDocAdinco	(NOLOCK)
                    ON AWS_DocAwsDocAdinco.IdDocAdinco = FI_Factura.IdFactura

        UPDATE
            #Facturas
        SET
            TipoComprobante = ''
        WHERE
            TipoComprobante IS NULL
            AND UUID IS NULL

        UPDATE
            #Facturas
        SET
            EsDePetrovendor = 0
        WHERE
            EsDePetrovendor IS NULL

        UPDATE
            #Facturas
        SET
            EsDePetrovendor = 1
        FROM
            #Facturas
            JOIN
                FI_FacturaAdincoPetrovendor
                    ON #Facturas.IdFactura = FI_FacturaAdincoPetrovendor.IdFacturaAdinco;

        IF EXISTS
            (
                SELECT
                    #Facturas.*
                FROM
                    #Facturas
                    JOIN
                        FI_Factura	(NOLOCK)
                            ON #Facturas.IdFactura = FI_Factura.IdFactura
                    JOIN
                        Petrovendor.dbo.FI_Factura FI_Factura_Petrovendor	(NOLOCK)
                            ON FI_Factura.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FI_Factura_Petrovendor.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
                WHERE
                    #Facturas.IdFactura = FI_Factura.IdFactura
                    AND ISNULL(FI_Factura.UUID, '') <> ''
            )
            BEGIN
                UPDATE
                    #Facturas
                SET
                    EsDePetrovendor = 1
                FROM
                    #Facturas
                    JOIN
                        FI_Factura	(NOLOCK)
                            ON #Facturas.IdFactura = FI_Factura.IdFactura
                    JOIN
                        Petrovendor.dbo.FI_Factura FI_Factura_Petrovendor	(NOLOCK)
                            ON FI_Factura.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FI_Factura_Petrovendor.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
                WHERE
                    #Facturas.IdFactura = FI_Factura.IdFactura
                    AND ISNULL(FI_Factura.UUID, '') <> ''
            END
        --
        -- Si es compra directa entonces se debe de mostrar los controles en la edicion
        --
        INSERT INTO #COMPRA_DIRECTA
            (
                UUID
            )
                    SELECT
                            FI_Factura.UUID
                    FROM
                            Petrovendor.dbo.FI_Factura	(NOLOCK)
                        INNER JOIN
                            Petrovendor.dbo.TA_Operacion	(NOLOCK)
                                ON FI_Factura.IdContrato = @IdContrato
                                   AND TA_Operacion.IdTipoOperacion = @IdTipoOperacionPetrovendor
                                   AND FI_Factura.IdFactura = TA_Operacion.IdDocumento
                    WHERE
                            CONVERT(VARCHAR, FI_Factura.Fecha, 112)
                    BETWEEN CONVERT(VARCHAR, @Del, 112) AND CONVERT(VARCHAR, @Al, 112)

        -- Se pone el bit de esPEtrovendor en Falso para que cuando sea una factura de compra directa se muestren los controles en la edicion del gasto
        UPDATE
            #Facturas
        SET
            #Facturas.EsDePetrovendor = 0
        FROM
            #Facturas
		INNER JOIN
            #COMPRA_DIRECTA
         ON #Facturas.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = #COMPRA_DIRECTA.UUID COLLATE SQL_Latin1_General_CP1_CI_AS


        SELECT
            F.IdFactura,
            F.NombreEmisor                                       AS NombreEmisor,
            F.RFC_Emisor                                         AS RFC_Emisor,
            F.Fecha,
            F.Serie,
            F.Folio,
            ISNULL(F.SubTotal, 0)                                AS SubTotal,
            ISNULL(F.Descuento, 0)                               AS Descuento,
            ISNULL(F.TipoCambio, 0)                              AS TipoCambio,
            ISNULL(F.Total, 0)                                   AS Total,
            ISNULL(F.Moneda, 'NA')                               AS Moneda,
            UPPER(ISNULL(F.TipoComprobante, ''))                 AS TipoComprobante,
            UPPER(ISNULL(F.MetodoPago, ''))                      AS MetodoPago,
            UPPER(ISNULL(F.LugarExpedicion, ''))                 AS LugarExpedicion,
            UPPER(ISNULL(F.NumCtaPago, ''))                      AS NumCtaPago,
            F.RFC_Receptor                                       AS Receptor,
            ISNULL(F.UUID, 'NA')                                 AS UUID,
            F.FechaTimbrado,
            ISNULL(F.SelloCFD, '')                               AS SelloCFD,
            ISNULL(F.NoCertificadoSAT, '')                       AS NoCertificadoSAT,
            ISNULL(F.SelloSAT, '')                               AS SelloSAT,
            ISNULL(CONCAT(F.TipoComprobante, ' - ', F.Tipo), '') AS Tipo,
            F.FechaRecepcion,
            F.Año,
            F.Mes,
            F.NombreReceptor                                     AS Receptor,
            F.TieneArchivo,
            F.IVA,
            F.IdContrato,
            F.CCN,
            F.CRCCN,
            C.NumeroContrato,
            CAST(CASE
                     WHEN @NombreAreaContractual = 'Amatitlán'
                         THEN ISNULL(F.EsDePetrovendor, 0)
                     ELSE
                         1
                 END AS BIT)                                     AS EsDePetrovendor
        FROM
            #Facturas           F
            JOIN
                dbo.CO_Contrato C	(NOLOCK)
                    ON C.IdContrato = F.IdContrato
        WHERE
            F.TipoComprobante NOT LIKE '%P%'
        ORDER BY
            F.IdFactura DESC;
    END;
