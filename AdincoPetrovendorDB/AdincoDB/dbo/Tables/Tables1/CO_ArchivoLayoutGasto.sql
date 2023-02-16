CREATE TABLE CO_ArchivoLayoutGasto(
Id	int IDENTITY(1,1),
AWSDocumentoId 	int ,
ContratoId INT,
CreadoEl DATETIME,
CreadoPor INT
PRIMARY KEY (Id),
CONSTRAINT FK_CO_ArchivoLayoutGasto_Contrato FOREIGN KEY (ContratoId) references CO_Contrato (IdContrato),
CONSTRAINT FK_CO_ArchivoLayoutGasto_UsuarioCreador FOREIGN KEY (CreadoPor) references  AP_usuario(UsuarioID),
CONSTRAINT FK_CO_ArchivoLayoutGasto_Archivos FOREIGN KEY (AWSDocumentoId) references  AWS_Documentos(AWSDocumentoId)
);