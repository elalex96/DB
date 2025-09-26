IF OBJECT_ID('dbo.fn_AP_ValidarUsuario', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_AP_ValidarUsuario;
GO
CREATE FUNCTION [dbo].[fn_AP_ValidarUsuario]
(
    @pUsuarioID     INT,
    @pUsuario       VARCHAR(30),
    @pContrasenia   VARCHAR(30),
    @pNombre        VARCHAR(250)
)
RETURNS VARCHAR(250)
AS
BEGIN
    DECLARE @result VARCHAR(250);

    IF EXISTS (
        SELECT 1
        FROM ap_usuario
        WHERE RTRIM(Usuario) = RTRIM(@pUsuario)
          AND UsuarioID <> @pUsuarioID
    )
    BEGIN
        SET @result = 'El correo [' + @pUsuario + '] ya está asignado';
    END

    RETURN @result;
END
GO
