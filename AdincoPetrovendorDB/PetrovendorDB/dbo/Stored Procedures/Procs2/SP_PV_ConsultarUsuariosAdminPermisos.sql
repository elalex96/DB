-- =============================================
-- Author: Alexander Gomez
-- Create date: 08/03/2018
-- Description:	CONSULTAR USUARIO
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PV_ConsultarUsuariosAdminPermisos]
@IdProveedor  int

AS 

BEGIN

SELECT U.[IdUsuario],U.[Nombre], TU.NombreTipoUsuario AS Rol
FROM S_Usuario AS U
INNER JOIN S_USUARIOPROVEEDOR AS UP ON UP.IDUSUARIO= U.IdUsuario
INNER JOIN S_Proveedor AS P ON P.IDPROVEEDOR = UP.IDPROVEEDOR
LEFT JOIN dbo.S_TipoUsuario AS TU ON TU.IdTipoUsuario = U.IdTipoUsuario
WHERE UP.IdProveedor = @IdProveedor AND U.Activo=1 AND  (u.IsEliminado= 0 OR u.IsEliminado IS NULL) AND U.IdTipoUsuario != 3
GROUP BY U.[IdUsuario],U.[Nombre],TU.NombreTipoUsuario
	
END