-- =============================================
-- Author:		Manuel CD
-- Create date: 01-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_RelacionesTransferencias] 
-- Add the parameters for the stored procedure here
@IdTran     INT, 
@IdUsuario  INT, 
@IdContrato INT, 
@CvTipoDoc  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         IF(@CvTipoDoc = 1)
             BEGIN
                 SELECT F.IdFactura, 
                        TF.IdTransfer
                 FROM dbo.FI_Factura F
                      JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                      JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
                 WHERE T.IdTransferencia = @IdTran
                       AND TF.CvTipoDocFacturacion = 1;
             END;
         --
         IF(@CvTipoDoc = 2)
             BEGIN
                 SELECT PC.IdPedimentoComprobante, 
                        TF.IdTransfer
                 FROM dbo.FI_PedimentoComprobante PC
                      JOIN dbo.FI_TransferFactura TF ON PC.IdPedimentoComprobante = TF.IdPedimentoComprobante
                      JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                      JOIN dbo.CO_Contrato C ON PC.IdContrato = C.IdContrato
                 WHERE T.IdTransferencia = @IdTran
                       AND PC.CvTipoDocFacturacion = 2;
             END;
         --
         IF(@CvTipoDoc = 3)
             BEGIN
                 SELECT PC.IdPedimentoComprobante, 
                        TF.IdTransfer
                 FROM dbo.FI_PedimentoComprobante PC
                      JOIN dbo.FI_TransferFactura TF ON PC.IdPedimentoComprobante = TF.IdPedimentoComprobante
                      JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                      JOIN dbo.CO_Contrato C ON PC.IdContrato = C.IdContrato
                 WHERE T.IdTransferencia = @IdTran
                       AND PC.CvTipoDocFacturacion = 3;
             END;
         --
         IF(@CvTipoDoc = 6)
             BEGIN
                 SELECT F.IdFactura AS IdCompReciboPago, 
                        TF.IdTransfer
                 FROM dbo.FI_Factura F
                      JOIN dbo.FI_TransferFactura TF ON F.IdFactura = TF.IdFactura
                      JOIN dbo.FI_Transfer T ON TF.IdTransfer = T.IdTransferencia
                      JOIN dbo.CO_Contrato C ON F.IdContrato = C.IdContrato
                 WHERE T.IdTransferencia = @IdTran
                       AND TF.CvTipoDocFacturacion = 6;
             END;
     END;