-- Eliminar el procedimiento si ya existe
DROP PROCEDURE IF EXISTS [dbo].[UPS_UPD_AP_ActualizarFinNotificacionTareaBitacora]
GO

CREATE PROCEDURE [dbo].[UPS_UPD_AP_ActualizarFinNotificacionTareaBitacora]
    @Id INT,
    @TieneError BIT,
    @MensajeError NVARCHAR(4000) OUT  -- Nuevo parámetro para devolver el error
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Iniciar la transacción
        BEGIN TRANSACTION;

        -- Actualizar la bitácora
        UPDATE [dbo].[AP_NotificacionTareaBitacora]
        SET [FinEjecucion] = GETDATE(),
            TieneError = @TieneError
        WHERE Id = @Id;

        -- Verificar si realmente se actualizó algún registro
        IF @@ROWCOUNT = 0
        BEGIN
            SET @MensajeError = 'Error en ' + ERROR_PROCEDURE() + ': No se encontró el ID especificado.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Confirmar la transacción
        COMMIT TRANSACTION;
        SET @MensajeError = '';  -- No hay error
    END TRY
    BEGIN CATCH
        -- Deshacer transacción en caso de error
        ROLLBACK TRANSACTION;

        -- Capturar y devolver el mensaje de error
        SET @MensajeError = 'Error en ' + ERROR_PROCEDURE() + ': ' + ERROR_MESSAGE();
    END CATCH;
END
