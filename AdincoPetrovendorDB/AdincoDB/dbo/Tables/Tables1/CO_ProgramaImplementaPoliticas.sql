CREATE TABLE [dbo].[CO_ProgramaImplementaPoliticas] (
    [IdProgramaImplementaPolitica] INT            NOT NULL,
    [IdProgramaImplementa]         INT            NOT NULL,
    [Descripcion]                  VARCHAR (1500) NULL,
    Orden                           INT         NULL,
    [CreadoEl]                     DATETIME       NOT NULL,
    [CreadoPor]                    INT            NULL,
    CONSTRAINT [PK_CO_ProgramaImplementaPoliticas] PRIMARY KEY CLUSTERED ([IdProgramaImplementaPolitica] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementaPoliticas_CO_ProgramaImplementa] FOREIGN KEY ([IdProgramaImplementa]) REFERENCES [dbo].[CO_ProgramaImplementa] ([IdProgramaImplementa])
);

