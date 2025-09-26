use adinco

DROP PROCEDURE IF EXISTS dbo.USP_SEL_AP_Usuarios_Admin;
GO
CREATE PROC [dbo].[USP_SEL_AP_Usuarios_Admin]
    @pIdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    ----------------------------------------------------------
    -- Consulta de usuarios (sin tablas de perfil)
    ----------------------------------------------------------
    SELECT 
        l.UsuarioID,
        l.Usuario,
        l.Nombre,
        l.IsActivo,
        l.fchRegistro
    FROM dbo.AP_Usuario AS l WITH (NOLOCK)
    WHERE ISNULL(l.IsGrupo, 0) = 0
    ORDER BY 
        l.IsActivo DESC,
        l.UsuarioID;


END
GO
