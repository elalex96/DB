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
        NumeroSerieMercancia NVARCHAR(MAX),
        ClaseBienServicio NVARCHAR(MAX),
        PrecioUnitario MONEY,
        Cantidad NUMERIC,
        ImporteTotal MONEY,
        IdUnidadMedida INT,
        IdUnidadMedidaTexto VARCHAR(MAX),
        IdSubcontratistaImportador INT,
        IdSubcontratistaImportadorTexto VARCHAR(MAX),
        IdSubcontratistaExportador INT,
        IdSubcontratistaExportadorTexto VARCHAR(MAX),
        IdMoneda INT,
        IdMonedaTexto VARCHAR(MAX),
        IdFormaPago INT,
        IdFormaPagoTexto VARCHAR(MAX),
        CreadoPor INT,
        CreadoPorTexto VARCHAR(MAX),
        ModificadoPor INT,
        ModificadoPorTexto VARCHAR(MAX),
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
    SELECT PC.IdPedimentoComprobante,
           'NO CARGADO',
           '',
           '',
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           PC.IdSubcontratistaImportador,
           '',
           PC.IdSubcontratistaExportador,
           '',
           PC.IdMoneda,
           '',
           PC.IdFormaPago,
           '',
           PC.CreadoPor,
           '',
           PC.ModificadoPor,
           ''
    FROM FI_PedimentoComprobante PC (NOLOCK)
    WHERE PC.CvTipoDocFacturacion = 3
          AND PC.IdContrato = @IdContrato

    UPDATE TEMP
    SET Archivo = CASE
                      WHEN D.DocumentoByte LIKE 0x THEN
                          'NO CARGADO'
                      ELSE
                          'Cargado'
                  END
    FROM #FI_Comprobante TEMP
        JOIN dbo.FI_Documento D (NOLOCK)
            ON TEMP.IdPedimentoComprobante = D.IdPedimentoComprobante
               AND D.DocumentoByte IS NOT NULL
               AND ISNULL(D.IsEliminado, 0) = 0

    UPDATE TEMP
    SET CreadoPorTexto = UC.Nombre
    FROM #FI_Comprobante TEMP
        JOIN dbo.AP_Usuario UC (NOLOCK)
            ON TEMP.CreadoPor = UC.UsuarioID

    UPDATE TEMP
    SET ModificadoPorTexto = UM.Nombre
    FROM #FI_Comprobante TEMP
        JOIN dbo.AP_Usuario UM (NOLOCK)
            ON TEMP.ModificadoPor = UM.UsuarioID

    UPDATE TEMP
    SET IdFormaPagoTexto = L.Nombre
    FROM #FI_Comprobante TEMP
        JOIN dbo.AP_Lista L (NOLOCK)
            ON TEMP.IdFormaPago = L.IdClave
               AND L.IdGrupo = 10001

    UPDATE TEMP
    SET IdMonedaTexto = M.TipoMonedaCorto
    FROM #FI_Comprobante TEMP
        JOIN PV_TipoMoneda M (NOLOCK)
            ON TEMP.IdMoneda = M.IdMoneda


    UPDATE TEMP
    SET IdSubcontratistaImportadorTexto = SI.RazonSocial
    FROM #FI_Comprobante TEMP
        JOIN dbo.PV_Subcontratista SI (NOLOCK)
            ON TEMP.IdSubcontratistaImportador = SI.IdSubcontratista

    UPDATE TEMP
    SET IdSubcontratistaExportadorTexto = SE.RazonSocial
    FROM #FI_Comprobante TEMP
        JOIN dbo.PV_Subcontratista SE (NOLOCK)
            ON TEMP.IdSubcontratistaExportador = SE.IdSubcontratista

    UPDATE TEMP
    SET NumeroSerieMercancia = PCD.NumeroSerieMercancia,
        ClaseBienServicio = PCD.ClaseBienServicio,
        PrecioUnitario = PCD.PrecioUnitario,
        Cantidad = PCD.Cantidad,
        ImporteTotal = PCD.ImporteTotal,
        IdUnidadMedida = PCD.IdUnidadMedida
    FROM #FI_Comprobante TEMP
        JOIN FI_PedimentoComprobanteDetalle PCD (NOLOCK)
            ON TEMP.IdPedimentoComprobante = PCD.IdPedimentoComprobante

    UPDATE TEMP
    SET IdUnidadMedidaTexto = MU.UMB
    FROM #FI_Comprobante TEMP
        JOIN dbo.PV_MM_MaterialUnidad MU (NOLOCK)
            ON TEMP.IdUnidadMedida = MU.IdUnidad

    SELECT PC.IdPedimentoComprobante AS IdComprobante,
           PC.FolioComprobante,
           PC.FechaPago,
           SUBSTRING(TEMP.IdSubcontratistaExportadorTexto, 0, 30) AS Exportador,
           TEMP.NumeroSerieMercancia,
           TEMP.ClaseBienServicio,
           SUBSTRING(TEMP.IdUnidadMedidaTexto, 0, 30) AS UnidadMedida,
           TEMP.IdMonedaTexto AS TipoMonedaCorto,
           ----------------------------------------------------------------------- 
           /*Se suma el importe total pero se deja con el nombre de PrecioUnitario para no afectar en codigo :
					<dx:GridViewDataTextColumn FieldName="PrecioUnitario" VisibleIndex="9" Caption="Subtotal"> 
					Cuando no hay importe total si se toma el precio unitario*/
           ----------------------------------------------- DR 03/08/2020
           SUM(   CASE
                      WHEN TEMP.ImporteTotal IS NOT NULL THEN
                          TEMP.ImporteTotal
                      ELSE
                          TEMP.PrecioUnitario
                  END
              ) AS 'PrecioUnitario',
           ----------------------------------------------------------------------------  
           TEMP.Cantidad,
           ----------------------------------------------------------------------------
           /*Se envía como nulo ya que no se ocupa y para no afectar en codigo:
					<dx:GridViewDataTextColumn FieldName="ImporteTotal" VisibleIndex="11" Visible="false">*/
           ---------------------- DR 03/08/2020
           NULL AS 'ImporteTotal',
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
        JOIN FI_PedimentoComprobante PC (NOLOCK)
            ON TEMP.IdPedimentoComprobante = PC.IdPedimentoComprobante
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
             END
    ORDER BY IdComprobante DESC;
END;