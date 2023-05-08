-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <27-04-18>
-- Description:	<Consulta los tipos >
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <21-01-2019>
-- Description:	<Agregado del DISTINCT para evitar duplicaciones>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_UsuariosPorTipoOperacion] --420, 2
@IdProveedor INT,
@IdTipoOperacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT 
		U.IdUsuario,
		U.Nombre +'/'+TU.NombreTipoUsuario AS Nombre
	FROM dbo.S_Usuario U
	INNER JOIN S_TipoUsuario AS TU 
		ON TU.IdTipoUsuario=U.IdTipoUsuario
	INNER JOIN dbo.S_UsuarioRol UR 
		ON UR.IdUsuario = U.IdUsuario
	INNER JOIN dbo.S_Rol R 
		ON R.IdRol = UR.IdRol
	INNER JOIN dbo.S_UsuarioProveedor UP
		ON UP.IdUsuario = U.IdUsuario
	INNER JOIN dbo.S_Proveedor P 
		ON P.IdProveedor = UP.IdProveedor
	INNER JOIN dbo.TA_TipoOperacion TIOP
		ON TIOP.IdRol = R.IdRol
	WHERE 
		U.Activo=1 
		AND P.IdProveedor = @IdProveedor 
		AND UR.Activo= 1 
		AND TIOP.IdTipoOperacion = @IdTipoOperacion 
	GROUP BY U.Nombre + '/' + TU.NombreTipoUsuario,
             U.IdUsuario


END
