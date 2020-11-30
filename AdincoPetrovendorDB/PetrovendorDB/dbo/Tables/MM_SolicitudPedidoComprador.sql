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
    PRIMARY KEY CLUSTERED ([IdSolicitudPedidoComprador] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

