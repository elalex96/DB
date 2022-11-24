-- =============================================
-- Author: DANIEL AC
-- Create date: 31/08/2017
-- Description:	CONSULTAR USUARIO
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PV_ConsultarUsuario]
@IdUsuario int

AS
 

BEGIN

SELECT U.[IdUsuario],U.[Activo],U.[IdTipoUsuario],U.[Correo],U.[Contrasena],U.[Nombre]
FROM S_Usuario AS U
INNER JOIN S_USUARIOPROVEEDOR AS UP ON UP.IDUSUARIO= U.IdUsuario
INNER JOIN S_Proveedor AS P ON P.IDPROVEEDOR = UP.IDPROVEEDOR
WHERE U.IdUsuario = @IdUsuario
	
END


