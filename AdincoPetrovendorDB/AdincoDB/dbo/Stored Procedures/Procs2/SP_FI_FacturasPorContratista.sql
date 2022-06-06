-- =============================================
-- Author:      Marcos Garcia
-- Create date: 05-12-2019
-- Description: Seleccion de Facturas por Proveedor
--				de los Contratos de el Mismo Contratista.   
-- =============================================
-- Modification Author:	Neri del Angel
-- Modification Date:	02 de Junio del 2022
-- Description:			Optimizacion de PROCEDURE por temas de error marcado 
--						[Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding.]
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_FacturasPorContratista]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    --==============Contratos Relacionados al Contratista===========       
    IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
        DROP TABLE #Facturas;
    IF OBJECT_ID('tempdb..#FI_Factura', 'U') IS NOT NULL
        DROP TABLE #FI_Factura;
    --======================== 
    CREATE TABLE #Facturas
    (
        IdFactura INT,
        NombreEmisor VARCHAR(2000),
        RFC_Emisor VARCHAR(500),
        NumeroContrato VARCHAR(500),
        Fecha DATETIME,
        Serie VARCHAR(500),
        Folio VARCHAR(500),
        SubTotal FLOAT,
        Descuento FLOAT,
        TipoCambio FLOAT,
        Total FLOAT,
        Moneda VARCHAR(250),
        TipoComprobante VARCHAR(250),
        MetodoPago VARCHAR(500),
        LugarExpedicion VARCHAR(500),
        NumCtaPago VARCHAR(1000),
        RFC_Receptor VARCHAR(500),
        UUID VARCHAR(500),
        FechaTimbrado DATETIME,
        SelloCFD VARCHAR(MAX),
        NoCertificadoSAT VARCHAR(MAX),
        SelloSAT VARCHAR(MAX),
        Tipo VARCHAR(250),
        FechaRecepcion DATETIME,
        Año INT,
        Mes VARCHAR(500),
        NombreReceptor VARCHAR(2000),
        TieneArchivo BIT,
        IVA FLOAT,
        IdContrato INT,
        IdMoneda INT,
        PRIMARY KEY (IdFactura)
    );

    CREATE TABLE #FI_Factura
    (
        IdFactura INT,
        TieneArchivo BIT,
        IdMoneda INT,
        IdMonedaTexto VARCHAR(MAX),
        PRIMARY KEY (IdFactura)
    )
    --========================
    DECLARE @IdContratista INT;
    --========================
    SET @IdContratista =
    (
        SELECT IdContratista
        FROM dbo.CO_Contrato (NOLOCK)
        WHERE IdContrato = @IdContrato
    );
    IF @IdContrato = 10007
    BEGIN

        INSERT INTO #FI_Factura
        (
            IdFactura,
            TieneArchivo,
            IdMoneda,
            IdMonedaTexto
        )
        SELECT F.IdFactura,
               0,
               F.IdMoneda,
               ''
        FROM dbo.FI_Factura F (NOLOCK)
        WHERE F.IdContrato = @IdContrato
              AND Activa = 1

        UPDATE TEMP
        SET TieneArchivo = CASE
                               WHEN D.DocumentoByte LIKE 0x THEN
                                   0
                               ELSE
                                   1
                           END
        FROM #FI_Factura TEMP
            JOIN dbo.FI_Documento D (NOLOCK)
                ON TEMP.IdFactura = D.IdFactura
                   AND D.DocumentoByte IS NOT NULL
                   AND D.IdTipoDocumento = 1
                   AND ISNULL(D.IsEliminado, 0) = 0

        UPDATE TEMP
        SET IdMonedaTexto = M.TipoMonedaCorto
        FROM #FI_Factura TEMP
            JOIN dbo.PV_TipoMoneda M (NOLOCK)
                ON TEMP.IdMoneda = M.IdMoneda

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
            IdMoneda
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
               TEMP.IdMonedaTexto AS Moneda,
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
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes,
               CC.RazonSocial AS Receptor,
               TieneArchivo = TEMP.TieneArchivo,
               ISNULL((F.MontoConIva * .16), 0) AS IVA,
               C.IdContrato,
               F.IdMoneda
        FROM #FI_Factura TEMP
            JOIN FI_Factura F (NOLOCK)
                ON TEMP.IdFactura = F.IdFactura
            JOIN dbo.PV_Subcontratista AS S (NOLOCK)
                ON F.IdSubcontratista = S.IdSubcontratista
                   AND F.IdContrato = @IdContrato
            JOIN dbo.CO_Contrato C (NOLOCK)
                ON F.IdContrato = C.IdContrato
            JOIN dbo.CO_Contratista CC (NOLOCK)
                ON C.IdContratista = CC.IdContratista
        ORDER BY F.IdFactura DESC;
    END;
    --========================
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
            IdMoneda
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
               REPLICATE('0', 2 - LEN(MONTH(F.Fecha))) + LTRIM(MONTH(F.Fecha)) AS Mes,
               CC.RazonSocial AS Receptor,
               0,
               ISNULL((F.MontoConIva * .16), 0) AS IVA,
               C.IdContrato,
               F.IdMoneda
        FROM dbo.CO_Contrato C (NOLOCK)
            JOIN dbo.CO_Contratista CC (NOLOCK)
                ON C.IdContratista = CC.IdContratista
                   AND CC.IdContratista = @IdContratista
            JOIN dbo.FI_Factura AS F (NOLOCK)
                ON C.IdContrato = F.IdContrato
                   AND F.Activa = 1
            JOIN dbo.PV_Subcontratista AS S (NOLOCK)
                ON F.IdSubcontratista = S.IdSubcontratista
        GROUP BY F.IdFactura,
                 S.RazonSocial,
                 S.RFC,
                 C.NumeroContrato,
                 F.Fecha,
                 F.Serie,
                 F.Folio,
                 F.SubTotal,
                 F.Descuento,
                 F.TipoCambio,
                 F.MontoConIva,
                 SUBSTRING(F.TipoComprobante, 1, 1),
                 F.MetodoPago,
                 SUBSTRING(F.LugarExpedicion, 0, 20),
                 F.NumCtaPago,
                 CC.RFC,
                 F.UUID,
                 F.FechaTimbrado,
                 F.SelloCFD,
                 F.NoCertificadoSAT,
                 F.SelloSAT,
                 F.Tipo,
                 F.FechaRecepcion,
                 YEAR(F.Fecha),
                 REPLICATE('0', 2 - LEN(MONTH(F.Fecha))) + LTRIM(MONTH(F.Fecha)),
                 CC.RazonSocial,
                 ISNULL((F.MontoConIva * .16), 0),
                 C.IdContrato,
                 F.IdMoneda

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
            IdMoneda
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
               REPLICATE('0', 2 - LEN(MONTH(F.Fecha))) + LTRIM(MONTH(F.Fecha)) as mes,
               CC.RazonSocial AS Receptor,
               0,
               ISNULL((F.MontoConIva * .16), 0) AS IVA,
               F.IdContrato,
               F.IdMoneda
        FROM dbo.CO_Contrato C (NOLOCK)
            JOIN dbo.CO_Contratista CC (NOLOCK)
                ON C.IdContratista = CC.IdContratista
                   AND CC.IdContratista = @IdContratista
            JOIN dbo.FI_FacturaContrato FC (NOLOCK)
                ON C.IdContrato = FC.IdContrato
            JOIN dbo.FI_Factura AS F (NOLOCK)
                ON FC.IdFactura = F.IdFactura
                   AND F.IdFactura NOT IN (
                                              SELECT IdFactura FROM #Facturas
                                          )
                   AND F.Activa = 1
            JOIN dbo.PV_Subcontratista AS S (NOLOCK)
                ON F.IdSubcontratista = S.IdSubcontratista
        GROUP BY F.IdFactura,
                 S.RazonSocial,
                 S.RFC,
                 C.NumeroContrato,
                 F.Fecha,
                 F.Serie,
                 F.Folio,
                 F.SubTotal,
                 F.Descuento,
                 F.TipoCambio,
                 F.MontoConIva,
                 SUBSTRING(F.TipoComprobante, 1, 1),
                 F.MetodoPago,
                 SUBSTRING(F.LugarExpedicion, 0, 20),
                 F.NumCtaPago,
                 CC.RFC,
                 F.UUID,
                 F.FechaTimbrado,
                 F.SelloCFD,
                 F.NoCertificadoSAT,
                 F.SelloSAT,
                 F.Tipo,
                 F.FechaRecepcion,
                 YEAR(F.Fecha),
                 REPLICATE('0', 2 - LEN(MONTH(F.Fecha))) + LTRIM(MONTH(F.Fecha)),
                 CC.RazonSocial,
                 ISNULL((F.MontoConIva * .16), 0),
                 F.IdContrato,
                 F.IdMoneda
        ORDER BY F.IdFactura DESC;

        UPDATE F
        SET Moneda = M.TipoMonedaCorto
        FROM #Facturas F
            JOIN dbo.PV_TipoMoneda M (NOLOCK)
                ON F.IdMoneda = M.IdMoneda

        UPDATE F
        SET TieneArchivo = CAST(CASE
                                    WHEN D.DocumentoByte IS NULL THEN
                                        0
                                    ELSE
                                        1
                                END AS BIT)
        FROM #Facturas F
            JOIN dbo.FI_Documento D (NOLOCK)
                ON F.IdFactura = D.IdFactura
                   AND D.IdTipoDocumento = 1
                   AND ISNULL(D.IsEliminado, 0) = 0
    END;
    /**/
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
           ISNULL(F.TieneArchivo, 0) AS TieneArchivo,
           F.IVA,
           F.IdContrato,
           C.NumeroContrato
    FROM #Facturas F (NOLOCK)
        JOIN dbo.CO_Contrato C (NOLOCK)
            ON C.IdContrato = F.IdContrato
        JOIN dbo.CO_Contratista CC (NOLOCK)
            ON C.IdContratista = CC.IdContratista
               AND CC.IdContratista = @IdContratista
    ORDER BY F.IdFactura DESC;
END;
