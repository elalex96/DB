CREATE TABLE [dbo].[PRED_PreviosDetalle] (
    [IdPrevioDetalle] INT           NOT NULL,
    [IdPrevio]        INT           NULL,
    [Cantidad]        REAL          NULL,
    [Concepto]        VARCHAR (MAX) NULL,
    [PrecioUnitario]  REAL          NULL,
    [CreadoPor]       INT           NULL,
    [CreadoEl]        DATETIME      NULL,
    [ModificadoPor]   INT           NULL,
    [ModificadoEl]    DATETIME      NULL,
    [Activo]          BIT           NULL,
    CONSTRAINT [PK_PRED_PreviosDetale] PRIMARY KEY CLUSTERED ([IdPrevioDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

