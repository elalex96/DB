
CREATE TABLE CO_InicioReportePODContrato(
Id INT IDENTITY(1,1),
FechaInicio DATETIME,
IdContrato INT,
Descripcion VARCHAR(150),
CreadoPor	INT,
CreadoEl	DATETIME,
ModificadoPor	INT NULL,
ModificadoEl	DATETIME NULL,
Activo	BIT
CONSTRAINT PK_InicioReportePODContrato PRIMARY KEY (Id),
CONSTRAINT FK_InicioReportePODContratoContrato FOREIGN KEY (IdContrato)
REFERENCES CO_CONTRATO(IdContrato),
CONSTRAINT FK_InicioReportePODContratoCreadoPor FOREIGN KEY (CreadoPor)
REFERENCES AP_Usuario(UsuarioID),
CONSTRAINT FK_InicioReportePODContratoModificadoPor FOREIGN KEY (ModificadoPor)
REFERENCES AP_Usuario(UsuarioID)
)

