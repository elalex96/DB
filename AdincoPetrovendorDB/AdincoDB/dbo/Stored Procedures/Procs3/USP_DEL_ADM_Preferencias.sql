DROP PROCEDURE IF EXISTS dbo.USP_DEL_ADM_Preferencias;
GO
CREATE PROCEDURE dbo.USP_DEL_ADM_Preferencias
    @Id          INT,
    @UsuarioId   INT = NULL,
    @ContratoId  INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- 1) Validar FK: ¿está referenciada por contratistas?
        IF EXISTS (
            SELECT 1
            FROM dbo.CON_ContratistaPreferencias c WITH (NOLOCK)
            WHERE c.PreferenciaId = @Id
        )
        BEGIN
            -- Error de negocio controlado
            THROW 50012, 'No se puede eliminar: la preferencia está asignada a uno o más contratistas.', 1;
        END

        -- Datos antes del eliminado
        DECLARE @before NVARCHAR(MAX) =
        (
            SELECT p.Id, p.Nombre, p.EsDeContratista, p.Descripcion, p.RequiereValor,
                   p.CreadoPor, p.CreadoEl, p.ModificadoPor, p.ModificadoEl
            FROM dbo.APP_PREFERENCIAS p WITH (NOLOCK)
            WHERE p.Id = @Id
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        );

        DELETE FROM dbo.APP_PREFERENCIAS WHERE Id = @Id;

        INSERT INTO dbo.AP_Bitacora (Fecha, Tipo, Mensaje, Detalle, UsuarioId, ContratoId)
        VALUES (GETDATE(), 'DELETE', CONCAT('APP_PREFERENCIAS eliminado Id=', @Id), @before, @UsuarioId, @ContratoId);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO
