
CREATE PROCEDURE [dbo].[SP_PV_ConsultaSubContratistas]
	@IdProveedor int
AS
BEGIN
    
	select  c.IdRelacion, p.RazonSocial, p.RegimenCapital
		from PV_ContratistaSubContratista as c
			inner join S_Proveedor as p on p.IdProveedor = c.IdSubContratista
			inner join S_Proveedor as p2 on p2.IdProveedor = c.IdContratista
		where c.IdContratista = @IdProveedor

END

