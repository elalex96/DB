CREATE TABLE [dbo].[EN_FrecuenciaEntregable] (
    [IdFrecuenciaEntregable] INT            IDENTITY (10000, 1) NOT NULL,
    [FrecuenciaEntregable]   NVARCHAR (MAX) NULL,
    [FrecuenciaIngles]       VARCHAR (3000) NULL,
    CONSTRAINT [PK_EN_FrecuenciaEntregable] PRIMARY KEY CLUSTERED ([IdFrecuenciaEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [IX_EN_FrecuenciaEntregable]
    ON [dbo].[EN_FrecuenciaEntregable]([IdFrecuenciaEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

