-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarContactosRelacionados]
@IdProveedor int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select ccsc.IdContactoCS, ccsc.IdContacto, c.Puesto, c.Nombres, pp.RazonSocial
	from S_ContactoContratistaSubContratista ccsc
	inner join S_Contacto_PA c
	on c.IdContacto = ccsc.IdContacto
	inner join S_Proveedor P
	on c.IdProveedor = p.IdProveedor 
	inner join PV_ContratistaSubContratista csc
	on ccsc.IdContratistaSubContratista = csc.IdRelacion
	inner join S_Proveedor pp 
	on csc.IdSubContratista = pp.IdProveedor
	where ccsc.IsActivo = 1 and c.IdProveedor = @IdProveedor

END

