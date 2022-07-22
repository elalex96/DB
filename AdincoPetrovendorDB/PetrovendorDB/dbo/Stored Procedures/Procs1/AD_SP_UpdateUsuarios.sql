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
			CorreoVerificado = @CorreoVerificado,
			IsEliminado = CASE 
					WHEN @Activo = 1 THEN 0
                            		ELSE 1
                        	      END
		WHERE IdUsuario = @IdUsuario

	

END

