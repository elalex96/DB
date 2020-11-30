CREATE TABLE [dbo].[CO_ProgramaImplementa_ImportarDep] (
    [IdProgramaImplementa] INT           NOT NULL,
    [IdContrato]           INT           NULL,
    [Categoria]            VARCHAR (MAX) NULL,
    [IdUsuario]            INT           NULL,
    CONSTRAINT [PK_CO_ProgramaImplementa_ImportarDep] PRIMARY KEY CLUSTERED ([IdProgramaImplementa] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementa_ImportarDep_AP_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementa_ImportarDep_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

