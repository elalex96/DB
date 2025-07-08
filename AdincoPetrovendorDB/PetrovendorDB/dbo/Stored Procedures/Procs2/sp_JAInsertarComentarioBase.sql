USE Petrovendor
GO
DROP PROC IF EXISTS sp_JAInsertarComentarioBase
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Modified: DANIEL AC 
-- Updated date: 02/01/2017 
-- Description: Agregue campos IdProveedor,IdContrato
-- =============================================
-- Modified: Alexander Gomez
-- Updated date: 29/04/2020
-- Description: se agrego el sp de envio de notificacion por correo
-- =============================================
-- Modified: Luis David
-- Updated date: 19/09/2023
-- Description: Se agrega el idOferta para no duplicar correos
-- =============================================
-- Modified: Luis David
-- Updated date: 07/07/25
-- Description: Se sacan las notificaciones a s_notificación para enviarlas desde el sdk
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAInsertarComentarioBase]
(
    @IdUsuario INT,
    @Comentario NVARCHAR(MAX),
    @IdPerfil INT,
    @IdSolPed INT,
    @PetrovendorProcura INT = 2, --Petrovendor 0 - Procura 1 - Adinco 2
	@IdProveedor INT,
	@IdContrato INT = NULL,
	@IdOferta int = NULL

)
AS
BEGIN
    DECLARE @IdComentario INT

    INSERT INTO dbo.JA_ComentarioBase
    (
        Comentario,
        IdUsuario,
        IdPerfil,
        IdSolPed,
        FechaCreado,
		IdProveedor,
		IdContrato
    )
    VALUES
    (   @Comentario, -- Comentario - nvarchar(max)
        @IdUsuario,  -- IdUsuario - int
        @IdPerfil,   -- IdPerfil - int
        @IdSolPed,
        GETDATE(),    -- FechaCreado - datetime
		@IdProveedor,
		@IdContrato
    )

    SELECT @IdComentario = SCOPE_IDENTITY();

    
    EXEC dbo.Ja_InsertarNotificacionProveedores @IdSolPed = @IdSolPed,                    -- int
                                                @IdUsuario = @IdUsuario,                  -- int
                                                @TipoMensaje = 0,                         -- int
                                                @IdPrimario = @IdComentario,              -- int
                                                @PetrovendorProcura = @PetrovendorProcura, --Es petrovendor donde se insertando?
									            @IdProveedorCreador=@IdProveedor,
												@IdContratoCreador  = @IdContrato;

	--SE SACA FUERA DEL MÉTODO PRINCIPAL
	--EXEC dbo.SP_JA_EnviarCorreoComentarioPregunta @IdSolPed,	-- int
	--                                              @IdUsuario,   -- int
	--                                              @IdProveedor, -- int
	--                                              @Comentario,   -- nvarchar(max)
	--											  @IdOferta = @IdOferta
	

    SELECT base.IdComentarioBase,
           base.Comentario,
           base.IdUsuario,
           base.IdPerfil,
           usuario.Nombre,
           base.FechaCreado,
		   ISNULL(base.IdProveedor,0)
    FROM dbo.JA_ComentarioBase base
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = base.IdUsuario
    WHERE base.IdComentarioBase = @IdComentario and base.IdProveedor=@IdProveedor;

END
