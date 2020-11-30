-- =============================================
-- Author:		Reyna Olvera
-- Create date: 05/06/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContratoConSoporte] 
-- sp_FI_ConsultaFacturasPorContratoConSoporte 3
@IdContrato INT = 0
AS
BEGIN
             -- SET NOCOUNT ON added to prevent extra result sets from
             -- interfering with SELECT statements.
             SET NOCOUNT ON;
             SET LANGUAGE spanish;

             /**/

             SELECT --DISTINCT
             F.IdFactura, 
             S.RazonSocial AS NombreEmisor, 
             F.Emisor AS RFC_Emisor, 
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
             CONCAT(RIGHT('00'+CAST(MONTH(f.fecha) AS VARCHAR(2)), 2), ' ', DATENAME(month, f.Fecha)) AS Mes, 
             r.RazonSocial AS Receptor,

/*CASE
                         WHEN D.Documento IS NULL
                         THEN 'Falta PDF'
                         ELSE 'PDF Cargado'
                     END AS Archivo,*/

             TieneArchivo = CAST(CASE
                                     WHEN D.DocumentoByte IS NULL
                                     THEN 0
                                     ELSE 1
                                 END AS BIT), 
             TieneSoporte = CAST(CASE
                                     WHEN FS.DocumentoSoporteId IS NULL
                                     THEN 0
                                     ELSE 1
                                 END AS BIT), 
             ISNULL((f.MontoConIva * .16), 0) AS IVA
             --, F.IdSubcontratista, F.IdContrato, F.XML, F.Activa, F.ArchivoPDF, F.ArchivoXML, F.CreadoPor, F.CreadoEn, F.ModificadoPor, F.ModificadoEn
             FROM FI_Factura AS F
                  LEFT JOIN PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
                  LEFT JOIN PV_TipoMoneda M ON M.IdMoneda = F.IdMoneda
                  LEFT JOIN PV_Subcontratista R ON R.IdSubcontratista = F.IdReceptor
                  LEFT JOIN FI_Documento D ON F.IdFactura = D.IdFactura
                                              AND D.IdTipoDocumento = 1
                                              AND ISNULL(D.IsEliminado, 0) = 0
                  LEFT JOIN FI_RelacionSoporteFactura FS ON F.IdFactura = FS.IdFactura
             WHERE IdContrato = @IdContrato
             ORDER BY F.IdFactura DESC;
END;