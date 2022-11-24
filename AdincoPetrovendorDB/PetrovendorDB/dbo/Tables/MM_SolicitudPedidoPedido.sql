CREATE TABLE [dbo].[MM_SolicitudPedidoPedido] (
    [IdSolicitudPedidoPedido] INT IDENTITY (10000, 1) NOT NULL,
    [IdSolicitudPedido]       INT NULL,
    [IdPedido]                INT NULL,
    [Activo]                  BIT NULL,
    CONSTRAINT [PK_MM_SolicitudPedidoPedido] PRIMARY KEY CLUSTERED ([IdSolicitudPedidoPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_SolicitudPedidoPedido_MM_SolicitudPedido] FOREIGN KEY ([IdSolicitudPedido]) REFERENCES [dbo].[MM_SolicitudPedido] ([IdSolicitudPedido])
);

