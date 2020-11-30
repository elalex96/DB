-- =============================================
-- Author:		<Daniel AC>
-- Create date: <02-08-19>
-- Description:	<Consulta usuarios con rol de aprobación de factura>
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_UsuariosRolAprobacionFactura] 
@IdProveedor INT,
@IdUsuario INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT 
		U.IdUsuario,
		U.Nombre,
		TU.NombreTipoUsuario AS Nombre
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
		U.Activo=1  ---> USUARIO SE ENCUENTRE ACTIVO
		AND P.IdProveedor =@IdProveedor 
		AND UR.Activo= 1 ---> ROL SE ENCUENTRE ACTIVO
		AND TIOP.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA  
	GROUP BY U.Nombre, TU.NombreTipoUsuario,
             U.IdUsuario
	ORDER BY U.Nombre ASC



END
