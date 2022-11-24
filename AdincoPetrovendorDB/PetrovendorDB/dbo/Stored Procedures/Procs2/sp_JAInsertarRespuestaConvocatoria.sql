CREATE PROCEDURE [dbo].[sp_JAInsertarRespuestaConvocatoria]
(
    @IdComentarioBase INT,
    @IdUsuario INT,
    @Respuesta NVARCHAR(MAX),
    @IdPerfil INT,
    @IdEncabezado INT,
    @IdSolped INT,
    @PetrovendorProcura INT = 2, --Petrovendor 0 - Procura 1 -Adinco 2
	@IdProveedorCreador INT,
	@IdContratoCreador INT = 0
)
AS
BEGIN
    DECLARE @IdRespuesta INT

    INSERT INTO dbo.JA_ComentariosBasesConvocatoriaRespuesta
    (
        Respuesta,
        Idusuario,
        IdPerfil,
        IdEncabezado,
        FechaCreado,
		IdProveedorCreador,
		IdContratoCreador
    )
    VALUES
    (   @Respuesta,    -- Respuesta - nvarchar(max)
        @IdUsuario,    -- Idusuario - int
        @IdPerfil,     -- IdPerfil - int
        @IdEncabezado, -- IdEncabezado - int
        GETDATE(),      -- FechaCreado - datetime
		@IdProveedorCreador,
		@IdContratoCreador
    )

    SELECT @IdRespuesta = @@IDENTITY

    --Enviar notificacion
    EXEC dbo.Ja_InsertarNotificacionProveedores @IdSolPed = @IdSolped,             -- int
                                                @IdUsuario = @IdUsuario,           -- int
                                                @TipoMensaje = 3,                  -- int
                                                @IdPrimario = @IdRespuesta,        -- int
                                                @PetrovendorProcura = @PetrovendorProcura, --Es petrovendor donde se insertando
												@IdContratoCreador =@IdContratoCreador,
												@IdProveedorCreador = @IdProveedorCreador

    INSERT INTO dbo.JA_ComentarioConvocatoriaRelacion
    (
        IdComentarioBase,
        IdRespuestaConvocatoria
    )
    VALUES
    (   @IdComentarioBase, -- IdComentarioBase - int
        @IdRespuesta       -- IdRespuestaConvocatoria - int
    )

    SELECT resp.FechaCreado,
           resp.Respuesta,
           usuario.Nombre
    FROM dbo.JA_ComentariosBasesConvocatoriaRespuesta resp
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = resp.Idusuario
    WHERE resp.IdRespuesta = @IdRespuesta

END
