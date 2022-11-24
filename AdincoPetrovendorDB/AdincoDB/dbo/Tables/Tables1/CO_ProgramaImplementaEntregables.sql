CREATE TABLE [dbo].[CO_ProgramaImplementaEntregables] (
    [IdProgramaImplementaEntregable]   INT           NOT NULL,
    [IdProgramaImplementaProgramacion] INT           NOT NULL,
    [Archivo]                          IMAGE         NOT NULL,
    [NombreArchivo]                    VARCHAR (250) NOT NULL,
    [TipoArchivo]                      VARCHAR (100) NOT NULL,
    [CreadoEl]                         DATETIME      NOT NULL,
    [CreadoPor]                        INT           NOT NULL,
    CONSTRAINT [PK_CO_ProgramaImplementaEntregables] PRIMARY KEY CLUSTERED ([IdProgramaImplementaEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementaEntregables_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementaEntregables_CO_ProgramaImplementaProgramacion] FOREIGN KEY ([IdProgramaImplementaProgramacion]) REFERENCES [dbo].[CO_ProgramaImplementaProgramacion] ([IdProgramaImplementaProgramacion])
);

