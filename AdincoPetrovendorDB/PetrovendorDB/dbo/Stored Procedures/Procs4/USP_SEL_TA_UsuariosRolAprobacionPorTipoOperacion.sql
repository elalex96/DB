USE [Petrovendor]
GO
DROP PROC IF EXISTS USP_SEL_TA_UsuariosRolAprobacionPorTipoOperacion
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Daniel AC>
-- Create date: <28-01-2026>
-- Description:	<Consulta usuarios con rol de aprobación de comprobante extranjero mercadeo>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_TA_UsuariosRolAprobacionPorTipoOperacion] 
@IdProveedor INT,
@IdUsuario INT,
@NombreTipoOperacion NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT 
		U.IdUsuario,
		U.Nombre,
		TU.NombreTipoUsuario AS Nombre
	FROM dbo.S_Usuario U (NOLOCK)
	INNER JOIN S_TipoUsuario AS TU  (NOLOCK)
		ON U.IdTipoUsuario = TU.IdTipoUsuario
	INNER JOIN dbo.S_UsuarioRol UR  (NOLOCK)
		ON U.IdUsuario = UR.IdUsuario 
	INNER JOIN dbo.S_Rol R  (NOLOCK)
		ON  UR.IdRol = R.IdRol 
	INNER JOIN dbo.S_UsuarioProveedor UP (NOLOCK)
		ON  U.IdUsuario = UP.IdUsuario 
	INNER JOIN dbo.S_Proveedor P  (NOLOCK)
		ON UP.IdProveedor = P.IdProveedor 
	INNER JOIN dbo.TA_TipoOperacion TIOP (NOLOCK)
		ON  R.IdRol = TIOP.IdRol 
	WHERE 
		U.Activo=1  ---> USUARIO SE ENCUENTRE ACTIVO
		AND P.IdProveedor =@IdProveedor 
		AND UR.Activo= 1 ---> ROL SE ENCUENTRE ACTIVO
		AND RTRIM(LTRIM(UPPER(TIOP.NombreOperacion))) = RTRIM(LTRIM(UPPER(@NombreTipoOperacion)))
	GROUP BY U.Nombre, TU.NombreTipoUsuario,
             U.IdUsuario
	ORDER BY U.Nombre ASC



END
