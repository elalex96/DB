IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_EliminarTransferNoLigada'
)
    DROP PROCEDURE SP_FI_EliminarTransferNoLigada;
GO
-- =============================================
-- Author:		Manuel CD
-- Create date: 18-06-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarTransferNoLigada]
    @IdTransfer INT,
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN

    SET NOCOUNT ON;


    DELETE dbo.FI_TransferFactura
    WHERE IdTransfer = @IdTransfer;
    DELETE dbo.FI_Transfer
    WHERE IdTransferencia = @IdTransfer;

    INSERT INTO AP_Bitacora
    (
        [Fecha],
        [Tipo],
        [Mensaje],
        [Detalle],
        [UsuarioId],
        [ContratoId]
    )
    VALUES
    (GETDATE(),
     'Eliminación',
     'Eliminación de registro en las tablas FI_TransferFactura y FI_Transfer, en la página MisTransferencias.aspx',
     CONCAT('Se eliminó transferencia con identificador: ', CONVERT(VARCHAR(10), @IdTransfer)),
     @IdUsuario,
     @IdContrato
    );
    --
    IF @@ERROR <> 0
        SELECT 'false' AS msj;
    ELSE
        SELECT 'true' AS msj;
END;
