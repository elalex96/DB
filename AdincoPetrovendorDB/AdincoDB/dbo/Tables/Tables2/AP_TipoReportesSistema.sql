CREATE TABLE AP_TipoReportesSistema
(
    Id INT IDENTITY(1,1),
    NombreReporte VARCHAR(7000),
    Activo BIT,
    CreadoEn DATETIME,
    CreadoPor INT,
    ModificadoPor INT NULL,
    ModificadoEn DATETIME NULL,

    CONSTRAINT FK_AP_Usuario_AP_TipoReportesSistema_CreadoPor 
        FOREIGN KEY (CreadoPor) REFERENCES AP_Usuario(UsuarioID),

    CONSTRAINT FK_AP_Usuario_AP_TipoReportesSistema_ModificadoPor 
        FOREIGN KEY (ModificadoPor) REFERENCES AP_Usuario(UsuarioID),

    CONSTRAINT PK_AP_TipoReportesSistema 
        PRIMARY KEY (Id)
);