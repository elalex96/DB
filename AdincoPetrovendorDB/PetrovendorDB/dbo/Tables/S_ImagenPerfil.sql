CREATE TABLE [dbo].[S_ImagenPerfil] (
    [IdImagen]             INT            IDENTITY (1, 1) NOT NULL,
    [IdProveedor]          INT            NULL,
    [IdUsuario]            INT            NULL,
    [IsVisible]            BIT            NULL,
    [Imagen]               NVARCHAR (MAX) NULL,
    [Fecha_Modificacion]   DATETIME       NULL,
    [Fecha_Carga]          DATETIME       NULL,
    [MembreteEmpresa]      NVARCHAR (MAX) NULL,
    [ImagenProveedor]      IMAGE          NULL,
    [ImagenProveedorThumb] IMAGE          NULL,
    [ModificadoPor]        INT            NULL,
    CONSTRAINT [PK_S_ImagenPerfil] PRIMARY KEY CLUSTERED ([IdImagen] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_ImagenPerfil_S_Proveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor]),
    CONSTRAINT [FK_S_ImagenPerfil_S_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

