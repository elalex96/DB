IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_AP_Usuarios_Admin'
    )
    DROP PROCEDURE USP_SEL_AP_Usuarios_Admin;
GO
CREATE PROC [dbo].[USP_SEL_AP_Usuarios_Admin]
    @pIdUsuario INT,
    @IdContrato INT
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
        l.fchRegistro,
        L.UltimoAcceso
    FROM 
        AP_Usuario AS l WITH (NOLOCK)
    WHERE 
        ISNULL(l.IsGrupo, 0) = 0
    ORDER BY 
        l.IsActivo DESC,
        l.UsuarioID;


END
