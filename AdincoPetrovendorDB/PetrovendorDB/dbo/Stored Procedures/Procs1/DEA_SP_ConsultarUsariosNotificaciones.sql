-- =============================================
-- Author:	Daniel AC
-- Create date: <20/08/2019>
-- Description:	<Consulta de las PR>
-- =============================================
create PROCEDURE [dbo].[DEA_SP_ConsultarUsariosNotificaciones] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@TipoNotificacion NVARCHAR(MAX)	,
	@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT U.IdUsuario, U.Nombre, ISNULL(UN.Activo,0) AS Activo, UN.TipoNotificacion, ISNULL(TU.NombreTipoUsuario,'Tipo de usuario no establecido') AS NombreTipoUsuario
	 FROM dbo.S_Usuario U 
	 INNER JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario = U.IdUsuario
	 INNER JOIN dbo.S_Proveedor P ON P.IdProveedor=UP.IdProveedor
	 LEFT JOIN dbo.DEA_UsuariosNotificar UN ON UN.IdUsuario = U.IdUsuario AND UN.TipoNotificacion=@TipoNotificacion
	 LEFT JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario = U.IdTipoUsuario
	 WHERE P.IdProveedor=@IdProveedor AND ISNULL(U.Activo,0)=1
	 GROUP BY U.IdUsuario, U.Nombre, UN.Activo, UN.TipoNotificacion, TU.NombreTipoUsuario
	 ORDER BY U.Nombre
	 
END
