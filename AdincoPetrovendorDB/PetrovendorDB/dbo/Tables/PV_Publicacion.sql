CREATE TABLE [dbo].[PV_Publicacion] (
    [IdPublicacion]    INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]      NVARCHAR (MAX) NULL,
    [IdProveedor]      INT            NULL,
    [SrcImagen]        NVARCHAR (100) NULL,
    [FechaAlta]        DATETIME       NULL,
    [FechaPublicacion] DATETIME       NULL,
    [IdAprobador]      INT            NULL,
    [IsPublicado]      BIT            NULL,
    [Imagen]           NVARCHAR (MAX) NULL,
    [IdUsuario]        INT            NULL,
    CONSTRAINT [PK_PV_Publicacion] PRIMARY KEY CLUSTERED ([IdPublicacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__PV_Public__IdPro__6B79F03D] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

