-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017
-- Description:	Consultar Correos de ventas 
 -- Author:		Daniel A Cruz
-- Create date: 12/Septiembre/2017
-- Description:	Consultar Correos de ventas y administrador 
-- =============================================
CREATE PROCEDURE  [dbo].[SP_MM_ConsultaCorreoProveedorVentas] 
	-- Add the parameters for the stored procedure here
		
	@IdProveedor int
		 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	SELECT U.Correo, U.Nombre, U.IdUsuario
	FROM S_Usuario AS U
	INNER JOIN S_UsuarioProveedor AS UP ON UP.IdUsuario= U.IdUsuario
	INNER JOIN S_Proveedor AS P ON P.IdProveedor = UP.IdProveedor
	WHERE P.IdProveedor  = @IdProveedor  AND (U.IdTipoUsuario = 4 OR U.IdTipoUsuario= 3) AND U.Activo = 1 
	

END



