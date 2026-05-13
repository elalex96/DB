CREATE TABLE [dbo].[CO_ProgramaImplementa_Importar] (
    [IdProgramaImplementa] INT           NOT NULL,
    [DescripcionPolitica]  VARCHAR (MAX) NULL,
    [DescripcionElemento]  VARCHAR (MAX) NULL,
    [DescripcionAccion]    VARCHAR (MAX) NULL,
    [Departamento]         VARCHAR (MAX) NULL,
    [IniciaPrimerAccion]   DATE          NULL,
    [TerminaPrimerAccion]  DATE          NULL,
    [Anexo3]               VARCHAR (MAX) NULL,
    [Numerales]            VARCHAR (MAX) NULL,
    [Periodicidad]         VARCHAR (MAX) NULL,
    [Porcentaje]           MONEY         NULL,
    [IdContrato]           INT           NULL,
    [IdUsuario]            INT           NULL,
    CONSTRAINT [PK_CO_ProgramaImplementa_Importar] PRIMARY KEY CLUSTERED ([IdProgramaImplementa] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ProgramaImplementa_Importar_AP_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ProgramaImplementa_Importar_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

