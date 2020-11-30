
CREATE procedure [dbo].[AD_SP_UpdateUsuarios]
	@IdUsuario INT,
	@Correo NVARCHAR(max),
	@Activo BIT,
	@IdTipoUsuario INT,
	@IsEliminado BIT,
	@IdUsuarioADINCO INT = NULL,
	@Nombre NVARCHAR(MAX),
	@IdUsuarioProveedor INT,
	@CorreoVerificado bit

AS
BEGIN
	UPDATE dbo.S_Usuario
		SET Correo = @Correo,
			Activo = @Activo,
			Nombre = @Nombre,
			IdTipoUsuario = @IdTipoUsuario,
			IsEliminado = @IsEliminado,
			IdUsuarioADINCO = @IdUsuarioADINCO,
			CorreoVerificado = @CorreoVerificado
		WHERE IdUsuario = @IdUsuario
END

