USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[AD_SP_UpdateUsuarios]    Script Date: 21/07/2022 11:00:26 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER procedure [dbo].[AD_SP_UpdateUsuarios]
	@IdUsuario INT,
	@Correo NVARCHAR(max),
	@Activo BIT,
	@IdTipoUsuario INT,
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
			IdUsuarioADINCO = @IdUsuarioADINCO,
			CorreoVerificado = @CorreoVerificado
		WHERE IdUsuario = @IdUsuario

	IF @Activo = 0
	BEGIN
		
		UPDATE dbo.S_Usuario
		SET IsEliminado = 1
		WHERE IdUsuario = @IdUsuario
		
	END
	ELSE
	BEGIN
		UPDATE dbo.S_Usuario
		SET IsEliminado = 0
		WHERE IdUsuario = @IdUsuario
	END
	

END

