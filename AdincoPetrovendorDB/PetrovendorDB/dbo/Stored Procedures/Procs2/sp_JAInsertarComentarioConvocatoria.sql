-- =============================================
 -- Modified: DANIEL AC 
-- Updated date: 02/01/2017 
-- Description: Agregue campos IdProveedorCreador,IdContratoCreador 
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAInsertarComentarioConvocatoria]
(
    @IdUsuario INT,
    @Comentario NVARCHAR(MAX),
    @IdPerfil INT,
    @IdEncabezado INT,
    @IdSolped INT,
    @PetrovendorProcura INT = 2, --Petrovendor 0 - Procura 1 - Adinco 2
	@IdProveedorCreador INT, ---MOD DAC Add parameter @IdProveedorCreador
	@IdContratoCreador INT = 0---MOD DAC Add parameter @IdContratoCreador
)
AS
BEGIN
    DECLARE @IdComentarioBases INT         
	    

    INSERT INTO dbo.JA_ComentariosBasesConvocatoria
    (
        Comentario,
        IdUsuario,
        IdPerfil,
        IdEncabezado,
        FechaCreado,
		IdProveedorCreador,
		IdContratoCreador
    )
    VALUES
    (   @Comentario,   -- Comentario - nvarchar(max)
        @IdUsuario,    -- IdUsuario - int
        @IdPerfil,     -- IdPerfil - int
        @IdEncabezado, -- IdEncabezado - int
        GETDATE(),      -- FechaCreado - datetime
		@IdProveedorCreador,
		@IdContratoCreador
    )

    SELECT @IdComentarioBases = @@IDENTITY

    --Mandar a notificacion
    EXEC dbo.Ja_InsertarNotificacionProveedores @IdSolPed = @IdSolped,             -- int
                                                @IdUsuario = @IdUsuario,           -- int
                                                @TipoMensaje = 2,                  -- int
                                                @IdPrimario = @IdComentarioBases,  -- int
                                                @PetrovendorProcura = @PetrovendorProcura, --Es petrovendor donde se insertando?
												@IdProveedorCreador=@IdProveedorCreador,
												@IdContratoCreador=@IdContratoCreador



    SELECT base.IdComentarioBases,
           base.Comentario,
           base.IdUsuario,
           base.IdPerfil,
           usuario.Nombre,
           base.IdEncabezado,
           base.FechaCreado
    FROM JA_ComentariosBasesConvocatoria base
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = base.IdUsuario
    WHERE base.IdComentarioBases = @IdComentarioBases

END
 