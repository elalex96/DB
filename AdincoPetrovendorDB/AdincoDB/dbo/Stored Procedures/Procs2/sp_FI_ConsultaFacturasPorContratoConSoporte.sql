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
CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContratoConSoporte] 
	@IdContrato INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;

    CREATE TABLE #FI_Factura
    (
        IdFactura INT,
        Archivo BIT,
        IdSubcontratista INT,
        IdSubcontratistaTexto VARCHAR(MAX),
        IdMoneda INT,
        IdMonedaTexto VARCHAR(MAX),
        IdReceptor INT,
        IdReceptorTexto VARCHAR(MAX),
        TieneSoporte BIT,
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
        TieneSoporte
    )
    SELECT F.IdFactura,
           0,
           F.IdSubcontratista,
           '',
           F.IdMoneda,
           '',
           F.IdReceptor,
           '',
           0
    FROM FI_Factura F (NOLOCK)
    WHERE F.IdContrato = @IdContrato AND F.Activa = 1

    UPDATE TEMP
    SET Archivo = CASE
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

    SELECT F.IdFactura,
           TEMP.IdSubcontratistaTexto AS NombreEmisor,
           F.Emisor AS RFC_Emisor,
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
           F.LugarExpedicion,
           F.NumCtaPago,
           F.Receptor,
           F.UUID,
           F.FechaTimbrado,
           F.SelloCFD,
           F.NoCertificadoSAT,
           F.SelloSAT,
           F.Tipo,
           F.FechaRecepcion,
           YEAR(f.Fecha) AS Año,
           CONCAT(RIGHT('00' + CAST(MONTH(f.fecha) AS VARCHAR(2)), 2), ' ', DATENAME(month, f.Fecha)) AS Mes,
           TEMP.IdReceptorTexto AS Receptor,
           TieneArchivo = TEMP.Archivo,
           TieneSoporte = TEMP.TieneSoporte,
           ISNULL((f.MontoConIva * .16), 0) AS IVA
    FROM #FI_Factura TEMP
        JOIN FI_Factura F (NOLOCK)
            ON TEMP.IdFactura = F.IdFactura
    ORDER BY F.IdFactura DESC;
END;