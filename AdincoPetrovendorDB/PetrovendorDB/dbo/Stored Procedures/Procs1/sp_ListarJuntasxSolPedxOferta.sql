CREATE PROCEDURE [dbo].[sp_ListarJuntasxSolPedxOferta]
(
    @IdUsuario INT,
    @IdSolPed INT,
    @IdOferta INT,
	@IdProveedor INT
)
AS
BEGIN
    DECLARE @tablaRetornoVista TABLE
    (
        IdTopic INT,
        IdSolPed INT,
        IdDomicilio INT,
        Estatus INT,
        FechaHoraJunta DATETIME,
        Domicilio NVARCHAR(MAX),
        NombreEstatus NVARCHAR(MAX),
        Comentario NVARCHAR(MAX),
        IdPeticionOferta INT,
        CreadoPor INT,
        RazonSocial NVARCHAR(MAX)
    )

    --utilizo la tabla auziliar para sacar al creado en este caso el que creo la junta de aclaracion
    INSERT INTO @tablaRetornoVista
    (
        IdTopic,
        IdSolPed,
        IdDomicilio,
        Estatus,
        FechaHoraJunta,
        Domicilio,
        NombreEstatus,
        Comentario,
        IdPeticionOferta,
        CreadoPor
    )
    SELECT DISTINCT
        topic.IdTopic,
        topic.IdSolPed,
        topic.IdDomicilio,
        estatus.Estatus,
        topic.FechaHoraJunta,
        domicilio.Domicilio,
        CASE
            WHEN estatus.Estatus = -1 THEN
                'Pendiente'
            WHEN estatus.Estatus = 1 THEN
                'Confirmada'
            WHEN estatus.Estatus = 0 THEN
                'Cancelada'
        END AS NombreEstatus,
        topic.Comentario,
        petOferta.IdPeticionOferta,
        petOferta.CreadoPor
    FROM MM_PeticionOferta petOferta
        INNER JOIN dbo.JA_TopicAclaraciones topic
            ON topic.IdSolPed = petOferta.IdSolicitudPedido
        INNER JOIN dbo.JA_LugarJunta domicilio
            ON domicilio.IdLugar = topic.IdDomicilio
        INNER JOIN dbo.S_UsuarioProveedor uProv
            ON uProv.IdProveedor = petOferta.IdSubcontratista
        INNER JOIN dbo.JA_Estatus estatus
            ON estatus.IdProveedor = uProv.IdProveedor
               AND estatus.IdTopic = topic.IdTopic
    WHERE petOferta.IdSolicitudPedido = @IdSolPed
          AND petOferta.IdPeticionOferta = @IdOferta
          AND petOferta.IdSubcontratista = @IdProveedor --Seguridad en caso de que el usuario modifique el numero de la solped o solOferta
           

    UPDATE @tablaRetornoVista
    SET RazonSocial = prov.RazonSocial
    FROM dbo.S_UsuarioProveedor uProv
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = uProv.IdUsuario
        INNER JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = uProv.IdProveedor
    WHERE [@tablaRetornoVista].CreadoPor = uProv.IdUsuario AND prov.IdProveedor=@IdProveedor

    --retorno a la vista
    SELECT *
    FROM @tablaRetornoVista
END

