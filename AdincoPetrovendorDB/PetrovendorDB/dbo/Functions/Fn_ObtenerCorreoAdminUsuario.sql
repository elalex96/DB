CREATE FUNCTION dbo.Fn_ObtenerCorreoAdminUsuario
(
	@IdProveedor INT
)
RETURNS NVARCHAR(250)
AS
BEGIN
DECLARE @Correo VARCHAR(250)
-- OBTENER SOLO UN CORREO PARA MOSTRAR EN LA VISTA DE JAGUAR
	SELECT
		@Correo	=	LTRIM(RTRIM(U.Correo))
	FROM
		dbo.S_UsuarioProveedor	UP	(NOLOCK)
	JOIN
		S_Usuario				U	(NOLOCK)
		ON	UP.IdUsuario	=	U.IdUsuario
		AND UP.IdProveedor = @IdProveedor
		AND U.IsEliminado	=	0
		AND UP.IsAdmin		=	1

	IF @Correo IS NULL
	BEGIN
		SELECT
			@Correo	=	LTRIM(RTRIM(U.Correo))
		FROM
			dbo.S_UsuarioProveedor	UP	(NOLOCK)
		JOIN
			S_Usuario				U	(NOLOCK)
			ON	UP.IdUsuario	=	U.IdUsuario
			AND UP.IdProveedor = @IdProveedor
			AND	U.IsEliminado	=	0
			AND U.IdTipoUsuario	IN (3, 4)		-- Administrador, Ventas
	END
									
	RETURN @Correo

END
