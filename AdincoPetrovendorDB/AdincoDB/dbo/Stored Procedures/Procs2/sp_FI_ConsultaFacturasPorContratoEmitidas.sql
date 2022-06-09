-- =============================================
-- Author:		Manuel Cruz
-- Create date: 21-06-2018
-- Description:	
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 05-02-2020
-- Description:	Agregar Campo (CreadoEn,CreadoPor)
-- =============================================
-- Author:		Neri Garcia
-- Create date: 07 de Mayo del 2022
-- Description:	Ajustes de Consulta principal y se agregan filtros de @FechaInicio y @FechaFin
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContratoEmitidas]
    @IdContrato INT = 0,
    @IdUsuario INT = 0,
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET NOCOUNT ON;
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
        CreadoEn DATE,
        CreadoPor NVARCHAR(MAX),
        IdMoneda INT,
        CreadoPorID INT,
        IdSubcontratista INT,
        Receptor VARCHAR(MAX),
        PRIMARY KEY (IdFactura)
    );
   
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
            CreadoEn,
            CreadoPor,
            IdMoneda,
            CreadoPorID,
            IdSubcontratista,
            Receptor
        )
        SELECT F.IdFactura,
               '',
               '',
               C.NumeroContrato,
               F.Fecha,
               F.Serie,
               F.Folio,
               F.SubTotal,
               F.Descuento,
               F.TipoCambio,
               F.MontoConIva AS Total,
               'NA',
               SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante,
               F.MetodoPago,
               SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
               F.NumCtaPago,
               F.Receptor AS Receptor,
               F.UUID,
               F.FechaTimbrado,
               F.SelloCFD,
               F.NoCertificadoSAT,
               F.SelloSAT,
               F.Tipo,
               F.FechaRecepcion,
               YEAR(F.Fecha) AS Año,
               CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes,
               '',
               0,
               0,
               C.IdContrato,
               CONVERT(DATE, F.CreadoEn) AS CreadoEn,
               '',
               F.IdMoneda,
               F.CreadoPor,
               F.IdSubcontratista,
               F.Receptor
        FROM dbo.FI_Factura AS F (NOLOCK)
            JOIN dbo.CO_Contrato C (NOLOCK)
                ON F.IdContrato = @IdContrato
                   AND F.IdContrato = C.IdContrato
                   AND CONVERT(DATE, ISNULL(F.FechaTimbrado, F.Fecha))
                   BETWEEN CONVERT(DATE, @FechaInicio) AND CONVERT(DATE, @FechaFin)
            JOIN dbo.CO_Contratista CC (NOLOCK)
                ON C.IdContratista = CC.IdContratista
                   AND F.Emisor = CC.RFC
 

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
    SET Moneda = M.TipoMonedaCorto
    FROM #Facturas TEMP
        JOIN dbo.PV_TipoMoneda M (NOLOCK)
            ON TEMP.IdMoneda = M.IdMoneda

    UPDATE TEMP
    SET NombreEmisor = S.RazonSocial,
        RFC_Emisor = S.RFC
    FROM #Facturas TEMP
        JOIN PV_Subcontratista S (NOLOCK)
            ON TEMP.IdSubcontratista = S.IdSubcontratista

    UPDATE TEMP
    SET NombreReceptor = SR.RazonSocial
    FROM #Facturas TEMP
        JOIN dbo.PV_Subcontratista SR WITH (NOLOCK)
            ON TEMP.Receptor = SR.RFC

    UPDATE TEMP
    SET CreadoPor = UM.Nombre
    FROM #Facturas TEMP
        JOIN dbo.AP_Usuario UM WITH (NOLOCK)
            ON TEMP.CreadoPorID = UM.UsuarioID

    UPDATE TEMP
    SET IVA = IMP.Importe
    FROM #Facturas TEMP
        JOIN #Importes IMP
            ON TEMP.IdFactura = IMP.IdFactura

    SELECT F.IdFactura,
           F.NombreEmisor,
           F.RFC_Emisor,
           F.NumeroContrato,
           F.Fecha,
           F.Serie,
           F.Folio,
           F.SubTotal,
           F.Descuento,
           F.TipoCambio,
           F.Total,
           F.Moneda,
           SUBSTRING(F.TipoComprobante, 1, 1) AS TipoComprobante,
           F.MetodoPago,
           SUBSTRING(F.LugarExpedicion, 0, 20) AS LugarExpedicion,
           F.NumCtaPago,
           F.RFC_Receptor AS Receptor,
           F.UUID,
           F.FechaTimbrado,
           F.SelloCFD,
           F.NoCertificadoSAT,
           F.SelloSAT,
           F.Tipo,
           F.FechaRecepcion,
           YEAR(F.Fecha) AS Año,
           CONCAT(RIGHT('00' + CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes,
           F.NombreReceptor AS Receptor,
           F.TieneArchivo,
           F.IVA,
           F.IdContrato,
           CONVERT(DATE, F.CreadoEn) AS CreadoEn,
           F.CreadoPor
    FROM #Facturas F
    ORDER BY F.IdFactura DESC;
END