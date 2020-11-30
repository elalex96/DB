-- =============================
-- Author:		Pedro Acuña
-- Create date: 13-11-2018
-- Description: Funcion para retornar los aprobadores concatenados filtrados por operacion
-- =============================================

CREATE FUNCTION FN_AprobadoresDePedidoPorOperacion
	( @IdOperacion INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @Aprobadores NVARCHAR(MAX)

		SELECT		@Aprobadores = COALESCE ( @Aprobadores + ', ', '' ) + u.Nombre
		FROM		TA_Tarea AS T
		INNER JOIN	TA_Operacion AS TOO
			ON TOO.IdOperacion = T.IdOperacion
		INNER JOIN	S_Usuario AS U
			ON u.IdUsuario = T.IdAprobador
		INNER JOIN	TA_Estatus AS TAE
			ON TAE.IdEstatus = T.IdEstatus
		WHERE		TOO.IdOperacion = @IdOperacion
		ORDER BY	NoSecuencia ASC

		RETURN @Aprobadores
	END
