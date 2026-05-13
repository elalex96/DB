CREATE TABLE [dbo].[AX_UnidadClasificacion] (
    [IdUnidad]        INT      NOT NULL,
    [IdClasificacion] INT      NOT NULL,
    [Activo]          BIT      NOT NULL,
    [CreadoEl]        DATETIME NOT NULL,
    [ModificadoEl]    DATETIME NULL,
    PRIMARY KEY CLUSTERED ([IdUnidad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdClasificacion]) REFERENCES [dbo].[MM_TipoMaterialProcura] ([IdTipoMaterialProcura]),
    FOREIGN KEY ([IdUnidad]) REFERENCES [dbo].[PV_MM_MaterialUnidad] ([IdUnidad])
);

