use Petrovendor
go
drop proc if exists sp_JAInsertarRespuesta
go
-- =============================================
 -- Modified: DANIEL AC 
-- Updated date: 02/01/2017 
-- Description: Agregue campos IdProveedorCreador,IdContratoCreador 
-- =============================================
 -- Modified: Alexander Gomez 
-- Updated date: 29/04/2020
-- Description: se agrega el envio de notificacion por correo
-- =============================================
 -- Modified: Luis David
-- Updated date: 07/07/25
-- Description: Se excluye la ejecución del sp ya que se enviará mediante sdk
-- =============================================
CREATE PROCEDURE [dbo].[sp_JAInsertarRespuesta]
(
    @IdComentarioBase INT,
    @IdUsuario INT,
    @Respuesta NVARCHAR(MAX),
    @IdPerfil INT,
	@IdSolPed INT, 
    @PetrovendorProcura INT = 2, --Petrovendor 0 - Procura 1 - Adinco 2
	@IdProveedor INT,
	@IdContrato INT
)
AS
BEGIN
    DECLARE @IdRespuesta INT
    INSERT INTO dbo.JA_ComentarioRespuesta
    (
        Respuesta,
        IdUsuario,
        IdPerfil,
		IdSolPed,
        FechaCreado,
		IdProveedor,
		IdContrato
    )
    VALUES
    (   @Respuesta, -- Respuesta - nvarchar(max)
        @IdUsuario, -- IdUsuario - int
        @IdPerfil,  -- IdPerfil - int
		@IdSolPed,
        GETDATE(),   -- FechaCreado - datetime
		@IdProveedor,
		@IdContrato
    )

    SELECT @IdRespuesta = SCOPE_IDENTITY()

	--Enviar notificacion
	-- se comento este sp por que tiene un subquery con el idusuario
    EXEC dbo.Ja_InsertarNotificacionProveedores @IdSolPed = @IdSolped,             -- int
                                                @IdUsuario = @IdUsuario,           -- int
                                                @TipoMensaje = 1,                  -- int
                                                @IdPrimario = @IdRespuesta,        -- int
                                                @PetrovendorProcura = @PetrovendorProcura, --Es petrovendor donde se insertando
												@IdProveedorCreador =@IdProveedor, 
												@IdContratoCreador  = @IdContrato;

	--Se enviarán por eñ sdk fuera del sp
	--EXEC dbo.SP_JA_EnviarCorreoComentarioRespuesta @IdSolicitudPedido = @IdSolped, -- int
	--                                               @IdUsuario = @IdUsuario,         -- int
	--                                               @IdProveedor = @IdProveedor,       -- int
	--                                               @Respuesta = @Respuesta,         -- int
	--                                               @IdComentarioBase =  @IdComentarioBase;  -- int
	
 
	
    INSERT INTO dbo.JA_ComentarioRelacion
    (
        IdComentarioBase,
        IdComentarioRespuesta
    )
    VALUES
    (   @IdComentarioBase, -- IdComentarioBase - int
        @IdRespuesta       -- IdComentarioRespuesta - int
    )

    SELECT resp.FechaCreado,
           resp.Respuesta,
           usuario.Nombre
    FROM JA_ComentarioRespuesta resp
        INNER JOIN dbo.S_Usuario usuario
            ON usuario.IdUsuario = resp.IdUsuario
    WHERE resp.IdComentarioRespuesta = @IdRespuesta

END
