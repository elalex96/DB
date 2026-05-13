-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_AD_ActualizarUsuario]
@IdUsuario int,
@Nombre nvarchar(max),
@IdTipoUsuario int, 
@Telefono nvarchar(max),
@Correo nvarchar(max),
@Contrasena nvarchar(max),
@Activo bit

AS
 

BEGIN



UPDATE S_Usuario
SET Nombre = @Nombre,
Contrasena=@Contrasena,
Activo=@Activo,
Correo=@Correo,
Telefono = @Telefono,
IdTipoUsuario=@IdTipoUsuario
WHERE IdUsuario = @IdUsuario

 	
END


