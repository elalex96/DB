CREATE TABLE [dbo].[MM_LicitacionSolicitudPedidoDetalle] (
    [IdLicitacionSolicitudPedidoDetalle] INT IDENTITY (10000, 1) NOT NULL,
    [IdLicitacion]                       INT NULL,
    [IdSolicitudPedidoDetalle]           INT NULL,
    CONSTRAINT [PK_MM_LicitacionSolicitudPedidoDetalle] PRIMARY KEY CLUSTERED ([IdLicitacionSolicitudPedidoDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_LicitacionSolicitudPedidoDetalle_MM_Licitacion] FOREIGN KEY ([IdLicitacion]) REFERENCES [dbo].[MM_Licitacion] ([IdLicitacion]),
    CONSTRAINT [FK_MM_LicitacionSolicitudPedidoDetalle_MM_SolicitudPedidoDetalle] FOREIGN KEY ([IdSolicitudPedidoDetalle]) REFERENCES [dbo].[MM_SolicitudPedidoDetalle] ([IdSolicitudPedidoDetalle])
);

