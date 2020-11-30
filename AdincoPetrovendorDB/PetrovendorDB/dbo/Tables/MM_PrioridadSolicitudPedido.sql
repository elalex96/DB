CREATE TABLE [dbo].[MM_PrioridadSolicitudPedido] (
    [IdPrioridadSolicitudPedido] INT          IDENTITY (10000, 1) NOT NULL,
    [Prioridad]                  VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_MM_PrioridadSolicitudPedido] PRIMARY KEY CLUSTERED ([IdPrioridadSolicitudPedido] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

