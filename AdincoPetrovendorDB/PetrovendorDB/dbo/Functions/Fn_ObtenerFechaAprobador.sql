-- =============================================
-- Author: Pedro Acuña
-- Create date: 21/06/2018
-- Description: obtener la fecha de la aprobacion del pedido por numero de aprobador
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaAprobador
	( @IdOperacion INT ,
	  @NumAprobador INT )
RETURNS DATETIME
AS
	BEGIN
		DECLARE @FechaAprobacion DATETIME

		SELECT		@FechaAprobacion = T.FechaCambioEstatus
		FROM		TA_Tarea AS T
		INNER JOIN	TA_Operacion AS TOO
			ON TOO.IdOperacion = T.IdOperacion
		INNER JOIN	S_Usuario AS U
			ON u.IdUsuario = T.IdAprobador
		INNER JOIN	TA_Estatus AS TAE
			ON TAE.IdEstatus = T.IdEstatus
		WHERE
					TOO.IdOperacion = @IdOperacion
					AND T.NoSecuencia = @NumAprobador

		RETURN @FechaAprobacion
	END