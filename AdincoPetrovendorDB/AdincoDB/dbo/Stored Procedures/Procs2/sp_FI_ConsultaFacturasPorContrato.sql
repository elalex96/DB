IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_FI_ConsultaFacturasPorContrato'
)
    DROP PROCEDURE sp_FI_ConsultaFacturasPorContrato
GO
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
-- Author: Marcos Garcia  
-- Alter date: 18-04-2022  
-- Description: Ajustar Importe,  
--				Se realiza SUM de importes
-- ============================================= 
-- Author:		Neri Garcia
-- Create date: 07 de Mayo del 2022
-- Description:	Ajustes de Consulta principal y se agregan filtros de @FechaInicio y @FechaFin
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 30 de Enero del 2023
-- Description:	Ajustes de agrupado para no repetir varias facturas
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContrato]
    @IdContrato INT = 0,
    @IdUsuario INT = 0,
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET LANGUAGE spanish;
    IF OBJECT_ID('tempdb..#tmpFiles') IS NOT NULL
        DROP TABLE #tmpFiles

    IF OBJECT_ID('tempdb..#CartasProcura') IS NOT NULL
        DROP TABLE #CartasProcura

    IF OBJECT_ID('tempdb..#Importes') IS NOT NULL
        DROP TABLE #Importes

    IF OBJECT_ID('tempdb..#Facturas') IS NOT NULL
        DROP TABLE #Facturas

    IF OBJECT_ID('tempdb..#FI_Factura_General') IS NOT NULL
        DROP TABLE #FI_Factura_General

    /*Creación de Tablas Temporales*/
    CREATE TABLE #tmpFiles
    (
        IdFactura INT,
        PRIMARY KEY (IdFactura)
    )
    CREATE TABLE #CartasProcura
    (
        IdFactura INT,
        UUID NVARCHAR(200)
    );
    CREATE TABLE #Importes
    (
        IdFactura INT,
        Importe DECIMAL(18, 4),
        PRIMARY KEY (IdFactura)
    );
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
        SelloCFD VARCHAR(8000),
        NoCertificadoSAT VARCHAR(8000),
        SelloSAT VARCHAR(8000),
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
        CreadoPor VARCHAR(8000),
        TieneArchivos BIT,
        FacturaRelacionadaDropbox BIT,
        IdMoneda INT,
        TipoMonedaCorto VARCHAR(8000),
        CreadoPorID INT,
        Nombre VARCHAR(8000),
        IdSubcontratista INT,
        Emisor VARCHAR(8000),
        PRIMARY KEY (IdFactura)
    );

	CREATE NONCLUSTERED INDEX IX_Facturas_UUID ON #Facturas(UUID);
	CREATE NONCLUSTERED INDEX IX_Facturas_IdFactura ON #Facturas(IdFactura);

    INSERT INTO #CartasProcura
    (
        IdFactura,
        UUID
    )
    SELECT DISTINCT
        FP.IdFactura,
        FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
    FROM Petrovendor.dbo.MM_AceptacionCartaPCN AS AC WITH (NOLOCK)
        JOIN Petrovendor.dbo.S_Documento_S3 AS D WITH (NOLOCK)
            ON AC.IdDocumento = D.IdDocumento 
               AND AC.IdEstatus = 2
               AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
        JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP WITH (NOLOCK)
            ON AC.IdAceptacionPedido = AP.IdAceptacionPedido
        JOIN Petrovendor.dbo.MM_Pedido AS P WITH (NOLOCK)
            ON P.IdContrato = @IdContrato
			AND AP.IdPedido = P.IdPedido 
        JOIN Petrovendor.dbo.S_Proveedor AS PR WITH (NOLOCK)
            ON P.IdSubcontratista = PR.IdProveedor
        JOIN Petrovendor.dbo.S_TipoValidacionDoc AS TD WITH (NOLOCK)
            ON AC.IdEstatus = TD.IdTipoValidacionDoc
        JOIN Petrovendor.dbo.MM_Pedidos AS PG WITH (NOLOCK)
            ON P.IdPedido = PG.IdIdentificador
        LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP WITH (NOLOCK)
            ON PG.IdTipoPedido = TP.IdTipoPedido
        LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF WITH (NOLOCK)
            ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
        LEFT JOIN Petrovendor.dbo.FI_Factura FP WITH (NOLOCK)
            ON AF.IdFactura = FP.IdFactura 
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
            CreadoPor,
            TieneArchivos,
            FacturaRelacionadaDropbox,
            IdMoneda,
            TipoMonedaCorto,
            CreadoPorID,
            IdSubcontratista,
            Emisor
        )
        SELECT F.IdFactura,
               S.RazonSocial,
               S.RFC,
               C.NumeroContrato,
               F.Fecha,
               F.Serie,
               F.Folio,
               F.SubTotal,
               F.Descuento,
               F.TipoCambio,
               F.MontoConIva AS Total,
               '',
               SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante,
               F.MetodoPago,
               SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
               F.NumCtaPago,
               CC.RFC,
               F.UUID,
               F.FechaTimbrado,
               F.SelloCFD,
               F.NoCertificadoSAT,
               F.SelloSAT,
               F.Tipo,
               F.FechaRecepcion,
               YEAR(F.Fecha) AS Año,
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS NVARCHAR(20)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes,
               CC.RazonSocial,
               0,
               0,
               C.IdContrato,
               0,
               NULL AS CRCCN,
               CONVERT(DATE, F.CreadoEn) AS CreadoEn,
               '' AS CreadoPor,
               0,
               0,
               F.IdMoneda,
               'NA',
               F.CreadoPor,
               F.IdSubcontratista,
               F.Emisor
        FROM dbo.FI_Factura AS F (NOLOCK)
            JOIN dbo.PV_Subcontratista AS S WITH (NOLOCK)
                ON F.IdContrato = @IdContrato
                   AND CONVERT(DATE, ISNULL(F.FechaTimbrado, F.Fecha))
                   BETWEEN CONVERT(DATE, @FechaInicio) AND CONVERT(DATE, @FechaFin)
                   AND F.IdSubcontratista = S.IdSubcontratista
            JOIN dbo.CO_Contrato C WITH (NOLOCK)
                ON F.IdContrato = C.IdContrato
            JOIN dbo.CO_Contratista CC WITH (NOLOCK)
                ON C.IdContratista = CC.IdContratista
			GROUP BY 
				F.IdFactura,
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
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS NVARCHAR(20)), 2), ' ', DATENAME(MONTH, F.Fecha)),
               CC.RazonSocial,
               C.IdContrato,
               CONVERT(DATE, F.CreadoEn),
               F.IdMoneda,
               F.CreadoPor,
               F.IdSubcontratista,
               F.Emisor
    END;
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
            CreadoPor,
            TieneArchivos,
            FacturaRelacionadaDropbox,
            IdMoneda,
            TipoMonedaCorto,
            CreadoPorID,
            IdSubcontratista,
            Emisor
        )
        SELECT F.IdFactura,
               S.RazonSocial,
               S.RFC,
               C.NumeroContrato,
               F.Fecha,
               F.Serie,
               F.Folio,
               F.SubTotal,
               F.Descuento,
               F.TipoCambio,
               F.MontoConIva AS Total,
               '',
               SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante,
               F.MetodoPago,
               SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
               F.NumCtaPago,
               F.Receptor,
               F.UUID,
               F.FechaTimbrado,
               F.SelloCFD,
               F.NoCertificadoSAT,
               F.SelloSAT,
               F.Tipo,
               F.FechaRecepcion,
               YEAR(F.Fecha) AS Año,
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS NVARCHAR(20)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes,
               '',
               0,
               0,
               C.IdContrato,
               0,
               NULL AS CRCCN,
               CONVERT(DATE, F.CreadoEn) AS CreadoEn,
               '' AS CreadoPor,
               0,
               0,
               F.IdMoneda,
               'NA',
               F.CreadoPor,
               F.IdSubcontratista,
               F.Emisor
        FROM dbo.FI_Factura AS F (NOLOCK)
            JOIN dbo.PV_Subcontratista AS S WITH (NOLOCK)
                ON F.IdContrato = @IdContrato
                   AND CONVERT(DATE, ISNULL(F.FechaTimbrado, F.Fecha))
                   BETWEEN CONVERT(DATE, @FechaInicio) AND CONVERT(DATE, @FechaFin)
                   AND F.IdSubcontratista = S.IdSubcontratista
            JOIN dbo.CO_Contrato C WITH (NOLOCK)
                ON F.IdContrato = C.IdContrato
            LEFT JOIN dbo.CO_Contratista CC WITH (NOLOCK)
                ON C.IdContratista = CC.IdContratista
                   AND F.Receptor <> CC.RFC 
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
               F.Receptor,
               F.UUID,
               F.FechaTimbrado,
               F.SelloCFD,
               F.NoCertificadoSAT,
               F.SelloSAT,
               F.Tipo,
               F.FechaRecepcion,
               YEAR(F.Fecha),
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS NVARCHAR(20)), 2), ' ', DATENAME(MONTH, F.Fecha)),
               C.IdContrato,
               CONVERT(DATE, F.CreadoEn),
               F.IdMoneda,
               F.CreadoPor,
               F.IdSubcontratista,
               F.Emisor;

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
            CreadoPor,
            TieneArchivos,
            FacturaRelacionadaDropbox,
            IdMoneda,
            TipoMonedaCorto,
            CreadoPorID,
            IdSubcontratista,
            Emisor
        )
        SELECT F.IdFactura,
               S.RazonSocial,
               S.RFC,
               C.NumeroContrato,
               F.Fecha,
               F.Serie,
               F.Folio,
               F.SubTotal,
               F.Descuento,
               F.TipoCambio,
               F.MontoConIva AS Total,
               '',
               SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante,
               F.MetodoPago,
               SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
               F.NumCtaPago,
               F.Receptor,
               F.UUID,
               F.FechaTimbrado,
               F.SelloCFD,
               F.NoCertificadoSAT,
               F.SelloSAT,
               F.Tipo,
               F.FechaRecepcion,
               YEAR(F.Fecha) AS Año,
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS NVARCHAR(20)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes,
               '',
               0,
               0,
               C.IdContrato,
               0,
               NULL AS CRCCN,
               CONVERT(DATE, F.CreadoEn) AS CreadoEn,
               '' AS CreadoPor,
               0,
               0,
               F.IdMoneda,
               '',
               F.CreadoPor,
               F.IdSubcontratista,
               F.Emisor
        FROM dbo.FI_FacturaContrato FC WITH (NOLOCK)
            JOIN dbo.FI_Factura AS F WITH (NOLOCK)
                ON FC.IdFactura = F.IdFactura
				AND	FC.IdContrato = @IdContrato
                   AND CONVERT(DATE, ISNULL(F.FechaTimbrado, F.Fecha))
                   BETWEEN CONVERT(DATE, @FechaInicio) AND CONVERT(DATE, @FechaFin)
          JOIN dbo.PV_Subcontratista AS S WITH (NOLOCK)
                ON F.IdSubcontratista = S.IdSubcontratista
            JOIN dbo.CO_Contrato C WITH (NOLOCK)
                ON F.IdContrato = C.IdContrato
            LEFT JOIN dbo.CO_Contratista CC WITH (NOLOCK)
                ON C.IdContratista = CC.IdContratista
                   AND F.Receptor <> CC.RFC
			 LEFT JOIN #Facturas TEMP2 
                ON FC.IdFactura = TEMP2.IdFactura
			WHERE
				TEMP2.IdFactura IS NULL
			GROUP BY
			F.IdFactura,
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
               F.Receptor,
               F.UUID,
               F.FechaTimbrado,
               F.SelloCFD,
               F.NoCertificadoSAT,
               F.SelloSAT,
               F.Tipo,
               F.FechaRecepcion,
               YEAR(F.Fecha),
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS NVARCHAR(20)), 2), ' ', DATENAME(MONTH, F.Fecha)),
               C.IdContrato,
               CONVERT(DATE, F.CreadoEn),
               F.IdMoneda,
               F.CreadoPor,
               F.IdSubcontratista,
               F.Emisor;

        UPDATE TEMP
        SET NombreReceptor = PV.RazonSocial
        FROM #Facturas TEMP
            JOIN dbo.PV_Subcontratista PV WITH (NOLOCK)
                ON TEMP.RFC_Receptor = PV.RFC
    END;
    /**/
    UPDATE TEMP
    SET TieneArchivo = CASE
                           WHEN D.DocumentoByte LIKE 0x THEN
                               0
                           ELSE
                               1
                       END
    FROM #Facturas TEMP
        JOIN dbo.FI_Documento D (NOLOCK)
            ON TEMP.IdFactura = D.IdFactura
               AND D.DocumentoByte IS NOT NULL
               AND D.IdTipoDocumento = 1
               AND ISNULL(D.IsEliminado, 0) = 0

    UPDATE TEMP
    SET TipoMonedaCorto = M.TipoMonedaCorto
    FROM #Facturas TEMP
        JOIN dbo.PV_TipoMoneda M (NOLOCK)
            ON TEMP.IdMoneda = M.IdMoneda

    UPDATE TEMP
    SET CCN = CASE
                  WHEN WAD.IdDocAwsDocAdinco IS NULL THEN
                      0
                  ELSE
                      1
              END
    FROM #Facturas TEMP
        JOIN dbo.AWS_DocAwsDocAdinco WAD WITH (NOLOCK)
            ON TEMP.IdFactura = WAD.IdDocAdinco

    UPDATE TEMP
    SET CreadoPor = UM.Nombre
    FROM #Facturas TEMP
        JOIN dbo.AP_Usuario UM WITH (NOLOCK)
            ON UM.UsuarioID = TEMP.CreadoPorID 

    /*Importes de Facturas*/
    INSERT INTO #Importes
    (
        IdFactura,
        Importe
    )
    SELECT FIM.IdFactura,
           SUM(FIM.Importe)
    FROM #Facturas F WITH (NOLOCK)
        INNER JOIN FI_CFDIImpuesto FIM WITH (NOLOCK)
            ON F.IdFactura = FIM.IdFactura
    GROUP BY FIM.IdFactura
    ORDER BY FIM.IdFactura

    UPDATE TEMP
    SET IVA = IMP.Importe
    FROM #Facturas TEMP
        JOIN #Importes IMP
            ON TEMP.IdFactura = IMP.IdFactura

    UPDATE #Facturas
    SET CCN = 1
  FROM #Facturas F
        JOIN #CartasProcura CP
            ON F.UUID = CP.UUID  
    WHERE F.UUID = CP.UUID;

    /**/
    INSERT INTO #tmpFiles
    (
        IdFactura
    )
    SELECT faws.IdFactura
    FROM adinco..FacturasAWSDocumentos faws
        INNER JOIN AWS_Documentos awsd (NOLOCK)
            ON faws.AWSDocumentoId = awsd.AWSDocumentoId
    GROUP BY faws.IdFactura

    UPDATE #Facturas
    SET TieneArchivos = case
                            when t1.IdFactura is null then
                                cast(0 as bit)
                            else
                                cast(1 as bit)
                        end
    FROM #Facturas F
        join #tmpFiles t1
            on f.IdFactura = t1.IdFactura

    UPDATE #Facturas
    SET FacturaRelacionadaDropbox = CASE
                                        WHEN DF.IdFactura IS NULL THEN
                                            CAST(0 AS BIT)
                                        ELSE
                                            CAST(1 AS BIT)
                                    END
    FROM #Facturas F
        JOIN APP_RelacionRutaDropboxFactura DF (NOLOCK)
            ON F.IdFactura = DF.IdFactura  

    SELECT F.IdFactura,
           F.NombreEmisor AS NombreEmisor,
           F.RFC_Emisor AS RFC_Emisor,
           F.NumeroContrato,
           F.Fecha,
           F.Serie,
           F.Folio,
           ISNULL(F.SubTotal, 0) AS SubTotal,
           ISNULL(F.Descuento, 0) AS Descuento,
           ISNULL(F.TipoCambio, 0) AS TipoCambio,
           ISNULL(F.Total, 0) AS Total,
           ISNULL(F.TipoMonedaCorto, 'NA') AS Moneda,
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
           F.NombreReceptor,
           F.TieneArchivo,
           F.IVA,
           F.IdContrato,
           F.CCN,
           F.CRCCN,
           F.NumeroContrato,
           F.CreadoEn,
           F.CreadoPor,
           F.TieneArchivos,
           F.FacturaRelacionadaDropbox
    FROM #Facturas F
    ORDER BY F.IdFactura DESC;
END;