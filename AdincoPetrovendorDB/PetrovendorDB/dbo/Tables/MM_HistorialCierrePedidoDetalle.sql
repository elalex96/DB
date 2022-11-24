CREATE TABLE [dbo].[MM_HistorialCierrePedidoDetalle] (
    [IdHistorialCierrePedidoDetalle] INT        IDENTITY (1, 1) NOT NULL,
    [IdHistorialCierrePedido]        INT        NOT NULL,
    [IdPedidoDetalle]                INT        NOT NULL,
    [CantidadFaltanteAlCierre]       FLOAT (53) NOT NULL,
    CONSTRAINT [PK_MM_HistorialCierrePedidoDetalle] PRIMARY KEY CLUSTERED ([IdHistorialCierrePedidoDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_HistorialCierrePedidoDetalle_MM_HistorialCierrePedido1] FOREIGN KEY ([IdHistorialCierrePedido]) REFERENCES [dbo].[MM_HistorialCierrePedido] ([IdHistorialCierrePedido]),
    CONSTRAINT [FK_MM_HistorialCierrePedidoDetalle_MM_PedidoDetalle1] FOREIGN KEY ([IdPedidoDetalle]) REFERENCES [dbo].[MM_PedidoDetalle] ([IdPedidoDetalle])
);

