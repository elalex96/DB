CREATE PROCEDURE [dbo].ObtenerRutaInitialFolderDropboxFactura @IdFactura INT
AS
BEGIN
	SELECT * FROM APP_RelacionRutaDropboxFactura WHERE IdFactura = @IdFactura
END