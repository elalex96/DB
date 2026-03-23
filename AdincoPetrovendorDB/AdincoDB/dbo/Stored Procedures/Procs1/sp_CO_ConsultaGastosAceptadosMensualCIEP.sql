IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ConsultaGastosAceptadosMensualCIEP'
          AND type = 'P'
)
    DROP PROCEDURE sp_CO_ConsultaGastosAceptadosMensualCIEP
GO

-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2016
-- Description:	Consulta los Gastos Aceptados Mensuales
-- =============================================
CREATE PROCEDURE dbo.sp_CO_ConsultaGastosAceptadosMensualCIEP
    -- Add the parameters for the stored procedure here
    @IdContrato INT = 0,
    @IdIdioma INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;

    BEGIN TRY      
    
        SELECT IdGEAceptadoMes,
               IdContrato,
               GEAprobados AS Monto,
               Mes,
               CreadoPor,
               CreadoEl,
               ModificadoPor,
               ModificadoEl,
               Activo AS Mes,
               RIGHT('00' + CAST(month(Mes) AS VARCHAR(2)), 2) + ' ' + DATENAME(month, Mes) AS NombreMes,
               DATENAME(YEAR, Mes) AS Anio
        FROM CO_GEAceptadosMes WITH (NOLOCK)
        WHERE IdContrato = @IdContrato
        ORDER BY CO_GEAceptadosMes.Mes DESC;

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
                @ErrorNumber INT = ERROR_NUMBER(),
                @ErrorLine INT = ERROR_LINE(),
                @ErrorProc NVARCHAR(200) = ISNULL(ERROR_PROCEDURE(), OBJECT_NAME(@@PROCID)),
                @ErrorState INT = ERROR_STATE();
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
                        @IdContrato
                    );

        -- Lanzar error sin rollback (solo consulta)
        THROW 50002, @FullError, 1;
    END CATCH
END;
GO
