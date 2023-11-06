CREATE TABLE CO_BitacoraPresupuesto
(
    IdCarga INT IDENTITY(1, 1) NOT NULL,
    IdArchivoAWS INT NOT NULL,
    IdContrato INT NOT NULL,
    DetalleAnalisis VARCHAR(8000) NULL,
    Inicio DATE NOT NULL,
    Fin DATE NOT NULL,
    CreadoEl DATETIME NOT NULL,
    CreadoPor INT NOT NULL,
    DetalleInsercion VARCHAR(8000),
    IdPresupuesto INT NULL,
    chkAdjuntaClaveSubTarea BIT NOT NULL, 
    IdTipoProgramaActividad  INT,
    CONSTRAINT PK_CO_BitacoraPresupuesto
        PRIMARY KEY CLUSTERED (IdCarga ASC),
    CONSTRAINT FK_CO_BitacoraPresupuesto_ArchivoAWS
        FOREIGN KEY (IdArchivoAWS)
        REFERENCES AWS_Documentos (AWSDocumentoId),
    CONSTRAINT FK_CO_BitacoraPresupuesto_Contrato
        FOREIGN KEY (IdContrato)
        REFERENCES CO_Contrato (IdContrato),
    CONSTRAINT FK_CO_BitacoraPresupuesto_Usuario
        FOREIGN KEY (CreadoPor)
        REFERENCES AP_Usuario (UsuarioID),
    CONSTRAINT FK_CO_BitacoraPresupuesto_Presupuesto
        FOREIGN KEY (IdPresupuesto)
        REFERENCES CO_Presupuesto (IdPresupuesto)
);