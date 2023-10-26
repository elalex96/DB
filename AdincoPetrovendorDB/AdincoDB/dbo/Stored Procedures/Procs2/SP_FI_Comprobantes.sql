
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_FI_Comprobantes'
    )
    DROP PROCEDURE SP_FI_Comprobantes
GO
-- =============================================  
-- Author:  Manuel CD  
-- Create date: 15-11-17  
-- Description:   
-- =============================================  
-- Modification Author:	Neri del Angel
-- Modification Date:	02 de Junio del 2022
-- Description:			Optimizacion de PROCEDURE por temas de error marcado 
--						[Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding.]
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_Comprobantes]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    CREATE TABLE #FI_Comprobante
    (
        IdPedimentoComprobante INT,
        Archivo VARCHAR(50),
        NumeroSerieMercancia VARCHAR(5000),
        ClaseBienServicio VARCHAR(5000),
        PrecioUnitario MONEY,
        Cantidad NUMERIC,
        ImporteTotal MONEY,
        IdUnidadMedida INT,
        IdUnidadMedidaTexto VARCHAR(5000),
        IdSubcontratistaImportador INT,
        IdSubcontratistaImportadorTexto VARCHAR(5000),
        IdSubcontratistaExportador INT,
        IdSubcontratistaExportadorTexto VARCHAR(5000),
        IdMoneda INT,
        IdMonedaTexto VARCHAR(5000),
        IdFormaPago INT,
        IdFormaPagoTexto VARCHAR(5000),
        CreadoPor INT,
        CreadoPorTexto VARCHAR(5000),
        ModificadoPor INT,
        ModificadoPorTexto VARCHAR(5000),
		PRIMARY KEY (IdPedimentoComprobante)
    )

    INSERT INTO #FI_Comprobante
    (
        IdPedimentoComprobante,
        Archivo,
        NumeroSerieMercancia,
        ClaseBienServicio,
        PrecioUnitario,
        Cantidad,
        ImporteTotal,
        IdUnidadMedida,
        IdUnidadMedidaTexto,
        IdSubcontratistaImportador,
        IdSubcontratistaImportadorTexto,
        IdSubcontratistaExportador,
        IdSubcontratistaExportadorTexto,
        IdMoneda,
        IdMonedaTexto,
        IdFormaPago,
        IdFormaPagoTexto,
        CreadoPor,
        CreadoPorTexto,
        ModificadoPor,
        ModificadoPorTexto
    )
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante,
           'NO CARGADO',
           '',
           '',
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           FI_PedimentoComprobante.IdSubcontratistaImportador,
           '',
           FI_PedimentoComprobante.IdSubcontratistaExportador,
           '',
           FI_PedimentoComprobante.IdMoneda,
           '',
           FI_PedimentoComprobante.IdFormaPago,
           '',
           FI_PedimentoComprobante.CreadoPor,
           '',
           FI_PedimentoComprobante.ModificadoPor,
           ''
    FROM FI_PedimentoComprobante  (NOLOCK)
    WHERE FI_PedimentoComprobante.CvTipoDocFacturacion = 3
          AND FI_PedimentoComprobante.IdContrato = @IdContrato

    UPDATE TEMP
    SET Archivo = CASE
                      WHEN D.DocumentoByte LIKE 0x THEN
                          'NO CARGADO'
                      ELSE
                          'Cargado'
                  END
    FROM #FI_Comprobante TEMP
        JOIN dbo.FI_Documento D 
            ON TEMP.IdPedimentoComprobante = D.IdPedimentoComprobante
               AND D.DocumentoByte IS NOT NULL
               AND ISNULL(D.IsEliminado, 0) = 0

    UPDATE TEMP
    SET CreadoPorTexto = UC.Nombre
    FROM #FI_Comprobante TEMP
        JOIN dbo.AP_Usuario UC 
            ON TEMP.CreadoPor = UC.UsuarioID

    UPDATE TEMP
    SET ModificadoPorTexto = UM.Nombre
    FROM #FI_Comprobante TEMP
        JOIN dbo.AP_Usuario UM 
            ON TEMP.ModificadoPor = UM.UsuarioID

    UPDATE TEMP
    SET IdFormaPagoTexto = L.Nombre
    FROM #FI_Comprobante TEMP
        JOIN dbo.AP_Lista L
            ON TEMP.IdFormaPago = L.IdClave
               AND L.IdGrupo = 10001

    UPDATE TEMP
    SET IdMonedaTexto = M.TipoMonedaCorto
    FROM #FI_Comprobante TEMP
        JOIN PV_TipoMoneda M 
            ON TEMP.IdMoneda = M.IdMoneda


    UPDATE TEMP
    SET IdSubcontratistaImportadorTexto = SI.RazonSocial
    FROM #FI_Comprobante TEMP
        JOIN dbo.PV_Subcontratista SI 
            ON TEMP.IdSubcontratistaImportador = SI.IdSubcontratista

    UPDATE TEMP
    SET IdSubcontratistaExportadorTexto = SE.RazonSocial
    FROM #FI_Comprobante TEMP
        JOIN dbo.PV_Subcontratista SE 
            ON TEMP.IdSubcontratistaExportador = SE.IdSubcontratista

    UPDATE TEMP
    SET NumeroSerieMercancia = PCD.NumeroSerieMercancia,
        ClaseBienServicio = PCD.ClaseBienServicio,
        PrecioUnitario = PCD.PrecioUnitario,
        Cantidad = PCD.Cantidad,
        ImporteTotal = PCD.ImporteTotal,
        IdUnidadMedida = PCD.IdUnidadMedida
    FROM #FI_Comprobante TEMP
        JOIN FI_PedimentoComprobanteDetalle PCD
            ON TEMP.IdPedimentoComprobante = PCD.IdPedimentoComprobante

    UPDATE TEMP
    SET IdUnidadMedidaTexto = MU.UMB
    FROM #FI_Comprobante TEMP
        JOIN dbo.PV_MM_MaterialUnidad MU 
            ON TEMP.IdUnidadMedida = MU.IdUnidad

    SELECT PC.IdPedimentoComprobante AS IdComprobante,
           PC.FolioComprobante,
           PC.FechaPago,
           SUBSTRING(TEMP.IdSubcontratistaExportadorTexto, 0, 30) AS Exportador,
           TEMP.NumeroSerieMercancia,
           TEMP.ClaseBienServicio,
           SUBSTRING(TEMP.IdUnidadMedidaTexto, 0, 30) AS UnidadMedida,
           TEMP.IdMonedaTexto AS TipoMonedaCorto,
           SUM(   CASE
                      WHEN TEMP.PrecioUnitario IS NOT NULL  AND TEMP.PrecioUnitario > 0
					  THEN
                           TEMP.PrecioUnitario
					   ELSE
						   TEMP.ImporteTotal
                  END
              ) AS 'PrecioUnitario',
           TEMP.Cantidad,
           TEMP.ImporteTotal AS 'ImporteTotal',
           TEMP.IdFormaPagoTexto AS FormaDePago,
           Archivo AS 'Archivo',
           TEMP.CreadoPorTexto AS CreadoPor,
           PC.CreadoEn,
           TEMP.ModificadoPorTexto AS ModificadoPor,
           PC.ModificadoEn,
           PC.NumFacturaC,
           CASE
               WHEN ISNULL(PC.EsnotaCredito, 0) = 0 THEN
                   'No'
               ELSE
                   'Si'
           END AS EsnotaCredito
    FROM #FI_Comprobante TEMP
    JOIN 
		FI_PedimentoComprobante PC (NOLOCK)
    ON 
		TEMP.IdPedimentoComprobante = PC.IdPedimentoComprobante
    GROUP BY PC.IdPedimentoComprobante,
             PC.FolioComprobante,
             PC.FechaPago,
             SUBSTRING(TEMP.IdSubcontratistaExportadorTexto, 0, 30),
             TEMP.NumeroSerieMercancia,
             TEMP.ClaseBienServicio,
             SUBSTRING(TEMP.IdUnidadMedidaTexto, 0, 30),
             TEMP.IdMonedaTexto,
             TEMP.Cantidad,
             TEMP.IdFormaPagoTexto,
             Archivo,
             TEMP.CreadoPorTexto,
             PC.CreadoEn,
             TEMP.ModificadoPorTexto,
             PC.ModificadoEn,
             PC.NumFacturaC,
             CASE
                 WHEN ISNULL(PC.EsnotaCredito, 0) = 0 THEN
                     'No'
                 ELSE
                     'Si'
             END,
			 TEMP.ImporteTotal
    ORDER BY IdComprobante DESC;
END;
