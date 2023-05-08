CREATE PROCEDURE [dbo].[sp_dg_ReemplazarDocumento]
	-- Add the parameters for the stored procedure here
	@idDocumento int,
	@documento nvarchar(max),
	@idUsuario int,
	@idTipoValidacionDocumento int

AS
BEGIN

	insert S_RevisionDocumento (idDocumento, idUsuarioAprovador, AutorizadoEl, Comentario, EstatusAnterior, DocumentoAnterior)
		values (@idDocumento, @idUsuario, getdate(), 'Archivo reemplazado', 
		(select IdTipoValidacionDocumento from dbo.S_Documento_S3 where IdDocumento = @idDocumento), 
		(select Documento from S_Documento_S3 where IdDocumento = @idDocumento))
	
	 UPDATE dbo.S_Documento_S3 
		SET Documento = @documento,
			ModificadoEl = getdate(),
			ModificadoPor = @idUsuario,
			IdTipoValidacionDocumento = @idTipoValidacionDocumento
		WHERE IdDocumento = @idDocumento;

END