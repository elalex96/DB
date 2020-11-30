-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Description:	Regresa todos los usuarios activos de un proveedor 
-- Actualización filtro solo usuario con rol de aprobación de pedido Activo
-- Update 30/08/2017
-- ============================================
CREATE   PROCEDURE [dbo].[SP_TA_UsuariosProveedor]
	-- Add the parameters for the stored procedure here
	 @IdProveedor int, 
	 @IdRol int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 --SELECT U.IdUsuario, Nombre +'/'+TU.NombreTipoUsuario AS Nombre, U.Correo
	 --FROM S_Usuario AS U
	 --INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario=U.IdTipoUsuario
	 --INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=U.IdUsuario
	 --INNER JOIN S_Proveedor  AS P on P.IdProveedor = UP.IdProveedor	 
	 --WHERE  U.Activo=1 AND P.IdProveedor = @IdProveedor 
	 --ORDER BY Nombre
	 
	 SELECT   distinct  U.IdUsuario, Nombre +'/'+TU.NombreTipoUsuario AS Nombre, U.Correo, Nombre AS NombreAprobador
	 FROM S_Usuario AS U
	 INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario=U.IdTipoUsuario
	 INNER JOIN S_UsuarioRol AS UR ON UR.IdUsuario = U.IdUsuario
	 INNER JOIN S_Rol AS R ON R.IdRol = UR.IdRol
	 INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=U.IdUsuario
	 INNER JOIN S_Proveedor  AS P on P.IdProveedor = UP.IdProveedor	 
	 WHERE  U.Activo=1 AND P.IdProveedor = @IdProveedor AND UR.IdRol =@IdRol AND UR.Activo=1
	 ORDER BY Nombre
	 
END