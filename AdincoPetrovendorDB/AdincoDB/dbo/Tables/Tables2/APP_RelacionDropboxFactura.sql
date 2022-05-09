CREATE TABLE APP_RelacionRutaDropboxFactura(
Id INT IDENTITY, 
Ruta NVARCHAR(MAX), 
IdFactura INT, 
CreadoPor INT, 
CreadoEl DATETIME, 
ModificadoPor INT, 
ModificadoEl DATETIME,
CONSTRAINT FK_APP_RelacionRutaDropboxFactura_FI_Factura FOREIGN KEY (IdFactura)  REFERENCES FI_FACTURA(IdFactura),
CONSTRAINT FK_APP_RelacionRutaDropboxFactura_AP_Usuario_Creado FOREIGN KEY(CreadoPor) REFERENCES AP_USUARIO(UsuarioID),
CONSTRAINT FK_APP_RelacionRutaDropboxFactura_AP_Usuario_Modificado FOREIGN KEY(ModificadoPor) REFERENCES AP_USUARIO(UsuarioID)
)


