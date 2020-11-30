CREATE TABLE [dbo].[AP_FlujoAprobacionContratos] (
    [FlujoAprobacionId] INT      NOT NULL,
    [IdContrato]        INT      NOT NULL,
    [CreadoEl]          DATETIME NOT NULL,
    CONSTRAINT [PK_AP_FlujoAprobacionContratos] PRIMARY KEY CLUSTERED ([FlujoAprobacionId] ASC, [IdContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_FlujoAprobacionContratos_AP_FlujoAprobacion] FOREIGN KEY ([FlujoAprobacionId]) REFERENCES [dbo].[AP_FlujoAprobacion] ([FlujoAprobacionId]),
    CONSTRAINT [FK_AP_FlujoAprobacionContratos_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

