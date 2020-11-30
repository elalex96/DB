-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <19/08/2019>
-- Description:	<actualizacion de los comentarios y asignacion de usuario DEA>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PO_ActualizarComentarioAsignado]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT,
	@IdAsignado NVARCHAR(MAX),
	@ComentarioInternoPO NVARCHAR(MAX),
	@IdUsuario INT ,
	@IdProveedor INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.MM_SolicitudPedido
	SET ComentarioInternoPO = @ComentarioInternoPO,
		FechaAsignado = GETDATE(),
		FechaComentarioMod = GETDATE()
	WHERE IdSolicitudPedido = @IdSolicitudPedido

	DECLARE @tablaAsignados TABLE
			( Id INT IDENTITY ,
			  IdUsuarioCompras INT )

		INSERT INTO @tablaAsignados
			( IdUsuarioCompras )
		SELECT splitdata  FROM dbo .fnSplitString ( @IdAsignado, ' ' )

		DECLARE @cantidadAsignados INT

		SELECT @cantidadAsignados  = COUNT ( * ) FROM @tablaAsignados

		IF ( @cantidadAsignados = 0 ) --actualizar todos los asigadores que estan activos por que no se selecciono ninguno
			BEGIN
				UPDATE	dbo.MM_SolicitudPedidoComprador
				SET		Activo = 0,
				 ModificadoEl = GETDATE (),
				 ModificadoPor =@IdUsuario
				WHERE	IdSolicitudPedido = @IdSolicitudPedido
				AND Activo=1
			END

		DECLARE @IdUsuarioComprasAux INT, @Contador INT = 1

		IF ( @cantidadAsignados > 0 ) --primero revisar si existe si es asi activalo si no entonces insertalo en la tabla
			BEGIN
				WHILE ( @cantidadAsignados >= @Contador )
					BEGIN
						SELECT @IdUsuarioComprasAux  = IdUsuarioCompras FROM @tablaAsignados  WHERE Id = @Contador

						IF EXISTS ( SELECT 1  FROM dbo.MM_SolicitudPedidoComprador WHERE IdSolicitudPedido  =@IdSolicitudPedido  AND IdAsignadoA = @IdUsuarioComprasAux )
							BEGIN

								UPDATE	dbo.MM_SolicitudPedidoComprador
								SET		
								Activo = 1, 
								IdAsignadorPor=@IdUsuario,
								ModificadoEl = GETDATE(),
								ModificadoPor = @IdUsuario
								WHERE
								IdAsignadoA = @IdUsuarioComprasAux
								AND IdSolicitudPedido = @IdSolicitudPedido

							END
						ELSE
							BEGIN
								INSERT INTO dbo.MM_SolicitudPedidoComprador
								(								    
								    IdSolicitudPedido,
								    IdAsignadoA,
								    IdAsignadorPor,
								    CreadoPor,
								    CreadoEl,								   
								    Activo
								)
								VALUES
								(   
								    @IdSolicitudPedido,         -- IdSolicitudPedido - int
								    @IdUsuarioComprasAux,         -- IdAsignadoA - int
								    @IdUsuario,         -- IdAsignadorPor - int
								    @IdUsuario,         -- CreadoPor - int
								    GETDATE(), -- CreadoEl - datetime								   
								    1       -- Activo - bit
								    )
																
							END

						SET @Contador += 1
					END
			END

			--EN CASO DE QUE SE ELIMINEN ROLES
			UPDATE dbo.MM_SolicitudPedidoComprador
			SET Activo = 0,
			ModificadoEl=GETDATE(),
			ModificadoPor=@IdUsuario
			WHERE IdAsignadoA NOT IN (SELECT IdUsuarioCompras FROM @tablaAsignados) 
			AND IdSolicitudPedido = @IdSolicitudPedido
			AND Activo=1
	 
	 
END


