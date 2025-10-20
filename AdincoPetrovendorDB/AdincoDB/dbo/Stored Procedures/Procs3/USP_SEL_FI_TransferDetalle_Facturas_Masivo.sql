use Adinco
-- =============================================
-- SP MASIVO SIMPLIFICADO para Facturas
-- =============================================
IF OBJECT_ID('[dbo].[USP_SEL_FI_TransferDetalle_Facturas_Masivo]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[USP_SEL_FI_TransferDetalle_Facturas_Masivo]
GO

CREATE PROCEDURE [dbo].[USP_SEL_FI_TransferDetalle_Facturas_Masivo]
    @IdsTransferencias VARCHAR(MAX), -- "1,2,3,4,5..."
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Convertir string a tabla de IDs
    DECLARE @TempIds TABLE (IdTransferencia INT);
    
    INSERT INTO @TempIds
    SELECT CAST(splitdata AS INT)
    FROM dbo.fnSplitString(@IdsTransferencias, ',')
    WHERE splitdata <> '';

    -- Simplemente ejecutar la misma lógica que el SP original pero para múltiples transferencias
    -- Usamos UNION ALL para combinar los resultados de todas las transferencias
    
    SELECT 
        tf.IdTransfer AS IdTransferencia,
        f.IdFactura,
        f.TipoComprobante,
        f.Serie,
        f.Folio,
        f.Fecha,
        f.FormaPago,
        f.SubTotal,
        f.Moneda,
        f.MontoConIva,
        f.MetodoPago,
        f.UUID,
        f.FechaRecepcion,
        ps.RazonSocial,
        f.Emisor,
        SUM(CASE
                WHEN cp.IdFactura IS NULL THEN CAST(tf.MontoPagado AS MONEY)
                ELSE cp.Monto
            END) AS MontoPagado
    FROM @TempIds ids
        INNER JOIN FI_TransferFactura tf (NOLOCK)
            ON ids.IdTransferencia = tf.IdTransfer
        INNER JOIN FI_Factura f (NOLOCK)
            ON tf.IdFactura = f.IdFactura
        INNER JOIN PV_Subcontratista ps (NOLOCK)
            ON f.IdSubcontratista = ps.IdSubcontratista
        LEFT JOIN FI_ComplementoDePago cp (NOLOCK)
            ON f.IdFactura = cp.IdFactura
    WHERE f.IdContrato = @IdContrato
    GROUP BY 
        tf.IdTransfer,
        f.IdFactura,
        f.TipoComprobante,
        f.Serie,
        f.Folio,
        f.Fecha,
        f.FormaPago,
        f.SubTotal,
        f.Moneda,
        f.MontoConIva,
        f.MetodoPago,
        f.UUID,
        f.FechaRecepcion,
        ps.RazonSocial,
        f.Emisor

    UNION ALL

    -- Facturas de Complementos de Pago relacionados
    SELECT 
        tf.IdTransfer AS IdTransferencia,
        f.IdFactura,
        f.TipoComprobante,
        f.Serie,
        f.Folio,
        f.Fecha,
        f.FormaPago,
        f.SubTotal,
        f.Moneda,
        f.MontoConIva,
        f.MetodoPago,
        cpd.IdDocumento AS UUID,
        f.FechaRecepcion,
        ps.RazonSocial,
        f.Emisor,
        cpd.ImpPagado AS MontoPagado
    FROM @TempIds ids
        INNER JOIN FI_TransferFactura tf (NOLOCK)
            ON ids.IdTransferencia = tf.IdTransfer
        INNER JOIN FI_ComplementoDePago cp (NOLOCK)
            ON tf.IdFactura = cp.IdFactura
        INNER JOIN FI_CPDocRelacionado cpd (NOLOCK)
            ON cp.IdComplementoDePago = cpd.IdComplementoDePago
        INNER JOIN FI_Factura f (NOLOCK)
            ON cpd.IdDocumento = f.UUID
        INNER JOIN PV_Subcontratista ps (NOLOCK)
            ON f.IdSubcontratista = ps.IdSubcontratista
    WHERE f.IdContrato = @IdContrato
        -- Excluir las que ya salieron en la primera consulta
        AND NOT EXISTS (
            SELECT 1 
            FROM FI_TransferFactura tf2
            WHERE tf2.IdTransfer = tf.IdTransfer 
            AND tf2.IdFactura = f.IdFactura
        )
    GROUP BY 
        tf.IdTransfer,
        f.IdFactura,
        f.TipoComprobante,
        f.Serie,
        f.Folio,
        f.Fecha,
        f.FormaPago,
        f.SubTotal,
        f.Moneda,
        f.MontoConIva,
        f.MetodoPago,
        cpd.IdDocumento,
        f.FechaRecepcion,
        ps.RazonSocial,
        f.Emisor,
        cpd.ImpPagado

    UNION ALL

    -- Facturas NO CARGADAS en ADINCO (las que están en CPDocRelacionado pero no en FI_Factura)
    SELECT 
        tf.IdTransfer AS IdTransferencia,
        0 AS IdFactura,
        '¡NO CARGADO EN ADINCO!' AS TipoComprobante,
        NULL AS Serie,
        NULL AS Folio,
        NULL AS Fecha,
        NULL AS FormaPago,
        NULL AS SubTotal,
        NULL AS Moneda,
        NULL AS MontoConIva,
        NULL AS MetodoPago,
        cpd.IdDocumento AS UUID,
        NULL AS FechaRecepcion,
        '' AS RazonSocial,
        NULL AS Emisor,
        cpd.ImpPagado AS MontoPagado
    FROM @TempIds ids
        INNER JOIN FI_TransferFactura tf (NOLOCK)
            ON ids.IdTransferencia = tf.IdTransfer
        INNER JOIN FI_ComplementoDePago cp (NOLOCK)
            ON tf.IdFactura = cp.IdFactura
        INNER JOIN FI_CPDocRelacionado cpd (NOLOCK)
            ON cp.IdComplementoDePago = cpd.IdComplementoDePago
        LEFT JOIN FI_Factura f (NOLOCK)
            ON cpd.IdDocumento = f.UUID
    WHERE f.IdFactura IS NULL
    GROUP BY 
        tf.IdTransfer,
        cpd.IdDocumento,
        cpd.ImpPagado

    ORDER BY IdTransferencia, IdFactura;
END
GO