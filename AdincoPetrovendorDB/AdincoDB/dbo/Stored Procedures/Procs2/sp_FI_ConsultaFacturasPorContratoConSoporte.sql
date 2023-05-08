-- =============================================
-- Author:		Reyna Olvera
-- Create date: 05/06/2018
-- Description:	<Description,,>
-- =============================================
-- Modification Author:	Neri del Angel
-- Modification Date:	02 de Junio del 2022
-- Description:			Optimizacion de PROCEDURE por temas de error marcado 
--						[Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding.]
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContratoConSoporte] @IdContrato INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    
    CREATE TABLE #FI_Factura
    (
        IdFactura INT,
        Archivo BIT,
        IdSubcontratista INT,
        IdSubcontratistaTexto VARCHAR(2000),
        IdMoneda INT,
        IdMonedaTexto VARCHAR(500),
        IdReceptor INT,
        IdReceptorTexto VARCHAR(1000),
        TieneSoporte BIT,
        Emisor NVARCHAR(1000),
        Fecha DATETIME,
        Serie NVARCHAR(1000),
        Folio NVARCHAR(1000),
        Subtotal MONEY,
        Descuento MONEY,
        TipoCambio MONEY,
        MontoConIva MONEY,
        TipoComprobante NVARCHAR(1000),
        MetodoPago NVARCHAR(1000),
        LugarExpedicion NVARCHAR(1000),
        NumCtaPago NVARCHAR(1000),
        Receptor NVARCHAR(1000),
        UUID VARCHAR(500),
        FechaTimbrado DATETIME,
        SelloCFD NVARCHAR(1000),
        NoCertificadoSAT NVARCHAR(1000),
        SelloSAT NVARCHAR(1000),
        Tipo NVARCHAR(1000),
        FechaRecepcion DATETIME,
        PRIMARY KEY (IdFactura)
    )


    INSERT INTO #FI_Factura
    (
        IdFactura,
        Archivo,
        IdSubcontratista,
        IdSubcontratistaTexto,
        IdMoneda,
        IdMonedaTexto,
        IdReceptor,
        IdReceptorTexto,
        TieneSoporte,
        Emisor,
        Fecha,
        Serie,
        Folio,
        Subtotal,
        Descuento,
        TipoCambio,
        MontoConIva,
        TipoComprobante,
        MetodoPago,
        LugarExpedicion,
        NumCtaPago,
        Receptor,
        UUID,
        FechaTimbrado,
        SelloCFD,
        NoCertificadoSAT,
        SelloSAT,
        Tipo,
        FechaRecepcion
    )
    SELECT F.IdFactura,
           0,
           F.IdSubcontratista,
           '',
           F.IdMoneda,
           '',
           F.IdReceptor,
           '',
           0,
           Emisor,
           Fecha,
           Serie,
           Folio,
           Subtotal,
           Descuento,
           TipoCambio,
           MontoConIva,
           TipoComprobante,
           MetodoPago,
           LugarExpedicion,
           NumCtaPago,
           Receptor,
           UUID,
           FechaTimbrado,
           SelloCFD,
           NoCertificadoSAT,
           SelloSAT,
           Tipo,
           FechaRecepcion
    FROM FI_Factura F (NOLOCK)
    WHERE F.IdContrato = @IdContrato
          AND F.Activa = 1

    UPDATE TEMP
    SET Archivo = CASE
                      WHEN D.DocumentoByte LIKE 0x OR  D.DocumentoByte IS NULL THEN
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
    SET TieneSoporte = 1
    FROM #FI_Factura TEMP
        JOIN FI_RelacionSoporteFactura FS (NOLOCK)
            ON TEMP.IdFactura = FS.IdFactura
               AND FS.DocumentoSoporteId IS NOT NULL
               AND FS.Activo = 1

    UPDATE TEMP
    SET IdMonedaTexto = M.TipoMonedaCorto
    FROM #FI_Factura TEMP
        JOIN PV_TipoMoneda M (NOLOCK)
            ON TEMP.IdMoneda = M.IdMoneda

    UPDATE TEMP
    SET IdSubcontratistaTexto = S.RazonSocial
    FROM #FI_Factura TEMP
        JOIN PV_Subcontratista S (NOLOCK)
            ON TEMP.IdSubcontratista = S.IdSubcontratista

    UPDATE TEMP
    SET IdReceptorTexto = R.RazonSocial
    FROM #FI_Factura TEMP
        JOIN PV_Subcontratista R (NOLOCK)
            ON TEMP.IdReceptor = R.IdSubcontratista

    SELECT #FI_Factura.IdFactura,
           #FI_Factura.IdSubcontratistaTexto AS NombreEmisor,
           #FI_Factura.Emisor AS RFC_Emisor,
           #FI_Factura.Fecha,
           #FI_Factura.Serie,
           #FI_Factura.Folio,
           #FI_Factura.SubTotal,
           #FI_Factura.Descuento,
           #FI_Factura.TipoCambio,
           #FI_Factura.MontoConIva AS Total,
           #FI_Factura.IdMonedaTexto AS Moneda,
           SUBSTRING(#FI_Factura.TipoComprobante, 1, 1) AS TipoComprobante,
           #FI_Factura.MetodoPago,
           #FI_Factura.LugarExpedicion,
           #FI_Factura.NumCtaPago,
           #FI_Factura.Receptor,
           #FI_Factura.UUID,
           #FI_Factura.FechaTimbrado,
           #FI_Factura.SelloCFD,
           #FI_Factura.NoCertificadoSAT,
           #FI_Factura.SelloSAT,
           #FI_Factura.Tipo,
           #FI_Factura.FechaRecepcion,
           YEAR(#FI_Factura.Fecha) AS Año,
           CONCAT(
                     RIGHT('00' + CAST(MONTH(#FI_Factura.fecha) AS VARCHAR(2)), 2),
                     ' ',
                     DATENAME(month, #FI_Factura.Fecha)
                 ) AS Mes,
           #FI_Factura.IdReceptorTexto AS Receptor,
           TieneArchivo = #FI_Factura.Archivo,
           TieneSoporte = #FI_Factura.TieneSoporte,
           ISNULL((#FI_Factura.MontoConIva * .16), 0) AS IVA
    FROM #FI_Factura (NOLOCK)
    ORDER BY #FI_Factura.IdFactura DESC;
END;