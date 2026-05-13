-- =============================================
-- Author: Pedro Acu�a
-- Create date: 12/06/2018
-- Description: obtener la Fecha de la Orden de Compra
-- =============================================

CREATE FUNCTION Fn_ObtenerFEchaOrdenCompra
	( @IdOperacion INT )
RETURNS @Retorno TABLE
	( IdOperacion INT ,
	  IdUsuario INT ,
	  NoSecuencia INT ,
	  Nombre NVARCHAR(MAX) ,
	  Estatus NVARCHAR(MAX) ,
	  Comentario NVARCHAR(MAX))
AS
	BEGIN
		INSERT INTO @Retorno
			( IdOperacion, IdUsuario, NoSecuencia, Nombre, Estatus, Comentario )
		SELECT		TOO.IdOperacion, U.IdUsuario, T.NoSecuencia, U.Nombre, TAE.Nombre AS estatus ,
					T.Comentario AS Descripcion
		FROM		TA_Tarea AS T
		INNER JOIN	TA_Operacion AS TOO
			ON TOO.IdOperacion = T.IdOperacion
		INNER JOIN	S_Usuario AS U
			ON u.IdUsuario = T.IdAprobador
		INNER JOIN	TA_Estatus AS TAE
			ON TAE.IdEstatus = T.IdEstatus
		WHERE		TOO.IdOperacion = @IdOperacion
		ORDER BY	NoSecuencia ASC

		RETURN
	END