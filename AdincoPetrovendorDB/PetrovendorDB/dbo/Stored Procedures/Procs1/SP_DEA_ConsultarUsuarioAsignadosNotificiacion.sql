-- =============================================
-- Author:	Daniel AC
-- Create date: <20/08/2019>
-- Description:	<Consulta de las PR>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_DEA_ConsultarUsuarioAsignadosNotificiacion] 
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdUsuario INT,
	@TipoNotificacion NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT U.IdUsuario, U.Nombre, U.Correo,UN.TipoNotificacion
	FROM dbo.DEA_UsuariosNotificar UN
	INNER JOIN dbo.S_Usuario U ON UN.IdUsuario=U.IdUsuario
	WHERE UN.TipoNotificacion=@TipoNotificacion
	AND UN.Activo=1 
	AND U.Activo=1
	AND UN.IdProveedor=@IdProveedor
	 
	 
END

