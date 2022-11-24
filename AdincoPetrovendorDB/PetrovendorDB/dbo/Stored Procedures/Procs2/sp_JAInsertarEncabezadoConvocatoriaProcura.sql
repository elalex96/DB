CREATE PROCEDURE [dbo].[sp_JAInsertarEncabezadoConvocatoriaProcura]
(
    @IdUsuario INT,
    @Nombre NVARCHAR(MAX),
    @Paginas NVARCHAR(MAX),
    @PuntosBases NVARCHAR(MAX),
    @Pregunta NVARCHAR(MAX),
    @IdSolPed INT
)
AS
BEGIN
    DECLARE @IdComentario INT,
            @Contador INT = 1,
            @NumeroDeRegistros INT,
            @IdOferta INT

    DECLARE @tablaIdOferta TABLE
    (
        NumeroFila INT,
        IdOferta INT
    )
    INSERT INTO @tablaIdOferta
    (
        NumeroFila,
        IdOferta
    )
    SELECT ROW_NUMBER() OVER (ORDER BY IdSolicitudPedido),
           IdPeticionOferta
    FROM dbo.MM_PeticionOferta
    WHERE IdSolicitudPedido = @IdSolPed

    SELECT @NumeroDeRegistros = COUNT(IdOferta)
    FROM @tablaIdOferta

    WHILE (@Contador <= @NumeroDeRegistros)
    BEGIN
        SELECT @IdOferta = IdOferta
        FROM @tablaIdOferta
        WHERE NumeroFila = @Contador

        INSERT INTO dbo.JA_EncabezadoComentarios
        (
            Nombre,
            Paginas,
            PuntosBases,
            Pregunta,
            IdSolPed,
            IdOferta,
            CreadoPor,
            FechaCreado
        )
        VALUES
        (   @Nombre,      -- Nombre - nvarchar(max)
            @Paginas,     -- Paginas - nvarchar(max)
            @PuntosBases, -- PuntosBases - nvarchar(max)
            @Pregunta,    -- Pregunta - nvarchar(max)
            @IdSolPed,    -- IdSolPed - int
            @IdOferta,    -- IdOferta - int
            @IdUsuario,   -- CreadoPor - int
            GETDATE()     -- FechaCreado - datetime
        )

        SET @Contador += 1
    END
END

