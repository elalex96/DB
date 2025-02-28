IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_ObtenNotification2FAServicio'
)
    DROP PROCEDURE USP_SEL_ObtenNotification2FAServicio;
GO

CREATE PROCEDURE USP_SEL_ObtenNotification2FAServicio
    @Modulo VARCHAR(100),
    @UsuarioId INT,
    @ContratoId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        SET NOCOUNT ON;

        DECLARE @ErrorMessage VARCHAR(8000)

        SELECT TOP 1
            Id,
            Url,
            Correo,
            Modulo
        FROM AP_Notification2FAServicio (NOLOCK)
        WHERE Modulo = @Modulo

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END