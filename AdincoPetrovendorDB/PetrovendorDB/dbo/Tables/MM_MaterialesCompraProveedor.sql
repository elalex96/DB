CREATE TABLE [dbo].[MM_MaterialesCompraProveedor] (
    [IdMaterialesCompraProveedor] INT      IDENTITY (10000, 1) NOT NULL,
    [IdProveedor]                 INT      NULL,
    [IdMaterial]                  INT      NULL,
    [CreadoPor]                   INT      NULL,
    [CreadoEn]                    DATETIME NULL,
    [IsActivo]                    BIT      NULL,
    [IsEliminado]                 BIT      NULL,
    CONSTRAINT [PK_MM_MaterialesCompraProveedor] PRIMARY KEY CLUSTERED ([IdMaterialesCompraProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_MaterialesCompraProveedor_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_MM_MaterialesCompraProveedor_S_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

