-- =============================================
-- Author: Pedro Acu�a
-- Create date: 18/05/2018
-- Description: actualizar el comentario del rechazo
-- =============================================

CREATE PROCEDURE SP_MA_WSActualizarComentarioRechazo @IdDocumento INT, @ComentarioRechazo NVARCHAR(MAX), @IdApp INT ,
													 @IdTipoOperacion INT
AS
	BEGIN
		SET DATEFORMAT DMY
		DECLARE @IdLineaTiempo INT

		SELECT		@IdLineaTiempo = linea.IdLineaTiempo
		FROM		Adinco.dbo.MA_LineaTiempo linea
		INNER JOIN	Adinco.dbo.MA_Operacion operacion
			ON operacion.IdDocumento = linea.IdDocumento
			   AND	operacion.IdLineaTiempo = linea.IdLineaTiempo
		WHERE
					operacion.IdDocumento = @IdDocumento
					AND operacion.IdApp = @IdApp
					AND operacion.IdTipoOperacion = @IdTipoOperacion

		UPDATE		linea
		SET			linea.ComentarioRechazo = @ComentarioRechazo
		FROM		Adinco.dbo.MA_LineaTiempo linea
		INNER JOIN	Adinco.dbo.MA_Operacion operacion
			ON operacion.IdDocumento = linea.IdDocumento
			   AND	operacion.IdLineaTiempo = linea.IdLineaTiempo
		WHERE
					linea.IdDocumento = @IdDocumento
					AND operacion.IdApp = @IdApp
					AND linea.IdLineaTiempo = @IdLineaTiempo
	END
--------------------------------------------------------------------------------------------------------------
