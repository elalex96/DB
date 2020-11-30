-- ============================================= 
-- Author:		Pedro Acu�a
-- Create date: 11/Jun/2018
-- Description:	se obtienen los usuarios para que puedan ser seleccioandos para que no sean notificados
-- =============================================

CREATE PROCEDURE SP_ListaNoNotificacion @IdProveedor INT
AS
	BEGIN
		SELECT		U.IdUsuario, U.Nombre, U.Correo
		FROM		S_Usuario AS U
		LEFT JOIN	S_TipoUsuario AS TU
			ON TU.IdTipoUsuario = U.IdTipoUsuario
		LEFT JOIN	S_UsuarioRol AS UR
			ON UR.IdUsuario = U.IdUsuario
		LEFT JOIN	S_Rol AS R
			ON R.IdRol = UR.IdRol
		LEFT JOIN	S_UsuarioProveedor AS UP
			ON UP.IdUsuario = U.IdUsuario
			   AND	UP.IdUsuario = UR.IdUsuario
		LEFT JOIN	S_Proveedor AS P
			ON P.IdProveedor = UP.IdProveedor
		WHERE
					U.Activo = 1
					AND UR.Activo = 1
					AND P.IdProveedor = @IdProveedor
		GROUP BY	U.IdUsuario, U.Nombre, U.Correo
	END