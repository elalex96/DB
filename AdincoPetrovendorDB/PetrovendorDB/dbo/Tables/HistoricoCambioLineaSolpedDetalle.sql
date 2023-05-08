CREATE TABLE [dbo].[HistoricoCambioLineaSolpedDetalle] (
    [Id]                       INT      IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido]        INT      NULL,
    [IdSolicitudPedidoDetalle] INT      NULL,
    [IdLineaPresupuestoOld]    INT      NULL,
    [FechaModificado]          DATETIME NULL
);

