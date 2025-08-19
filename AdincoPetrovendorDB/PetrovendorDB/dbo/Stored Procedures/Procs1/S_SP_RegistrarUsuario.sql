USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[S_SP_RegistrarUsuario]    Script Date: 05/08/2025 04:41:03 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <20-03-2018>
-- Description:	<Se registra un usuario nuevo>
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 27/03/2023
-- Description:	Agregado del dominio al agregar un usuario
-- =============================================
-- =============================================
-- Author:		Daniel Ac
-- Create date: 05/08/2025
-- Description:	Cambia el orden de la instrucciones para devolver el usuario correcto
-- =============================================
ALTER PROCEDURE [dbo].[S_SP_RegistrarUsuario] 
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
		NotificacionActualizaciones,
		Dominio
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
		1,
		SUBSTRING(@Correo, CHARINDEX('@', @Correo) + 1, LEN(@Correo))
	)

	-- TABLA 2 
	SELECT SCOPE_IDENTITY() AS IdUsuarioNuevo 

	IF(@EliminarUsuario = 1)
	BEGIN
	   -- EL UPDATE RETORNA EL ID DEL USUARIO MODIFICADO, OSEA EN UNA TABLA 2
	   -- SE INACTIVA EL USUARIO ANTERIOR PARA QUE SE PUEDA USAR EL USUARIO EN PETROVENDOR
		UPDATE dbo.S_Usuario
			SET Activo = 0,
				IsEliminado = 1
		WHERE IdUsuario = @IdUsuario 
	END
END
