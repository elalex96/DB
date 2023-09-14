CREATE TABLE CO_ExcepcionesReporte
(
    [Id]            INT           IDENTITY(1, 1) NOT NULL,
    [IdTipoReporte] INT           NOT NULL,
    [IdContrato]    INT           NOT NULL,
    [MesReporte]    DATE          NOT NULL,
    [FechaFin]      DATETIME      NOT NULL,
    [Motivo]        VARCHAR(5000) NOT NULL,
    [CreadoEl]      DATETIME      NOT NULL,
    [CreadoPor]     INT           NOT NULL,
    [ModificadoEl]  DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [Activo]        BIT           NOT NULL,
    CONSTRAINT PK_CO_ExcepcionesReporte PRIMARY KEY CLUSTERED (Id ASC),
	CONSTRAINT FK_CO_ExcepcionesReporte_TipoReporte FOREIGN KEY (IdTipoReporte) REFERENCES AA_TipoReporte (IdTipoReporte),
    CONSTRAINT FK_CO_ExcepcionesReporte_Contrato FOREIGN KEY (IdContrato) REFERENCES CO_Contrato (IdContrato),
    CONSTRAINT FK_CO_ExcepcionesReporte_Usuario_Creador FOREIGN KEY (CreadoPor) REFERENCES AP_Usuario (UsuarioID),
    CONSTRAINT FK_CO_ExcepcionesReporte_Usuario_Modificador FOREIGN KEY (ModificadoPor) REFERENCES AP_Usuario (UsuarioID)
);