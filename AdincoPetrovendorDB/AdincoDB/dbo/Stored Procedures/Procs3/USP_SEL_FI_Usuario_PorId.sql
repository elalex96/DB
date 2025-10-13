IF OBJECT_ID(N'dbo.USP_SEL_FI_Usuario_PorId', N'P') IS NOT NULL
    DROP PROCEDURE dbo.USP_SEL_FI_Usuario_PorId;
GO

CREATE PROCEDURE [dbo].[USP_SEL_FI_Usuario_PorId]
    @pUsuarioID     INT,         -- ID del usuario a consultar
    @pSoloActivos   BIT = 0,     -- 1 = solo si IsActivo = 1
    @pIncluirFoto   BIT = 1      -- 0 = no traer columna Foto
AS
BEGIN
    SET NOCOUNT ON;

    IF @pIncluirFoto = 1
    BEGIN
        SELECT
            u.UsuarioID,
            u.Usuario,           -- correo
            u.Nombre,
            u.Foto,             
            u.IsActivo,
			u.idRuta as Ruta
        FROM dbo.AP_Usuario AS u
        WHERE u.UsuarioID = @pUsuarioID
          AND (@pSoloActivos = 0 OR u.IsActivo = 1);
    END
    ELSE
    BEGIN
        SELECT
            u.UsuarioID,
            u.Usuario,          
            u.Nombre,
            CAST(NULL AS VARBINARY(MAX)) AS Foto, 
            u.IsActivo,
			u.idRuta as Ruta
        FROM dbo.AP_Usuario AS u
        WHERE u.UsuarioID = @pUsuarioID
          AND (@pSoloActivos = 0 OR u.IsActivo = 1);
    END
END
