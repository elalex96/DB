-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <03/03/2022>
-- Description:	<Guardado de archivos en db>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DROPBOX_GuardarArchivoDB] 
	-- Add the parameters for the stored procedure here
	@IdArchivo INT,
	@Archivo IMAGE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DR_ArchivosEnvioDropbox
	SET Archivo = @Archivo
	WHERE IdArchivoEnvio = @IdArchivo;

END