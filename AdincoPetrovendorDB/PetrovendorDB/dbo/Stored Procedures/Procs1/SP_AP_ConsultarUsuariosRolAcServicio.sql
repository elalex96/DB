-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <Consulta la lista de usuarios con rol de "Aceptación de servicio">
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_AP_ConsultarUsuariosRolAcServicio --420,3
@IdProveedor INT,
@IdContrato INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT U.IdUsuario AS Asignado,U.Nombre FROM dbo.S_UsuarioRol UR
	LEFT JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = UR.IdUsuario
	LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = UP.IdUsuario
	WHERE UP.IdProveedor = @IdProveedor 
	AND ISNULL(U.IsEliminado,0) = 0
	AND UP.IdContrato = @IdContrato
	AND UR.IdRol = 8 -- aceptación servicio



END
