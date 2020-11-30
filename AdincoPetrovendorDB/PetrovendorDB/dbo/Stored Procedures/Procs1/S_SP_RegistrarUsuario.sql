
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <20-03-2018>
-- Description:	<Se registra un usuario nuevo>
-- =============================================

CREATE procedure [dbo].[S_SP_RegistrarUsuario]
	@EliminarUsuario BIT,
	@Correo VARCHAR(50),
	@Nombre VARCHAR(100),
	@Contrasena VARCHAR(max),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	IF(@EliminarUsuario = 1)
	BEGIN
		UPDATE dbo.S_Usuario
			SET Activo = 0,
				IsEliminado = 1
		WHERE IdUsuario = @IdUsuario 
	END
    
	INSERT INTO dbo.S_Usuario
	(
	    Nombre,
	    Correo,
	    Contrasena,
		Activo,
		IdTipoUsuario,
		IsEliminado,
		CorreoVerificado,
		FechaRegistro,
		NotificacionActualizaciones
	)
	VALUES
	(   @Nombre,       -- Nombre - nvarchar(100)
	    @Correo,       -- Correo - nvarchar(50)
	    @Contrasena,    -- Contrasena - nvarchar(max)
		1,
		3,
		0,
		0,
		GETDATE(),
		1
	)

	SELECT @@IDENTITY
END

--SELECT * FROM dbo.S_TipoUsuario