IF OBJECT_ID(N'dbo.USP_VAL_AP_UsuarioCorreo', N'P') IS NOT NULL
    DROP PROCEDURE dbo.USP_VAL_AP_UsuarioCorreo;
GO

CREATE PROCEDURE dbo.USP_VAL_AP_UsuarioCorreo
    @pUsuarioID   INT,            -- ID actual (0 si es nuevo)
    @pCorreo      VARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ExisteDuplicado BIT = 0;
    DECLARE @Mensaje NVARCHAR(200);

    SET @pCorreo = LTRIM(RTRIM(@pCorreo));

    IF EXISTS (
        SELECT 1
        FROM dbo.AP_Usuario WITH (NOLOCK)
        WHERE LOWER(Usuario) = LOWER(@pCorreo)
          AND (@pUsuarioID = 0 OR UsuarioID <> @pUsuarioID) 
    )
    BEGIN
        SET @ExisteDuplicado = 1;
        SET @Mensaje = N'El correo ya está registrado en otro usuario.';
    END
    ELSE
    BEGIN
        SET @ExisteDuplicado = 0;
        SET @Mensaje = N'El correo está disponible.';
    END

    SELECT @ExisteDuplicado AS ExisteDuplicado, @Mensaje AS Mensaje;
END
GO
