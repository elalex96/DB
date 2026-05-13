
create procedure [dbo].[ME_ComboProveedores]
	@IdProveedor int
as 
begin
	select IdProveedor, RazonSocial
		from S_Proveedor
		where IdProveedor <> @IdProveedor
end
