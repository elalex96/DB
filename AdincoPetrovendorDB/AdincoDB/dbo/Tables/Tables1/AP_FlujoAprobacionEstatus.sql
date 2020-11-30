CREATE TABLE [dbo].[AP_FlujoAprobacionEstatus] (
    [FlujoAprobacionEstatusId] INT           NOT NULL,
    [TipoFlujoAprobacionId]    SMALLINT      NOT NULL,
    [Descripcion]              VARCHAR (250) NOT NULL,
    [Orden]                    SMALLINT      NOT NULL,
    [CreadoEl]                 DATETIME      NOT NULL,
    CONSTRAINT [PK_AP_FlujoAprobacionEstatus] PRIMARY KEY CLUSTERED ([FlujoAprobacionEstatusId] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_FlujoAprobacionEstatus_AP_FlujoAprobacionTipos] FOREIGN KEY ([TipoFlujoAprobacionId]) REFERENCES [dbo].[AP_FlujoAprobacionTipos] ([TipoFlujoAprobacionId])
);

