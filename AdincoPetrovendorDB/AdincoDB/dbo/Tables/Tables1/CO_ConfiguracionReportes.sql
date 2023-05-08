CREATE TABLE [dbo].[CO_ConfiguracionReportes] (
    [IdContrato]      INT            NOT NULL,
    [PorcentajePCM]   DECIMAL (5, 2) NOT NULL,
    [PorcentajePemex] DECIMAL (5, 2) NOT NULL,
    [CreadoEl]        DATETIME       NOT NULL,
    [ModificadoPor]   DATETIME       NULL,
    CONSTRAINT [PK_CO_ConfiguracionReportes] PRIMARY KEY CLUSTERED ([IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ConfiguracionReportes_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

