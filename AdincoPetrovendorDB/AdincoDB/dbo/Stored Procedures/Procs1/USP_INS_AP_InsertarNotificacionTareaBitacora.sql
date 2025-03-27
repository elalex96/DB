-- Eliminar el procedimiento si ya existe
DROP PROCEDURE IF EXISTS [dbo].[USP_INS_AP_InsertarNotificacionTareaBitacora]
GO

CREATE PROCEDURE [dbo].[USP_INS_AP_InsertarNotificacionTareaBitacora]
    @Id INT OUT,
    @HostNameTarea VARCHAR(100),
    @TareaId VARCHAR(15),
    @TieneError BIT,
    @MensajeError NVARCHAR(4000) OUT -- Nuevo parámetro para devolver el error
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @NewId INT;

    BEGIN TRY
        -- Iniciar transacción
        BEGIN TRANSACTION;

        INSERT INTO [dbo].[AP_NotificacionTareaBitacora]
        (
            InicioEjecucion,
            FinEjecucion,
            HostNameTarea,
            TareaId,
            TieneError
        )
        VALUES
        (GETDATE(), NULL, @HostNameTarea, @TareaId, @TieneError);

        -- Obtener el ID generado
        SET @NewId = SCOPE_IDENTITY();
        SET @Id = @NewId;
        SET @MensajeError = ''; -- No hay error

        -- Confirmar la transacción
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- En caso de error, hacer ROLLBACK
        ROLLBACK TRANSACTION;

        -- Devolver el mensaje de error con el nombre del procedimiento
        SET @Id = -1;
        SET @MensajeError = 'Error en ' + ERROR_PROCEDURE() + ': ' + ERROR_MESSAGE();
    END CATCH;
END