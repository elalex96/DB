create proc [dbo].[p_CO_SAP_DesactivarSAPVendor]
@pVendorIDSAP	varchar(20),
@pIdContrato	int,
@pKeyLastImport varchar(50)
as


	
	if isnull(@pKeyLastImport,'') <> ''
	begin
		update [CO_SAPVendor]
		set activo = 0,
			ModificadoEl = getdate()
		where --VendorIDSAP = @pVendorIDSAP and
		IdContrato = @pIdContrato and
		KeyLastImport <> @pKeyLastImport
	end
	