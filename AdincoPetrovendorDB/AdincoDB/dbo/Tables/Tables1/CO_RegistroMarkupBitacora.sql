CREATE TABLE CO_RegistroMarkupBitacora(Id INT IDENTITY, 
IdRegistro INT, 
IdEstadoAnterior INT,
MesEstadoPemexAnterior DATE ,  
CreadoEn DATETIME, CreadoPor INT,
FOREIGN KEY (IdRegistro) REFERENCES Co_Registro(IdRegistro),
FOREIGN KEY (CreadoPor) REFERENCES AP_Usuario(UsuarioID))

