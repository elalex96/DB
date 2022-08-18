-- =============================================
-- Author:		Manuel CD
-- Create date: 18-06-2018
-- Description:	
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			16 de Agosto del 2022
-- Descripción:		Eliminación de código comentado
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarTransferNoLigada]
    @IdTransfer INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    -- 
    DELETE FI_TransferFactura
    WHERE FI_TransferFactura.IdTransfer = @IdTransfer;
    --
    DELETE FI_Transfer
    WHERE FI_Transfer.IdTransferencia = @IdTransfer;
    --
    IF @@ERROR <> 0
        SELECT 'false' AS msj;
    ELSE
        SELECT 'true' AS msj;
END;
