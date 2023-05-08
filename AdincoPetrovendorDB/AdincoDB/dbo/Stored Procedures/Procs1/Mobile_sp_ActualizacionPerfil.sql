
CREATE proc [dbo].[Mobile_sp_ActualizacionPerfil]
@idusuario INT,
@nombre VARCHAR(1000),
@telefono VARCHAR(100),
@tfa BIT 
AS
BEGIN

	UPDATE AP_Usuario
	SET Nombre = @nombre,	
	NumeroCelular = @telefono,
	TFAuthentication = @tfa,
	ModificadoEl =GETDATE(),
	ModificadoPor = @idusuario
	WHERE UsuarioID = @idusuario

	SELECT *
	from AP_Usuario
	WHERE UsuarioID = @idusuario
			
END
