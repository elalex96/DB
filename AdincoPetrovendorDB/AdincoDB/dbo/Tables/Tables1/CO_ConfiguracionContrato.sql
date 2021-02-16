CREATE TABLE CO_ConfiguracionContrato (
IdConfCon int IDENTITY (1000,1) PRIMARY KEY,
IdContrato int FOREIGN KEY REFERENCES CO_Contrato(IdContrato),
BtnExpSanciones bit,
BtnExpDefiniciones bit
);