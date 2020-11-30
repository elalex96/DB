CREATE TABLE [dbo].[IN_IndicadorPorContrato] (
    [idIndicadorContrato] INT      IDENTITY (1, 1) NOT NULL,
    [idIndicador]         INT      NULL,
    [idContrato]          INT      NULL,
    [CreadoPor]           INT      NULL,
    [CreadoEl]            DATETIME NULL,
    [ModificadoPor]       INT      NULL,
    [ModificadoEl]        DATETIME NULL,
    [Activo]              BIT      NULL,
    CONSTRAINT [PK__IN_Indic__1931B2882CDCDE65] PRIMARY KEY CLUSTERED ([idIndicadorContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IndicadorPoContratoContrato] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_IndicadorPoContratoIndicador] FOREIGN KEY ([idIndicador]) REFERENCES [dbo].[IN_Indicadores] ([idIndicador])
);

