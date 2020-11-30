CREATE TABLE [dbo].[SCOC_PuntosdeEntregaContrato] (
    [IdContrato]     INT      NOT NULL,
    [PuntoEntregaID] INT      NOT NULL,
    [Bit_Activo]     BIT      NULL,
    [CreadoPor]      INT      NULL,
    [CreadoEn]       DATETIME NULL,
    [ModificadoPor]  INT      NULL,
    [ModificadoEn]   DATETIME NULL,
    CONSTRAINT [PK_SCOC_PuntosdeEntregaContrato] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [PuntoEntregaID] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_PuntosdeEntregaContrato_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_SCOC_PuntosdeEntregaContrato_CO_PuntosdeEntrega] FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID])
);

