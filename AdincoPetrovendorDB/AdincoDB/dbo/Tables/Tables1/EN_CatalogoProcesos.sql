CREATE TABLE [dbo].[EN_CatalogoProcesos] (
    [IdCatProceso]  INT           IDENTITY (10000, 1) NOT NULL,
    [Clave]         VARCHAR (150) NULL,
    [Nombre]        VARCHAR (MAX) NULL,
    [Descripcion]   VARCHAR (MAX) NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEn]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEn]  DATETIME      NULL,
    CONSTRAINT [PK_CatProceso] PRIMARY KEY CLUSTERED ([IdCatProceso] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CreadoPor_EN_CatalogoProcesos] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_ModificadoPor_EN_CatalogoProcesos] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [idxClaveCatProc]
    ON [dbo].[EN_CatalogoProcesos]([Clave] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

