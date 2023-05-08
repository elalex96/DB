-- =============================================
-- Author: Pedro Acu�a
-- Create date: 12/06/2018
-- Description: obtener la ultima fecha de modificacion
-- =============================================

CREATE FUNCTION Fn_ObtenerUltimaFechaTareaModificacion
	( @IdOperacion INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @UltimaFechaModificada DATETIME

		SELECT		TOP 1
					@UltimaFechaModificada = CASE WHEN T.FechaCambioEstatus IS NULL THEN
													  T.FechaRegistro
											 ELSE
												 T.FechaCambioEstatus
											 END
		FROM		dbo.TA_TareaOperacion TAO
		INNER JOIN	dbo.TA_Tarea T
			ON T.IdTarea = TAO.IdTarea
		WHERE		T.IdOperacion = @IdOperacion
		ORDER BY	T.FechaCambioEstatus DESC

		RETURN @UltimaFechaModificada
	END