CREATE PROCEDURE [dbo].[sp_FI_ConsultaFacturasPorContratoGastos]
-- Add the parameters for the stored procedure here
--[sp_FI_ConsultaFacturasPorContratoGastos] 10015,1
--[sp_FI_ConsultaFacturasPorContratoGastos] 10016,1
--[sp_FI_ConsultaFacturasPorContratoGastos] 10018,1
--[sp_FI_ConsultaFacturasPorContratoGastos] 10007,1
@IdContrato INT = 0, 
@IdUsuario  INT = 0
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
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SET LANGUAGE spanish;

/*
         --DROP TABLE #CartasProcura;
         --DROP TABLE #Facturas;
         */

         CREATE TABLE #CartasProcura
         (IdFacutra INT, 
          UUID      NVARCHAR(100)
         );

         /**/

         CREATE TABLE #Facturas
         (IdFactura        INT, 
          NombreEmisor     NVARCHAR(MAX), 
          RFC_Emisor       NVARCHAR(MAX), 
          Fecha            DATETIME, 
          Serie            NVARCHAR(MAX), 
          Folio            NVARCHAR(MAX), 
          SubTotal         FLOAT, 
          Descuento        FLOAT, 
          TipoCambio       FLOAT, 
          Total            FLOAT, 
          Moneda           NVARCHAR(MAX), 
          TipoComprobante  NVARCHAR(MAX), 
          MetodoPago       NVARCHAR(MAX), 
          LugarExpedicion  NVARCHAR(MAX), 
          NumCtaPago       NVARCHAR(MAX), 
          RFC_Receptor     NVARCHAR(MAX), 
          UUID             NVARCHAR(MAX), 
          FechaTimbrado    DATETIME, 
          SelloCFD         NVARCHAR(MAX), 
          NoCertificadoSAT NVARCHAR(MAX), 
          SelloSAT         NVARCHAR(MAX), 
          Tipo             NVARCHAR(MAX), 
          FechaRecepcion   DATETIME, 
          Año              INT, 
          Mes              NVARCHAR(MAX), 
          NombreReceptor   NVARCHAR(MAX), 
          TieneArchivo     BIT, 
          IVA              FLOAT, 
          IdContrato       INT, 
          CCN              BIT, 
          CRCCN            NVARCHAR(MAX)
         );

         /**/

         INSERT INTO #CartasProcura
         (IdFacutra, 
          UUID
         )
                SELECT DISTINCT 
                       FP.IdFactura, 
                       FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
                FROM Petrovendor.dbo.MM_AceptacionCartaPCN	AS AC (NOLOCK)
                     JOIN Petrovendor.dbo.S_Documento_S3	AS D (NOLOCK)
						 ON D.IdDocumento = AC.IdDocumento
						 AND AC.IdEstatus = 2
						 AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                     JOIN Petrovendor.dbo.MM_AceptacionPedido AS AP (NOLOCK)
						ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                     JOIN Petrovendor.dbo.MM_Pedido			AS P (NOLOCK)
						ON P.IdPedido = AP.IdPedido
						AND P.IdContrato = @IdContrato
                     JOIN Petrovendor.dbo.S_Proveedor AS PR (NOLOCK)
						ON PR.IdProveedor = P.IdSubcontratista
                     JOIN Petrovendor.dbo.S_TipoValidacionDoc AS TD (NOLOCK)
						ON TD.IdTipoValidacionDoc = AC.IdEstatus
                     JOIN Petrovendor.dbo.MM_Pedidos AS PG (NOLOCK)
						ON P.IdPedido = PG.IdIdentificador
                     LEFT JOIN Petrovendor.dbo.MM_TipoPedido AS TP (NOLOCK)
						ON TP.IdTipoPedido = PG.IdTipoPedido
                     LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF (NOLOCK)
						ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
                     LEFT JOIN Petrovendor.dbo.FI_Factura FP (NOLOCK)
						ON FP.IdFactura = AF.IdFactura
                WHERE AC.IdEstatus = 2
                      AND ISNULL(AC.IdEstatusEliminado, 0) <> 1
                      AND P.IdContrato = @IdContrato
                      AND FP.UUID IS NOT NULL
                      AND FP.Activa = 1
                      AND ISNULL(FP.IsEliminado, 0) <> 1;--*******

         /**/

         IF --@IdCon = 0 AND 
         @IdContrato = 10007
             BEGIN
                 INSERT INTO #Facturas
                 (IdFactura, 
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
                  CRCCN
                 )
                        SELECT F.IdFactura, 
                               S.RazonSocial AS NombreEmisor, 
                               S.RFC AS RFC_Emisor, 
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
                               CONCAT(RIGHT('00'+CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes, 
                               CC.RazonSocial AS Receptor, 
                               TieneArchivo = CAST(CASE
                                                       WHEN D.DocumentoByte IS NULL
                                                       THEN 0
                                                       ELSE 1
                                                   END AS BIT), 
                               ISNULL((F.MontoConIva * .16), 0) AS IVA, 
                               C.IdContrato,
                               CASE
                                   WHEN WAD.IdDocAwsDocAdinco IS NULL
                                   THEN 0
                                   ELSE 1
                               END AS CCN, 
                               NULL AS CRCCN
                        FROM dbo.FI_Factura AS F	(NOLOCK)
                             JOIN dbo.PV_Subcontratista AS S (NOLOCK)
								ON F.IdSubcontratista = S.IdSubcontratista
								AND	F.IdContrato = @IdContrato
                             JOIN dbo.CO_Contrato C (NOLOCK)
								ON F.IdContrato = C.IdContrato
                             JOIN dbo.CO_Contratista CC (NOLOCK)
								ON C.IdContratista = CC.IdContratista
                             JOIN dbo.PV_TipoMoneda M (NOLOCK)
								ON M.IdMoneda = F.IdMoneda
                             LEFT JOIN dbo.FI_Documento D (NOLOCK)
								ON F.IdFactura = D.IdFactura
                                                             AND D.IdTipoDocumento = 1
                                                             AND ISNULL(D.IsEliminado, 0) = 0
                             LEFT JOIN dbo.AWS_DocAwsDocAdinco WAD (NOLOCK)
								ON F.IdFactura = WAD.IdDocAdinco
                        WHERE F.IdContrato = @IdContrato
                        ORDER BY F.IdFactura DESC;
             END;

                 /**/

             ELSE
             BEGIN
                 INSERT INTO #Facturas
                 (IdFactura, 
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
                  CRCCN
                 )
                 SELECT DISTINCT 
                        F.IdFactura, 
                        S.RazonSocial AS NombreEmisor, 
                        S.RFC AS RFC_Emisor, 
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
                        CONCAT(RIGHT('00'+CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes, 
                        CC.RazonSocial AS Receptor, 
                        TieneArchivo = CAST(CASE
                                                WHEN D.DocumentoByte IS NULL
                                                THEN 0
                                                ELSE 1
                                            END AS BIT), 
                        ISNULL((F.MontoConIva * .16), 0) AS IVA, 
                        C.IdContrato,
                        CASE
                            WHEN WAD.IdDocAwsDocAdinco IS NULL
                            THEN 0
                            ELSE 1
                        END AS CCN, 
                        NULL AS CRCCN
                 FROM dbo.FI_Factura AS F	(NOLOCK)
                      JOIN dbo.PV_Subcontratista AS S (NOLOCK)
						ON F.IdSubcontratista = S.IdSubcontratista
						AND	F.IdContrato = @IdContrato
                      JOIN dbo.CO_Contrato C (NOLOCK)
						ON F.IdContrato = C.IdContrato
                      JOIN dbo.CO_Contratista CC (NOLOCK)
						ON C.IdContratista = CC.IdContratista
						AND CC.RFC <> F.Emisor
                      JOIN dbo.PV_TipoMoneda M (NOLOCK)
						ON M.IdMoneda = F.IdMoneda
                      LEFT JOIN dbo.FI_Documento D (NOLOCK)
						ON F.IdFactura = D.IdFactura
                                                      AND D.IdTipoDocumento = 1
                                                      AND ISNULL(D.IsEliminado, 0) = 0
                      LEFT JOIN dbo.AWS_DocAwsDocAdinco WAD ON F.IdFactura = WAD.IdDocAdinco
                 WHERE F.IdContrato = @IdContrato
                       AND CC.RFC <> F.Emisor
                 UNION
                 SELECT DISTINCT 
						F.IdFactura, 
                        S.RazonSocial AS NombreEmisor, 
                        S.RFC AS RFC_Emisor, 
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
                        CONCAT(RIGHT('00'+CAST(MONTH(F.Fecha) AS VARCHAR(2)), 2), ' ', DATENAME(MONTH, F.Fecha)) AS Mes, 
                        CC.RazonSocial AS Receptor, 
                        TieneArchivo = CAST(CASE
                                                WHEN D.DocumentoByte IS NULL
                                                THEN 0
                                                ELSE 1
                                            END AS BIT), 
                        ISNULL((F.MontoConIva * .16), 0) AS IVA, 
                        F.IdContrato,
                        CASE
                            WHEN WAD.IdDocAwsDocAdinco IS NULL
                            THEN 0
                            ELSE 1
                        END AS CCN, 
                        NULL AS CRCCN
                 FROM dbo.FI_Factura AS F	(NOLOCK)
                      JOIN dbo.FI_FacturaContrato FC (NOLOCK)
						ON F.IdFactura = FC.IdFactura
						AND	FC.IdContrato = @IdContrato
                      JOIN dbo.PV_Subcontratista AS S (NOLOCK)
						ON F.IdSubcontratista = S.IdSubcontratista
                      JOIN dbo.CO_Contrato C (NOLOCK)
						ON FC.IdContrato = C.IdContrato
                      JOIN dbo.CO_Contratista CC (NOLOCK)
						ON C.IdContratista = CC.IdContratista
                      JOIN dbo.PV_TipoMoneda M (NOLOCK)
						ON M.IdMoneda = F.IdMoneda
                      LEFT JOIN dbo.FI_Documento D (NOLOCK)
						ON F.IdFactura = D.IdFactura
                                                      AND D.IdTipoDocumento = 1
                                                      AND ISNULL(D.IsEliminado, 0) = 0
                      LEFT JOIN dbo.AWS_DocAwsDocAdinco WAD (NOLOCK)
						ON F.IdFactura = WAD.IdDocAdinco
                 WHERE FC.IdContrato = @IdContrato
                 ORDER BY F.IdFactura DESC;
             END;

         /**/

         UPDATE #Facturas
           SET 
               CCN = 1
         FROM #Facturas F
              JOIN #CartasProcura CP ON CP.UUID = F.UUID
         WHERE F.UUID = CP.UUID;

		 /**/
		 
		 UPDATE #Facturas 
		 SET 
			TipoComprobante = '' 
		 WHERE TipoComprobante IS NULL 
			   AND UUID IS NULL

         /**/

         SELECT F.IdFactura, 
                F.NombreEmisor AS NombreEmisor, 
                F.RFC_Emisor AS RFC_Emisor, 
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
                ISNULL(CONCAT(F.TipoComprobante, ' - ', F.Tipo), '') AS Tipo, 
                F.FechaRecepcion, 
                F.Año, 
                F.Mes, 
                F.NombreReceptor AS Receptor, 
                F.TieneArchivo, 
                F.IVA, 
                F.IdContrato, 
                F.CCN, 
                F.CRCCN, 
                C.NumeroContrato
         FROM #Facturas F
              JOIN dbo.CO_Contrato C ON C.IdContrato = F.IdContrato
         WHERE F.TipoComprobante NOT LIKE '%P%'
         ORDER BY F.IdFactura DESC;

         /**/

         --[sp_FI_ConsultaFacturasPorContratoGastos] 3,1
     END;
