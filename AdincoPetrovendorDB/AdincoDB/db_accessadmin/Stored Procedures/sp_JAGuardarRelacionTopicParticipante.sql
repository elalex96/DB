CREATE PROCEDURE [db_accessadmin].sp_JAGuardarRelacionTopicParticipante
(
    @IdTopic INT,
    @IdParticipante INT = 0, --si el idParticipante es 0 entonces es correo externo
    @IdUsuarioCreador INT,
    @NombreExterno NVARCHAR(MAX),
    @CorreoExterno NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @IdExterno INT,
            @IdProveedor INT

    SELECT @IdProveedor = IdProveedor
    FROM dbo.S_UsuarioProveedor
    WHERE IdUsuario = @IdUsuarioCreador

    --Si tiene participantes externos primero insertarlos y despues guardar la relacion

    IF (@CorreoExterno != '')
    BEGIN
        INSERT INTO dbo.JA_Participantes
        (
            NombreParticipante,
            CorreoParticipanteExterno,
            IdProveedor,
            IdUsuario,
            CreadoPor,
            FechaCreado,
            Activo
        )
        VALUES
        (   @NombreExterno,    -- NombreParticipante - nvarchar(150)
            @CorreoExterno,    -- CorreoParticipanteExterno - nvarchar(200)
            @IdProveedor,      -- IdProveedor - int
            @IdUsuarioCreador, -- IdUsuario - int
            @IdUsuarioCreador, -- CreadoPor - int
            GETDATE(),         -- FechaCreado - smalldatetime
            NULL               -- Activo - bit
        )
        SELECT @IdExterno = @@IDENTITY
    END

    IF (@IdParticipante = 0)
        SELECT @IdParticipante = @IdExterno

    INSERT INTO dbo.JA_RelacionParticipantes
    (
        IdTopic,
        IdParticipante,
        CreadoPor,
        FechaCreado
    )
    VALUES
    (   @IdTopic,        -- IdTopic - int
        @IdParticipante, -- IdParticipante - int
        @IdUsuarioCreador,
        GETDATE()
    )
END
