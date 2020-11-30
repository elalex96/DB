-- p_CO_SAP_ReferecniaPrefactura 0,44
create proc [dbo].[p_CO_SAP_ReferecniaPrefactura]
@pIdContrato int,
@pIdProveedor int
as

	declare @pSAPVendorID  varchar(20)

	select @pSAPVendorID = ven.VendorIDSAP
	from S_Proveedor p
	inner join Adinco..CO_SAPVendor ven on ven.TaxID collate Modern_Spanish_CI_AS = p.RFC collate Modern_Spanish_CI_AS
	where p.IdProveedor = @pIdProveedor
	

	select IdPRESES,Referencia = SAPSESNUmber,Monto=MontoTotalPrefactura
	from Adinco.[dbo].[CO_SAPPRESES] pro	
	where pro.SAPVendornumber = @pSAPVendorID 
	 and IdEstatus = 2  --Solo aprobadas 
	 and not exists (
		select 1 
		from MPY_MM_AceptacionPedido st1
		where st1.referencenumber collate SQL_Latin1_General_CP1_CI_AS= pro.SAPSESNUmber  collate SQL_Latin1_General_CP1_CI_AS
	 )

