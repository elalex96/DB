CREATE TABLE [dbo].[EN_ReceptorEntregable] (
    [IdReceptorEntregable] INT            IDENTITY (10000, 1) NOT NULL,
    [ReceptorEntregable]   VARCHAR (3000) NULL,
    [CreadoPor]            INT            NULL,
    [CreadoEn]             DATETIME       NULL,
    CONSTRAINT [PK_EN_ReceptorEntregable] PRIMARY KEY CLUSTERED ([IdReceptorEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [IX_EN_ReceptorEntregable]
    ON [dbo].[EN_ReceptorEntregable]([IdReceptorEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

