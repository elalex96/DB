CREATE TABLE [dbo].[PR_FactorPuntoEntrega] (
    [PuntoEntregaID]   INT              NOT NULL,
    [Mes]              DATE             NOT NULL,
    [FactorConversion] DECIMAL (18, 12) NULL,
    [ModificadoPor]    INT              NULL,
    [ModificadoEn]     DATETIME         NULL,
    [Eventos]          NVARCHAR (MAX)   NULL,
    CONSTRAINT [PK_PR_FactorPuntoEntrega] PRIMARY KEY CLUSTERED ([PuntoEntregaID] ASC, [Mes] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_FactorPuntoEntrega_CO_PuntoMedicion] FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID])
);

