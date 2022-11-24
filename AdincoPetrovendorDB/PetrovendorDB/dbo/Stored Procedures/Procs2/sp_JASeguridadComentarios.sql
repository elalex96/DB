CREATE PROCEDURE [dbo].[sp_JASeguridadComentarios]
(
    @IdUsuario INT,
    @IdSolPed INT,
	@IdProveedorActual INT 
)
AS
BEGIN
    DECLARE @tablaAProveedor TABLE (IdProveedor INT)
    DECLARE @tablaIdUsuariosDeProveedores TABLE (IdUsuario INT)

    INSERT INTO @tablaAProveedor
    (
        IdProveedor
    )
    SELECT uProv.IdProveedor
    FROM dbo.S_Usuario usuario
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON uProv.IdUsuario = usuario.IdUsuario
        INNER JOIN dbo.MM_PeticionOferta oferta
            ON oferta.IdSubcontratista = uProv.IdProveedor
    WHERE oferta.IdSolicitudPedido = @IdSolPed

    INSERT INTO @tablaAProveedor
    (
        IdProveedor
    )
    SELECT uProv.IdProveedor
    FROM dbo.S_Usuario usuario
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON uProv.IdUsuario = usuario.IdUsuario
    WHERE usuario.IdUsuario = @IdUsuario AND uProv.IdProveedor=@IdProveedorActual


    INSERT INTO @tablaIdUsuariosDeProveedores
    (
        IdUsuario
    )
    SELECT uProv.IdUsuario
    FROM dbo.S_Usuario usuario
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON uProv.IdUsuario = usuario.IdUsuario
    WHERE uProv.IdProveedor IN (
                                   SELECT IdProveedor FROM @tablaAProveedor
                               )
          AND uProv.IdUsuario = @IdUsuario


    SELECT IdUsuario
    FROM @tablaIdUsuariosDeProveedores --Si retorna un usuario es que tiene permiso y en caso de que no retorne nada no tiene relacion con los comentarios

END