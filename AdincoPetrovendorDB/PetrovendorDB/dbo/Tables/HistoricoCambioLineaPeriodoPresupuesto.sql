CREATE TABLE [dbo].[HistoricoCambioLineaPeriodoPresupuesto] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT      NULL,
    [IdPeriodoOld]      INT      NULL,
    [IdPresupuestoOld]  INT      NULL,
    [FechaModificado]   DATETIME NULL
);

