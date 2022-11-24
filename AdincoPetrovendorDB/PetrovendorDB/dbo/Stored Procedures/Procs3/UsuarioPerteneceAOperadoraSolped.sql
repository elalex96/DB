CREATE PROCEDURE UsuarioPerteneceAOperadoraSolped
@IdSolicitudPedido INT,
@IdUsuario INT
AS
BEGIN
    IF EXISTS
    (   SELECT 1
        FROM dbo.S_UsuarioProveedor up
            INNER JOIN dbo.MM_SolicitudPedido sp
                ON sp.IdProveedor = up.IdProveedor
        WHERE up.IdUsuario = @IdUsuario
              AND sp.IdSolicitudPedido = @IdSolicitudPedido)
    BEGIN
        SELECT 1 -- es usuario de la operadora
    END
    ELSE
    BEGIN
        SELECT 0 -- no es usuario de la operadora no permitir que entre
    END
END




