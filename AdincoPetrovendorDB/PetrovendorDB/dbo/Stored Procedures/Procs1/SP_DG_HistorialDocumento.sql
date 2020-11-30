CREATE PROCEDURE [dbo].[SP_DG_HistorialDocumento]
	@idDocumento int
AS
BEGIN
	
	select rd.idRevision, us.Nombre, rd.AutorizadoEl, rd.Comentario, tv.TipoValidacion, rd.DocumentoAnterior
		from S_RevisionDocumento as rd
		inner join S_Usuario as us on us.IdUsuario = rd.idUsuarioAprovador
		inner join S_TipoValidacionDoc as tv on tv.IdTipoValidacionDoc = rd.EstatusAnterior
		where rd.IdDocumento = @idDocumento
		order by rd.AutorizadoEl desc

return 
END
