DROP PROCEDURE IF EXISTS dbo.USP_INS_ADM_Preferencias;
GO
CREATE PROCEDURE dbo.USP_INS_ADM_Preferencias
    @Nombre            VARCHAR(1000),
    @EsDeContratista   BIT,
    @Descripcion       VARCHAR(1000) = NULL,
    @RequiereValor     BIT = NULL,
    @CreadoPor         INT,
    @ContratoId        INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF EXISTS (
            SELECT 1
            FROM dbo.APP_PREFERENCIAS WITH (NOLOCK)
            WHERE UPPER(LTRIM(RTRIM(Nombre))) = UPPER(LTRIM(RTRIM(@Nombre)))
        )
        BEGIN
            -- Código propio para identificar duplicado desde C#
            THROW 50011, 'PREFERENCIA_DUPLICADA', 1;
        END

        BEGIN TRAN;

        INSERT INTO dbo.APP_PREFERENCIAS
            (Nombre, EsDeContratista, Descripcion, RequiereValor, CreadoPor, CreadoEl)
        VALUES
            (@Nombre, @EsDeContratista, @Descripcion, @RequiereValor, @CreadoPor, GETDATE());

        DECLARE @Id INT = SCOPE_IDENTITY();

        DECLARE @detalle NVARCHAR(MAX) =
        (
            SELECT p.Id, p.Nombre, p.EsDeContratista, p.Descripcion, p.RequiereValor,
                   p.CreadoPor, p.CreadoEl, p.ModificadoPor, p.ModificadoEl
            FROM dbo.APP_PREFERENCIAS p WITH (NOLOCK)
            WHERE p.Id = @Id
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        INSERT INTO dbo.AP_Bitacora (Fecha, Tipo, Mensaje, Detalle, UsuarioId, ContratoId)
        VALUES (GETDATE(), 'INSERT', CONCAT('APP_PREFERENCIAS insertado Id=', @Id), @detalle, @CreadoPor, @ContratoId);

        COMMIT TRAN;

        SELECT p.Id, p.Nombre, p.EsDeContratista, p.Descripcion, p.RequiereValor,
               p.CreadoPor, p.CreadoEl, p.ModificadoPor, p.ModificadoEl
        FROM dbo.APP_PREFERENCIAS p WITH (NOLOCK)
        WHERE p.Id = @Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;

        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50011, 'PREFERENCIA_DUPLICADA', 1;
        ELSE
            THROW;
    END CATCH
END
GO
