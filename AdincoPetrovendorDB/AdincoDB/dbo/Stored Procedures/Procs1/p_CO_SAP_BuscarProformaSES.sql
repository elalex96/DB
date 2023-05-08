

-- p_CO_SAP_BuscarProformaSES '4500095868','TEST01',1
create proc [dbo].[p_CO_SAP_BuscarProformaSES]
@pPO_SAPNumer varchar(50),
@pSESReferenceNumber varchar(20),
@pIdEstatus int
as

	select pr.IdPRESES,
		prov.IdProveedor,
		--IdUsuarioAdinco = usu.UsuarioID,
		--UsuarioAdinco = usu.Usuario,
		IdUsuarioPetrovendor = PR.CreadoPor,
		UsuarioPetrovendor = usuP.Correo,
		pr.SAPPONumber,
		pr.SAPVendorNumber,		
		pr.IdEstatus,
		pr.ItemNumber,
		pr.Justificacion,		
		pr.SAPSESNumber,
		pr.MontoTotalPrefactura,
		pr.Plant
	from CO_SAPPRESES pr
	inner join [dbo].[CO_SAPVendor] ven on ven.VendorIDSAP = pr.SAPVendorNumber
	inner join Petrovendor..S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = ven.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS
	--inner join AP_Usuario usu on usu.UsuarioID = pr.CreadoPor
	INNER join Petrovendor..S_Usuario usuP on usuP.IdUsuario = pr.CreadoPor
	where pr.SAPPONumber = @pPO_SAPNumer and
	pr.SAPSESNumber = @pSESReferenceNumber and
	@pIdEstatus in(0,pr.IdEstatus)

	