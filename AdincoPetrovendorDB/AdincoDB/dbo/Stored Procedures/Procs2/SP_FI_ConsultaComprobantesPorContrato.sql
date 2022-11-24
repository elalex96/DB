-- =============================================
-- Author:		Manuel CD
-- Create date: 05-12-17
-- Description:	
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	10 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado.
--							Ajustes de left joins (esto ajusto detalles de datos repetidos)
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaComprobantesPorContrato]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    DECLARE @NombreAreaContractual VARCHAR(100) = '';
    --
    CREATE TABLE #TablaComprobantesPorContrato
    (
        IdComprobante INT,
        FolioComprobante VARCHAR(100),
        FechaPago DATE,
        Exportador VARCHAR(150),
        NumeroSerieMercancia VARCHAR(100),
        ClaseBienServicio VARCHAR(1000),
        UnidadMedida VARCHAR(50),
        TipoMonedaCorto VARCHAR(10),
        PrecioUnitario MONEY,
        Cantidad NUMERIC(15, 0),
        ImporteTotal MONEY,
        FormaDePago VARCHAR(100),
        IdUnidadMedida INT,
        IdSubcontratistaExportador INT,
        IdMoneda INT,
        IdFormaPago INT,
        EsDePetrovendor BIT
    )
    CREATE TABLE #TablaComprobantesPorContratoDetalles
    (
        IdComprobante INT,
        PrecioUnitario MONEY,
        Cantidad NUMERIC(15, 0),
        ImporteTotal MONEY
    )

    SELECt TOP 1
        @NombreAreaContractual = ISNULL(CO_AreaContractual.NombreAreaContractual, '')
    FROM CO_Contrato
        JOIN CO_AreaContractual
            ON CO_Contrato.IdContrato = @IdContrato
               AND CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual

    INSERT INTO #TablaComprobantesPorContrato
    (
        IdComprobante,
        FolioComprobante,
        FechaPago,
        Exportador,
        NumeroSerieMercancia,
        ClaseBienServicio,
        UnidadMedida,
        TipoMonedaCorto,
        PrecioUnitario,
        Cantidad,
        ImporteTotal,
        FormaDePago,
        IdUnidadMedida,
        IdSubcontratistaExportador,
        IdMoneda,
        IdFormaPago,
        EsDePetrovendor
    )
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante AS IdComprobante,
           FI_PedimentoComprobante.FolioComprobante,
           FI_PedimentoComprobante.FechaPago,
           '',
           '',
           '',
           '',
           '',
           NULL,
           NULL,
           NULL,
           '',
           NULL,
           FI_PedimentoComprobante.IdSubcontratistaExportador,
           FI_PedimentoComprobante.IdMoneda,
           FI_PedimentoComprobante.IdFormaPago,
           EsDePetrovendor = CAST(CASE
                                      WHEN FI_PedimentoComprobante.IdPedimentoComprobantePetrovendor IS NULL THEN
                                          0
                                      ELSE
                                          1
                                  END AS BIT)
    FROM FI_PedimentoComprobante (NOLOCK)
    WHERE FI_PedimentoComprobante.CvTipoDocFacturacion = 3
          AND FI_PedimentoComprobante.IdContrato = @IdContrato
    GROUP BY FI_PedimentoComprobante.IdPedimentoComprobante,
             FI_PedimentoComprobante.FolioComprobante,
             FI_PedimentoComprobante.FechaPago,
             FI_PedimentoComprobante.IdSubcontratistaExportador,
             FI_PedimentoComprobante.IdMoneda,
             FI_PedimentoComprobante.IdFormaPago,
             FI_PedimentoComprobante.IdPedimentoComprobantePetrovendor
    ORDER BY IdComprobante DESC;

    INSERT INTO #TablaComprobantesPorContratoDetalles
    (
        IdComprobante,
        PrecioUnitario,
        Cantidad,
        ImporteTotal
    )
    SELECT #TablaComprobantesPorContrato.IdComprobante,
           ----------------------------------------------------------------------- 
           /*Se suma el importe total pero se deja con el nombre de PrecioUnitario para no afectar en codigo :
					Cuando no hay importe total si se toma el precio unitario*/
           --------------------------------------------- DR 06/08/2020
           SUM(   CASE
                      WHEN FI_PedimentoComprobanteDetalle.ImporteTotal IS NOT NULL THEN
                          FI_PedimentoComprobanteDetalle.ImporteTotal
                      ELSE
                          FI_PedimentoComprobanteDetalle.PrecioUnitario
                  END
              ),
           SUM(ISNULL(FI_PedimentoComprobanteDetalle.Cantidad, 0)),

           /*Esta columna posiblemente no sea necesaria, pero se deja para no afectar en codigo
			Hace practicamente lo mismo que el subtotal
			--------------------------------------------------------  DR 06/08/2020*/
           SUM(   CASE
                      WHEN FI_PedimentoComprobanteDetalle.ImporteTotal IS NOT NULL THEN
                          FI_PedimentoComprobanteDetalle.ImporteTotal
                      ELSE
                          FI_PedimentoComprobanteDetalle.PrecioUnitario
                  END
              )
    FROM #TablaComprobantesPorContrato
        JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON #TablaComprobantesPorContrato.IdComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
    GROUP BY #TablaComprobantesPorContrato.IdComprobante

    UPDATE #TablaComprobantesPorContrato
    SET #TablaComprobantesPorContrato.NumeroSerieMercancia = FI_PedimentoComprobanteDetalle.NumeroSerieMercancia,
        #TablaComprobantesPorContrato.ClaseBienServicio = FI_PedimentoComprobanteDetalle.ClaseBienServicio,
        #TablaComprobantesPorContrato.IdUnidadMedida = FI_PedimentoComprobanteDetalle.IdUnidadMedida
    FROM #TablaComprobantesPorContrato
        JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON #TablaComprobantesPorContrato.IdComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante

    UPDATE #TablaComprobantesPorContrato
    SET #TablaComprobantesPorContrato.PrecioUnitario = #TablaComprobantesPorContratoDetalles.PrecioUnitario,
        #TablaComprobantesPorContrato.Cantidad = #TablaComprobantesPorContratoDetalles.Cantidad,
        #TablaComprobantesPorContrato.ImporteTotal = #TablaComprobantesPorContratoDetalles.ImporteTotal
    FROM #TablaComprobantesPorContrato
        JOIN #TablaComprobantesPorContratoDetalles (NOLOCK)
            ON #TablaComprobantesPorContrato.IdComprobante = #TablaComprobantesPorContratoDetalles.IdComprobante

    UPDATE #TablaComprobantesPorContrato
    SET #TablaComprobantesPorContrato.Exportador = PV_Subcontratista.RazonSocial
    FROM #TablaComprobantesPorContrato
        JOIN PV_Subcontratista (NOLOCK)
            ON #TablaComprobantesPorContrato.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista

    UPDATE #TablaComprobantesPorContrato
    SET #TablaComprobantesPorContrato.FormaDePago = AP_Lista.Nombre
    FROM #TablaComprobantesPorContrato
        JOIN AP_Lista
            ON #TablaComprobantesPorContrato.IdFormaPago = AP_Lista.IdClave
               AND AP_Lista.IdGrupo = 10001

    UPDATE #TablaComprobantesPorContrato
    SET #TablaComprobantesPorContrato.UnidadMedida = (CASE
                                                          WHEN PV_MM_MaterialUnidad.UMB IS NULL
                                                               AND PV_MM_MaterialUnidad.Unidad IS NULL THEN
                                                              ''
                                                          WHEN PV_MM_MaterialUnidad.UMB IS NULL THEN
                                                              PV_MM_MaterialUnidad.Unidad
                                                          WHEN PV_MM_MaterialUnidad.Unidad IS NULL THEN
                                                              PV_MM_MaterialUnidad.UMB
                                                          ELSE
                                                              PV_MM_MaterialUnidad.UMB + ' - '
                                                              + PV_MM_MaterialUnidad.Unidad
                                                      END
                                                     )
    FROM #TablaComprobantesPorContrato
        JOIN PV_MM_MaterialUnidad (NOLOCK)
            ON #TablaComprobantesPorContrato.IdUnidadMedida = PV_MM_MaterialUnidad.IdUnidad

    UPDATE #TablaComprobantesPorContrato
    SET #TablaComprobantesPorContrato.TipoMonedaCorto = PV_TipoMoneda.TipoMonedaCorto
    FROM #TablaComprobantesPorContrato
        JOIN PV_TipoMoneda (NOLOCK)
            ON #TablaComprobantesPorContrato.IdMoneda = PV_TipoMoneda.IdMoneda

    SELECT IdComprobante,
           FolioComprobante,
           FechaPago,
           Exportador,
           NumeroSerieMercancia,
           ClaseBienServicio,
           UnidadMedida,
           TipoMonedaCorto,
           PrecioUnitario,
           Cantidad,
           ImporteTotal,
           FormaDePago,
           CAST(CASE
                    WHEN @NombreAreaContractual = 'Amatitlán' THEN
                        ISNULL(EsDePetrovendor, 0)
                    ELSE
                        1
                END AS BIT) AS EsDePetrovendor
    FROM #TablaComprobantesPorContrato
    ORDER BY IdComprobante DESC
END;