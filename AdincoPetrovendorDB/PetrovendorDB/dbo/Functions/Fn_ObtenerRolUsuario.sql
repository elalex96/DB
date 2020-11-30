-- =============================================
-- Author: Pedro Acu�a
-- Create date: 13/08/2018
-- Description: obtener los roles separados por comas del usuario
-- =============================================

CREATE FUNCTION Fn_ObtenerRolUsuario
	( @IdProveedor INT ,
	  @IdUsuario INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @Retorno NVARCHAR(MAX)

		SELECT	@Retorno =
			( SELECT	STUFF (
							(	SELECT		CAST(' ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), R.IdRol )
								FROM		S_Usuario AS U
								INNER JOIN	S_USUARIOPROVEEDOR AS UP
									ON UP.IDUSUARIO = U.IdUsuario
								INNER JOIN	S_Proveedor AS P
									ON P.IDPROVEEDOR = UP.IDPROVEEDOR
								INNER JOIN	S_UsuarioRol AS UR
									ON UR.IdUsuario = U.IdUsuario
								INNER JOIN	S_Rol AS R
									ON R.IdRol = UR.IdRol
								WHERE
											UP.IdProveedor = @IdProveedor
											AND U.IdUsuario = @IdUsuario
											AND UR.Activo = 1
								ORDER BY	R.IdRol
								FOR XML PATH ( '' )), 1, 1, '' ) AS IdRol )

		RETURN @Retorno
	END