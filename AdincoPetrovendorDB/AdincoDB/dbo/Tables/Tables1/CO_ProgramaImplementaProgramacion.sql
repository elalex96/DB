CREATE TABLE [dbo].[CO_ProgramaImplementaProgramacion] (
    [IdProgramaImplementaProgramacion] INT      NOT NULL,
    [IdProgramaImplementaAccion]       INT      NOT NULL,
    [FechaInicioProgramada]            DATETIME NOT NULL,
    [FechaFinProgramada]               DATETIME NOT NULL,
    [FechaInicioImplementa]            DATETIME NULL,
    [FechaFinImplementa]               DATETIME NULL,
    [RevisadoPor]                      INT      NULL,
    [CreadoEl]                         DATETIME NOT NULL,
    [CreadoPor]                        INT      NULL,
    CONSTRAINT [PK_CO_ProgramaImplementaProgramacion] PRIMARY KEY CLUSTERED ([IdProgramaImplementaProgramacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementaProgramacion_AP_Usuario] FOREIGN KEY ([RevisadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementaProgramacion_AP_Usuario1] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementaProgramacion_CO_ProgramaImplementaAcciones] FOREIGN KEY ([IdProgramaImplementaAccion]) REFERENCES [dbo].[CO_ProgramaImplementaAcciones] ([IdProgramaImplementaAccion])
);

