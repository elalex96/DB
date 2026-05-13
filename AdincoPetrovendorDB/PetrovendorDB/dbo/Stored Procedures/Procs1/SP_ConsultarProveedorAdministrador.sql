-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarProveedorAdministrador]
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select RazonSocial from S_Proveedor 
	where IdProveedor = @IdProveedor
	and (IsEliminado = 0 OR IsEliminado IS NULL)

END
