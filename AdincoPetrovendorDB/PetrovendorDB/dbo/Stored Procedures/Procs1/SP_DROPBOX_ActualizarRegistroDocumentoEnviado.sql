-- =============================================
-- Author:		<Alexander GOMEZ>
-- Create date: <03/03/2022>
-- Description:	<Actualizar el archivo cuando ya fue enviado a dropbox>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DROPBOX_ActualizarRegistroDocumentoEnviado]
	-- Add the parameters for the stored procedure here
	@IdArchivo INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE DR_ArchivosEnvioDropbox
	SET Cargado = 1,
		CargadoEl = GETDATE(),
		Archivo = NULL
	WHERE IdArchivoEnvio = @IdArchivo;

END