CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContrato]
    @IdContrato INT = 0,
    @IdUsuario INT = 0
AS
-- =============================================  
-- Author: Miguel Gomez  
-- Create date: 14-01-2017  
-- Description: Lista las facturas de un contrato  
-- =============================================  
-- Author: Marcos Garcia  
-- Alter date: 05-02-2020  
-- Description: Quitar UNION,  
--				Agregar Campos (Creado En, Creado Por)  
-- =============================================  
-- =============================================  
-- Author: Marcos Garcia  
-- Alter date: 18-04-2022  
-- Description: Ajustar Importe,  
--				Se realiza SUM de importes
-- ============================================= 
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    /*  
         --DROP TABLE #CartasProcura;  
         --DROP TABLE #Facturas;  
         */

    CREATE TABLE #CartasProcura
    (
        IdFacutra INT,
        UUID NVARCHAR(200)
    );
    CREATE TABLE #Importes
    (
        IdFactura INT,
        Importe DECIMAL(18, 4)
    );
    /**/
    INSERT INTO #Importes
    (
        IdFactura,
        Importe
    )
    SELECT FIm.IdFactura,
           SUM(Fim.Importe)
    FROM FI_Factura F WITH (NOLOCK)
        INNER JOIN FI_CFDIImpuesto FIm WITH (NOLOCK)
            ON F.IdContrato = @IdContrato
               AND F.IdFactura = Fim.IdFactura
    GROUP BY FIm.IdFactura
    ORDER BY FIm.IdFactura

    CREATE TABLE #Facturas
    (
        IdFactura INT,
        NombreEmisor NVARCHAR(2000),
        RFC_Emisor NVARCHAR(1000),
        NumeroContrato NVARCHAR(1000),
        Fecha DATETIME,
        Serie VARCHAR(1000),
        Folio VARCHAR(1000),
        SubTotal FLOAT,
        Descuento FLOAT,
        TipoCambio FLOAT,
        Total FLOAT,
        Moneda NVARCHAR(1000),
        TipoComprobante NVARCHAR(1000),
        MetodoPago NVARCHAR(1000),
        LugarExpedicion NVARCHAR(1000),
        NumCtaPago NVARCHAR(1000),
        RFC_Receptor NVARCHAR(1000),
        UUID NVARCHAR(1000),
        FechaTimbrado DATETIME,
        SelloCFD NVARCHAR(MAX),
        NoCertificadoSAT NVARCHAR(MAX),
        SelloSAT NVARCHAR(MAX),
        Tipo NVARCHAR(250),
        FechaRecepcion DATETIME,
        Año INT,
        Mes NVARCHAR(1000),
        NombreReceptor NVARCHAR(2000),
        TieneArchivo BIT,
        IVA FLOAT,
        IdContrato INT,
        CCN BIT,
        CRCCN NVARCHAR(1000),
        CreadoEn DATE,
        CreadoPor NVARCHAR(MAX)
    );

    /**/

    INSERT INTO #CartasProcura
    (
        IdFacutra,
        UUID
    )
    SELECT DISTINCT
        FP.IdFactura,
        FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
    FROM Petrovendor.dbo.MM_AceptacionCartaPCN AS AC WITH (NOLOCK)
        JOIN Petrovendor.dbo.S_Documento_S3 AS D WITH (NOLOCK)
            ON D.IdDocumento = AC.IdDocumento
               AND AC.IdEstatus = 2
               AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
        JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP WITH (NOLOCK)
            ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
        JOIN Petrovendor.dbo.MM_Pedido AS P WITH (NOLOCK)
            ON P.IdPedido = AP.IdPedido
               AND P.IdContrato = @IdContrato
        JOIN Petrovendor.dbo.S_Proveedor AS PR WITH (NOLOCK)
            ON PR.IdProveedor = P.IdSubcontratista
        JOIN Petrovendor.dbo.S_TipoValidacionDoc AS TD WITH (NOLOCK)
            ON TD.IdTipoValidacionDoc = AC.IdEstatus
        JOIN Petrovendor.dbo.MM_Pedidos AS PG WITH (NOLOCK)
            ON P.IdPedido = PG.IdIdentificador
        LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP WITH (NOLOCK)
            ON TP.IdTipoPedido = PG.IdTipoPedido
        LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF WITH (NOLOCK)
            ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
        LEFT JOIN Petrovendor.dbo.FI_Factura FP WITH (NOLOCK)
            ON FP.IdFactura = AF.IdFactura
               AND FP.UUID IS NOT NULL
               AND FP.Activa = 1
               AND ISNULL(FP.IsEliminado, 0) <> 1
    /**/

    IF @IdContrato = 10007
    BEGIN
        INSERT INTO #Facturas
        (
            IdFactura,
            NombreEmisor,
            RFC_Emisor,
            NumeroContrato,
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
            CreadoEn,
            CreadoPor
        )
        SELECT F.IdFactura,
               S.RazonSocial AS NombreEmisor,
               S.RFC AS RFC_Emisor,
               C.NumeroContrato,
               F.Fecha,
               F.Serie,
               F.Folio,
               F.SubTotal,
               F.Descuento,
               F.TipoCambio,
               F.MontoConIva AS Total,
               M.TipoMonedaCorto AS Moneda,
               SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante,
               F.MetodoPago,
               SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
               F.NumCtaPago,
               CC.RFC AS Receptor,
               F.UUID,
               F.FechaTimbrado,
               F.SelloCFD,
               F.NoCertificadoSAT,
               F.SelloSAT,
               F.Tipo,
               F.FechaRecepcion,
               YEAR(F.Fecha) AS Año,
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS NVARCHAR(20)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes,
               CC.RazonSocial AS Receptor,
               TieneArchivo = CAST(CASE
                                       WHEN D.DocumentoByte IS NULL THEN
                                           0
                                       ELSE
                                           1
                                   END AS BIT),
               imp.importe as IVA,
               C.IdContrato,
               CASE
                   WHEN WAD.IdDocAwsDocAdinco IS NULL THEN
                       0
                   ELSE
                       1
               END AS CCN,
               NULL AS CRCCN,
               CONVERT(DATE, F.CreadoEn) AS CreadoEn,
               UM.Nombre AS CreadoPor
        FROM dbo.FI_Factura AS F WITH (NOLOCK)
            JOIN dbo.PV_Subcontratista AS S WITH (NOLOCK)
                ON F.IdSubcontratista = S.IdSubcontratista
                   AND F.IdContrato = @IdContrato
            JOIN dbo.CO_Contrato C WITH (NOLOCK)
                ON F.IdContrato = C.IdContrato
            JOIN dbo.CO_Contratista CC WITH (NOLOCK)
                ON C.IdContratista = CC.IdContratista
            LEFT JOIN dbo.PV_TipoMoneda M WITH (NOLOCK)
                ON F.IdMoneda = M.IdMoneda
            LEFT JOIN dbo.FI_Documento D WITH (NOLOCK)
                ON F.IdFactura = D.IdFactura
                   AND D.IdTipoDocumento = 1
                   AND ISNULL(D.IsEliminado, 0) = 0
            LEFT JOIN dbo.AWS_DocAwsDocAdinco WAD WITH (NOLOCK)
                ON F.IdFactura = WAD.IdDocAdinco
            LEFT JOIN dbo.AP_Usuario UM WITH (NOLOCK)
                ON F.CreadoPor = UM.UsuarioID
            left join #Importes imp
                on imp.idfactura = f.IdFactura
        ORDER BY F.IdFactura DESC;
    END;

    /**/

    ELSE
    BEGIN
        INSERT INTO #Facturas
        (
            IdFactura,
            NombreEmisor,
            RFC_Emisor,
            NumeroContrato,
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
            CreadoEn,
            CreadoPor
        )
        SELECT DISTINCT
            F.IdFactura,
            S.RazonSocial AS NombreEmisor,
            S.RFC AS RFC_Emisor,
            C.NumeroContrato,
            F.Fecha,
            F.Serie,
            F.Folio,
            F.SubTotal,
            F.Descuento,
            F.TipoCambio,
            F.MontoConIva AS Total,
            M.TipoMonedaCorto AS Moneda,
            SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante,
            F.MetodoPago,
            SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
            F.NumCtaPago,
            CC.RFC AS Receptor,
            F.UUID,
            F.FechaTimbrado,
            F.SelloCFD,
            F.NoCertificadoSAT,
            F.SelloSAT,
            F.Tipo,
            F.FechaRecepcion,
            YEAR(F.Fecha) AS Año,
            CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS NVARCHAR(20)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes,
            CC.RazonSocial AS Receptor,
            TieneArchivo = CAST(CASE
                                    WHEN D.DocumentoByte IS NULL THEN
                                        0
                                    ELSE
                                        1
                                END AS BIT),
            I.Importe as IVA,
            C.IdContrato,
            CASE
                WHEN WAD.IdDocAwsDocAdinco IS NULL THEN
                    0
                ELSE
                    1
            END AS CCN,
            NULL AS CRCCN,
            CONVERT(DATE, F.CreadoEn) AS CreadoEn,
            UM.Nombre AS CreadoPor
        FROM dbo.FI_Factura AS F WITH (NOLOCK)
            LEFT JOIN dbo.FI_FacturaContrato FC WITH (NOLOCK)
                ON F.IdFactura = FC.IdFactura
            JOIN dbo.PV_Subcontratista AS S WITH (NOLOCK)
                ON F.IdSubcontratista = S.IdSubcontratista
            JOIN dbo.CO_Contrato C WITH (NOLOCK)
                ON F.IdContrato = C.IdContrato
                   AND (
                           F.IdContrato = @IdContrato
                           OR FC.IdContrato = @IdContrato
                       )
            LEFT JOIN dbo.CO_Contratista CC WITH (NOLOCK)
                ON C.IdContratista = CC.IdContratista
                   AND CC.RFC <> F.Emisor
            LEFT JOIN dbo.PV_TipoMoneda M WITH (NOLOCK)
                ON F.IdMoneda = M.IdMoneda
            LEFT JOIN dbo.FI_Documento D WITH (NOLOCK)
                ON F.IdFactura = D.IdFactura
                   AND D.IdTipoDocumento = 1
                   AND ISNULL(D.IsEliminado, 0) = 0
            LEFT JOIN dbo.AWS_DocAwsDocAdinco WAD WITH (NOLOCK)
                ON F.IdFactura = WAD.IdDocAdinco
            LEFT JOIN dbo.AP_Usuario UM WITH (NOLOCK)
                ON F.CreadoPor = UM.UsuarioID
            LEFT JOIN #Importes I
                on I.IdFactura = F.IdFactura
        ORDER BY F.IdFactura DESC;
    END;

    /**/

    UPDATE #Facturas
    SET CCN = 1
    FROM #Facturas F
        JOIN #CartasProcura CP
            ON CP.UUID = F.UUID
    WHERE F.UUID = CP.UUID;

    /**/

    select faws.IdFactura
    into #tmpFiles
    from adinco..FacturasAWSDocumentos faws
        inner join AWS_Documentos awsd
            on faws.AWSDocumentoId = awsd.AWSDocumentoId
    group by faws.IdFactura

    SELECT F.IdFactura,
           F.NombreEmisor AS NombreEmisor,
           F.RFC_Emisor AS RFC_Emisor,
           C.NumeroContrato,
           F.Fecha,
           F.Serie,
           F.Folio,
           ISNULL(F.SubTotal, 0) AS SubTotal,
           ISNULL(F.Descuento, 0) AS Descuento,
           ISNULL(F.TipoCambio, 0) AS TipoCambio,
           ISNULL(F.Total, 0) AS Total,
           ISNULL(F.Moneda, 'NA') AS Moneda,
           UPPER(ISNULL(F.TipoComprobante, '')) AS TipoComprobante,
           UPPER(ISNULL(F.MetodoPago, '')) AS MetodoPago,
           UPPER(ISNULL(F.LugarExpedicion, '')) AS LugarExpedicion,
           UPPER(ISNULL(F.NumCtaPago, '')) AS NumCtaPago,
           F.RFC_Receptor AS Receptor,
           ISNULL(F.UUID, 'NA') AS UUID,
           F.FechaTimbrado,
           ISNULL(F.SelloCFD, '') AS SelloCFD,
           ISNULL(F.NoCertificadoSAT, '') AS NoCertificadoSAT,
           ISNULL(F.SelloSAT, '') AS SelloSAT,
           ISNULL(F.Tipo, '') AS Tipo,
           F.FechaRecepcion,
           F.Año,
           F.Mes,
           F.NombreReceptor AS Receptor,
           F.TieneArchivo,
           F.IVA,
           F.IdContrato,
           F.CCN,
           F.CRCCN,
           C.NumeroContrato,
           F.CreadoEn,
           F.CreadoPor,
           TieneArchivos = case
                               when t1.IdFactura is null then
                                   cast(0 as bit)
                               else
                                   cast(1 as bit)
                           end,
			FacturaRelacionadaDropbox = CASE WHEN APP_RelacionRutaDropboxFactura.IdFactura IS NULL THEN
									CAST(0 AS BIT)
								ELSE
									CAST(1 AS BIT)
								END
    FROM #Facturas F
        JOIN dbo.CO_Contrato C WITH (NOLOCK)
            ON F.IdContrato = C.IdContrato
        left join #tmpFiles t1
            on f.IdFactura = t1.IdFactura
		LEFT JOIN APP_RelacionRutaDropboxFactura 
			ON APP_RelacionRutaDropboxFactura.IdFactura = F.IdFactura
    ORDER BY F.IdFactura DESC;
END;