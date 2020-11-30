CREATE TABLE [dbo].[IN_AL_MaterialExistencias] (
    [AlmacenId]         INT             NOT NULL,
    [IdMaterial]        INT             NOT NULL,
    [Existencia]        DECIMAL (15, 3) NOT NULL,
    [CostoUltimaCompra] MONEY           NOT NULL,
    [CostoPromedio]     MONEY           NOT NULL,
    [CreadoPor]         INT             NOT NULL,
    [CreadoEl]          DATETIME        NOT NULL,
    [ModificadoPor]     INT             NULL,
    [ModificadoEl]      DATETIME        NULL,
    CONSTRAINT [PK_IN_AL_MaterialExistencias] PRIMARY KEY CLUSTERED ([AlmacenId] ASC, [IdMaterial] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IN_AL_MaterialExistencias_IN_Almacen] FOREIGN KEY ([AlmacenId]) REFERENCES [dbo].[IN_Almacen] ([IdAlmacen]),
    CONSTRAINT [FK_IN_AL_MaterialExistencias_MM_Material] FOREIGN KEY ([IdMaterial]) REFERENCES [dbo].[MM_Material] ([IdMaterial])
);

