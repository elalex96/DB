-- =============================================
-- Author:	Daniel AC
-- Create date: <20/08/2019>
-- Description:	<Consulta de las PR>
-- =============================================
create  PROCEDURE [dbo].[DEA_SP_ConsultarUsariosProveedor] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdContrato INT,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT U.IdUsuario, CONCAT(U.Nombre,' (',TU.NombreTipoUsuario,')') AS Nombre
	 FROM dbo.S_Usuario U 
	 INNER JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = U.IdUsuario
	 INNER JOIN dbo.S_Proveedor P ON P.IdProveedor=UP.IdProveedor
	 LEFT JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario = U.IdTipoUsuario	 
	 WHERE P.IdProveedor=@IdProveedor AND ISNULL(U.Activo,0)=1
	 GROUP BY U.IdUsuario, U.Nombre,TU.NombreTipoUsuario
	 ORDER BY U.Nombre
	 
END

