CREATE TABLE [dbo].[CO_ProgramaImplementaElemento] (
    [IdProgramaImplementaElemento] INT            NOT NULL,
    [IdProgramaImplementaPolitica] INT            NOT NULL,
    [IdProgramaImplementa]         INT            NOT NULL,
    [Descripcion]                  VARCHAR (1500) NULL,
    Orden                           int             NULL,
    [CreadoEl]                     DATETIME       NOT NULL,
    [CreadoPor]                    INT            NOT NULL,
    [ModificadoEl]                 DATETIME       NULL,
    [ModificadoPor]                INT            NULL,
    CONSTRAINT [PK_CO_ProgramaImplementaElemento] PRIMARY KEY CLUSTERED ([IdProgramaImplementaElemento] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementaElemento_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementaElemento_AP_Usuario1] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementaElemento_CO_ProgramaImplementa] FOREIGN KEY ([IdProgramaImplementa]) REFERENCES [dbo].[CO_ProgramaImplementa] ([IdProgramaImplementa]),
    CONSTRAINT [FK_CO_ProgramaImplementaElemento_CO_ProgramaImplementaPoliticas] FOREIGN KEY ([IdProgramaImplementaPolitica]) REFERENCES [dbo].[CO_ProgramaImplementaPoliticas] ([IdProgramaImplementaPolitica])
);

