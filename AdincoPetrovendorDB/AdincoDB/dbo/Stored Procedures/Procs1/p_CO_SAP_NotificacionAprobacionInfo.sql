-- p_CO_SAP_NotificacionAprobacionInfo 10037,'4500093763',10
CREATE proc p_CO_SAP_NotificacionAprobacionInfo
@pIdContrato int,
@pSAPPONumber varchar(20),
@pItemNumber	tinyint
as

	declare @pVendorIDSAP varchar(20)

	select @pVendorIDSAP = SAPVendorNumber from Adinco..[CO_SAPPO]
	where SAPPONumber = @pSAPPONumber and
	ItemNumber = @pItemNumber and
	IdCOntrato = @pIdContrato

	select Destinatario = ISNULL(u.Correo,'')+';',
		NombreUsuario = u.Nombre,
		IdUsuario = u.idUsuario,
		AreContractual = ac.NombreAreaContractual
	from Adinco..CO_SAPVendor v
	inner join S_Proveedor prov on prov.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = v.TaxID COLLATE SQL_Latin1_General_CP1_CI_AS
	INNER JOIN S_UsuarioProveedor up on up.idProveedor = prov.IdProveedor
	inner join S_Usuario u on u.idUsuario = up.IdUsuario
	inner join Adinco..Co_Contrato c on c.IdCOntrato = @pIdContrato
	inner join Adinco..CO_AreaContractual ac on ac.IdAreaContractual=c.IdAreaContractual
	where v.idContrato = @pidContrato and
	VendorIDSAP = @pVendorIDSAP
