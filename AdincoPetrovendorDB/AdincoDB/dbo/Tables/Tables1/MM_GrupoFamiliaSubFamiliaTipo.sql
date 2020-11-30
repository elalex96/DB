CREATE TABLE [dbo].[MM_GrupoFamiliaSubFamiliaTipo] (
    [IdGrupoFamiliaSubfamilia] INT IDENTITY (10000, 1) NOT NULL,
    [IdGrupo]                  INT NULL,
    [IdFamilia]                INT NULL,
    [IdSubFamilia]             INT NULL,
    [IdTipoMaterial]           INT NULL,
    [Activo]                   BIT NULL,
    CONSTRAINT [PK_MM_GrupoFamiliaSubFamiliaTipo] PRIMARY KEY CLUSTERED ([IdGrupoFamiliaSubfamilia] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_GrupoFamiliaSubFamiliaTipo_MM_MaterialFamilia] FOREIGN KEY ([IdFamilia]) REFERENCES [dbo].[MM_MaterialFamilia] ([IdMaterialFamilia]),
    CONSTRAINT [FK_MM_GrupoFamiliaSubFamiliaTipo_MM_MaterialGrupoDisciplina] FOREIGN KEY ([IdGrupo]) REFERENCES [dbo].[MM_MaterialGrupoDisciplina] ([IdGrupoDisciplina]),
    CONSTRAINT [FK_MM_GrupoFamiliaSubFamiliaTipo_MM_MaterialSubFamilia] FOREIGN KEY ([IdSubFamilia]) REFERENCES [dbo].[MM_MaterialSubFamilia] ([IdSubFamilia]),
    CONSTRAINT [FK_MM_GrupoFamiliaSubFamiliaTipo_MM_MaterialTipo] FOREIGN KEY ([IdTipoMaterial]) REFERENCES [dbo].[MM_MaterialTipo] ([IdTipoMaterial])
);

