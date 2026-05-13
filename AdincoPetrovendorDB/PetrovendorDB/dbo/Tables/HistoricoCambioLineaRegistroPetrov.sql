CREATE TABLE [dbo].[HistoricoCambioLineaRegistroPetrov] (
    [Id]                    INT      IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido]     INT      NULL,
    [IdRegistro]            INT      NULL,
    [IdLineaPresupuestoOld] INT      NULL,
    [FechaModificado]       DATETIME NULL
);

