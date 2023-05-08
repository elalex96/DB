-- =============================================
-- Author:		Manuel CD
-- Create date: 01-09-17
-- Description:	
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK y Nombrado de Tablas en select
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_RelacionesTransferencias]
    @IdTran INT,
    @IdUsuario INT,
    @IdContrato INT,
    @CvTipoDoc INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    IF (@CvTipoDoc = 1)
    BEGIN
        SELECT dbo.FI_Factura.IdFactura,
               dbo.FI_TransferFactura.IdTransfer
        FROM dbo.FI_Factura (NOLOCK)
            JOIN dbo.FI_TransferFactura (NOLOCK)
                ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
            JOIN dbo.FI_Transfer (NOLOCK)
                ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
            JOIN dbo.CO_Contrato (NOLOCK)
                ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
        WHERE dbo.FI_Transfer.IdTransferencia = @IdTran
              AND dbo.FI_TransferFactura.CvTipoDocFacturacion = 1;
    END;
    --
    IF (@CvTipoDoc = 2)
    BEGIN
        SELECT dbo.FI_PedimentoComprobante.IdPedimentoComprobante,
               dbo.FI_TransferFactura.IdTransfer
        FROM dbo.FI_PedimentoComprobante (NOLOCK)
            JOIN dbo.FI_TransferFactura (NOLOCK)
                ON dbo.FI_PedimentoComprobante.IdPedimentoComprobante = dbo.FI_TransferFactura.IdPedimentoComprobante
            JOIN dbo.FI_Transfer (NOLOCK)
                ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
            JOIN dbo.CO_Contrato (NOLOCK)
                ON dbo.FI_PedimentoComprobante.IdContrato = dbo.CO_Contrato.IdContrato
        WHERE dbo.FI_Transfer.IdTransferencia = @IdTran
              AND dbo.FI_PedimentoComprobante.CvTipoDocFacturacion = 2;
    END;
    --
    IF (@CvTipoDoc = 3)
    BEGIN
        SELECT dbo.FI_PedimentoComprobante.IdPedimentoComprobante,
               dbo.FI_TransferFactura.IdTransfer
        FROM dbo.FI_PedimentoComprobante (NOLOCK)
            JOIN dbo.FI_TransferFactura (NOLOCK)
                ON dbo.FI_PedimentoComprobante.IdPedimentoComprobante = dbo.FI_TransferFactura.IdPedimentoComprobante
            JOIN dbo.FI_Transfer (NOLOCK)
                ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
            JOIN dbo.CO_Contrato (NOLOCK)
                ON dbo.FI_PedimentoComprobante.IdContrato = dbo.CO_Contrato.IdContrato
        WHERE dbo.FI_Transfer.IdTransferencia = @IdTran
              AND dbo.FI_PedimentoComprobante.CvTipoDocFacturacion = 3;
    END;
    --
    IF (@CvTipoDoc = 6)
    BEGIN
        SELECT dbo.FI_Factura.IdFactura AS IdCompReciboPago,
               dbo.FI_TransferFactura.IdTransfer
        FROM dbo.FI_Factura (NOLOCK)
            JOIN dbo.FI_TransferFactura (NOLOCK)
                ON dbo.FI_Factura.IdFactura = dbo.FI_TransferFactura.IdFactura
            JOIN dbo.FI_Transfer (NOLOCK)
                ON dbo.FI_TransferFactura.IdTransfer = dbo.FI_Transfer.IdTransferencia
            JOIN dbo.CO_Contrato (NOLOCK)
                ON dbo.FI_Factura.IdContrato = dbo.CO_Contrato.IdContrato
        WHERE dbo.FI_Transfer.IdTransferencia = @IdTran
              AND dbo.FI_TransferFactura.CvTipoDocFacturacion = 6;
    END;
END;