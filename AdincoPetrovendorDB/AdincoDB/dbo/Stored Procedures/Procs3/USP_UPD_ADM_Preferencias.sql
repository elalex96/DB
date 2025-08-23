DROP PROCEDURE IF EXISTS dbo.USP_UPD_ADM_Preferencias;
GO
CREATE PROCEDURE dbo.USP_UPD_ADM_Preferencias
    @Id                INT,
    @Nombre            VARCHAR(1000),
    @EsDeContratista   BIT,
    @Descripcion       VARCHAR(1000) = NULL,
    @RequiereValor     BIT = NULL,
    @ModificadoPor     INT = NULL,
    @ContratoId        INT 
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF EXISTS (
            SELECT 1
            FROM dbo.APP_PREFERENCIAS p WITH (NOLOCK)
            WHERE p.Nombre = @Nombre
              AND p.Id <> @Id
        )
        BEGIN
            -- Lanza error controlado en el servidor
            THROW 50011, 'Ya existe una preferencia con ese nombre.', 1;
        END

        -- Datos antes de cambios
        DECLARE @before NVARCHAR(MAX) =
        (
            SELECT p.Id, p.Nombre, p.EsDeContratista, p.Descripcion, p.RequiereValor,
                   p.CreadoPor, p.CreadoEl, p.ModificadoPor, p.ModificadoEl
            FROM dbo.APP_PREFERENCIAS p WITH (NOLOCK)
            WHERE p.Id = @Id
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        UPDATE dbo.APP_PREFERENCIAS
           SET Nombre          = @Nombre,
               EsDeContratista = @EsDeContratista,
               Descripcion     = @Descripcion,
               RequiereValor   = @RequiereValor,
               ModificadoPor   = @ModificadoPor,
               ModificadoEl    = GETDATE()
         WHERE Id = @Id;

        -- Datos despues de cambios
        DECLARE @after NVARCHAR(MAX) =
        (
            SELECT p.Id, p.Nombre, p.EsDeContratista, p.Descripcion, p.RequiereValor,
                   p.CreadoPor, p.CreadoEl, p.ModificadoPor, p.ModificadoEl
            FROM dbo.APP_PREFERENCIAS p WITH (NOLOCK)
            WHERE p.Id = @Id
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        DECLARE @detalle NVARCHAR(MAX) = N'{"before":' + ISNULL(@before, 'null') + N',"after":' + ISNULL(@after,'null') + N'}';

        INSERT INTO dbo.AP_Bitacora (Fecha, Tipo, Mensaje, Detalle, UsuarioId, ContratoId)
        VALUES (GETDATE(), 'UPDATE', CONCAT('APP_PREFERENCIAS actualizado Id=', @Id), @detalle, @ModificadoPor, @ContratoId);

        COMMIT TRAN;

        -- devolver fila resultante
        SELECT p.Id, p.Nombre, p.EsDeContratista, p.Descripcion, p.RequiereValor,
               p.CreadoPor, p.CreadoEl, p.ModificadoPor, p.ModificadoEl
        FROM dbo.APP_PREFERENCIAS p WITH (NOLOCK)
        WHERE p.Id = @Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO
