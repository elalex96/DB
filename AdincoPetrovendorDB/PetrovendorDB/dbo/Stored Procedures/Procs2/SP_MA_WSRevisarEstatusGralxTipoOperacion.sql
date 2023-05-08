-- =============================================
-- Author: Pedro Acu�a
-- Create date: 09/05/2018
-- Description: obtener el ultimo estatus gral de la operacion filtrato por el tipo de operacion (Revision, aprobacion)
-- =============================================

CREATE PROCEDURE SP_MA_WSRevisarEstatusGralxTipoOperacion
	( @TipoOperacion INT, @IdDocumento INT, @IdApp INT )
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
					linea.IdDocumento = @IdDocumento
					AND operacion.IdApp = @IdApp
		ORDER BY	linea.IdLineaTiempo ASC

		SELECT	IdEstatusOperacion AS EstatusGral
		FROM	Adinco.dbo.MA_Operacion
		WHERE
				IdDocumento = @IdDocumento
				AND IdLineaTiempo = @IdLineaTiempo
				AND IdTipoOperacion = @TipoOperacion
				AND IdApp = @IdApp
	END
--------------------------------------------------------------------------------------------------------------
