-- =============================================
-- Author:          Manuel CD
-- Create date: 1-09-17
-- Description:     
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 16-12-2019
-- Description:	Agregar Columnas Año y Mes 
--				agregar SET LANGUAGE spanish
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_TransferContrato] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SET LANGUAGE spanish;
         --===========================================
         IF OBJECT_ID('tempdb..#Facturas', 'U') IS NOT NULL
             DROP TABLE #Facturas;
         --===========================================
         CREATE TABLE #Facturas
         (IdFactura       INT, 
          Serie           NVARCHAR(MAX), 
          NumeroContrato  NVARCHAR(50), 
          Folio           NVARCHAR(MAX), 
          Fecha           DATETIME, 
          FormaPago       NVARCHAR(MAX), 
          SubTotal        MONEY, 
          Moneda          NVARCHAR(MAX), 
          MontoConIva     MONEY, 
          TipoComprobante NVARCHAR(MAX), 
          MetodoPago      NVARCHAR(MAX), 
          LugarExpedicion NVARCHAR(MAX), 
          UUID            VARCHAR(500), 
          FechaRecepcion  DATETIME, 
          RazonSocial     VARCHAR(MAX), 
          Emisor          NVARCHAR(MAX)
         );
         --===========================================
         INSERT INTO #Facturas
         (IdFactura, 
          Serie, 
          NumeroContrato, 
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
                SELECT DISTINCT 
                       F.IdFactura, 
                       F.Serie, 
                       C.NumeroContrato, 
                       F.Folio, 
                       F.Fecha,
                       CASE
                           WHEN F.MetodoPago LIKE '%exhibi%'
                                OR F.MetodoPago LIKE '%PUE%'
                                OR F.MetodoPago LIKE '%parcia%'
                                OR F.MetodoPago LIKE '%dife%'
                                OR F.MetodoPago LIKE '%PPD%'
                           THEN F.FormaPago
                           WHEN F.FormaPago LIKE '%exhibi%'
                                OR F.FormaPago LIKE '%PUE%'
                                OR F.FormaPago LIKE '%parcia%'
                                OR F.FormaPago LIKE '%dife%'
                                OR F.FormaPago LIKE '%PPD%'
                           THEN F.MetodoPago
                           ELSE 'NA'
                       END AS FormaPago, 
                       ISNULL(F.SubTotal, 0) AS SubTotal, 
                       F.Moneda, 
                       ISNULL(F.MontoConIva, 0) AS MontoConIva, 
                       F.TipoComprobante,
                       CASE
                           WHEN F.MetodoPago LIKE '%exhibi%'
                                OR F.MetodoPago LIKE '%PUE%'
                                OR F.FormaPago LIKE '%exhibi%'
                                OR F.FormaPago LIKE '%PUE%'
                           THEN 'PUE'
                           WHEN F.MetodoPago LIKE '%parcia%'
                                OR F.MetodoPago LIKE '%dife%'
                                OR F.MetodoPago LIKE '%PPD%'
                                OR F.FormaPago LIKE '%parcia%'
                                OR F.FormaPago LIKE '%dife%'
                                OR F.FormaPago LIKE '%PPD%'
                           THEN 'PPD'
                           ELSE 'NA'
                       END AS MetodoPago, 
                       SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                       F.UUID, 
                       F.FechaRecepcion, 
                       S.RazonSocial, 
                       F.Emisor
                FROM dbo.FI_Factura AS F
                     JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
                     JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
                WHERE C.IdContrato = @IdContrato;

         /**/

         CREATE TABLE #UUIDS
         (IdTransfer INT, 
          UUID       VARCHAR(500)
         );
         CREATE TABLE #TransferenciaUUIDS
         (IdTransfer INT, 
          UUIDS      VARCHAR(8000)
         );

         /**/

         INSERT INTO #UUIDS
         (#UUIDS.IdTransfer, 
          #UUIDS.UUID
         )
                SELECT t.IdTransferencia, 
                       concat(ff.TipoComprobante, '-', SUBSTRING(LTRIM(RTRIM(ff.UUID)), 1, 500))
                FROM dbo.FI_Transfer AS T
                     LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
                     LEFT JOIN dbo.FI_Factura ff ON tf.IdFactura = ff.IdFactura
                WHERE T.IdContrato = @IdContrato
                      AND TF.IdTransfer IS NOT NULL
                GROUP BY t.IdTransferencia, 
                         concat(ff.TipoComprobante, '-', SUBSTRING(LTRIM(RTRIM(ff.UUID)), 1, 500));

         /**/

         INSERT INTO #UUIDS
         (#UUIDS.IdTransfer, 
          #UUIDS.UUID
         )
                SELECT t.IdTransferencia, 
                       concat('I-', SUBSTRING(LTRIM(RTRIM(fcr.IdDocumento)), 1, 500))
                FROM dbo.FI_Transfer AS T
                     LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
                     LEFT JOIN dbo.FI_Factura ff ON tf.IdFactura = ff.IdFactura
                     JOIN dbo.FI_ComplementoDePago cp ON cp.IdFactura = ff.IdFactura
                     JOIN dbo.FI_CPDocRelacionado fcr ON fcr.IdComplementoDePago = cp.IdComplementoDePago
                WHERE T.IdContrato = @IdContrato
                      AND TF.IdTransfer IS NOT NULL
                GROUP BY t.IdTransferencia, 
                         concat('I-', SUBSTRING(LTRIM(RTRIM(fcr.IdDocumento)), 1, 500));

         /**/

         INSERT INTO #TransferenciaUUIDS
         (IdTransfer, 
          UUIDS
         )
                SELECT DISTINCT 
                       B.IdTransfer, 
                       SUBSTRING(STUFF(
                (
                    SELECT ' | '+RTRIM(LTRIM(UUID))
                    FROM #UUIDS u
                    WHERE B.IdTransfer = u.IdTransfer FOR XML PATH('')
                ), 1, 1, ''), 1, 8000)
                FROM #UUIDS B
                GROUP BY IdTransfer;

         /**/

         SELECT DISTINCT 
                T.IdTransferencia, 
                CBO.CuentaClave AS 'Cuenta Origen', 
                CBD.CuentaClave AS 'Cuenta Destino', 
                S.RazonSocial, 
                S.RFC, 
                T.ReferenciaBancaria, 
                T.FechaPago, 
                YEAR(T.FechaPago) AS Año, 
                CONCAT(RIGHT('00'+CAST(MONTH(T.FechaPago) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, T.FechaPago)) AS Mes, 
                T.MontoPagado, 
                T.Intereses, 
                MP.MetodoPago, 
                TM.TipoMonedaCorto AS TipoMoneda, 
                concat(T.Concepto, ' - UUID ', UPPER(isnull(tu.UUIDS, ''))) AS Concepto, 
                T.NumeroPolizaContable,
                --CASE
                --    WHEN T.PDF LIKE ''
                --         OR T.PDF IS NULL
                --    THEN '¡PDF NO CARGADO!'
                --    ELSE 'Pdf Cargado'
                --END AS 'Comprobante de Pago', 
                CASE
                    WHEN T.AWSPDFId IS NULL
                    THEN '¡PDF NO CARGADO!'
                    ELSE 'Pdf Cargado'
                END AS 'Comprobante de Pago', 
                U.Nombre AS CreadoPor, 
                T.CreadoEn AS 'Fecha Registro', 
                UM.Nombre AS ModificadoPor, 
                T.ModificadoEn AS 'Fecha Modificado',
                CASE
                    WHEN TF.CvTipoDocFacturacion = 1
                         AND T.IdFormaPago = 1
                    THEN 'CF PUE'
                    WHEN TF.CvTipoDocFacturacion = 2
                    THEN 'PI'
                    WHEN TF.CvTipoDocFacturacion = 3
                    THEN 'PE'
                    WHEN TF.CvTipoDocFacturacion = 6
                    THEN 'CF-P'
                    WHEN TF.CvTipoDocFacturacion = 1
                         AND T.IdFormaPago = 2
                    THEN 'CF PPD Pendiente de Complemento de Pago'
                    WHEN TF.CvTipoDocFacturacion = 1
                         AND FT.MetodoPago = 'PUE'
                    THEN 'CF PUE'
                    WHEN TF.CvTipoDocFacturacion = 1
                         AND FT.MetodoPago = 'PPD'
                    THEN 'CF PPD Pendiente de Complemento de Pago'
                    ELSE 'NA'
                END AS TipoDoc
         FROM dbo.FI_Transfer AS T
              JOIN dbo.PV_CuentaBancaria AS CBD ON CBD.DatoBancarioID = T.IdCuentaDestino
              JOIN dbo.PV_CuentaBancaria AS CBO ON CBO.DatoBancarioID = T.IdCuentaOrigen
              JOIN dbo.PV_Subcontratista AS S ON CBD.IdProveedor = S.IdSubcontratista
              JOIN dbo.PV_TipoMoneda AS TM ON T.IdMoneda = TM.IdMoneda
              JOIN dbo.PV_MetodoPago AS MP ON T.IdMetodoPago = MP.idMetodoPago
              LEFT JOIN dbo.AP_Usuario AS U ON T.CreadoPor = U.UsuarioID
              LEFT JOIN dbo.AP_Usuario AS UM ON T.ModificadoPor = UM.UsuarioID
              LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdTransfer = T.IdTransferencia
              LEFT JOIN #TransferenciaUUIDS tu ON tu.IdTransfer = t.IdTransferencia
              LEFT JOIN #Facturas AS FT ON FT.IdFactura = TF.IdFactura
         WHERE T.IdContrato = @IdContrato
               AND TF.IdTransfer IS NOT NULL
         ORDER BY T.IdTransferencia DESC;
     END;