-- =============================================
-- Author:		Daniel AC
-- Create date: <05/12/2019>
-- Description:	<Consulta de los usuarios de compras>
-- =============================================
CREATE PROCEDURE SP_PO_UsuariosCompras
	-- Add the parameters for the stored procedure here
	@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		US.IdUsuario AS Asignado,
		CONCAT(US.Nombre,'(',ISNULL(TU.NombreTipoUsuario,''),')') AS Nombre 
	FROM dbo.S_Usuario AS US
		LEFT JOIN dbo.S_UsuarioProveedor AS USP ON USP.IdUsuario = US.IdUsuario
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = USP.IdProveedor
		LEFT JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario = US.IdTipoUsuario
	WHERE PR.IdProveedor = @IdProveedor AND US.Activo = 1 AND ISNULL(US.IsEliminado,0) = 0
	GROUP BY US.IdUsuario,
             US.Nombre,
			 TU.NombreTipoUsuario
END

