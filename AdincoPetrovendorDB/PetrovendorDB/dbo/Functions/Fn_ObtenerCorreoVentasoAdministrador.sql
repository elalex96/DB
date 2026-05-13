-- =============================================
-- Author: Pedro Acuña
-- Create date: 05/11/2018
-- Description: obtener el correo del usuario de ventas o en caso de no existir el del administrador
-- =============================================

CREATE FUNCTION Fn_ObtenerCorreoVentasoAdministrador
	( @IdProveedor INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		SELECT		TOP 1
					@retorno = u.Correo
		FROM		dbo.S_Usuario u
		INNER JOIN	dbo.S_UsuarioProveedor uProv
			ON uProv.IdUsuario = u.IdUsuario
		WHERE
					u.IdTipoUsuario IN ( 4, 3 ) --ventas o administrador
					AND u.Activo = 1
					AND ISNULL ( u.IsEliminado, 0 ) = 0
					AND uProv.IdProveedor = @IdProveedor
					AND u.Correo <> ''
		ORDER BY	u.IdTipoUsuario DESC

		RETURN @retorno
	END