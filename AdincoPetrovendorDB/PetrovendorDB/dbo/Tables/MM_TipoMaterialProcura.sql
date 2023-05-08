CREATE TABLE [dbo].[MM_TipoMaterialProcura] (
    [IdTipoMaterialProcura] INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]           NVARCHAR (200) NULL,
    [Activo]                BIT            NULL,
    CONSTRAINT [PK_MM_TipoMaterialProcura] PRIMARY KEY CLUSTERED ([IdTipoMaterialProcura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

