CREATE TABLE [dbo].[MM_SolicitudAceptacionPedido] (
    [IdSolicitudAceptacionPedido] INT            IDENTITY (1000, 1) NOT NULL,
    [IdProveedorVenta]            INT            NULL,
    [IdPedido]                    INT            NULL,
    [IdAceptacionPedido]          INT            NULL,
    [Comentario]                  NVARCHAR (MAX) NULL,
    [NombreUsuarioEntrega]        NVARCHAR (300) NULL,
    [NombreRecibidoPor]           NVARCHAR (300) NULL,
    [Activo]                      BIT            NULL,
    [CreadoEl]                    DATETIME       NULL,
    [CreadorPor]                  INT            NULL,
    [ModificadoEl]                DATETIME       NULL,
    [ModificadoPor]               INT            NULL,
    PRIMARY KEY CLUSTERED ([IdSolicitudAceptacionPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_SolicitudAceptacionPedido_MM_AceptacionPedido] FOREIGN KEY ([IdAceptacionPedido]) REFERENCES [dbo].[MM_AceptacionPedido] ([IdAceptacionPedido]),
    CONSTRAINT [FK_MM_SolicitudAceptacionPedido_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido]),
    CONSTRAINT [FK_MM_SolicitudAceptacionPedido_S_Proveedor] FOREIGN KEY ([IdProveedorVenta]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

