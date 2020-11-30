CREATE TABLE [dbo].[PV_MM_GrupoFamiliaSubFamiliaUnidadTipo] (
    [IdGrupoFamiliaSubfamiliaUnidadTipo] INT IDENTITY (10000, 1) NOT NULL,
    [IdGrupo]                            INT NULL,
    [IdFamilia]                          INT NULL,
    [IdSubFamilia]                       INT NULL,
    [IdUnidad]                           INT NULL,
    [IdTipoMaterial]                     INT NULL,
    [IsActivo]                           BIT NULL,
    CONSTRAINT [PK_PV_MM_GrupoFamiliaSubFamiliaUnidadTipo] PRIMARY KEY CLUSTERED ([IdGrupoFamiliaSubfamiliaUnidadTipo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

