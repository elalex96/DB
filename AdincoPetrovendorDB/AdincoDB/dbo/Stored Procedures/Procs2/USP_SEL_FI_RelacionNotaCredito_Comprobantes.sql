IF OBJECT_ID('[dbo].[USP_SEL_FI_RelacionNotaCredito_Comprobantes]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[USP_SEL_FI_RelacionNotaCredito_Comprobantes];
GO

CREATE PROCEDURE [dbo].[USP_SEL_FI_RelacionNotaCredito_Comprobantes]
    @IdNotaCredito   INT,
    @IdContrato      INT,
    @IdUsuario       INT,
    @TipoDocumento   VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    IF @TipoDocumento = 'Comprobante'
    BEGIN
        SELECT 
            R.IdComprobanteRelacionado				AS IdComprobante,
            R.Monto									AS MontoPagado,
			ISNULL(S.RazonSocial, '')               AS RazonSocial,
            ISNULL(PC.NumFacturaC, '')              AS NumFacturaC,
            PC.FolioComprobante,
            ISNULL(PC.FechaPago, '')                AS FechaPago,
            PCD.PrecioUnitario,
            ISNULL(PCD.DescripcionMercancia, '')    AS DescripcionMercancia,
            ISNULL(U.Unidad, '')                    AS Unidad
        FROM FI_NotaCredito_REL_Comprobantes R WITH (NOLOCK)
        INNER JOIN FI_PedimentoComprobante PC WITH (NOLOCK) 
            ON PC.IdPedimentoComprobante = R.IdComprobanteRelacionado
        INNER JOIN FI_PedimentoComprobanteDetalle PCD WITH (NOLOCK)
            ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
        INNER JOIN Cat_TipoDocumento TD WITH (NOLOCK)
            ON PC.CvTipoDocFacturacion = TD.IdTipoDocumento
        LEFT JOIN PV_Subcontratista S WITH (NOLOCK)
            ON PC.IdSubcontratistaExportador = S.IdSubcontratista
        LEFT JOIN PV_MM_MaterialUnidad U WITH (NOLOCK)
            ON PCD.IdUnidadMedida = U.IdUnidad 
        WHERE 
            R.IdNotaCredito = @IdNotaCredito 
            AND PC.IdContrato = @IdContrato 
            AND TD.TipoDeDocumento = @TipoDocumento
        GROUP BY 
            R.IdComprobanteRelacionado,
            R.Monto,
            PC.FolioComprobante,
            PC.NumFacturaC,
            PC.FechaPago,
            S.RazonSocial,
            PCD.PrecioUnitario,
            PCD.DescripcionMercancia,
            U.Unidad
    END

    IF @TipoDocumento = 'Pedimento'
    BEGIN
        SELECT
            R.IdComprobanteRelacionado				AS IdComprobante,
            R.Monto									AS MontoPagado,
            LEFT(S.RazonSocial, 30)                 AS RazonSocial,
            PC.IdFiscalP							AS IdFiscal,
            PC.RazonSocialP,
            PC.NumeroPedimento,
            ISNULL(CP.Clave, '')                    AS ClavePedimento,
            PC.FolioComprobante,
            PC.FechaPago,
            PCD.PrecioUnitario,
            PCD.ImporteTotal,
            PCD.DescripcionMercancia
        FROM FI_NotaCredito_REL_Comprobantes R WITH (NOLOCK)
        INNER JOIN FI_PedimentoComprobante PC WITH (NOLOCK)
            ON PC.IdPedimentoComprobante = R.IdComprobanteRelacionado
        INNER JOIN FI_PedimentoComprobanteDetalle PCD WITH (NOLOCK)
            ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
        INNER JOIN Cat_TipoDocumento TD WITH (NOLOCK)
            ON PC.CvTipoDocFacturacion = TD.IdTipoDocumento
        LEFT JOIN PV_Subcontratista S WITH (NOLOCK)
            ON PC.IdSubcontratistaExportador = S.IdSubcontratista
        LEFT JOIN PV_MM_MaterialUnidad U WITH (NOLOCK) 
            ON PCD.IdUnidadMedida = U.IdUnidad
        LEFT JOIN FI_ClavesPedimento CP WITH (NOLOCK)
            ON PC.ClavePedimento = CP.IdPedimento
        WHERE 
            R.IdNotaCredito = @IdNotaCredito 
            AND PC.IdContrato = @IdContrato 
            AND TD.TipoDeDocumento = @TipoDocumento
        GROUP BY 
            R.IdComprobanteRelacionado,
            R.Monto,
            LEFT(S.RazonSocial, 30),
            PC.IdFiscalP,
            PC.RazonSocialP,
            PC.NumeroPedimento,
            CP.Clave,
            PC.FolioComprobante,
            PC.FechaPago,
            PCD.PrecioUnitario,
            PCD.ImporteTotal,
            PCD.DescripcionMercancia
    END
END;
GO
