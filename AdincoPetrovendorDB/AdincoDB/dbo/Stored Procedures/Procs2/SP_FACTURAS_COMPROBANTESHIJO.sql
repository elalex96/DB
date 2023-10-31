IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FACTURAS_COMPROBANTESHIJO'
)
    DROP PROCEDURE SP_FACTURAS_COMPROBANTESHIJO;
GO

CREATE PROCEDURE [dbo].[SP_FACTURAS_COMPROBANTESHIJO] 
	@IdFacturapadre INT,
	@IdContrato INT = 0,
	@IdUsuario INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Pedimento INT = 2,
            @Comprobante INT = 3

    CREATE TABLE #TemporalComprobantesHijo
    (
        Identificador INT NULL,
        Tipo VARCHAR(100) NULL,
        NumeroPedimento VARCHAR(100) NULL,
        ClavePedimento VARCHAR(100) NULL,
        FolioComprobante VARCHAR(100) NULL,
        FechaPago DATE NULL,
        Regimen VARCHAR(100) NULL,
        Importador VARCHAR(200) NULL,
        Exportador VARCHAR(200) NULL,
        AduanaES VARCHAR(100) NULL,
        ClaseBienServicio VARCHAR(1000) NULL,
        UnidadMedida VARCHAR(100) NULL,
        AcuseElectronico VARCHAR(100) NULL,
        DescripcionMercancia VARCHAR(1000) NULL,
        TipoMonedaCorto VARCHAR(100) NULL,
        PrecioUnitario MONEY NULL,
        Cantidad INT NULL,
        CuentaBancaria VARCHAR(100) NULL,
        NumFacturaC VARCHAR(100) NULL,
        IdSubcontratistaImportador INT NULL,
        IdSubcontratistaExportador INT NULL,
        IdClavePedimento INT NULL,
        IdUnidadMedida INT NULL
    )

    CREATE TABLE #TemporalSumaMontos
    (
        Identificador INT NULL,
        PrecioUnitario MONEY NULL
    )

    INSERT INTO #TemporalComprobantesHijo
    (
        Identificador,
        Tipo,
        NumeroPedimento,
        ClavePedimento,
        FolioComprobante,
        FechaPago,
        Regimen,
        Importador,
        Exportador,
        AduanaES,
        ClaseBienServicio,
        UnidadMedida,
        AcuseElectronico,
        DescripcionMercancia,
        TipoMonedaCorto,
        PrecioUnitario,
        Cantidad,
        CuentaBancaria,
        NumFacturaC,
        IdSubcontratistaImportador,
        IdSubcontratistaExportador,
        IdClavePedimento,
        IdUnidadMedida
    )
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante,
           CASE
               WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = @Pedimento THEN
                   'Pedimento'
               ELSE
                   'Comprobante'
           END,
           ISNULL(FI_PedimentoComprobante.NumeroPedimento, 'NA'),
           'NA',
           ISNULL(FI_PedimentoComprobante.FolioComprobante, 'NA'),
           FI_PedimentoComprobante.FechaPago,
           ISNULL(FI_PedimentoComprobante.Regimen, 'NA'),
           '',
           '',
           'NA',
           'NA',
           '',
           ISNULL(FI_PedimentoComprobante.AcuseElectronico, 'NA'),
           '',
           ISNULL(PV_TipoMoneda.TipoMonedaCorto, ''),
           0,
           NULL,
           ISNULL(FI_PedimentoComprobante.CuentaBancaria, ''),
           ISNULL(FI_PedimentoComprobante.NumFacturaC, ''),
           FI_PedimentoComprobante.IdSubcontratistaImportador,
           FI_PedimentoComprobante.IdSubcontratistaExportador,
           FI_PedimentoComprobante.ClavePedimento,
           NULL
    FROM FI_PedimentoComprobante (NOLOCK)
        INNER JOIN FI_RelacionPedimento (NOLOCK)
            ON FI_PedimentoComprobante.CvTipoDocFacturacion IN ( @Pedimento, @Comprobante )
               AND FI_RelacionPedimento.IdFacturaPadre = @IdFacturapadre
               AND FI_PedimentoComprobante.IdPedimentoComprobante = FI_RelacionPedimento.IdPedimentoHijo
        INNER JOIN PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
    GROUP BY FI_PedimentoComprobante.IdPedimentoComprobante,
             CASE
                 WHEN FI_PedimentoComprobante.CvTipoDocFacturacion = @Pedimento THEN
                     'Pedimento'
                 ELSE
                     'Comprobante'
             END,
             ISNULL(FI_PedimentoComprobante.NumeroPedimento, 'NA'),
             ISNULL(FI_PedimentoComprobante.FolioComprobante, 'NA'),
             FI_PedimentoComprobante.FechaPago,
             ISNULL(FI_PedimentoComprobante.Regimen, 'NA'),
             ISNULL(FI_PedimentoComprobante.AcuseElectronico, 'NA'),
             ISNULL(PV_TipoMoneda.TipoMonedaCorto, ''),
             ISNULL(FI_PedimentoComprobante.CuentaBancaria, ''),
             ISNULL(FI_PedimentoComprobante.NumFacturaC, ''),
             FI_PedimentoComprobante.IdSubcontratistaImportador,
             FI_PedimentoComprobante.IdSubcontratistaExportador,
             FI_PedimentoComprobante.ClavePedimento

    INSERT INTO #TemporalSumaMontos
    (
        Identificador,
        PrecioUnitario
    )
    SELECT #TemporalComprobantesHijo.Identificador,
           SUM(   CASE
                      WHEN FI_PedimentoComprobanteDetalle.ImporteTotal IS NOT NULL THEN
                          ISNULL(FI_PedimentoComprobanteDetalle.ImporteTotal, 0)
                      ELSE
                          ISNULL(FI_PedimentoComprobanteDetalle.PrecioUnitario, 0)
                  END
              )
    FROM #TemporalComprobantesHijo
        INNER JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON #TemporalComprobantesHijo.Identificador = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
    GROUP BY #TemporalComprobantesHijo.Identificador

    UPDATE #TemporalComprobantesHijo
    SET #TemporalComprobantesHijo.PrecioUnitario = #TemporalSumaMontos.PrecioUnitario
    FROM #TemporalComprobantesHijo
        JOIN #TemporalSumaMontos
            ON #TemporalComprobantesHijo.Identificador = #TemporalSumaMontos.Identificador

    UPDATE #TemporalComprobantesHijo
    SET #TemporalComprobantesHijo.ClaseBienServicio = ISNULL(FI_PedimentoComprobanteDetalle.ClaseBienServicio, 'NA'),
        #TemporalComprobantesHijo.DescripcionMercancia = ISNULL(FI_PedimentoComprobanteDetalle.DescripcionMercancia, ''),
        #TemporalComprobantesHijo.Cantidad = FI_PedimentoComprobanteDetalle.Cantidad,
        #TemporalComprobantesHijo.IdUnidadMedida = FI_PedimentoComprobanteDetalle.IdUnidadMedida
    FROM #TemporalComprobantesHijo
        INNER JOIN FI_PedimentoComprobanteDetalle
            ON #TemporalComprobantesHijo.Identificador = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante

    UPDATE #TemporalComprobantesHijo
    SET #TemporalComprobantesHijo.UnidadMedida = SUBSTRING(ISNULL(PV_MM_MaterialUnidad.UMB, ''), 0, 30)
    FROM #TemporalComprobantesHijo
        INNER JOIN PV_MM_MaterialUnidad
            ON #TemporalComprobantesHijo.IdUnidadMedida = PV_MM_MaterialUnidad.IdUnidad

    UPDATE #TemporalComprobantesHijo
    SET #TemporalComprobantesHijo.ClavePedimento = ISNULL(FI_ClavesPedimento.Clave, 'NA')
    FROM #TemporalComprobantesHijo
        INNER JOIN FI_ClavesPedimento
            ON #TemporalComprobantesHijo.IdClavePedimento = FI_ClavesPedimento.IdPedimento

    UPDATE #TemporalComprobantesHijo
    SET #TemporalComprobantesHijo.Importador = SUBSTRING(ISNULL(PV_Subcontratista.RazonSocial, ''), 0, 30)
    FROM #TemporalComprobantesHijo
        INNER JOIN PV_Subcontratista
            ON #TemporalComprobantesHijo.IdSubcontratistaImportador = PV_Subcontratista.IdSubcontratista

    UPDATE #TemporalComprobantesHijo
    SET #TemporalComprobantesHijo.Exportador = SUBSTRING(ISNULL(PV_Subcontratista.RazonSocial, ''), 0, 30)
    FROM #TemporalComprobantesHijo
        INNER JOIN PV_Subcontratista
            ON #TemporalComprobantesHijo.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista

    SELECT Identificador,
           Tipo,
           NumeroPedimento,
           ClavePedimento,
           FolioComprobante,
           FechaPago,
           Regimen,
           Importador,
           Exportador,
           AduanaES,
           ClaseBienServicio,
           UnidadMedida,
           AcuseElectronico,
           DescripcionMercancia,
           TipoMonedaCorto,
           PrecioUnitario,
           Cantidad,
           CuentaBancaria,
           NumFacturaC
    FROM #TemporalComprobantesHijo
    ORDER BY Identificador DESC
END;