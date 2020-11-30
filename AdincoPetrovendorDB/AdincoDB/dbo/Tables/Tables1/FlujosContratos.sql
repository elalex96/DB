CREATE TABLE [dbo].[FlujosContratos] (
    [IdFlujoContrato] INT NOT NULL,
    [IdFlujo]         INT NULL,
    [IdContrato]      INT NULL,
    CONSTRAINT [PK_FlujosContratos] PRIMARY KEY CLUSTERED ([IdFlujoContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FlujosContratos_CAT_Flujos] FOREIGN KEY ([IdFlujo]) REFERENCES [dbo].[CAT_Flujos] ([IdFlujo]),
    CONSTRAINT [FK_FlujosContratos_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

