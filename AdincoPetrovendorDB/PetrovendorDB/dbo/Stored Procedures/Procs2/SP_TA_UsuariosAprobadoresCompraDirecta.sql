-- =============================================
-- Author:		Pedro Acuña
-- Create date: 01/09/2017
-- Description:	Regresa todos los usuarios activos de un proveedor 
-- =============================================
	CREATE   PROCEDURE [dbo].[SP_TA_UsuariosAprobadoresCompraDirecta] 
	-- Add the parameters for the stored procedure here
	 @IdProveedor int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT U.IdUsuario, Nombre +'/'+TU.NombreTipoUsuario AS Nombre, U.Correo
	 FROM S_Usuario AS U
	 INNER JOIN S_TipoUsuario AS TU ON TU.IdTipoUsuario=U.IdTipoUsuario
	 INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario=U.IdUsuario
	 INNER JOIN S_Proveedor  AS P on P.IdProveedor = UP.IdProveedor
	 INNER JOIN S_UsuarioRol AS UR ON UR.IdUsuario = U.IdUsuario
	 INNER JOIN S_Rol AS R ON R.IdRol = UR.IdRol
	 WHERE  U.Activo=1 AND u.IsEliminado= 0 AND R.IdRol = 5  AND ur.Activo=1  AND	P.IdProveedor = @IdProveedor
	 ORDER BY Nombre
	
END
