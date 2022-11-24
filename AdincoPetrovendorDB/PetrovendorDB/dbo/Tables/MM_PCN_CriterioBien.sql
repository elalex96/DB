CREATE TABLE [dbo].[MM_PCN_CriterioBien] (
    [IdCriterio] INT            NOT NULL,
    [Nombre]     NVARCHAR (500) NULL,
    [Activo]     BIT            NULL,
    [CreadoPor]  INT            NULL,
    [CreadoEl]   DATETIME       NULL,
    [EditadoPor] INT            NULL,
    [EditadoEl]  DATETIME       NULL,
    UNIQUE NONCLUSTERED ([IdCriterio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

