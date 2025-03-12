IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_ObtenActivos_MM_BS_Actividad'
)
    DROP PROCEDURE USP_SEL_ObtenActivos_MM_BS_Actividad;
GO

CREATE PROCEDURE USP_SEL_ObtenActivos_MM_BS_Actividad
    @UsuarioId INT,
    @ContratoId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN;

        SET NOCOUNT ON;

        DECLARE @ErrorMessage VARCHAR(8000)

        SELECT UPPER(LTRIM(RTRIM(Codigo)))
        FROM MM_BS_Actividad (NOLOCK)
        WHERE ISNULL(Activo, 0) = 1
        ORDER BY Codigo ASC

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = ERROR_MESSAGE()

        ROLLBACK TRAN

        RAISERROR(@ErrorMessage, 17, 1)
    END CATCH;
END