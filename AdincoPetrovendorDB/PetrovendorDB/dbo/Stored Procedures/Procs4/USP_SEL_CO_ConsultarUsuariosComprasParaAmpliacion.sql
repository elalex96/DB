USE [Petrovendor];
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[USP_SEL_CO_ConsultarUsuariosComprasParaAmpliacion];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 14/04/2026
-- Description:	Consulta los usuarios activos ligados al proveedor de la  
--              solicitud de pedido. Prioriza usuarios con perfil 'Compras',
--              y si no existen, busca usuarios con perfil 'Administrador'.
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_CO_ConsultarUsuariosComprasParaAmpliacion]
	@IdSolicitudPedido INT,
	@IdPeticionOferta INT
AS
BEGIN
	SET NOCOUNT ON;

	-- 1. Obtener la justificación de la ampliación
	DECLARE @MENSAJE NVARCHAR(MAX);

	SELECT @MENSAJE = JustificacionAmplicacion
	FROM dbo.MM_PeticionOferta WITH (NOLOCK)
	WHERE IdPeticionOferta = @IdPeticionOferta;

	-- 2. Buscar primero usuarios con rol 'Compras' y guardarlos en tabla temporal
    -- Usamos SELECT INTO para que SQL infiera automáticamente los tipos de dato correctos
	SELECT DISTINCT 
		U.IdUsuario, 
		U.Nombre, 
		U.Correo, 
		@MENSAJE AS Justificacion
	INTO #UsuariosResult
	FROM dbo.MM_SolicitudPedido SP WITH (NOLOCK)
	INNER JOIN dbo.S_UsuarioProveedor UP WITH (NOLOCK)
		ON SP.IdProveedor = UP.IdProveedor
	INNER JOIN dbo.S_Usuario U WITH (NOLOCK)
		ON UP.IdUsuario = U.IdUsuario 
		AND U.Activo = 1
	INNER JOIN dbo.S_TipoUsuario TU WITH (NOLOCK)
		ON U.IdTipoUsuario = TU.IdTipoUsuario 
		AND TU.NombreTipoUsuario = 'Compras'
	WHERE SP.IdSolicitudPedido = @IdSolicitudPedido;

	-- 3. Validar si no se encontraron usuarios de 'Compras'
	IF @@ROWCOUNT = 0
	BEGIN
		-- Si entra aquí, insertamos los usuarios con rol 'Administrador'
		INSERT INTO #UsuariosResult (IdUsuario, Nombre, Correo, Justificacion)
		SELECT DISTINCT 
			U.IdUsuario, 
			U.Nombre, 
			U.Correo, 
			@MENSAJE
		FROM dbo.MM_SolicitudPedido SP WITH (NOLOCK)
		INNER JOIN dbo.S_UsuarioProveedor UP WITH (NOLOCK)
			ON SP.IdProveedor = UP.IdProveedor
		INNER JOIN dbo.S_Usuario U WITH (NOLOCK)
			ON UP.IdUsuario = U.IdUsuario 
			AND U.Activo = 1
		INNER JOIN dbo.S_TipoUsuario TU WITH (NOLOCK)
			ON U.IdTipoUsuario = TU.IdTipoUsuario 
			AND TU.NombreTipoUsuario = 'Administrador'
		WHERE SP.IdSolicitudPedido = @IdSolicitudPedido;
	END

	-- 4. Retornar el set de datos final (ya sean Compras o Administradores)
	SELECT 
		IdUsuario, 
		Nombre, 
		Correo, 
		Justificacion 
	FROM #UsuariosResult;

END
GO