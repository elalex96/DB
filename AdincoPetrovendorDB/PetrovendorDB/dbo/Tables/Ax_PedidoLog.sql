CREATE TABLE [dbo].[Ax_PedidoLog] (
    [RFC]               NVARCHAR (150)  NULL,
    [DataAreaId]        NVARCHAR (MAX)  NULL,
    [IdPedidoAdinco]    INT             NULL,
    [OCIPurchId]        NVARCHAR (150)  NULL,
    [OCIIdFormat]       NVARCHAR (MAX)  NULL,
    [CurrencyCode]      NVARCHAR (150)  NULL,
    [ItemId]            NVARCHAR (150)  NULL,
    [Observations]      NVARCHAR (MAX)  NULL,
    [Price]             DECIMAL (18, 4) NULL,
    [Qty]               DECIMAL (18, 4) NULL,
    [RecId]             BIGINT          NULL,
    [UnitId]            NVARCHAR (150)  NULL,
    [IdSolicitudPedido] INT             NULL,
    [FechaRegistro]     DATETIME        NULL
);

