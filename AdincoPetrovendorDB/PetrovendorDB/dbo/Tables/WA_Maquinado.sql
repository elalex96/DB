CREATE TABLE [dbo].[WA_Maquinado] (
    [IdMaquinadoPH]   INT        IDENTITY (10000, 1) NOT NULL,
    [IdMaterialPadre] INT        NULL,
    [IdMaterialHijo]  INT        NULL,
    [CantidadPadre]   FLOAT (53) NULL,
    [CantidadHijo]    FLOAT (53) NULL,
    [Activo]          BIT        NULL,
    [CreadoPor]       INT        NULL,
    [CreadoEl]        DATETIME   NULL,
    [ModificadoPor]   INT        NULL,
    [ModificadoEl]    DATETIME   NULL,
    CONSTRAINT [PK_WA_Maquinado] PRIMARY KEY CLUSTERED ([IdMaquinadoPH] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_WA_Maquinado_MM_Material] FOREIGN KEY ([IdMaterialPadre]) REFERENCES [dbo].[MM_Material] ([IdMaterial]),
    CONSTRAINT [FK_WA_Maquinado_MM_Material1] FOREIGN KEY ([IdMaterialHijo]) REFERENCES [dbo].[MM_Material] ([IdMaterial])
);

