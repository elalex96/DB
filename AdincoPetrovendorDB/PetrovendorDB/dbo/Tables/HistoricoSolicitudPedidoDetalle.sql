CREATE TABLE [dbo].[HistoricoSolicitudPedidoDetalle] (
    [IdSolicitudPedidoDetalle] INT            NULL,
    [IdMaterial]               INT            NULL,
    [IdDomicilio]              INT            NULL,
    [Observaciones]            NVARCHAR (MAX) NULL,
    [Cantidad]                 MONEY          NULL,
    [IdUnidad]                 INT            NULL,
    [FechaRegistro]            DATETIME       NULL,
    [IdUsuarioModifico]        INT            NULL
);

