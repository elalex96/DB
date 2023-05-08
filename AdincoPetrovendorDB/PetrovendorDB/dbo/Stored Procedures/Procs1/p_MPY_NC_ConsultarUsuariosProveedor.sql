create proc p_MPY_NC_ConsultarUsuariosProveedor
@pIdAceptacionPedido int,
@pIdAceptacionNotaCredito int
as

	declare @emails varchar(500) = '',
			@proveedor varchar(500) = ''

	select top 10 @emails =  isnull(u.Correo,'')  + ';' + @emails ,
		@proveedor = prov.RazonSocial
	from MPY_MM_AceptacionNotaCredito anc
	inner join MPY_MM_AceptacionPedido ap on ap.IdAceptacionPedido = anc.IdAceptacionPedido
	inner join Adinco..CO_SAPVendor ven on ven.VendorIDSAP COLLATE Modern_Spanish_CI_AS = ap.IdSubContratista COLLATE Modern_Spanish_CI_AS
	INNER JOIN S_Proveedor prov on prov.RFC COLLATE Modern_Spanish_CI_AS = ven.TAXID COLLATE Modern_Spanish_CI_AS
	inner join S_UsuarioProveedor up on up.Idproveedor = prov.IdProveedor
	inner join S_Usuario u on u.Idusuario = up.IdUsuario and u.Activo = 1
	where anc.IdAceptacionNotaCredito = @pIdAceptacionNotaCredito and
	 anc.IdAceptacionPedido = @pIdAceptacionPedido

	 select Email = isnull(@emails,'') , Proveedor = isnull(@proveedor,'')