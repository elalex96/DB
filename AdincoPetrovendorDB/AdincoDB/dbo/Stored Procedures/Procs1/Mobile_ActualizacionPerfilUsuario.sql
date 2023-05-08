CREATE PROCEDURE [dbo].[Mobile_ActualizacionPerfilUsuario]
@Nombre VARCHAR(50),
@Contrasenia VARCHAR(50),
@Telefono VARCHAR(50),
@TFA BIT,
@IdUsuario INT 
AS
BEGIN
UPDATE dbo.AP_Usuario
SET Nombre = @Nombre,
Contraseña = @Contrasenia,
NumeroCelular = @Telefono,
TFAuthentication = @TFA
WHERE UsuarioID = @IdUsuario
END
