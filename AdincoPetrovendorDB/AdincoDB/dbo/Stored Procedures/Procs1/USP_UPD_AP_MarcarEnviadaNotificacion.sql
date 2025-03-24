-- Eliminar el procedimiento si ya existe
DROP PROCEDURE IF EXISTS [dbo].[USP_UPD_AP_MarcarEnviadaNotificacion]
GO

CREATE PROCEDURE [dbo].[USP_UPD_AP_MarcarEnviadaNotificacion]
    @IdN INT,
    @ModificadoPor INT = 0,
    @MensajeError NVARCHAR(4000) OUT -- Parámetro de salida para errores
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Iniciar transacción
        BEGIN TRANSACTION;

        -- Actualizar la notificación
        UPDATE [AP_Notificacion] WITH (ROWLOCK)
        SET Enviada = 1,
            ModificadoPor = CASE WHEN @ModificadoPor > 0 THEN @ModificadoPor ELSE NULL END,
            ModificadoEl = GETDATE(),
            FechaEnvio = GETDATE()
        WHERE Id = @IdN;

        -- Verificar si se actualizó alguna fila
        IF @@ROWCOUNT = 0
        BEGIN
            SET @MensajeError = 'No se encontró la notificación con el ID proporcionado.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

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
