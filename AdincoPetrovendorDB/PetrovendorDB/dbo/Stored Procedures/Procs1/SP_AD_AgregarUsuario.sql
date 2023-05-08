-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_AD_AgregarUsuario]
@IdProveedor int,
@Nombre nvarchar(max),
@IdTipoUsuario int, 
@Telefono nvarchar(max),
@Correo nvarchar(max),
@Contrasena nvarchar(max),
@Activo bit

AS
 

BEGIN

DECLARE @IDUSUARIO INT

INSERT INTO S_Usuario(Nombre,Contrasena,Activo,Correo,FechaActivacion,FechaRegistro, IdTipoUsuario)
VALUES(@Nombre,@Contrasena,@Activo,@Correo,GETDATE(),GETDATE(),@IdTipoUsuario)

SET @IDUSUARIO = (SELECT @@IDENTITY)

INSERT INTO S_UsuarioProveedor(IdProveedor,IdUsuario,IsAdmin)
VALUES(@IdProveedor,@IDUSUARIO,0)


	
END


