
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <29/10/2018>
-- Description:	<Se consultan los usuarios de un proveedor para notificar la carga de materiales o servicios>
-- =============================================
-- Author:		<Marcos Neri>
-- Create date: <29/04/2019>
-- Description:	<Se modifica el valor de up.IdProveedor y up.IdContrato para que no seleccione correos >
-- =============================================

CREATE PROCEDURE [dbo].[MM_SP_ConsultarUsuariosPorProveedor]	--420,3
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN


	SELECT u.IdUsuario,
		u.Nombre,
		u.Correo
	FROM dbo.S_Usuario u
	INNER JOIN dbo.S_UsuarioProveedor up ON up.IdUsuario = u.IdUsuario
	WHERE up.IdProveedor = 0 --@IdProveedor
		AND up.IdContrato = 0  --@IdContrato
		AND u.Activo = 1
		AND ISNULL(u.IsEliminado, 0) = 0 
		AND u.IdTipoUsuario IS NOT NULL
END