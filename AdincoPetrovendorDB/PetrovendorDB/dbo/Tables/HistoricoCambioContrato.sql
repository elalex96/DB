CREATE TABLE [dbo].[HistoricoCambioContrato] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT      NULL,
    [IdContratoOld]     INT      NULL,
    [FechaModificado]   DATETIME NULL
);

