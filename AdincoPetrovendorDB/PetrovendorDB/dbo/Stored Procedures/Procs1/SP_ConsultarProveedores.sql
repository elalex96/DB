
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description:	Datos Basicos de los Proveedores
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_ConsultarProveedores] 
	-- Add the parameters for the stored procedure here
	 --@IdProveedor int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT IdProveedor, RazonSocial, Alias
	 FROM S_Proveedor
	 --WHERE IdProveedor = @Proveedor
	 --AND IdTipoOperacion = 2
	 --AND (Eliminado IS NULL OR Eliminado = 0)

END



