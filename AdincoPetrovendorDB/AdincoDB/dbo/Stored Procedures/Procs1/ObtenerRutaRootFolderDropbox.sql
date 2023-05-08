CREATE PROCEDURE [dbo].ObtenerRutaRootFolderDropbox
AS
BEGIN
   SELECT * FROM APP_ConfiguracionDropbox WHERE Tipo = 'Initial Folder Dropbox'
END