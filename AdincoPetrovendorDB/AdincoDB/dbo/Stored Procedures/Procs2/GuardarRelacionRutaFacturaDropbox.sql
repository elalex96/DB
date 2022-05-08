USE [Adinco]

IF EXISTS(SELECT 1 FROM sysobjects WHERE name = 'GuardarRelacionRutaFacturaDropbox')
DROP PROCEDURE GuardarRelacionRutaFacturaDropbox
GO
CREATE PROCEDURE [dbo].GuardarRelacionRutaFacturaDropbox @Ruta NVARCHAR(MAX), @IdFactura INT, @IdUsuario INT 
AS    
BEGIN
		IF EXISTS( SELECT 1 FROM APP_RelacionRutaDropboxFactura WHERE IdFactura = @IdFactura)
		BEGIN
			UPDATE APP_RelacionRutaDropboxFactura
			SET Ruta = @Ruta, ModificadoPor = @IdUsuario, ModificadoEl = GETDATE()
			WHERE IdFactura = @IdFactura
		END
		ELSE
		BEGIN
			INSERT INTO APP_RelacionRutaDropboxFactura(Ruta, IdFactura, CreadoPor, CreadoEl)
			SELECT @Ruta, @IdFactura, @IdUsuario, GETDATE()
		END
END



