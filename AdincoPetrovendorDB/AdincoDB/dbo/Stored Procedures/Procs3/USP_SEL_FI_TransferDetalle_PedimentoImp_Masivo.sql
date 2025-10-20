use Adinco
-- =============================================
-- SP MASIVO para Pedimentos de Importación
-- =============================================
IF OBJECT_ID('[dbo].[USP_SEL_FI_TransferDetalle_PedimentoImp_Masivo]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[USP_SEL_FI_TransferDetalle_PedimentoImp_Masivo]
GO

CREATE PROCEDURE [dbo].[USP_SEL_FI_TransferDetalle_PedimentoImp_Masivo]
    @IdsTransferencias VARCHAR(MAX),
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

    -- Retornar pedimentos de importación de todas las transferencias
    SELECT 
        FI_Transfer.IdTransferencia,
        FI_PedimentoComprobante.IdPedimentoComprobante AS IdPedimento,
        FI_PedimentoComprobante.NumeroPedimento,
        FI_ClavesPedimento.Clave AS ClavePedimento,
        FI_PedimentoComprobante.FolioComprobante,
        FI_PedimentoComprobante.FechaPago,
        FI_PedimentoComprobante.Regimen,
        PV_Subcontratista.RazonSocial AS Importador,
        FI_PedimentoComprobante.AduanaES,
        PV_SubcontratistaExportador.RazonSocial AS Exportador,
        FI_PedimentoComprobante.AcuseElectronico,
        FI_PedimentoComprobanteDetalle.DescripcionMercancia,
        PV_TipoMoneda.TipoMonedaCorto,
        FI_PedimentoComprobanteDetalle.PrecioUnitario,
        FI_PedimentoComprobanteDetalle.Cantidad,
        FI_TransferFactura.MontoPagado
    FROM @TempIds ids
        INNER JOIN FI_Transfer (NOLOCK)
            ON ids.IdTransferencia = FI_Transfer.IdTransferencia
            AND FI_Transfer.IdContrato = @IdContrato
        INNER JOIN FI_TransferFactura (NOLOCK)
            ON FI_Transfer.IdTransferencia = FI_TransferFactura.IdTransfer
        INNER JOIN FI_PedimentoComprobante (NOLOCK)
            ON FI_PedimentoComprobante.CvTipoDocFacturacion = 2
            AND FI_TransferFactura.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
        INNER JOIN PV_Subcontratista (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaImportador = PV_Subcontratista.IdSubcontratista
        INNER JOIN PV_Subcontratista PV_SubcontratistaExportador (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_SubcontratistaExportador.IdSubcontratista
        LEFT JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        LEFT JOIN FI_ClavesPedimento (NOLOCK)
            ON FI_PedimentoComprobante.ClavePedimento = FI_ClavesPedimento.IdPedimento
        LEFT JOIN PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
    GROUP BY 
        FI_Transfer.IdTransferencia,
        FI_PedimentoComprobante.IdPedimentoComprobante,
        FI_PedimentoComprobante.NumeroPedimento,
        FI_ClavesPedimento.Clave,
        FI_PedimentoComprobante.FolioComprobante,
        FI_PedimentoComprobante.FechaPago,
        FI_PedimentoComprobante.Regimen,
        PV_Subcontratista.RazonSocial,
        FI_PedimentoComprobante.AduanaES,
        PV_SubcontratistaExportador.RazonSocial,
        FI_PedimentoComprobante.AcuseElectronico,
        FI_PedimentoComprobanteDetalle.DescripcionMercancia,
        PV_TipoMoneda.TipoMonedaCorto,
        FI_PedimentoComprobanteDetalle.PrecioUnitario,
        FI_PedimentoComprobanteDetalle.Cantidad,
        FI_TransferFactura.MontoPagado
    ORDER BY FI_Transfer.IdTransferencia, FI_PedimentoComprobante.IdPedimentoComprobante;
END
GO