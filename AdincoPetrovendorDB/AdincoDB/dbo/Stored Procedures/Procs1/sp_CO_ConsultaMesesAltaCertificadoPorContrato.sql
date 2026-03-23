IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ConsultaMesesAltaCertificadoPorContrato'
          AND type = 'P'
)
    DROP PROCEDURE dbo.sp_CO_ConsultaMesesAltaCertificadoPorContrato
GO

CREATE PROCEDURE [dbo].[sp_CO_ConsultaMesesAltaCertificadoPorContrato] @IdContrato INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;

    DECLARE @FechaEfectiva DATE;
    DECLARE @MsgError NVARCHAR(4000);

    BEGIN TRY

        SELECT @FechaEfectiva = InicioVigencia
        FROM CO_Contrato WITH (NOLOCK)
        WHERE IdContrato = @IdContrato;

        SELECT CAST(C.IdFecha AS DATE) AS IdFecha,
               CONCAT(
                         RIGHT('00' + CAST(MONTH(IdFecha) AS VARCHAR(2)), 2),
                         ' ',
                         DATENAME(month, IdFecha),
                         ' ',
                         YEAR(IdFecha)
                     ) AS Fecha
        FROM AP_Calendario C WITH (NOLOCK)
            LEFT JOIN CO_GEAceptadosMes GEA WITH (NOLOCK)
                ON C.IdFecha = GEA.Mes
                   AND GEA.IdContrato = @IdContrato
        WHERE C.Dia = 1
              AND C.IdFecha
              BETWEEN @FechaEfectiva AND CURRENT_TIMESTAMP
              AND GEA.Mes IS NULL
        ORDER BY IdFecha DESC
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorLine INT = ERROR_LINE(),
                @ErrorProc SYSNAME = ISNULL(ERROR_PROCEDURE(), OBJECT_NAME(@@PROCID)),
                @ErrorState INT = ERROR_STATE();
        DECLARE @FullError NVARCHAR(2048);

        SET @FullError
            = CONCAT(
                        'SP: ',
                        @ErrorProc,
                        ' | Línea: ',
                        @ErrorLine,
                        ' | Error: ',
                        @ErrorMessage,
                        ' | Params: [IdContrato=',
                        @IdContrato,
                        ']',
                        ' | User: ',
                        SUSER_SNAME(),
                        ' | Host: ',
                        HOST_NAME(),
                        ' | App: ',
                        APP_NAME()
                    );

        THROW 50005, @FullError, @ErrorState;
    END CATCH
END
GO
