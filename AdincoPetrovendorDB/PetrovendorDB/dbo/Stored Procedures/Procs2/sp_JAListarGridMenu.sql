CREATE PROCEDURE [dbo].[sp_JAListarGridMenu]
(
    @IdProveedor INT,
    @Estatus INT
)
AS
BEGIN
    SELECT DISTINCT
        topic.IdTopic,
        topic.FechaHoraJunta,
        domicilio.Domicilio,
        topic.Comentario,
        petOferta.IdSubcontratista,
        prov.RazonSocial,
        CASE
            WHEN estatus.Estatus = -1 THEN
                'Pendiente'
            WHEN estatus.Estatus = 1 THEN
                'Confirmada'
            WHEN estatus.Estatus = 0 THEN
                'Cancelada'
        END AS NombreEstatus,
        estatus.Estatus,
        estatus.IdEstatus,
        petOferta.IdSolicitudPedido
    FROM dbo.MM_PeticionOferta petOferta
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON petOferta.IdSubcontratista = uProv.IdProveedor
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = uProv.IdProveedor
        INNER JOIN dbo.JA_TopicAclaraciones topic
            ON topic.IdSolPed = petOferta.IdSolicitudPedido
        INNER JOIN dbo.JA_LugarJunta domicilio
            ON domicilio.IdLugar = topic.IdDomicilio
        INNER JOIN dbo.JA_Estatus estatus
            ON estatus.IdProveedor = uProv.IdProveedor
               AND estatus.IdTopic = topic.IdTopic
    WHERE petOferta.CreadoPor IN ( --seguridad
                                     SELECT usuarioS.IdUsuario
                                     FROM dbo.S_Usuario usuarioS
                                         INNER JOIN dbo.S_UsuarioProveedor usProv
                                             ON usProv.IdUsuario = usuarioS.IdUsuario
                                     WHERE usProv.IdProveedor = @IdProveedor
                                 )
          AND estatus.Estatus = @Estatus
END

