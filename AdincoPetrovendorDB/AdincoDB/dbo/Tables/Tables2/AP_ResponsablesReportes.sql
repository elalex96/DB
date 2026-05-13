
CREATE TABLE AP_ResponsablesReportes
(
    Id INT IDENTITY(1,1),

    ContratoId INT, -- amatitlan
    TipoReporteId INT, -- Reporte de Certificado de GE.
    Tipo VARCHAR(7000), -- valida, vobo, elabora, revisa
    NombrePersona VARCHAR(7000),
    FichaPersona VARCHAR(7000), -- F-781925
    PuestoPersona VARCHAR(7000), -- Coordinador de Grupo multidisciplinario de operación

    Activo BIT,
    CreadoEn DATETIME,
    CreadoPor INT,
    ModificadoPor INT NULL,
    ModificadoEn DATETIME NULL,

    CONSTRAINT FK_AP_Usuario_AP_ResponsablesReportes_CreadoPor
        FOREIGN KEY (CreadoPor) REFERENCES AP_Usuario(UsuarioID),

    CONSTRAINT FK_AP_Usuario_AP_ResponsablesReportes_ModificadoPor
        FOREIGN KEY (ModificadoPor) REFERENCES AP_Usuario(UsuarioID),

    CONSTRAINT FK_AP_TipoReportesSistema_AP_ResponsablesReportes
        FOREIGN KEY (TipoReporteId) REFERENCES AP_TipoReportesSistema(Id),

    CONSTRAINT FK_CO_Contrato_AP_ResponsablesReportes
        FOREIGN KEY (ContratoId) REFERENCES CO_Contrato(IdContrato),

    CONSTRAINT PK_AP_ResponsablesReportes
        PRIMARY KEY (Id)
);