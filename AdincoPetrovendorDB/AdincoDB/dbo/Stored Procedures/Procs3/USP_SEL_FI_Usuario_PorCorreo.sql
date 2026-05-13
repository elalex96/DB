use adinco

DROP PROCEDURE IF EXISTS dbo.USP_SEL_FI_Usuario_PorCorreo;
GO
CREATE PROCEDURE dbo.USP_SEL_FI_Usuario_PorCorreo
    @IdContrato INT       = NULL,      
    @IdUsuario  INT       = NULL,      
    @Correo     NVARCHAR(100)          
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.UsuarioID,
        u.Nombre,
        u.Usuario,
        u.IsActivo,
        u.fchRegistro
    FROM dbo.AP_Usuario AS u
    WHERE
        u.Usuario = @Correo
END
GO
