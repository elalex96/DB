CREATE TABLE [dbo].[MM_MaterialFamilia] (
    [IdMaterialFamilia] INT            IDENTITY (10000, 1) NOT NULL,
    [Familia]           NVARCHAR (MAX) NULL,
    [Activo]            BIT            NULL,
    CONSTRAINT [PK_MM_MaterialFamilia] PRIMARY KEY CLUSTERED ([IdMaterialFamilia] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

