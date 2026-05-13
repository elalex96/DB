create PROCEDURE [dbo].[sp_RE_DocumentosUsuario] 
	@UsuarioId int
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Rol varchar(150) = (SELECT TOP 1 Rol FROM RE_RolUsuario WHERE UsuarioId = @UsuarioId)

	IF (@Rol = 'Admin')
	BEGIN
		SELECT * FROM RE_Documentos WHERE EsVersion != 1
	END
	ELSE
	BEGIN
		SELECT * FROM RE_Documentos WHERE EsVersion != 1 AND TipoDocumentoId IN (SELECT TipoDocumentoId FROM RE_PermisoDocumento WHERE UsuarioId = @UsuarioId) 
	END 
END