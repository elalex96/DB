CREATE TABLE [dbo].[IN_InsumoIndicador] (
    [idInsumoIndicador] INT      IDENTITY (1, 1) NOT NULL,
    [idInsumo]          INT      NULL,
    [idIndicador]       INT      NULL,
    [CreadoPor]         INT      NULL,
    [CreadoEl]          DATETIME NULL,
    [ModificadoPor]     INT      NULL,
    [ModificadoEl]      DATETIME NULL,
    [Activo]            BIT      NULL,
    CONSTRAINT [PK__IN_Insum__CA83368C96AF7E84] PRIMARY KEY CLUSTERED ([idInsumoIndicador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__IN_Insumo__idInd__2BABE5F0] FOREIGN KEY ([idIndicador]) REFERENCES [dbo].[IN_Indicadores] ([idIndicador]),
    CONSTRAINT [FK__IN_Insumo__idIns__2CA00A29] FOREIGN KEY ([idInsumo]) REFERENCES [dbo].[IN_Insumos] ([idInsumo])
);

