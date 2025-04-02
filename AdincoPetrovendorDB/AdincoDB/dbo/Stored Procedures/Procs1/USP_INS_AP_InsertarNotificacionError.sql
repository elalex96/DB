-- Eliminar el procedimiento si ya existe
DROP PROCEDURE IF EXISTS [dbo].[USP_INS_AP_InsertarNotificacionError]
GO

CREATE PROCEDURE [dbo].[USP_INS_AP_InsertarNotificacionError]
    @NotificacionId INT,
    @Error VARCHAR(5000),
    @MensajeError NVARCHAR(4000) OUT -- Parámetro de salida para errores
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Iniciar transacción
        BEGIN TRANSACTION;

        -- Insertar el error en la bitácora
        INSERT INTO [dbo].[AP_NotificacionError] (
            NotificacionId,
            Error,
            FechaRegistro
        )
        VALUES (
            @NotificacionId, -- Corrección del nombre del parámetro
            @Error,
            GETDATE()
        );

        -- Confirmar transacción
        COMMIT TRANSACTION;
        SET @MensajeError = ''; -- Indica éxito
    END TRY
    BEGIN CATCH
        -- Deshacer transacción si hay error
        ROLLBACK TRANSACTION;

        -- Capturar y devolver el mensaje de error
        SET @MensajeError = 'Error en ' + ERROR_PROCEDURE() + ': ' + ERROR_MESSAGE();
    END CATCH;
END
