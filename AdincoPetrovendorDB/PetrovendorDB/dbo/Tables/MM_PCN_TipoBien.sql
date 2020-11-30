CREATE TABLE [dbo].[MM_PCN_TipoBien] (
    [IdTipoBien] INT            NOT NULL,
    [TipoBien]   NVARCHAR (500) NULL,
    [Activo]     BIT            NULL,
    [CreadoPor]  INT            NULL,
    [CreadoEl]   DATETIME       NULL,
    [EditadoPor] INT            NULL,
    [EditadoEl]  DATETIME       NULL,
    UNIQUE NONCLUSTERED ([IdTipoBien] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

