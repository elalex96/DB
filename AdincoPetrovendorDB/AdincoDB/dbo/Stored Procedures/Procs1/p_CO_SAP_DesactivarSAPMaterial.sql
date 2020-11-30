create proc [dbo].[p_CO_SAP_DesactivarSAPMaterial]
@pIdContrato	int,
@pSAPMaterialNumber	varchar(20),
@pKeyLastImport varchar(50)
as

	if isnull(@pKeyLastImport,'') <> ''
	begin
		update [CO_SAPMaterial]
		set activo = 0
		where --SAPMaterialNumber = @pSAPMaterialNumber and
		IdContrato = @pIdContrato and
		KeyLastImport <> @pKeyLastImport
	end