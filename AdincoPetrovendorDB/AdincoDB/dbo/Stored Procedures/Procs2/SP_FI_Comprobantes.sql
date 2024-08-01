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
        IdPedimentoComprobante INT PRIMARY KEY,
        Archivo VARCHAR(50) DEFAULT 'NO CARGADO',
        NumeroSerieMercancia VARCHAR(5000) DEFAULT '',
        ClaseBienServicio VARCHAR(5000) DEFAULT '',
        PrecioUnitario MONEY,
        Cantidad NUMERIC,
        ImporteTotal MONEY,
        IdUnidadMedida INT,
        IdUnidadMedidaTexto VARCHAR(5000) DEFAULT '',
        IdSubcontratistaExportador INT,
        IdSubcontratistaExportadorTexto VARCHAR(5000) DEFAULT '',
        IdMonedaTexto VARCHAR(5000) DEFAULT '',
        IdFormaPagoTexto VARCHAR(5000) DEFAULT '',
        CreadoPor INT,
        CreadoPorTexto VARCHAR(5000) DEFAULT '',
        ModificadoPor INT,
        ModificadoPorTexto VARCHAR(5000) DEFAULT '',
		FolioComprobante NVARCHAR(100),
		FechaPago DATE,
		CreadoEn Datetime,
		ModificadoEn Datetime,
		NumFacturaC  NVARCHAR(100),
		EsnotaCredito BIT
    );

	DECLARE @CvTipoDocFacturacionComprobantes INT= 3;
	DECLARE @GrupoId INT = 10001;

    INSERT INTO #FI_Comprobante
    (
        IdPedimentoComprobante,
		FolioComprobante,
		FechaPago,
		CreadoEn,
		ModificadoEn,
		NumFacturaC,
		EsnotaCredito,
		CreadoPorTexto,
		ModificadoPorTexto,
		IdMonedaTexto,
		IdSubcontratistaExportadorTexto,
		IdFormaPagoTexto ,
		Archivo
    )
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante,
		   FI_PedimentoComprobante. FolioComprobante,
		   FI_PedimentoComprobante.FechaPago,
		   FI_PedimentoComprobante.CreadoEn,
		   FI_PedimentoComprobante.ModificadoEn,
		   FI_PedimentoComprobante.NumFacturaC,
		   FI_PedimentoComprobante.EsnotaCredito,
		   ISNULL(Creado.Nombre, ''),
		   ISNULL(Modificado.Nombre, ''),
		   ISNULL(PV_TipoMoneda.TipoMonedaCorto, ''),
		   ISNULL(Exportador.RazonSocial, ''),
		   ISNULL(AP_Lista.Nombre, ''),
		   CASE
                      WHEN FI_Documento.DocumentoByte LIKE 0x OR FI_Documento.IdDocumento IS NULL  THEN
                          'NO CARGADO'
                      ELSE
                          'Cargado'
                  END
    FROM FI_PedimentoComprobante  (NOLOCK)
	LEFT JOIN AP_Usuario Creado	 (NOLOCK)
		ON FI_PedimentoComprobante.CreadoPor = Creado.UsuarioID
	LEFT JOIN AP_Usuario Modificado	(NOLOCK)
		ON FI_PedimentoComprobante.CreadoPor = Modificado.UsuarioID
	LEFT JOIN PV_TipoMoneda  (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
	LEFT JOIN dbo.PV_Subcontratista Exportador 	(NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = Exportador.IdSubcontratista
	LEFT JOIN dbo.AP_Lista	(NOLOCK)
            ON AP_Lista.IdGrupo = @GrupoId 
               AND FI_PedimentoComprobante.IdFormaPago = AP_Lista.IdClave
	LEFT JOIN dbo.FI_Documento (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_Documento.IdPedimentoComprobante
               AND FI_Documento.DocumentoByte IS NOT NULL
               AND ISNULL(FI_Documento.IsEliminado, 0) = 0 
    WHERE FI_PedimentoComprobante.CvTipoDocFacturacion = @CvTipoDocFacturacionComprobantes
          AND FI_PedimentoComprobante.IdContrato = @IdContrato
 

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

    SELECT TEMP.IdPedimentoComprobante AS IdComprobante,
           TEMP.FolioComprobante,
           TEMP.FechaPago,
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
           TEMP.CreadoEn,
           TEMP.ModificadoPorTexto AS ModificadoPor,
           TEMP.ModificadoEn,
           TEMP.NumFacturaC,
           CASE
               WHEN ISNULL(TEMP.EsnotaCredito, 0) = 0 THEN
                   'No'
               ELSE
                   'Si'
           END AS EsnotaCredito
    FROM #FI_Comprobante TEMP
    GROUP BY TEMP.IdPedimentoComprobante,
             TEMP.FolioComprobante,
             TEMP.FechaPago,
             SUBSTRING(TEMP.IdSubcontratistaExportadorTexto, 0, 30),
             TEMP.NumeroSerieMercancia,
             TEMP.ClaseBienServicio,
             SUBSTRING(TEMP.IdUnidadMedidaTexto, 0, 30),
             TEMP.IdMonedaTexto,
             TEMP.Cantidad,
             TEMP.IdFormaPagoTexto,
             Archivo,
             TEMP.CreadoPorTexto,
             TEMP.CreadoEn,
             TEMP.ModificadoPorTexto,
             TEMP.ModificadoEn,
             TEMP.NumFacturaC,
             ISNULL(TEMP.EsnotaCredito, 0),
			 TEMP.ImporteTotal
    ORDER BY IdComprobante DESC;

END;
