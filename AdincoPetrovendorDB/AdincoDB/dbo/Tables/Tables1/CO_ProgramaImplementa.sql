CREATE TABLE [dbo].[CO_ProgramaImplementa] (
    [IdProgramaImplementa] INT      NOT NULL,
    [IdContrato]           INT      NOT NULL,
    [IdTipoPrograma]       TINYINT  NOT NULL,
    [FechaInicio]          DATETIME NOT NULL,
    [FechaFin]             DATETIME NOT NULL,
    [CreadoEl]             DATETIME NOT NULL,
    [CreadoPor]            INT      NOT NULL,
    [ModificadoEl]         DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    [Activo]               BIT      NULL,
    CONSTRAINT [PK_CO_ProgramaImplementa] PRIMARY KEY CLUSTERED ([IdProgramaImplementa] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementa_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementa_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementa_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_ProgramaImplementa_CO_ProgramaImplementacionTipo] FOREIGN KEY ([IdTipoPrograma]) REFERENCES [dbo].[CO_ProgramaImplementacionTipo] ([Id])
);

