CREATE TABLE [dbo].[MM_AceptacionPedidoDetalleInstalacion] (
    [IdAceptacionPedido]        INT        NOT NULL,
    [IdAceptacionPedidoDetalle] INT        NOT NULL,
    [IdPedidoDetalle]           INT        NOT NULL,
    [IdProveedor]               INT        NOT NULL,
    [IdMaterial]                INT        NOT NULL,
    [Cantidad]                  FLOAT (53) NOT NULL,
    [IdInstalacion]             INT        NOT NULL,
    [IdLineaPresupuesto]        INT        NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAceptacionPedido] ASC, [IdAceptacionPedidoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_AceptacionPedidoDetalleInstalacionIdAceptacionPedido] FOREIGN KEY ([IdAceptacionPedido]) REFERENCES [dbo].[MM_AceptacionPedido] ([IdAceptacionPedido]),
    CONSTRAINT [FK_MM_AceptacionPedidoDetalleInstalacionIdAceptacionPedidoDetalle] FOREIGN KEY ([IdAceptacionPedidoDetalle]) REFERENCES [dbo].[MM_AceptacionPedidoDetalle] ([IdAceptacionPedidoDetalle]),
    CONSTRAINT [FK_MM_AceptacionPedidoDetalleInstalacionIdMaterial] FOREIGN KEY ([IdMaterial]) REFERENCES [dbo].[MM_Material] ([IdMaterial]),
    CONSTRAINT [FK_MM_AceptacionPedidoDetalleInstalacionIdPedidoDetalle] FOREIGN KEY ([IdPedidoDetalle]) REFERENCES [dbo].[MM_PedidoDetalle] ([IdPedidoDetalle]),
    CONSTRAINT [FK_MM_AceptacionPedidoDetalleInstalacionIdProveedor] FOREIGN KEY ([IdProveedor]) REFERENCES [dbo].[S_Proveedor] ([IdProveedor])
);

