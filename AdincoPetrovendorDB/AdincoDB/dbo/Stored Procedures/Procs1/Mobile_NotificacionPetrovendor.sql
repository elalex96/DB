CREATE PROCEDURE [dbo].[Mobile_NotificacionPetrovendor]
@IdtareaIdentity INT --GetIdentity
AS
BEGIN 
DECLARE @TipoOperacion INT,
			@Aprobador VARCHAR(80),
			@Correo VARCHAR(100),
			@IdTareaInsertada INT,
			
			@IdTipoAprobacion INT, --OK
			@IdStatusAprobacionM INT, --OK
			@IdUsuario INT, --OK
			@IdContrato INT, --OK
			@IdDocumento int, --OK
			@ComentarioDocumento nvarchar(max),
			@ComentarioAprobacion nvarchar(max)
			
			SELECT @TipoOperacion = TAOP.IdTipoOperacion,
	@IdDocumento = TAOP.IdDocumento,
	@Aprobador = T.IdAprobador,
	@IdStatusAprobacionM = T.IdEstatus,
	@ComentarioAprobacion= TAOP.Descripcion
	FROM Petrovendor.dbo.TA_Tarea AS T
	LEFT JOIN Petrovendor.dbo.TA_Operacion AS TAOP ON T.IdOperacion = TAOP.IdOperacion	
	WHERE T.IdTarea = @IdtareaIdentity;

	SELECT @Correo= Correo FROM Petrovendor.dbo.S_Usuario WHERE IdUsuario = @Aprobador
	SELECT @IdUsuario= UsuarioID FROM Adinco.dbo.AP_Usuario WHERE Usuario = @Correo --IDUSUARIO


	IF @TipoOperacion = 2
	BEGIN
	SELECT @IdContrato = IdContrato,
			   @ComentarioDocumento = MotivoUrgencia
			   FROM Petrovendor.dbo.MM_SolicitudPedido WHERE IdSolicitudPedido = @IdDocumento; --IDCONTRATO --IDDOCUMENTO
			   -----------------------------------------------------------------------------

				   INSERT INTO Adinco.dbo.AM_Aprobacion
						(
							IdTipoAprobacion,
							IdStatusAprobacionM,
							IdUsuario,
							IdTareaOrigen,
							IdContrato,
							FechaCreacion,
							IdDocumento,
							ComentarioDocumento,
							ComentarioAprobacion
						)
			VALUES(@TipoOperacion,         -- IdTipoAprobacion - int
					@IdStatusAprobacionM,         -- IdStatusAprobacionM - int
					@IdUsuario,         -- IdUsuario - int
					@IdtareaIdentity,         -- IdTareaOrigen - int
					@IdContrato,         -- IdContrato - int
					GETDATE(), -- FechaCreacion - datetime
					@IdDocumento,         -- IdDocumento - int
					@ComentarioDocumento,        -- ComentarioDocumento - varchar(250)
					@ComentarioAprobacion)
    END
    
	IF @TipoOperacion = 9
	BEGIN
	SELECT @IdContrato = IdContrato,
			   @ComentarioDocumento = Comentarios
				 FROM Petrovendor.dbo.MM_Pedido WHERE IdPedido = @IdDocumento --IDCONTRATO --IDDOCUMENTO
				 -----------------------------------------------------------------------------
				 INSERT INTO Adinco.dbo.AM_Aprobacion
						(
							IdTipoAprobacion,
							IdStatusAprobacionM,
							IdUsuario,
							IdTareaOrigen,
							IdContrato,
							FechaCreacion,
							IdDocumento,
							ComentarioDocumento,
							ComentarioAprobacion
						)
			VALUES(@TipoOperacion,         -- IdTipoAprobacion - int
					@IdStatusAprobacionM,         -- IdStatusAprobacionM - int
					@IdUsuario,         -- IdUsuario - int
					@IdtareaIdentity,         -- IdTareaOrigen - int
					@IdContrato,         -- IdContrato - int
					GETDATE(), -- FechaCreacion - datetime
					@IdDocumento,         -- IdDocumento - int
					@ComentarioDocumento,        -- ComentarioDocumento - varchar(250)
					@ComentarioAprobacion)
    END
    
			
END



