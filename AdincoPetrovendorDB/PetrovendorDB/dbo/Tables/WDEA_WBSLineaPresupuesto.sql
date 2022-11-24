CREATE TABLE [dbo].[WDEA_WBSLineaPresupuesto] (
    [Id]                 INT      IDENTITY (1, 1) NOT NULL,
    [IdWBS]              INT      NULL,
    [IdLineaPresupuesto] INT      NULL,
    [IdContrato]         INT      NULL,
    [Activo]             BIT      NULL,
    [CreadoEl]           DATETIME NULL,
    [ModificadoEl]       DATETIME NULL,
    [CreadoPor]          INT      NULL,
    [ModificadoPor]      INT      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

