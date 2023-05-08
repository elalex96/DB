-- =============================================
-- Author: Pedro Acu�a
-- Create date: 30/04/2018
-- Description: traer los datos para enviar el correo del cambio de estatus
-- =============================================
--string nombreInstancia, string nombreUsuario, int idEstatus, string verDetalle, int tipoCorreo, string destinatario, int tipoAprobacion, int idDocumento, int idUsuario

CREATE PROCEDURE SP_MA_WSObtenerDatosCambioEstatus @IdDocumento INT, @IdTipoOperacion INT, @IdApp INT
AS
	BEGIN
		SET DATEFORMAT DMY
		DECLARE @IdLineaTiempo INT

		SELECT		TOP 1
					@IdLineaTiempo = linea.IdLineaTiempo
		FROM		Adinco.dbo.MA_LineaTiempo linea
		INNER JOIN	Adinco.dbo.MA_Operacion operacion
			ON operacion.IdDocumento = linea.IdDocumento
			   AND	operacion.IdLineaTiempo = linea.IdLineaTiempo
		WHERE
					linea.IdDocumento = @IdDocumento
					AND operacion.IdApp = @IdApp
		ORDER BY	linea.IdLineaTiempo DESC

		SELECT		operacion.ComentarioGral, aprobador.NombreUsuario, aprobador.EnlaceDetalle, aprobador.Correo ,
					aprobador.IdUsuario, aprobador.CreadoPor, aprobador.EnlaceAprobado, aprobador.EnlaceRechazo ,
					operacion.NombreInstancia
		FROM		Adinco.dbo.MA_Operacion operacion
		INNER JOIN	Adinco.dbo.MA_OperacionDetalle detalle
			ON detalle.IdLineaTiempo = operacion.IdLineaTiempo
			   AND	detalle.IdOperacion = operacion.IdOperacion
		INNER JOIN	Adinco.dbo.MA_Aprobador aprobador
			ON aprobador.IdAprobador = detalle.IdAprobador
			   AND	aprobador.IdLineaTiempo = operacion.IdLineaTiempo
		WHERE
					operacion.IdDocumento = @IdDocumento
					AND operacion.IdTipoOperacion = @IdTipoOperacion
					AND operacion.IdLineaTiempo = @IdLineaTiempo
					AND operacion.IdApp = @IdApp
	END
--------------------------------------------------------------------------------------------------------------
