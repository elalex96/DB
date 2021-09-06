-- =============================================
-- Author:		Luis David
-- Create date: 15/08/2019
-- =============================================
-- Author:		Marcos Neri
-- Create date: 01/09/2021
-- Se agregan tipo de cambio por idmoneda, moneda por id moneda, se agrgan facturas sin uuid
-- =============================================
CREATE PROCEDURE [dbo].[p_FI_FacturasProveedor] 
--[dbo].[p_FI_FacturasProveedor]  3,10026
-- Add the parameters for the stored procedure here
@IdContrato       INT, 
@IdSubcontratista INT
AS
     BEGIN
         SET NOCOUNT ON;
		 CREATE TABLE #Facturas
         (IdFactura			INT, 
          Serie				NVARCHAR(MAX), 
          Folio				NVARCHAR(MAX), 
          Fecha				DATETIME, 
          FormaPago         NVARCHAR(MAX), 
          NoCertificado     NVARCHAR(MAX), 
          CondicionesDePago NVARCHAR(MAX), 
		  SubTotal			FLOAT,
		  Moneda			NVARCHAR(MAX), 
          MontoConIva       FLOAT, 
		  TipoComprobante	NVARCHAR(MAX), 
		  MetodoPago		NVARCHAR(MAX), 
		  LugarExpedicion	NVARCHAR(MAX), 
		  UUID				NVARCHAR(MAX), 
		  FechaTimbrado		DATETIME, 
		  FechaRecepcion	DATETIME, 
		  RazonSocial       VARCHAR(MAX), 
		  Emisor            NVARCHAR(MAX), 
		  MontoPagado		FLOAT,
		  TCD				FLOAT
         );
		 /**/
		 INSERT INTO #Facturas
         SELECT F.IdFactura, 
                F.Serie, 
                F.Folio, 
                F.Fecha, 
                F.FormaPago, 
                F.NoCertificado, 
                F.CondicionesDePago, 
                F.SubTotal, 
                M.TipoMonedaCorto AS Moneda,
                F.MontoConIva, 
                F.TipoComprobante, 
                F.MetodoPago, 
                SUBSTRING(F.LugarExpedicion, 0, 15) AS LugarExpedicion, 
                F.UUID, 
                F.FechaTimbrado, 
                F.FechaRecepcion, 
                S.RazonSocial, 
                F.Emisor, 
                TF.MontoPagado AS MontoPagado, 
                TCD.TipoCambio AS TCD
         FROM FI_Factura AS F
              LEFT JOIN PV_Subcontratista AS S ON F.IdSubcontratista = S.IdSubcontratista
              LEFT JOIN CO_Contrato AS C ON F.IdContrato = C.IdContrato
              LEFT JOIN FI_TransferFactura TF ON TF.IdFactura = F.IdFactura --AND (tf.IdTransferFactura IS NULL OR TF.IdTransfer=@IdTransfer)
			  LEFT JOIN dbo.PV_TipoMoneda M (NOLOCK)
						ON M.IdMoneda = F.IdMoneda
              LEFT JOIN dbo.CO_TipoCambioDiario TCD ON CONVERT(DATE, F.Fecha) = TCD.Fecha
                                                  AND TCD.IdMoneda = F.IdMoneda
         WHERE S.IdSubcontratista = @IdSubcontratista
               AND C.IdContrato = @IdContrato
               --AND F.TipoComprobante <> 'P'
         GROUP BY F.IdFactura, 
                  F.Serie, 
                  F.Folio, 
                  F.Fecha, 
                  F.FormaPago, 
                  F.NoCertificado, 
                  F.CondicionesDePago, 
                  F.SubTotal, 
                  M.TipoMonedaCorto,
                  F.MontoConIva, 
                  F.TipoComprobante, 
                  F.MetodoPago, 
                  F.LugarExpedicion, 
                  F.UUID, 
                  F.FechaTimbrado, 
                  F.FechaRecepcion, 
                  S.RazonSocial, 
                  F.Emisor, 
                  TF.MontoPagado, 
                  TCD.TipoCambio
		 /**/
		 UPDATE #Facturas 
		 SET 
			TipoComprobante = '' 
		 WHERE TipoComprobante IS NULL 
			   AND UUID IS NULL
		 /**/
		  SELECT
				F.IdFactura, 
                F.Serie, 
                F.Folio, 
                F.Fecha, 
				ISNULL(F.FormaPago, '') AS FormaPago, 
				ISNULL(F.NoCertificado, '') AS NoCertificado, 
				ISNULL(F.CondicionesDePago, '') AS CondicionesDePago,
                ISNULL(F.SubTotal, 0) AS SubTotal,
                ISNULL(F.Moneda, 'NA') AS Moneda, 
				ISNULL(F.MontoConIva, 0) AS MontoConIva,
                UPPER(ISNULL(F.TipoComprobante, '')) AS TipoComprobante, 
				UPPER(ISNULL(F.MetodoPago, '')) AS MetodoPago, 
                UPPER(ISNULL(F.LugarExpedicion, '')) AS LugarExpedicion, 
                ISNULL(F.UUID, 'NA') AS UUID, 
                F.FechaTimbrado, 
                F.FechaRecepcion, 
				ISNULL(F.RazonSocial, '') AS RazonSocial,                  
				ISNULL(F.Emisor, '') AS Emisor,   
				ISNULL(F.MontoPagado, 0) AS MontoPagado,
				ISNULL(F.TCD, 0) AS TCD
         FROM #Facturas F
         WHERE F.TipoComprobante NOT LIKE '%P%'
         ORDER BY F.IdFactura DESC;
     END;