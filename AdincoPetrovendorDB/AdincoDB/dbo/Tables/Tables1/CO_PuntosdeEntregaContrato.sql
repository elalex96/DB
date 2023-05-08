CREATE TABLE [dbo].[CO_PuntosdeEntregaContrato] (
    [PuntoEntregaContratoID] INT      IDENTITY (1000, 1) NOT NULL,
    [PuntoEntregaID]         INT      NULL,
    [idContrato]             INT      NULL,
    [CreadoPor]              INT      NULL,
    [CreadoEl]               DATETIME NULL,
    [ModificadoPor]          INT      NULL,
    [ModificadoEl]           DATETIME NULL,
    [Activo]                 BIT      NULL,
    PRIMARY KEY CLUSTERED ([PuntoEntregaContratoID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

