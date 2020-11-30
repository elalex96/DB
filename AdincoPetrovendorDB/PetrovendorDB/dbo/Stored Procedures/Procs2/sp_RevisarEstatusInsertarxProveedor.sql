CREATE PROCEDURE [dbo].[sp_RevisarEstatusInsertarxProveedor]
(
    @IdProveedor INT,
    @IdUsuario INT,
    @IdSolPed INT,
    @IdOferta INT
)
AS
BEGIN
    DECLARE @IdTopic INT,
            @Contador INT = 1,
            @NumeroDeRegistros INT
    DECLARE @TablaIdTopics TABLE
    (
        NumeroFila INT,
        IdTopic INT
    )

    --obtengo los idTopics que se muestran en el grid
    INSERT INTO @TablaIdTopics
    (
        NumeroFila,
        IdTopic
    )
    SELECT ROW_NUMBER() OVER (ORDER BY topic.IdTopic),
           topic.IdTopic --Consulta del grid. Solo me interesan los idtopics para revisar si ya tienen un registro en Ja_estatus
    FROM MM_PeticionOferta petOferta
        LEFT JOIN dbo.JA_TopicAclaraciones topic
            ON topic.IdSolPed = petOferta.IdSolicitudPedido
        INNER JOIN dbo.JA_LugarJunta domicilio
            ON domicilio.IdLugar = topic.IdDomicilio
    WHERE petOferta.IdSolicitudPedido = @IdSolPed
          AND petOferta.IdPeticionOferta = @IdOferta
          AND petOferta.IdSubcontratista =@IdProveedor --Seguridad en caso de que el usuario modifique el numero de la solped o solOferta
          

    --obtengo la cantidad de IdTopic para recorrerlos
    SELECT @NumeroDeRegistros = COUNT(IdTopic)
    FROM @TablaIdTopics


    WHILE (@Contador <= @NumeroDeRegistros)
    BEGIN

        SELECT @IdTopic = IdTopic
        FROM @TablaIdTopics
        WHERE NumeroFila = @Contador

        IF NOT EXISTS
        (
            SELECT IdProveedor,
                   Estatus
            FROM dbo.JA_Estatus
            WHERE IdTopic = @IdTopic
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
            (   -1,           -- Estatus - int
                @IdTopic,     -- IdTopic - int
                @IdProveedor, -- IdProveedor - int
                @IdUsuario,   -- CreadoPor - int
                GETDATE()     -- FechaCreado - smalldatetime
            )
        END
        SET @Contador += 1
    END
END