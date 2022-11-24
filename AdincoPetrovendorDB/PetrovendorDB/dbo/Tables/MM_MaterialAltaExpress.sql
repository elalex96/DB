CREATE TABLE [dbo].[MM_MaterialAltaExpress] (
    [IdMaterialExpress] INT IDENTITY (1, 1) NOT NULL,
    [IdMaterial]        INT NULL,
    PRIMARY KEY CLUSTERED ([IdMaterialExpress] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

