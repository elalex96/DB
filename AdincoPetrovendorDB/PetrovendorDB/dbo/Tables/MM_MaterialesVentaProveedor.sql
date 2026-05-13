CREATE TABLE [dbo].[MM_MaterialesVentaProveedor] (
    [IdMaterialesVentaProveedor] INT      IDENTITY (10000, 1) NOT NULL,
    [IdProveedor]                INT      NULL,
    [IdMaterial]                 INT      NULL,
    [CreadoPor]                  INT      NULL,
    [CreadoEn]                   DATETIME NULL,
    [IsActivo]                   BIT      NULL,
    [IsEliminado]                BIT      NULL,
    CONSTRAINT [PK_MM_MaterialesVentaProveedor] PRIMARY KEY CLUSTERED ([IdMaterialesVentaProveedor] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_MaterialesVentaProveedor_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

