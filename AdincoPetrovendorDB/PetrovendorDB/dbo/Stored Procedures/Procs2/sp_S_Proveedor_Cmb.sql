
CREATE proc [dbo].[sp_S_Proveedor_Cmb]
as
begin
		select	IdProveedor,
				RazonSocial
		from	S_Proveedor
		ORDER BY RazonSocial ASC
		--where IdProveedor = 472
end
