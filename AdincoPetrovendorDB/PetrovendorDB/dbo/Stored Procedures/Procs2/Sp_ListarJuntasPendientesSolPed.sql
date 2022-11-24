CREATE PROCEDURE [dbo].[Sp_ListarJuntasPendientesSolPed]
(
    @IdProveedor INT,
    @IdSolPed INT
)
AS
BEGIN

    SELECT topic.IdTopic,
           topic.IdSolPed,
           topic.IdDomicilio,
           topic.FechaHoraJunta,
           domicilio.Domicilio,
           topic.Comentario
    FROM dbo.JA_TopicAclaraciones topic
        INNER JOIN dbo.S_UsuarioProveedor up
            ON up.IdUsuario = topic.CreadoPor
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = up.IdUsuario
        INNER JOIN dbo.JA_LugarJunta domicilio
            ON domicilio.IdLugar = topic.IdDomicilio
    WHERE IdSolPed = @IdSolPed
            AND up.IdProveedor = @IdProveedor

END


