IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_CO_DesactivarSAPMaterial'
)
    DROP PROCEDURE USP_UPD_CO_DesactivarSAPMaterial;
GO

CREATE PROCEDURE USP_UPD_CO_DesactivarSAPMaterial
    @KeyLastImport VARCHAR(50),
    @UsuarioId INT,
    @ContratoId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        SET NOCOUNT ON;

        DECLARE @ErrorMessage VARCHAR(4000);

        IF ISNULL(@KeyLastImport, '') <> ''
        BEGIN
            UPDATE CO_SAPMaterial
            SET Activo = 0
            WHERE IdContrato = @ContratoId
                  AND LTRIM(RTRIM(ISNULL(KeyLastImport, ''))) <> LTRIM(RTRIM(ISNULL(@KeyLastImport, '')));
        END;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END