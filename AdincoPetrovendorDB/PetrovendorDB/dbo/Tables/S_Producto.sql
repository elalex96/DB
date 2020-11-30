CREATE TABLE [dbo].[S_Producto] (
    [IdProducto]  INT            IDENTITY (1, 1) NOT NULL,
    [Marca]       NVARCHAR (50)  NULL,
    [Modelo]      NVARCHAR (50)  NULL,
    [Nombre]      NVARCHAR (50)  NULL,
    [Descripcion] NVARCHAR (MAX) NULL,
    [IdProveedor] INT            NULL,
    [IsEliminado] BIT            NULL,
    CONSTRAINT [PK_S_Producto] PRIMARY KEY CLUSTERED ([IdProducto] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__S_Product__IdPro__60FC61CA] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

