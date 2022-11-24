CREATE PROCEDURE sp_JAListarJuntasxProveedor
(
    @IdProveedor INT,
    @ProcuraPetrovendor INT = 0
)
AS
BEGIN
    DECLARE @tablaPetrovendor TABLE
    (
        Id INT,
        IdTopic INT,
        IdSolicitudPedido INT,
        IdPeticionOferta INT,
        RazonSocial NVARCHAR(MAX),
        FechaHoraJunta DATETIME,
        NombreEstatus NVARCHAR(MAX),
        Estatus INT,
        IdEstatus INT,
        CreadoPor INT
    )

    IF (@ProcuraPetrovendor = 1) -- si es procura entra
    BEGIN
        SELECT DISTINCT
            topic.IdTopic,
            petOferta.IdPeticionOferta,
            prov.RazonSocial,
            topic.FechaHoraJunta,
            petOferta.IdSolicitudPedido,
            CASE
                WHEN estatus.Estatus = -1 THEN
                    'Pendiente'
                WHEN estatus.Estatus = 1 THEN
                    'Confirmada'
                WHEN estatus.Estatus = 0 THEN
                    'Cancelada'
            END AS NombreEstatus,
            estatus.Estatus,
            estatus.IdEstatus
        FROM dbo.MM_PeticionOferta petOferta
            INNER JOIN dbo.S_UsuarioProveedor uProv
                ON petOferta.IdSubcontratista = uProv.IdProveedor
            INNER JOIN dbo.S_Proveedor prov
                ON prov.IdProveedor = uProv.IdProveedor
            INNER JOIN dbo.JA_TopicAclaraciones topic
                ON topic.IdSolPed = petOferta.IdSolicitudPedido
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
    END
    ELSE --si es petrovendor
    BEGIN
        INSERT INTO @tablaPetrovendor
        (
            Id,
            IdTopic,
            IdSolicitudPedido,
            IdPeticionOferta,
            FechaHoraJunta,
            NombreEstatus,
            Estatus,
            IdEstatus,
            CreadoPor
        )
        SELECT DISTINCT
            ROW_NUMBER() OVER (ORDER BY topic.IdTopic),
            topic.IdTopic,
            petOferta.IdSolicitudPedido,
            petOferta.IdPeticionOferta,
            topic.FechaHoraJunta,
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
            petOferta.CreadoPor
        FROM dbo.MM_PeticionOferta petOferta
            INNER JOIN dbo.S_UsuarioProveedor uProv
                ON petOferta.IdSubcontratista = uProv.IdProveedor
            INNER JOIN dbo.S_Proveedor prov
                ON prov.IdProveedor = uProv.IdProveedor
            INNER JOIN dbo.JA_TopicAclaraciones topic
                ON topic.IdSolPed = petOferta.IdSolicitudPedido
            INNER JOIN dbo.JA_Estatus estatus
                ON estatus.IdTopic = topic.IdTopic
                   AND estatus.IdProveedor = uProv.IdProveedor
        WHERE prov.IdProveedor = @IdProveedor
		GROUP BY topic.IdTopic, petOferta.IdSolicitudPedido,petOferta.IdPeticionOferta, topic.FechaHoraJunta, estatus.Estatus, estatus.IdEstatus, petOferta.CreadoPor

        UPDATE @tablaPetrovendor
        SET RazonSocial = prov.RazonSocial
        FROM dbo.S_UsuarioProveedor uProv
            INNER JOIN dbo.S_Usuario usuario
                ON usuario.IdUsuario = uProv.IdUsuario
            INNER JOIN dbo.S_Proveedor prov
                ON prov.IdProveedor = uProv.IdProveedor
        WHERE [@tablaPetrovendor].CreadoPor = uProv.IdUsuario

		--retorno a la vista
        SELECT *
        FROM @tablaPetrovendor
    END
END



