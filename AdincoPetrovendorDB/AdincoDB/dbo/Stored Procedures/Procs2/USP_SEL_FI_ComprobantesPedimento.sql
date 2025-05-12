IF OBJECT_ID('[dbo].[USP_SEL_FI_ComprobantesPedimento]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].USP_SEL_FI_ComprobantesPedimento;
GO

CREATE PROCEDURE [dbo].USP_SEL_FI_ComprobantesPedimento
    @IdContrato INT,
    @IdUsuario INT,
    @IdMoneda INT,
    @IdComprobanteEdit INT,
    @IdProveedor INT,
	@TipoDocumento VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GrupoId INT = 10001;


    SELECT PC.IdPedimentoComprobante AS IdComprobante,
           PC.FolioComprobante,
           PC.FechaPago,
           LEFT(SE.RazonSocial, 30) AS Exportador,
           PCD.NumeroSerieMercancia,
           PCD.ClaseBienServicio,
           LEFT(MU.Unidad, 30) AS UnidadMedida,
           TM.TipoMonedaCorto AS TipoMonedaCorto,
           CASE
               WHEN PCD.PrecioUnitario IS NOT NULL
                    AND PCD.PrecioUnitario > 0 THEN
                   PCD.PrecioUnitario
               ELSE
                   PCD.ImporteTotal
           END AS PrecioUnitario,
           ISNULL(FP.Nombre, '') AS FormaDePago,
           PC.NumFacturaC,
           CASE
               WHEN ISNULL(PC.EsnotaCredito, 0) = 0 THEN
                   'No'
               ELSE
                   'Sí'
           END AS EsNotaCredito,
           '' AS MontoPagado,
           CASE
               WHEN NCR.IdNotaCredito IS NOT NULL THEN
                   'Sí'
               ELSE
                   'No'
           END AS RelacionadoConOtraNota
    FROM FI_PedimentoComprobante PC WITH (NOLOCK)
        INNER JOIN FI_PedimentoComprobanteDetalle PCD WITH (NOLOCK)
            ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
        INNER JOIN Cat_TipoDocumento TD WITH (NOLOCK)
            ON PC.CvTipoDocFacturacion = TD.IdTipoDocumento
        INNER JOIN PV_Subcontratista SE WITH (NOLOCK)
            ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
        LEFT JOIN PV_MM_MaterialUnidad MU WITH (NOLOCK)
            ON PCD.IdUnidadMedida = MU.IdUnidad
        LEFT JOIN PV_TipoMoneda TM WITH (NOLOCK)
            ON PC.IdMoneda = TM.IdMoneda
        LEFT JOIN AP_Lista FP WITH (NOLOCK)
            ON PC.IdFormaPago = FP.IdClave
               AND FP.IdGrupo = @GrupoId
        LEFT JOIN FI_NotaCredito_REL_Comprobantes NCR WITH (NOLOCK)
            ON NCR.IdComprobanteRelacionado = PC.IdPedimentoComprobante
               AND NCR.IdNotaCredito <> @IdComprobanteEdit
		LEFT JOIN FI_NotaCredito_REL_Comprobantes NCR2 WITH (NOLOCK)
			ON NCR2.IdNotaCredito = @IdComprobanteEdit
			AND NCR2.IdComprobanteRelacionado = PC.IdPedimentoComprobante
    WHERE TD.TipoDeDocumento = @TipoDocumento
          AND PC.IdContrato = @IdContrato
          AND PC.IdPedimentoComprobante <> @IdComprobanteEdit
          AND PC.IdSubcontratistaExportador = @IdProveedor
		  AND (
				ISNULL(PC.EsnotaCredito, 0) = 0
				OR (
					ISNULL(PC.EsnotaCredito, 0) = 1
					AND NCR2.IdNotaCredito IS NOT NULL
				)
			)
    GROUP BY PC.IdPedimentoComprobante,
           PC.FolioComprobante,
           PC.FechaPago,
           LEFT(SE.RazonSocial, 30),
           PCD.NumeroSerieMercancia,
           PCD.ClaseBienServicio,
           LEFT(MU.Unidad, 30),
           TM.TipoMonedaCorto,
           CASE
               WHEN PCD.PrecioUnitario IS NOT NULL
                    AND PCD.PrecioUnitario > 0 THEN
                   PCD.PrecioUnitario
               ELSE
                   PCD.ImporteTotal
           END,
           ISNULL(FP.Nombre, ''),
           PC.NumFacturaC,
           CASE
               WHEN ISNULL(PC.EsnotaCredito, 0) = 0 THEN
                   'No'
               ELSE
                   'Sí'
           END,
           CASE
               WHEN NCR.IdNotaCredito IS NOT NULL THEN
                   'Sí'
               ELSE
                   'No'
           END
    ORDER BY PC.IdPedimentoComprobante DESC
END;
GO
