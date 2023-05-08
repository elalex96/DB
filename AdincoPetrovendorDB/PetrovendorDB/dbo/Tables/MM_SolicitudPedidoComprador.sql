CREATE TABLE [dbo].[MM_SolicitudPedidoComprador] (
    [IdSolicitudPedidoComprador] INT      IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido]          INT      NULL,
    [IdAsignadoA]                INT      NULL,
    [IdAsignadorPor]             INT      NULL,
    [CreadoPor]                  INT      NULL,
    [CreadoEl]                   DATETIME NULL,
    [ModificadoPor]              INT      NULL,
    [ModificadoEl]               DATETIME NULL,
    [Activo]                     BIT      NULL,
    [IsHistorico]                BIT      NULL,
    PRIMARY KEY CLUSTERED ([IdSolicitudPedidoComprador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_IdSolicitudPedido] FOREIGN KEY ([IdSolicitudPedido]) REFERENCES [dbo].[MM_SolicitudPedido] ([IdSolicitudPedido]),
    CONSTRAINT [FK_IdUsuario] FOREIGN KEY ([IdAsignadoA]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);


GO
CREATE NONCLUSTERED INDEX [idx_MM_SolicitudPedidoComprador_IdSolicitudPedido]
    ON [dbo].[MM_SolicitudPedidoComprador]([IdSolicitudPedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

