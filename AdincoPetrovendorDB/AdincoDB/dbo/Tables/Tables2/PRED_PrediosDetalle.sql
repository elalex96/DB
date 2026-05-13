CREATE TABLE [dbo].[PRED_PrediosDetalle] (
    [IdPredioDetalle] INT           NOT NULL,
    [IdPredio]        INT           NULL,
    [Cantidad]        FLOAT (53)    NULL,
    [Concepto]        VARCHAR (MAX) NULL,
    [PrecioUnitario]  FLOAT (53)    NULL,
    [CreadoPor]       INT           NULL,
    [CreadoEl]        DATETIME      NULL,
    [ModificadoPor]   INT           NULL,
    [ModificadoEl]    DATETIME      NULL,
    [Activo]          BIT           NULL,
    CONSTRAINT [PK_PRED_PrediosDetale] PRIMARY KEY CLUSTERED ([IdPredioDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PRED_PrediosDetale_PRED_Predios] FOREIGN KEY ([IdPredio]) REFERENCES [dbo].[PRED_Predios] ([IdPredio])
);

