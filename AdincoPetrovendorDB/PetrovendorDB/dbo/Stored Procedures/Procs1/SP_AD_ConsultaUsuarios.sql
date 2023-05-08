-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_AD_ConsultaUsuarios]
@IdProveedor int

AS
 

BEGIN

SELECT u.IdUsuario, [Nombre],[Correo],[Contrasena],U.[IdTipoUsuario],U.[Activo],u.[Telefono]
FROM S_Usuario AS U
INNER JOIN S_USUARIOPROVEEDOR AS UP ON UP.IDUSUARIO= U.IdUsuario
INNER JOIN S_Proveedor AS P ON P.IDPROVEEDOR = UP.IDPROVEEDOR
WHERE P.IDPROVEEDOR = @IdProveedor
	
END


