USE [Adinco]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Mobile_sp_ActualizacionPerfil'
)
    DROP PROCEDURE Mobile_sp_ActualizacionPerfil;

/****** Object:  StoredProcedure [dbo].[sp_CentroCostoFiltro_Grd]    Script Date: 13/07/2021 01:17:22 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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

