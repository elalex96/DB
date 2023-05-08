-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaEmpresasRelacionadasProveedor] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT relProvSub.IdRelacion, relProvSub.IdSubContratista, prove.RazonSocial
FROM dbo.PV_RelacionProveedorSubcotratista relProvSub
INNER JOIN dbo.S_Proveedor prov ON prov.IdProveedor = relProvSub.IdProveedor
INNER JOIN S_Proveedor prove on prove.IdProveedor = relProvSub.IdSubcontratista
WHERE prov.IdProveedor = @IdProveedor
END



