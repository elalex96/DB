IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_CO_DesactivarSAPVendor'
)
    DROP PROCEDURE USP_UPD_CO_DesactivarSAPVendor;
GO

CREATE PROCEDURE USP_UPD_CO_DesactivarSAPVendor
    @KeyLastImport VARCHAR(50),
    @UsuarioId INT,
    @ContratoId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        SET NOCOUNT ON;

        DECLARE @ErrorMessage VARCHAR(4000),
                @FechaHoy DATETIME = GETDATE();

        IF ISNULL(@KeyLastImport, '') <> ''
        BEGIN
            UPDATE CO_SAPVendor
            SET Activo = 0,
                ModificadoEl = @FechaHoy
            WHERE IdContrato = @ContratoId
                  AND LTRIM(RTRIM(ISNULL(KeyLastImport, ''))) <> LTRIM(RTRIM(ISNULL(@KeyLastImport, '')))
        END;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END