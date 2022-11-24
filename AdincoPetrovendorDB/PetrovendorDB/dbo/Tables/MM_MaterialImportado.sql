CREATE TABLE [dbo].[MM_MaterialImportado] (
    [IdMaterialImportado] INT      IDENTITY (1, 1) NOT NULL,
    [IdMaterial]          INT      NULL,
    [IdMaterialOperador]  INT      NULL,
    [CreadorEl]           DATETIME NULL,
    [CreadorPor]          INT      NULL,
    [IdProveedorOperador] INT      NULL,
    PRIMARY KEY CLUSTERED ([IdMaterialImportado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_MaterialImportado_MM_Material_ProveedorOperador] FOREIGN KEY ([IdMaterialOperador]) REFERENCES [dbo].[MM_Material] ([IdMaterial]),
    CONSTRAINT [FK_MM_MaterialImportado_MM_Material_ProveedorPetrovendor] FOREIGN KEY ([IdMaterial]) REFERENCES [dbo].[MM_Material] ([IdMaterial]),
    CONSTRAINT [FK_MM_MaterialImportado_S_Proveedor] FOREIGN KEY ([IdProveedorOperador]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_MM_MaterialImportado_S_Usuario] FOREIGN KEY ([CreadorPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

