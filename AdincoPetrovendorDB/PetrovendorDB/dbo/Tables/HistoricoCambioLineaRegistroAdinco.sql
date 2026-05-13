CREATE TABLE [dbo].[HistoricoCambioLineaRegistroAdinco] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [IdSolicitudPedido] INT      NULL,
    [IdRegistro]        INT      NULL,
    [IdProgramaOld]     INT      NULL,
    [FechaModificado]   DATETIME NULL
);

