IF OBJECT_ID('dbo.sp_CO_InsertaGEAceptadosMes', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CO_InsertaGEAceptadosMes;
GO

CREATE PROCEDURE dbo.sp_CO_InsertaGEAceptadosMes
(
    @IdContrato INT,
    @GEAprobados MONEY,
    @Mes DATE,
    @IdUsuario INT,
    @IdIdioma INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @InsertedRecord INT;

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO dbo.CO_GEAceptadosMes
        (
            IdContrato,
            GEAprobados,
            Mes,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            Activo
        )
        VALUES
        (@IdContrato, @GEAprobados, @Mes, @IdUsuario, SYSDATETIME(), @IdUsuario, SYSDATETIME(), 1);

        SET @InsertedRecord = SCOPE_IDENTITY();

        INSERT INTO dbo.CO_GEAceptadosMes_Log
        (
            IdGEAceptadoMes,
            IdContrato,
            GEAprobados,
            Mes,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            Activo
        )
        VALUES
        (@InsertedRecord, @IdContrato, @GEAprobados, @Mes, @IdUsuario, SYSDATETIME(), @IdUsuario, SYSDATETIME(), 1);

        COMMIT;

        SELECT @InsertedRecord AS INSERTADO,
               CONCAT('El monto de gasto se ha guardado exitosamente con el número de operación (NO) ', @InsertedRecord) AS MSG;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorNumber INT = ERROR_NUMBER(),
                @ErrorLine INT = ERROR_LINE(),
                @ErrorProc NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), OBJECT_NAME(@@PROCID)),
                @ErrorState INT = ERROR_STATE(),
                @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @FullError NVARCHAR(4000);

        SET @FullError
            = CONCAT(
                        'Error en SP: ',
                        @ErrorProc,
                        ' | Línea: ',
                        @ErrorLine,
                        ' | Número: ',
                        @ErrorNumber,
                        ' | Mensaje: ',
                        @ErrorMessage,
                        ' | Parámetros: ',
                        'IdContrato=',
                        @IdContrato,
                        ', ',
                        'GEAprobados=',
                        @GEAprobados,
                        ', ',
                        'Mes=',
                        CONVERT(VARCHAR(10), @Mes, 120),
                        ', ',
                        'IdUsuario=',
                        @IdUsuario
                    );

        THROW 50001, @FullError, 1;
    END CATCH
END;
GO
