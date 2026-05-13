--Modificado 05-dic-2017 ahora se muestran todos los usuarios del proveedor logueado
CREATE PROCEDURE sp_JAListarParticipantesJuntaAclaracion
(
    @IdProveedor INT,
    @IdUsuario INT
)
AS
BEGIN
    DECLARE @tablaAuxiliar TABLE
    (
        IdParticipante INT,
        NombreParticipante NVARCHAR(MAX),
        Correo NVARCHAR(MAX),
        IdUsuarioProveedor INT
    )

    INSERT INTO dbo.JA_Participantes
    (
        NombreParticipante,
        CorreoParticipanteExterno,
        IdProveedor,
        IdUsuario,
        CreadoPor,
        FechaCreado
    )
    SELECT Nombre,
           Correo,
           @IdProveedor,
           usu.IdUsuario,
           @IdUsuario,
           GETDATE()
    FROM dbo.S_Usuario usu
        INNER JOIN dbo.S_UsuarioProveedor uProve
            ON uProve.IdUsuario = usu.IdUsuario
    WHERE uProve.IdProveedor = @IdProveedor
          AND usu.Activo = 1
          AND usu.IdUsuario NOT IN (
                                       SELECT usuario.IdUsuario
                                       FROM dbo.JA_Participantes part
                                           INNER JOIN dbo.S_Usuario usuario
                                               ON usuario.IdUsuario = part.IdUsuario
                                           INNER JOIN dbo.S_UsuarioProveedor uProv
                                               ON uProv.IdUsuario = usuario.IdUsuario
                                       WHERE part.IdProveedor = @IdProveedor
                                             AND usu.Activo = 1
                                   )

    --Actualizo si esta activo el usuario para que aparezca en la lista dependiendo de su estatus en S_usuario
    UPDATE part
    SET part.Activo = usuario.Activo
    FROM dbo.JA_Participantes part
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = part.IdUsuario
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON uProv.IdUsuario = usuario.IdUsuario
    WHERE uProv.IdProveedor = @IdProveedor
          AND part.Activo IS NOT NULL

    --retorno a la vista
    SELECT partic.IdParticipante,
           CONCAT(partic.NombreParticipante, ' - ', partic.CorreoParticipanteExterno) AS Nombre
    FROM dbo.JA_Participantes partic
    WHERE partic.IdProveedor = @IdProveedor
          AND partic.Activo = 1

END