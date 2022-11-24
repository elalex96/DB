CREATE TABLE [dbo].[MM_PedidoFactura] (
    [IdPedidoFactura] INT IDENTITY (1, 1) NOT NULL,
    [IdPedido]        INT NULL,
    [IdFactura]       INT NULL,
    CONSTRAINT [PK_MM_PedidoFactura] PRIMARY KEY CLUSTERED ([IdPedidoFactura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_PedidoFactura_FI_Factura] FOREIGN KEY ([IdFactura]) REFERENCES [dbo].[FI_Factura] ([IdFactura]),
    CONSTRAINT [FK_MM_PedidoFactura_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido])
);

