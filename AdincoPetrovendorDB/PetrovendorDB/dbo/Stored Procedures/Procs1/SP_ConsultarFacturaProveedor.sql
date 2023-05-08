-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarFacturaProveedor]
@IdProveedor int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select csc.IdRelacion, p.IdProveedor as IdProveedorFactura, p.RFC, p.RazonSocial, csc.Correo
	from PV_ContratistaSubContratista csc
	inner join S_Proveedor p
	on csc.IdContratista = p.IdProveedor
	where csc.IdSubContratista = @IdProveedor AND (csc.Correo IS NOT NULL OR csc.Correo IS NULL ) AND csc.IsActivo = 1

END
