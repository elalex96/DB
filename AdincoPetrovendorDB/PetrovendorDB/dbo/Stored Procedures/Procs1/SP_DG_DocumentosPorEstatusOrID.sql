CREATE PROCEDURE [dbo].[SP_DG_DocumentosPorEstatusOrID]
	@status int,
	@idDocumento int

AS	

	if @idDocumento > 0
	begin
	--Devuelvo datos de un documento
		select doc.IdDocumento, doc.Documento, td.NombreTipoDocumento, p.RazonSocial, us.Nombre, doc.CreadoEl, tv.TipoValidacion, doc.Descripcion, doc.IdTipoValidacionDocumento --us2.Nombre, doc.ModificadoEl
			from DBO.S_Documento_S3 as doc 
				inner join dbo.s_proveedor as p on p.IdProveedor = doc.IdProveedor
				inner join dbo.s_tipodocumento as td on td.IdTipoDocumento = doc.IdTipoDocumento
				inner join dbo.S_TipoValidacionDoc as tv on tv.IdTipoValidacionDoc = doc.IdTipoValidacionDocumento-- ISNULL(doc.IdTipoValidacionDocumento, 4)
				inner join dbo.S_Usuario as us on us.IdUsuario = doc.IdUsuario
				--inner join dbo.S_Usuario as us2 on isnull(us2.IdUsuario, 0) = isnull(doc.ModificadoPor,0)
			where doc.IdDocumento = @idDocumento

	end

	else
	begin
	--Devuelvo Tipo de documento, Proveedor y el estatus del documento buscado por estatus
		select doc.IdDocumento, td.NombreTipoDocumento, p.RazonSocial, tv.TipoValidacion
			from DBO.S_Documento_S3 as doc 
				inner join dbo.s_proveedor as p on p.IdProveedor = doc.IdProveedor
				inner join dbo.s_tipodocumento as td on td.IdTipoDocumento = doc.IdTipoDocumento
				inner join dbo.S_TipoValidacionDoc as tv on tv.IdTipoValidacionDoc = doc.IdTipoValidacionDocumento-- ISNULL(doc.IdTipoValidacionDocumento, 4)
			where doc.idtipovalidaciondocumento = @status and not doc.IdTipoDocumento = 15
	end
	

RETURN