-- =============================================
-- Author: Pedro Acu�a
-- Create date: 04/05/2018
-- Description: subproceso de aprobacion, sirve para cambiar los estatus de los aprobadores y el estatus general siempre y cuando sea paralelo 
-- =============================================

CREATE PROCEDURE SP_MA_WSSubParaleloActualizarEstatusRevision @IdOperacion INT, @IdUsuarioTarea INT ,
															  @AprobarRechazar INT, @IdTipoOperacion INT ,
															  @IdDocumento INT, @IdApp INT
AS
	BEGIN
		SET DATEFORMAT DMY
		DECLARE @IdAprobador INT, @IdEstatusReturn INT, @IdLineaTiempoActual INT

		DECLARE @AprobadoresEstatus TABLE
			( Id INT IDENTITY ,
			  IdEstatus INT )

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

		-- se busca al aprobador
		SELECT	@IdAprobador = aprobador.IdAprobador
		FROM	Adinco.dbo.MA_Aprobador aprobador
		WHERE
				aprobador.IdOperacion = @IdOperacion
				AND aprobador.IdUsuario = @IdUsuarioTarea
				AND aprobador.IdLineaTiempo = @IdLineaTiempoActual

		IF ( @IdAprobador IS NOT NULL ) --si se encontro al aprobador
			BEGIN
				--guardo el historial y actualizo al nuevo valor
				INSERT INTO Adinco.dbo.MA_HistorialOperacionDetalle
					( IdOperacionDetalle, IdAprobador, IdLineaTiempo, IdEstatus, Comentario, FechaRegistro ,
					  FechaCambioEstatus , Activo, NoSecuencia, IdOperacion, IsEliminado, IdFirma, IdContrato ,
					  IdSubcontratista )
				SELECT	IdOperacionDetalle, IdAprobador, IdLineaTiempo, IdEstatus, Comentario, FechaRegistro ,
						FechaCambioEstatus , Activo, NoSecuencia, IdOperacion, IsEliminado, IdFirma, IdContrato ,
						IdSubcontratista
				FROM	Adinco.dbo.MA_OperacionDetalle detalle
				WHERE
						detalle.IdAprobador = @IdAprobador
						AND detalle.IdOperacion = @IdOperacion
						AND detalle.IdLineaTiempo = @IdLineaTiempoActual

				UPDATE	detalle
				SET		detalle.IdEstatus = @AprobarRechazar, detalle.FechaCambioEstatus = GETDATE ()
				FROM	Adinco.dbo.MA_OperacionDetalle detalle
				WHERE
						detalle.IdAprobador = @IdAprobador
						AND detalle.IdOperacion = @IdOperacion
						AND detalle.IdLineaTiempo = @IdLineaTiempoActual

				--Si el estatus fue rechazado entonces guardo en el historico y actualizo la tabla operacion
				IF ( @AprobarRechazar = 3 ) --Rechazado
					BEGIN
						INSERT INTO Adinco.dbo.MA_HistorialOperacion
							( IdOperacion, IdDocumento, IdLineaTiempo, IdEstatusOperacion, IdUsuarioRegistro ,
							  FechaRegistro , FechaModificacion, ModificadoPor )
						SELECT	IdOperacion, IdDocumento, IdLineaTiempo, IdEstatusOperacion, IdUsuarioRegistro ,
								FechaRegistro , FechaModificacion, ModificadoPor
						FROM	Adinco.dbo.MA_Operacion opera
						WHERE
								opera.IdOperacion = @IdOperacion
								AND opera.IdTipoOperacion = @IdTipoOperacion
								AND opera.IdLineaTiempo = @IdLineaTiempoActual
								AND opera.IdApp = @IdApp

						UPDATE	opera
						SET		opera.IdEstatusOperacion = @AprobarRechazar, opera.ModificadoPor = @IdUsuarioTarea ,
								opera.FechaModificacion = GETDATE ()
						FROM	Adinco.dbo.MA_Operacion opera
						WHERE
								opera.IdOperacion = @IdOperacion
								AND opera.IdTipoOperacion = @IdTipoOperacion
								AND opera.IdLineaTiempo = @IdLineaTiempoActual
								AND opera.IdApp = @IdApp
					END
				ELSE
					--guardo en una tabla temporal los aprobadores con su estatus
					BEGIN
						INSERT INTO @AprobadoresEstatus
							( IdEstatus )
						SELECT		detalle.IdEstatus
						FROM		Adinco.dbo.MA_OperacionDetalle detalle
						INNER JOIN	Adinco.dbo.MA_Aprobador aprobador
							ON aprobador.IdAprobador = detalle.IdAprobador
						WHERE
									detalle.IdOperacion = @IdOperacion
									AND aprobador.IdTipoOperacion = @IdTipoOperacion
									AND detalle.IdLineaTiempo = @IdLineaTiempoActual

						--Si todos son aprobados entonces actualizo el estatus general, pero primero lo guardo en el historico
						IF NOT EXISTS ( SELECT 1  FROM @AprobadoresEstatus WHERE IdEstatus	  != 2 ) --aprobado 
							BEGIN
								INSERT INTO Adinco.dbo.MA_HistorialOperacion
									( IdOperacion, IdDocumento, IdLineaTiempo, IdEstatusOperacion, IdUsuarioRegistro ,
									  FechaRegistro , FechaModificacion, ModificadoPor )
								SELECT	operacion.IdOperacion, operacion.IdDocumento, operacion.IdLineaTiempo ,
										operacion.IdEstatusOperacion, operacion.IdUsuarioRegistro ,
										operacion.FechaRegistro, operacion.FechaModificacion, operacion.ModificadoPor
								FROM	Adinco.dbo.MA_Operacion operacion
								WHERE
										operacion.IdOperacion = @IdOperacion
										AND operacion.IdTipoOperacion = @IdTipoOperacion
										AND operacion.IdLineaTiempo = @IdLineaTiempoActual
										AND operacion.IdApp = @IdApp

								UPDATE	operacion
								SET		operacion.IdEstatusOperacion = 2, operacion.FechaModificacion = GETDATE () ,
										operacion.ModificadoPor = @IdUsuarioTarea
								FROM	Adinco.dbo.MA_Operacion operacion
								WHERE
										operacion.IdOperacion = @IdOperacion
										AND operacion.IdTipoOperacion = @IdTipoOperacion
										AND operacion.IdLineaTiempo = @IdLineaTiempoActual
										AND operacion.IdApp = @IdApp
							END
					END

				SELECT	@IdEstatusReturn = IdEstatusOperacion
				FROM	Adinco.dbo.MA_Operacion
				WHERE
						IdOperacion = @IdOperacion
						AND IdTipoOperacion = @IdTipoOperacion
						AND IdLineaTiempo = @IdLineaTiempoActual
						AND IdApp = @IdApp

				RETURN @IdEstatusReturn
			END
		ELSE BEGIN
				 SELECT -1, 'No se encontro al aprobador'
			END
	END
--------------------------------------------------------------------------------------------------------------
