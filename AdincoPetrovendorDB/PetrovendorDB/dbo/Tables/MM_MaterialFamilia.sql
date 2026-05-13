CREATE TABLE [dbo].[MM_MaterialFamilia] (
    [IdMaterialFamilia] INT            IDENTITY (10000, 1) NOT NULL,
    [Familia]           NVARCHAR (MAX) NULL,
    [Activo]            BIT            NULL,
    CONSTRAINT [PK_MM_MaterialFamilia] PRIMARY KEY CLUSTERED ([IdMaterialFamilia] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

