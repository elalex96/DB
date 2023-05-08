CREATE TABLE [dbo].[EN_Bitacora_EntregablesModificados] (
    [Id]                 INT      IDENTITY (1, 1) NOT NULL,
    [IdContrato]         INT      NOT NULL,
    [IdEntregable]       INT      NOT NULL,
    [IdArea]             INT      NULL,
    [ElaboradorAnterior] INT      NULL,
    [RevisorAnterior]    INT      NULL,
    [AprobadorAnterior]  INT      NULL,
    [Activo]             BIT      NULL,
    [ModificadoPor]      INT      NOT NULL,
    [ModificadoEl]       DATETIME NULL,
    [BitAwareness]       BIT      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

