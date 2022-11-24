CREATE TABLE [dbo].[EN_CatalogoProcesosEntregables] (
    [IdCatProceso]  INT      NOT NULL,
    [IdEntregable]  INT      NOT NULL,
    [CreadoPor]     INT      NULL,
    [CreadoEn]      DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEn]  DATETIME NULL,
    [BitPrincipal]  BIT      NULL,
    CONSTRAINT [PK_CatalogoProcesosEntregables] PRIMARY KEY CLUSTERED ([IdCatProceso] ASC, [IdEntregable] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CreadoPor_CatalogoProcesosEntregables] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_IdCatProceso_CatalogoProcesosEntregables] FOREIGN KEY ([IdCatProceso]) REFERENCES [dbo].[EN_CatalogoProcesos] ([IdCatProceso]),
    CONSTRAINT [FK_IdEntregable_CatalogoProcesosEntregables] FOREIGN KEY ([IdEntregable]) REFERENCES [dbo].[EN_Entregable] ([IdEntregable]),
    CONSTRAINT [FK_ModificadoPor_CatalogoProcesosEntregables] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

