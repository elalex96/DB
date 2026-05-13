CREATE PROCEDURE [dbo].[SP_DG_AutorizacionDocumento]
	@status int,
	@idUsuario int,
	@idDocumento int,
	@descripcion nvarchar(max)
AS
BEGIN
	declare @estatusAnterio int
	set @estatusAnterio = (select IdTipoValidacionDocumento from dbo.S_Documento_S3 where IdDocumento = @idDocumento)

	if(@status = 2)
		set @descripcion = 'Aprobado'

	UPDATE dbo.S_Documento_S3
		SET IdTipoValidacionDocumento = @status
		WHERE IdDocumento = @idDocumento

	insert S_RevisionDocumento (idDocumento, idUsuarioAprovador, AutorizadoEl, Comentario, EstatusAnterior)
		values (@idDocumento, @idUsuario, getdate(), @descripcion, @estatusAnterio)

	select td.NombreTipoDocumento, us.Nombre, tv.TipoValidacion, doc.Descripcion, us.Correo
			from DBO.S_Documento_S3 as doc 
				inner join dbo.s_tipodocumento as td on td.IdTipoDocumento = doc.IdTipoDocumento
				inner join dbo.S_TipoValidacionDoc as tv on tv.IdTipoValidacionDoc = doc.IdTipoValidacionDocumento-- ISNULL(doc.IdTipoValidacionDocumento, 4)
				inner join dbo.S_Usuario as us on us.IdUsuario = doc.IdUsuario
			where doc.IdDocumento = @idDocumento
return 
END