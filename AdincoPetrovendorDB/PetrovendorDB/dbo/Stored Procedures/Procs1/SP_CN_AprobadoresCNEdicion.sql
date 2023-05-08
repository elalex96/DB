-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <14-06-2019>
-- Description:	<Consultar los aprobadores de contenido nacional de la operadora>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CN_AprobadoresCNEdicion]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT
		U.IdUsuario,
		U.Nombre,
		U.Correo
	FROM dbo.S_UsuarioRol AS UR
	LEFT JOIN dbo.S_Usuario AS U ON U.IdUsuario = UR.IdUsuario
	LEFT JOIN dbo.S_UsuarioProveedor AS UP ON UP.IdUsuario = U.IdUsuario
	LEFT JOIN dbo.S_Proveedor AS P ON P.IdProveedor = UP.IdProveedor
	WHERE P.IdProveedor = 420
		AND UR.IdRol = 3
		AND ISNULL(UR.Activo,0) = 1
		AND ISNULL(U.Activo,0) = 1
	GROUP BY U.IdUsuario,
             U.Nombre,
             U.Correo

END
