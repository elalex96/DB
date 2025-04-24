IF OBJECT_ID('[dbo].[SP_FI_ConsultaPedimentoComprobante]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[SP_FI_ConsultaPedimentoComprobante];
GO

CREATE PROCEDURE [dbo].[SP_FI_ConsultaPedimentoComprobante] 
    @IdPedimentoComprobante INT, 
    @Accion                 INT, -- 1 = Comprobante, 0 = Pedimento
    @IdContrato             INT, 
    @IdUsuario              INT
AS
BEGIN
    SET NOCOUNT ON;

    IF (@Accion = 1)
    BEGIN
        -- Comprobante
        SELECT 
            PC.IdSubcontratistaExportador AS IdSubcontratista,
            PC.FolioComprobante,
            PC.NumFacturaC,
            PC.FechaPago,
            PCD.ClaseBienServicio,
            PC.IdMoneda,
            PCD.PrecioUnitario,
            PCD.IdUnidadMedida,
            ISNULL(PC.EsnotaCredito, 0) AS EsNotaCredito
        FROM dbo.FI_PedimentoComprobante PC WITH (NOLOCK)
        LEFT JOIN dbo.FI_PedimentoComprobanteDetalle PCD WITH (NOLOCK)
            ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
        WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;
    END
    ELSE IF (@Accion = 0)
    BEGIN
        -- Pedimento
        SELECT 
            PC.IdSubcontratistaExportador,
            PC.IdFiscalP,
            PC.RazonSocialP,
            PC.NumeroPedimento,
            PC.ClavePedimento,
            PC.FechaPago,
            PC.Regimen,
            PC.AduanaES,
            PCD.DescripcionMercancia,
            PC.IdMoneda,
            PCD.PrecioUnitario,
            PCD.ImporteTotal,
            PC.AcuseElectronico,
            PC.FolioComprobante,
            ISNULL(PC.CuentaBancaria, '') AS CuentaBancaria,
            ISNULL(PC.EsnotaCredito, 0) AS EsNotaCredito
        FROM dbo.FI_PedimentoComprobante PC WITH (NOLOCK)
        INNER JOIN dbo.FI_PedimentoComprobanteDetalle PCD WITH (NOLOCK)
            ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
        WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante;
    END
END;
GO
