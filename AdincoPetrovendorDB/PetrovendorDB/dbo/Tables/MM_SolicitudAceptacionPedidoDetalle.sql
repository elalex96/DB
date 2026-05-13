CREATE TABLE [dbo].[MM_SolicitudAceptacionPedidoDetalle] (
    [IdSolicitudAceptacionPedidoDetalle] INT        IDENTITY (1, 1) NOT NULL,
    [IdSolicitudAceptacionPedido]        INT        NULL,
    [IdPedidoDetalle]                    INT        NULL,
    [Cantidad]                           FLOAT (53) NULL,
    [CreadoPor]                          INT        NULL,
    [CreadoEl]                           DATETIME   NULL,
    [EditadoPor]                         INT        NULL,
    [EditadoEl]                          DATETIME   NULL,
    [PrecioUnitario]                     FLOAT (53) NULL,
    PRIMARY KEY CLUSTERED ([IdSolicitudAceptacionPedidoDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_SolicitudAceptacionPedidoDetalle_MM_PedidoDetalle] FOREIGN KEY ([IdPedidoDetalle]) REFERENCES [dbo].[MM_PedidoDetalle] ([IdPedidoDetalle]),
    CONSTRAINT [FK_MM_SolicitudAceptacionPedidoDetalle_MM_SolicitudAceptacionPedido] FOREIGN KEY ([IdSolicitudAceptacionPedido]) REFERENCES [dbo].[MM_SolicitudAceptacionPedido] ([IdSolicitudAceptacionPedido])
);

