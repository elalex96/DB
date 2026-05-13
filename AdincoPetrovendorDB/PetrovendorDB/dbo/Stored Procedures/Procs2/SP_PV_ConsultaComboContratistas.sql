
create PROCEDURE [dbo].[SP_PV_ConsultaComboContratistas]
	@IdProveedor int
AS
BEGIN
    
	select IdProveedor, RazonSocial
		from S_Proveedor  
		where IdProveedor not in (select IdSubContratista 
									from PV_ContratistaSubContratista 
									where IdContratista = @IdProveedor)
			 and IdProveedor <> @IdProveedor

END

