-- =============================================
-- Author: Pedro Acuña
-- Create date: 30/04/2018
-- Description: cambio de estatus del detalle y de la cabecera e ingresos al historial para llevar el detalle de los cambios
-- =============================================

CREATE PROCEDURE SP_MA_WSActualizarEstatusRevisionGral @IdDocumento INT, @AprobarRechazar INT, @IdUsuarioTarea INT ,
													   @IdTipoOperacion INT, @IdApp INT
AS
	BEGIN
		DECLARE @IdEstatusRetorno INT, @TipoFlujo INT, @IdEstatusGralTipoOperacion INT, @IdOperacion INT ,
				@IdLineaTiempoActual INT

		DECLARE @tablaRetorno TABLE
			( Estatus INT ,
			  Mensaje NVARCHAR(200))

		--obtener la ultima linea de la operacion 
		SELECT		TOP 1
					@IdLineaTiempoActual = linea.IdLineaTiempo
		FROM		Adinco.dbo.MA_LineaTiempo linea
		INNER JOIN	Adinco.dbo.MA_Operacion operacion
			ON operacion.IdDocumento = linea.IdDocumento
			   AND	operacion.IdLineaTiempo = linea.IdLineaTiempo
		WHERE
					linea.IdDocumento = @IdDocumento
					AND operacion.IdApp = @IdApp
		ORDER BY	linea.IdLineaTiempo DESC

		SELECT	@TipoFlujo = operacion.IdTipoAprobacion, @IdOperacion = operacion.IdOperacion
		FROM	Adinco.dbo.MA_Operacion operacion
		WHERE
				IdDocumento = @IdDocumento
				AND IdTipoOperacion = @IdTipoOperacion
				AND operacion.IdLineaTiempo = @IdLineaTiempoActual

		IF ( @TipoFlujo = 1 ) --serial
			BEGIN
				INSERT INTO @tablaRetorno
					( Estatus, Mensaje )
				VALUES
					( -1 ,								-- Estatus - int
					  N'Serial no esta configurado aún' -- Mensaje - nvarchar(200)
					)

				SELECT *  FROM @tablaRetorno

				RETURN
			END

		IF ( @TipoFlujo = 2 ) --paralelo
			BEGIN
				--primero reviso cual es el estatus general en caso de no estar en aprobacion, entonces no debe de seguir
				SELECT	@IdEstatusGralTipoOperacion = IdEstatusOperacion
				FROM	Adinco.dbo.MA_Operacion
				WHERE
						IdOperacion = @IdOperacion
						AND IdTipoOperacion = @IdTipoOperacion
						AND IdLineaTiempo = @IdLineaTiempoActual

				IF (   @IdEstatusGralTipoOperacion != 1
					   AND	@IdEstatusGralTipoOperacion IS NOT NULL
					   AND	@IdTipoOperacion = @IdTipoOperacion )
					BEGIN
						INSERT INTO @tablaRetorno
							( Estatus, Mensaje )
						VALUES
							( @IdEstatusGralTipoOperacion ,										-- Estatus - int
							  N'Se encuentra en otro estatus la revision que no es aprobación'	-- Mensaje - nvarchar(200)
							)

						SELECT *  FROM @tablaRetorno

						RETURN
					END
				ELSE
					BEGIN
						IF ( @IdEstatusGralTipoOperacion IS NULL )
							BEGIN
								INSERT INTO @tablaRetorno
									( Estatus, Mensaje )
								VALUES
									( -1 ,										-- Estatus - int
									  N'El estatus de revisión no se encontro'	-- Mensaje - nvarchar(200)
									)

								SELECT *  FROM @tablaRetorno

								RETURN
							END
						ELSE
							BEGIN
								IF ( @IdTipoOperacion = 4 )
									BEGIN
										EXEC @IdEstatusRetorno = dbo.SP_MA_WSSubParaleloActualizarEstatusRevision @IdOperacion = @IdOperacion ,			-- int
																												  @IdUsuarioTarea = @IdUsuarioTarea ,	-- int
																												  @AprobarRechazar = @AprobarRechazar , -- int
																												  @IdTipoOperacion = @IdTipoOperacion , -- int
																												  @IdDocumento = @IdDocumento ,
																												  @IdApp = @IdApp

										SELECT @IdEstatusRetorno  AS retorno, 'Estatus gral'
									END
							END
					END
			END
	END