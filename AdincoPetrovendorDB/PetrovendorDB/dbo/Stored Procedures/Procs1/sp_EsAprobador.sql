CREATE PROCEDURE [dbo].[sp_EsAprobador]
(
    @IdUsuario INT,
    @IdProveedor INT
)
AS
BEGIN
    SELECT sUser.IdUsuario
    FROM dbo.S_Rol rol
        INNER JOIN dbo.S_UsuarioRol userRol
            ON userRol.IdRol = rol.IdRol
        INNER JOIN dbo.S_Usuario sUser
            ON sUser.IdUsuario = userRol.IdUsuario
        INNER JOIN dbo.S_UsuarioProveedor userProveedor
            ON userProveedor.IdUsuario = sUser.IdUsuario
    WHERE userRol.IdUsuario = @IdUsuario
          AND userProveedor.IdProveedor = @IdProveedor
		  AND rol.IdRol = 5 --Rol de Aprobador de Compra Directa
END
