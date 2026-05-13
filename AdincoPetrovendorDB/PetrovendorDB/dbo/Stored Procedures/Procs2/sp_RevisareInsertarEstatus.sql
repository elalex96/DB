CREATE PROCEDURE sp_RevisareInsertarEstatus
(
    @IdProveedorLogueado INT,
    @IdUsuario INT,
    @ProcuraPetrovendor INT = 0
)
AS
BEGIN
    DECLARE @IdTopic INT,
            @Contador INT = 1,
            @NumeroDeRegistros INT,
            @IdProveedorAInsertar INT
    DECLARE @TablaIdTopics TABLE
    (
        IdTopic INT,
        NumeroFila INT,
        IdProveedor INT,
        IdSolOferta INT,
        IdSolPed INT
    )

    IF (@ProcuraPetrovendor = 1) -- si es procura entra
    BEGIN
        INSERT INTO @TablaIdTopics
        (
            IdTopic,
            NumeroFila,
            IdProveedor
        )
        SELECT DISTINCT
            topic.IdTopic,
            ROW_NUMBER() OVER (ORDER BY topic.IdTopic),
            uProv.IdProveedor
        FROM dbo.MM_PeticionOferta petOferta
            INNER JOIN dbo.S_UsuarioProveedor uProv
                ON petOferta.IdSubcontratista = uProv.IdProveedor
            INNER JOIN dbo.S_Proveedor prov
                ON prov.IdProveedor = uProv.IdProveedor
            INNER JOIN dbo.JA_TopicAclaraciones topic
                ON topic.IdSolPed = petOferta.IdSolicitudPedido
            LEFT JOIN dbo.JA_Estatus estatus
                ON estatus.IdProveedor = uProv.IdProveedor
        WHERE petOferta.CreadoPor IN ( --seguridad
                                         SELECT usuarioS.IdUsuario
                                         FROM dbo.S_Usuario usuarioS
                                             INNER JOIN dbo.S_UsuarioProveedor usProv
                                                 ON usProv.IdUsuario = usuarioS.IdUsuario
                                         WHERE usProv.IdProveedor = @IdProveedorLogueado
                                     )
    END
    ELSE
    BEGIN --petrovendor
        INSERT INTO @TablaIdTopics
        (
            IdTopic,
            NumeroFila,
            IdProveedor
        )
        SELECT topic.IdTopic,
               ROW_NUMBER() OVER (ORDER BY topic.IdTopic),
               uProv.IdProveedor
        FROM dbo.MM_PeticionOferta petOferta
            INNER JOIN dbo.S_UsuarioProveedor uProv
                ON petOferta.IdSubcontratista = uProv.IdProveedor
            INNER JOIN dbo.S_Proveedor prov
                ON prov.IdProveedor = uProv.IdProveedor
            INNER JOIN dbo.JA_TopicAclaraciones topic
                ON topic.IdSolPed = petOferta.IdSolicitudPedido
            LEFT JOIN dbo.JA_Estatus estatus
                ON estatus.IdProveedor = uProv.IdProveedor
        WHERE prov.IdProveedor = @IdProveedorLogueado
    END

    --obtengo la cantidad de IdTopic para recorrerlos
    SELECT @NumeroDeRegistros = COUNT(IdTopic)
    FROM @TablaIdTopics


    WHILE (@Contador <= @NumeroDeRegistros)
    BEGIN

        SELECT @IdTopic = IdTopic,
               @IdProveedorAInsertar = IdProveedor
        FROM @TablaIdTopics
        WHERE NumeroFila = @Contador

        IF NOT EXISTS
        (
            SELECT IdProveedor,
                   Estatus
            FROM dbo.JA_Estatus
            WHERE IdTopic = @IdTopic
                  AND IdProveedor = @IdProveedorAInsertar
        )
        BEGIN
            INSERT INTO dbo.JA_Estatus
            (
                Estatus,
                IdTopic,
                IdProveedor,
                CreadoPor,
                FechaCreado
            )
            VALUES
            (   -1,                    -- Estatus - int
                @IdTopic,              -- IdTopic - int
                @IdProveedorAInsertar, -- IdProveedor - int
                @IdUsuario,            -- CreadoPor - int
                GETDATE()              -- FechaCreado - smalldatetime
            )
        END
        SET @Contador += 1
    END
END