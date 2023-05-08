-- =============================================
-- Author: Pedro Acu�a
-- Create date: 30/04/2018
-- Description: cambio de estatus del detalle y de la cabecera e ingresos al historial para llevar el detalle de los cambios
-- =============================================

CREATE PROCEDURE SP_MA_WSActualizarEstatusRevision @IdDocumento INT, @AprobarRechazar INT, @IdUsuarioTarea INT ,
												   @IdTipoOperacion INT, @IdApp INT
AS
	BEGIN
		SET DATEFORMAT DMY
		DECLARE @IdEstatusRetorno INT, @TipoFlujo INT, @IdEstatusGralTipoOperacion INT, @IdOperacion INT ,
				@CuentaOperacion INT, @IdEstatusRevision INT, @EstatusRevision INT, @EstatusAprobacion INT ,
				@IdLineaTiempoActual INT

		DECLARE @tablaRetorno TABLE
			( Estatus INT ,
			  Mensaje NVARCHAR(200))

		--obtener la ultima linea de la operacion 
		SELECT		TOP 1
					@IdLineaTiempoActual = linea.IdLineaTiempo
		FROM		Adinco.dbo.MA_LineaTiempo linea
		INNER JOIN	Adinco.dbo.MA_Operacion opera
			ON opera.IdDocumento = linea.IdDocumento
			   AND	opera.IdLineaTiempo = linea.IdLineaTiempo
		WHERE
					linea.IdDocumento = @IdDocumento
					AND opera.IdApp = @IdApp
		ORDER BY	linea.IdLineaTiempo DESC

		SELECT	@TipoFlujo = operacion.IdTipoAprobacion, @IdOperacion = operacion.IdOperacion
		FROM	Adinco.dbo.MA_Operacion operacion
		WHERE
				IdDocumento = @IdDocumento
				AND IdTipoOperacion = @IdTipoOperacion
				AND operacion.IdLineaTiempo = @IdLineaTiempoActual
				AND operacion.IdApp = @IdApp

		IF ( @TipoFlujo = 1 ) --serial
			BEGIN
				INSERT INTO @tablaRetorno
					( Estatus, Mensaje )
				VALUES
					( -1 ,								-- Estatus - int
					  N'Serial no esta configurado a�n' -- Mensaje - nvarchar(200)
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
						AND IdApp = @IdApp

				IF (   @IdEstatusGralTipoOperacion != 1
					   AND	@IdEstatusGralTipoOperacion IS NOT NULL
					   AND	@IdTipoOperacion = @IdTipoOperacion )
					BEGIN
						INSERT INTO @tablaRetorno
							( Estatus, Mensaje )
						VALUES
							( @IdEstatusGralTipoOperacion ,										-- Estatus - int
							  N'Se encuentra en otro estatus la revision que no es aprobaci�n'	-- Mensaje - nvarchar(200)
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
									  N'El estatus de revisi�n no se encontro'	-- Mensaje - nvarchar(200)
									)

								SELECT *  FROM @tablaRetorno

								RETURN
							END
						ELSE IF ( @IdTipoOperacion = 3 )
								 --si es de revision
								 BEGIN
									 EXEC @IdEstatusRetorno = dbo.SP_MA_WSSubParaleloActualizarEstatusRevision @IdOperacion = @IdOperacion ,			-- int
																											   @IdUsuarioTarea = @IdUsuarioTarea ,		-- int
																											   @AprobarRechazar = @AprobarRechazar ,	-- int
																											   @IdTipoOperacion = @IdTipoOperacion ,	-- int
																											   @IdDocumento = @IdDocumento,
																											   @IdApp = @IdApp

									 --si fue aprobado y existe otra aprobacion, entonces actualizar la fecha de creacion de la operacion en la aprobacion
									 IF EXISTS
										 (	 SELECT 1
											 FROM	Adinco.dbo.MA_Operacion
											 WHERE
													IdDocumento = @IdDocumento
													AND IdLineaTiempo = @IdLineaTiempoActual
													AND IdTipoOperacion = 4 --aprobacion
													AND IdApp = @IdApp
									 )
										 BEGIN
											 UPDATE operacion
											 SET	operacion.FechaRegistro = GETDATE ()
											 FROM	Adinco.dbo.MA_Operacion operacion
											 WHERE
													IdDocumento = @IdDocumento
													AND IdLineaTiempo = @IdLineaTiempoActual
													AND IdTipoOperacion = 4 --aprobacion
													AND	operacion.IdApp = @IdApp
										 END
								 END

						IF ( @IdTipoOperacion = 4 )
							BEGIN
								SELECT	@IdEstatusRevision = operacion.IdEstatusOperacion
								FROM	Adinco.dbo.MA_Operacion operacion
								WHERE
										operacion.IdDocumento = @IdDocumento
										AND operacion.IdTipoOperacion = 3
										AND operacion.IdLineaTiempo = @IdLineaTiempoActual
										AND operacion.IdApp = @IdApp

								--revision

								--si la revision ya fue aprobada
								IF ( @IdEstatusRevision = 2 )
									BEGIN
										EXEC @IdEstatusRetorno = dbo.SP_MA_WSSubParaleloActualizarEstatusRevision @IdOperacion = @IdOperacion ,			-- int
																												  @IdUsuarioTarea = @IdUsuarioTarea ,	-- int
																												  @AprobarRechazar = @AprobarRechazar , -- int
																												  @IdTipoOperacion = @IdTipoOperacion , -- int
																												  @IdDocumento = @IdDocumento,
																												  @IdApp = @IdApp
									END
								ELSE
									BEGIN
										INSERT INTO @tablaRetorno
											( Estatus, Mensaje )
										VALUES
											( @IdEstatusRevision ,									-- Estatus - int
											  N'El Estatus de la revisi�n aun no ah sido aprobada'	-- Mensaje - nvarchar(200)
											)

										SELECT *  FROM @tablaRetorno

										RETURN
									END
							END

						SELECT	@CuentaOperacion = COUNT ( IdEstatusOperacion )
						FROM	Adinco.dbo.MA_Operacion
						WHERE
								IdDocumento = @IdDocumento
								AND IdLineaTiempo = @IdLineaTiempoActual
								AND IdApp = @IdApp

						IF ( @IdTipoOperacion = 3 ) --revision
							BEGIN
								SELECT	IdEstatusOperacion, 'Revisi�n'
								FROM	Adinco.dbo.MA_Operacion
								WHERE
										IdOperacion = IdOperacion
										AND IdTipoOperacion = @IdTipoOperacion
										AND IdLineaTiempo = @IdLineaTiempoActual
										AND IdApp = @IdApp
							END
						ELSE
							BEGIN
								SELECT	@EstatusRevision = IdEstatusOperacion
								FROM	Adinco.dbo.MA_Operacion
								WHERE
										IdDocumento = @IdDocumento
										AND IdTipoOperacion = 3
										AND IdLineaTiempo = @IdLineaTiempoActual
										AND IdApp = @IdApp

								SELECT	@EstatusAprobacion = IdEstatusOperacion
								FROM	Adinco.dbo.MA_Operacion
								WHERE
										IdDocumento = @IdDocumento
										AND IdTipoOperacion = 4
										AND IdLineaTiempo = @IdLineaTiempoActual
										AND IdApp = @IdApp

								IF ( @CuentaOperacion > 2 )
									BEGIN
										IF EXISTS
											(	SELECT	IdEstatusOperacion
												FROM	Adinco.dbo.MA_Operacion
												WHERE
														IdOperacion = IdOperacion
														AND IdEstatusOperacion = 3
														AND IdLineaTiempo = @IdLineaTiempoActual
														AND IdApp = @IdApp ) --cancelado
											BEGIN
												SELECT 3 , 'Cancelado'	--retorna cancelado
											END
										ELSE -- si no existe 
											BEGIN
												IF ( @EstatusRevision = 2 AND @EstatusAprobacion   = 2 )
													BEGIN
														SELECT 2 , 'Aprobado'
													END
												ELSE
													SELECT	@EstatusRevision AS estatusRevision ,
															@EstatusAprobacion AS estatusAprobacion
											END
									END
								ELSE
									BEGIN
										IF ( @EstatusRevision = 2 AND @EstatusAprobacion   = 2 )
											BEGIN
												SELECT 2 , 'Aprobado'
											END
										ELSE
											SELECT	@EstatusRevision AS estatusRevision ,
													@EstatusAprobacion AS estatusAprobacion
									END
							END
					END
			END
	END

