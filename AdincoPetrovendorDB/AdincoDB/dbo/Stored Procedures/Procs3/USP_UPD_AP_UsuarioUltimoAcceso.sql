IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_UPD_AP_UsuarioUltimoAcceso'
    )
    DROP PROCEDURE USP_UPD_AP_UsuarioUltimoAcceso;
GO
CREATE PROCEDURE [dbo].[USP_UPD_AP_UsuarioUltimoAcceso]
    @UsuarioId              INT = 0,
    @ContratoId             INT = 0 -- Se agrega debido a estandares, pero la indicación es que se registre el ultimo acceso antes de que seleccione el área contractual, por lo que ira en 0
AS
    BEGIN

    UPDATE 
        AP_USUARIO
    SET 
        UltimoAcceso    =   GETDATE()
    WHERE 
        UsuarioId = @UsuarioId


      INSERT INTO dbo.AP_Bitacora
            (
                Fecha,
                Tipo,
                Mensaje,
                Detalle,
                UsuarioId,
                ContratoId
            )
            SELECT GETDATE(),'Inicio de sesión',
            'El usuario inicio sesión al sistema Adinco',
            'El usuario inicio sesión al sistema Adinco',
            @UsuarioId,
            @ContratoId;

    END;