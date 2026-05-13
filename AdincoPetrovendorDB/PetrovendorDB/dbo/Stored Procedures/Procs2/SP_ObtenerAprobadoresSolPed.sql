-- =============================================
-- Author:	Pedro Acuña
-- Create date: 20-07-2018
-- Description:	SP que obtiene los nombres de los aprobadores de la solicitud de pedido por operacion 
-- =============================================

CREATE PROCEDURE SP_ObtenerAprobadoresSolPed @IdOperacion INT
AS
	BEGIN
		SELECT		U.Nombre AS NomUsuario, T.NoSecuencia, e.Nombre, u.Correo
		FROM		dbo.TA_Tarea T
		INNER JOIN	dbo.S_Usuario U
			ON T.IdAprobador = U.IdUsuario
		INNER JOIN	dbo.TA_Estatus E
			ON E.IdEstatus = T.IdEstatus
		WHERE
					T.Activo = 1
					AND ISNULL ( IdEstatusEliminado, 0 ) = 0
					AND IdOperacion = @IdOperacion
		ORDER BY	T.NoSecuencia
	END