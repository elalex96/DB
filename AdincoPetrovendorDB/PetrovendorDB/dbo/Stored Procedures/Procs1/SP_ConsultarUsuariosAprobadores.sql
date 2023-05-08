-- =============================================
-- Author:		<Jose Roman>
-- Create date: <21-08-2018>
-- Description:	<Se consultan los usuarios aprobadores para las notificaciones SMS>
-- =============================================

create PROCEDURE SP_ConsultarUsuariosAprobadores	
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN

	SELECT u.IdUsuario, u.Nombre
	FROM dbo.S_Usuario u
	INNER JOIN dbo.S_UsuarioProveedor up ON up.IdUsuario = u.IdUsuario
	INNER JOIN dbo.S_UsuarioRol ur ON ur.IdUsuario = u.IdUsuario
	WHERE up.IdProveedor = @IdProveedor
		AND u.Activo = 1
		AND ur.Activo = 1
		AND ur.IdRol IN (1,2,4,5,7)
		AND up.IdContrato = @IdContrato
	GROUP BY u.IdUsuario, u.Nombre

END
