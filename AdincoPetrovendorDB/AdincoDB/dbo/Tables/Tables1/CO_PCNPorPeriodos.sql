CREATE TABLE [dbo].[CO_PCNPorPeriodos] (
    [IdPCNPorPeriodo]          INT        IDENTITY (10000, 1) NOT NULL,
    [IdTipoPgrogramaActividad] INT        NULL,
    [IdContrato]               INT        NULL,
    [Anios]                    INT        NULL,
    [PCNPorPeriodoMin]         FLOAT (53) NULL,
    [PCNPorPeriodoMax]         FLOAT (53) NULL,
    [CreadoPor]                INT        NULL,
    [CreadoEn]                 DATETIME   NULL,
    [ModificadoPor]            INT        NULL,
    [ModificadoEn]             DATETIME   NULL,
    [AnioInicio]               INT        NULL,
    CONSTRAINT [PK_CO_PCNPorPeriodos] PRIMARY KEY CLUSTERED ([IdPCNPorPeriodo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_PCNPorPeriodos_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_CO_PCNPorPeriodos_CO_TipoProgramaActividad] FOREIGN KEY ([IdTipoPgrogramaActividad]) REFERENCES [dbo].[CO_TipoProgramaActividad] ([IdTipoProgramaActividad])
);

