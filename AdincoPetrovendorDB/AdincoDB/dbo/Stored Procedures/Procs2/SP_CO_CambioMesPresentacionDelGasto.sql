USE [Adinco]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_CO_CambioMesPresentacionDelGasto'
)
    DROP PROCEDURE SP_CO_CambioMesPresentacionDelGasto;
GO

CREATE PROCEDURE [dbo].[SP_CO_CambioMesPresentacionDelGasto]
    @ContratoId INT,
    @UsuarioId INT,
    @GastoId INT,
    @MesPresentacion DATE,
    @Pantalla VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRAN;
        DECLARE @FechaHoy DATETIME = GETDATE(),
                @MesPresentacionActual DATE = (
                                                  SELECT MesPresentacion
                                                  FROM CO_Registro (NOLOCK)
                                                  WHERE IdRegistro = @GastoId
                                              )
        IF
        (
            SELECT COUNT(1)
            FROM CO_Registro
            WHERE IdRegistro = @GastoId
                  AND MesPresentacion = @MesPresentacion
        ) = 0
        BEGIN
            UPDATE CO_Registro
            SET MesPresentacion = @MesPresentacion,
                IdUsuarioModPor = @UsuarioId
            WHERE IdRegistro = @GastoId

            INSERT INTO AP_Bitacora
            (
                [Fecha],
                [Tipo],
                [Mensaje],
                [Detalle],
                [UsuarioId],
                [ContratoId]
            )
            VALUES
            (@FechaHoy,
             'Edición',
             'Edición de Mes Presentacion de CO_Registro en la página ' + @Pantalla,
             CONCAT(
                       'IdRegistro ' + CONVERT(VARCHAR, @GastoId) + ' - Mes Presentación Antes:',
                       CONVERT(VARCHAR, @MesPresentacionActual),
                       ', Después:',
                       CONVERT(VARCHAR, @MesPresentacion)
                   ),
             @UsuarioId,
             @ContratoId
            )
        END;
        COMMIT TRAN;

    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        SELECT 'ERROR MESSAGE: ' + ERROR_MESSAGE() + ' - ERROR PROCEDURE: ' + ERROR_PROCEDURE() + ' - ERROR LINE: '
               + CAST(ERROR_LINE() AS VARCHAR) AS Respuesta;
    END CATCH
    SELECT 'CORRECTO' AS Respuesta;
END