-- =============================================
-- Author: DANIEL AC
-- Create date: 31/08/2017
-- Description:	CONSULTAR USUARIO ROL
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PV_ConsultarRolUsuario]
@IdProveedor  int,
@IdUsuario int 
AS 

BEGIN

SELECT  R.IdRol, R.Rol 
FROM S_Usuario AS U
INNER JOIN S_USUARIOPROVEEDOR AS UP ON UP.IDUSUARIO= U.IdUsuario
INNER JOIN S_Proveedor AS P ON P.IDPROVEEDOR = UP.IDPROVEEDOR
INNER JOIN S_UsuarioRol AS UR ON UR.IdUsuario= U.IdUsuario
INNER JOIN S_Rol AS R ON R.IdRol = UR.IdRol
WHERE UP.IdProveedor = @IdProveedor   AND U.IdUsuario= @IdUsuario AND UR.Activo=1

	
END


