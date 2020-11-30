-- =============================================
-- Author: Pedro Acu�a
-- Create date: 21/06/2018
-- Description: obtener la fecha de la aprobacion de pedido por la solicitud de pedido  y la operacion
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaAprobacionPedido
	( @IdOperacion INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaEstatusOperacion DATETIME

		SELECT		@FechaEstatusOperacion
			= MAX ( CASE WHEN TOO.IdEstadoFlujo = 3 THEN t.FechaCambioEstatus ELSE NULL END )
		FROM		TA_Tarea AS T
		INNER JOIN	TA_Operacion AS TOO
			ON TOO.IdOperacion = T.IdOperacion
		INNER JOIN	S_Usuario AS U
			ON u.IdUsuario = T.IdAprobador
		INNER JOIN	TA_Estatus AS TAE
			ON TAE.IdEstatus = T.IdEstatus
		WHERE		TOO.IdOperacion = @IdOperacion

		RETURN @FechaEstatusOperacion
	END