CREATE PROCEDURE [dbo].ObtenerRutaInitialFolderDropbox @IdRegistro INT
AS
BEGIN
	DECLARE @IdFactura INT
	
	SELECT TOP 1 @IdFactura = IdFactura FROM CO_Registro WHERE IdRegistro = @IdRegistro
	SELECT * FROM APP_RelacionRutaDropboxFactura WHERE IdFactura = @IdFactura
END