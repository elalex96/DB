IF EXISTS (
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_SC_Materiales_Del'
)
    DROP PROCEDURE [dbo].[sp_SC_Materiales_Del]
GO

CREATE PROCEDURE [dbo].[sp_SC_Materiales_Del]
(
    @IdSCMaterial INT,
    @pError VARCHAR(250) OUT
)
AS
BEGIN
    SET @pError = '';

    IF NOT EXISTS (
        SELECT 1 
        FROM OT_SolicitudMaterial WITH (NOLOCK)
        WHERE IdSCMaterial = @IdSCMaterial
    )
    BEGIN
        BEGIN TRY
            DELETE 
            FROM SC_MaterialesBitacora
            WHERE IdSCMaterial = @IdSCMaterial;

            DELETE 
            FROM SC_Materiales
            WHERE IdSCMaterial = @IdSCMaterial;

            SELECT result = '';
        END TRY  
        BEGIN CATCH
            IF (ERROR_NUMBER() = 547)
            BEGIN
                SET @pError = 'No se puede eliminar el registro porque está siendo utilizado';
            END
            ELSE
            BEGIN
                SET @pError = CAST(ERROR_NUMBER() AS VARCHAR);
            END
        END CATCH
    END
    ELSE
    BEGIN
        SET @pError = 'No se puede eliminar el registro porque está siendo utilizado';
    END
END
