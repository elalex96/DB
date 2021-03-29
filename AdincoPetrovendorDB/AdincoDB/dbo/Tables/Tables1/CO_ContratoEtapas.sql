CREATE TABLE CO_ContratoEtapas  
(ContratoId INT NOT NULL,
EtapaId INT  NOT NULL, 
FechaInicio DATETIME, 
FechaFin DATETIME,
Activo BIT NOT NULL,
CreadoEl DATETIME NOT NULL,
CreadoPor INT,
ModificadoEl DATETIME,
ModificadoPor INT,
CONSTRAINT PK_CO_ContratoEtapas 
PRIMARY KEY(ContratoId,EtapaId),
CONSTRAINT FK_CO_ContratoEtapas_CO_Contrato
FOREIGN KEY (ContratoId) REFERENCES dbo.CO_Contrato(IdContrato),
CONSTRAINT FK_CO_ContratoEtapas_EN_Etapa
FOREIGN KEY (EtapaId) REFERENCES dbo.EN_Etapa(IdEtapa)
)