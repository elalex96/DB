CREATE TABLE CO_RegistroMarkupBitacora(Id INT IDENTITY, 
IdRegistro INT, 
IdEstadoAnterior INT,
IdEstadoActual INT,
MesEstadoPemexAnterior DATE ,  
MesEstadoPemexActual DATE ,  
CreadoEn DATETIME, CreadoPor INT,
FOREIGN KEY (CreadoPor) REFERENCES AP_Usuario(UsuarioID))


