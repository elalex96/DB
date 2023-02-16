CREATE TABLE CO_ArchivoLayoutGastoBitacora(
Id	int IDENTITY(1,1),
AWSDocumentoId 	int ,
GastoId INT,
CreadoEl DATETIME,
CreadoPor INT
PRIMARY KEY (Id),
CONSTRAINT FK_CO_ArchivoLayoutGastoBitacora_UsuarioCreador FOREIGN KEY (CreadoPor) references  AP_usuario(UsuarioID),
CONSTRAINT FK_CO_ArchivoLayoutGastoBitacora_GastoId FOREIGN KEY (GastoId) references  CO_Registro(IdRegistro),
CONSTRAINT FK_CO_ArchivoLayoutGastoBitacora_Archivos FOREIGN KEY (AWSDocumentoId) references  AWS_Documentos(AWSDocumentoId)
);
