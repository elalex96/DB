IF OBJECT_ID('[dbo].[SP_FI_EliminarPedimentoComprobante]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[SP_FI_EliminarPedimentoComprobante];
GO

CREATE PROCEDURE [dbo].[SP_FI_EliminarPedimentoComprobante] 
    @IdPedimentoComprobante INT, 
    @IdUsuario              INT, 
    @IdContrato             INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;


        DELETE FROM FI_NotaCredito_REL_Comprobantes
        WHERE IdNotaCredito = @IdPedimentoComprobante;

        DELETE FROM dbo.FI_PedimentoComprobanteDetalle
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante;

        DELETE FROM dbo.FI_Documento
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante;

        DELETE FROM dbo.FI_PedimentoComprobante
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante;

        COMMIT TRANSACTION

        SELECT 0 AS Eliminado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @msg NVARCHAR(MAX);
        SET @msg = CONCAT(
            'Error en SP [SP_FI_EliminarPedimentoComprobante]: ',
            ERROR_MESSAGE()
        );

        -- Lanzar mensaje personalizado con nombre del SP
        THROW 51000, @msg, 1;
    END CATCH
END;
GO
