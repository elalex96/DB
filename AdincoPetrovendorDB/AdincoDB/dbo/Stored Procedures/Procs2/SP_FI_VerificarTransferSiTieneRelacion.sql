-- =============================================
-- Author:		Manuel CD
-- Create date: 18-06-2018
-- Description:	
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			16 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK)
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_VerificarTransferSiTieneRelacion]
    @IdTransfer INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    IF EXISTS
    (
        SELECT *
        FROM FI_TransferFactura (NOLOCK)
            JOIN CO_Registro (NOLOCK)
                ON FI_TransferFactura.IdFactura = CO_Registro.IdFactura
        WHERE FI_TransferFactura.IdTransfer = @IdTransfer
    )
       OR EXISTS
    (
        SELECT *
        FROM FI_TransferFactura (NOLOCK)
            JOIN CO_Registro (NOLOCK)
                ON FI_TransferFactura.IdPedimentoComprobante = CO_Registro.IdPedimentoComprobante
        WHERE FI_TransferFactura.IdTransfer = @IdTransfer
    )
        SELECT 1 AS Relacion;
    ELSE
        SELECT 0 AS Relacion;
END;