CREATE TABLE [dbo].[MM_ComentarioRecepcionPedido] (
    [IdComentarioRecepcion] INT           IDENTITY (1, 1) NOT NULL,
    [IdPedido]              INT           NULL,
    [IdPedidoDetalle]       INT           NULL,
    [Comentario]            VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_MM_ComentarioRecepcionPedido] PRIMARY KEY CLUSTERED ([IdComentarioRecepcion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_ComentarioRecepcionPedido_MM_Pedido] FOREIGN KEY ([IdPedido]) REFERENCES [dbo].[MM_Pedido] ([IdPedido]),
    CONSTRAINT [FK_MM_ComentarioRecepcionPedido_MM_PedidoDetalle] FOREIGN KEY ([IdPedidoDetalle]) REFERENCES [dbo].[MM_PedidoDetalle] ([IdPedidoDetalle])
);

