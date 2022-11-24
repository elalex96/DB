CREATE proc [dbo].[p_CO_InsUpsSAPVendor]
@pVendorIDSAP	varchar(20),
@pIdContrato	int,
@pVendorName	varchar(250),
@pTaxID	varchar(20),
@pCountry	varchar(50),
@pAddress	varchar(30),
@pContactName	varchar(250),
@pContactEmail	varchar(100),
@pCreadoPor	int,
@pCompanyCode varchar(4),
@pVendorAccountGroup varchar(10),
@pKeyLastImport varchar(50)
as

	if not exists (
		select 1
		from [CO_SAPVendor]
		where VendorIDSAP = @pVendorIDSAP and
		IdContrato = @pIdContrato
	)
	begin

	insert into [dbo].[CO_SAPVendor](
		VendorIDSAP,IdContrato,VendorName,TaxID,
		Country,Address,ContactName,ContactEmail,
		CreadoEl,CreadoPor,ModificadoEl,CompanyCode,
		VendorAccountGroup,Activo,KeyLastImport
	)
	values(
		@pVendorIDSAP,@pIdContrato,@pVendorName,@pTaxID,
		@pCountry,@pAddress,@pContactName,@pContactEmail,
		getdate(),@pCreadoPor,null,@pCompanyCode,
		@pVendorAccountGroup,1,@pKeyLastImport
	)
	end
	else
	begin

		update [CO_SAPVendor]
		set VendorName = @pVendorName,
			TaxID = case when RTRIM(LTRIM(ISNULL(@pTaxID,''))) = '' THEN TaxID ELSE  RTRIM(LTRIM(ISNULL(@pTaxID,''))) END ,
			Country= @pCountry,
			Address = @pAddress,
			ContactName = @pContactName,
			ContactEmail = @pContactEmail,
			CreadoPor = CreadoPor,
			ModificadoEl = getdate(),
			CompanyCode = @pCompanyCode,
			VendorAccountGroup = @pVendorAccountGroup,
			Activo = 1,
			KeyLastImport = @pKeyLastImport
		where VendorIDSAP = @pVendorIDSAP and
		IdContrato = @pIdContrato
	end