CREATE TABLE [dbo].[AP_FlujoAprobacion_Tareas] (
    [FlujoAprobacionTareaId] SMALLINT      NOT NULL,
    [TipoFlujoAprobacionId]  SMALLINT      NOT NULL,
    [Descripcion]            VARCHAR (250) NOT NULL,
    [CreadoEl]               DATETIME      NOT NULL,
    CONSTRAINT [PK_AP_FlujoAprobacion_Tareas] PRIMARY KEY CLUSTERED ([FlujoAprobacionTareaId] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_FlujoAprobacion_Tareas_AP_FlujoAprobacionTipos] FOREIGN KEY ([TipoFlujoAprobacionId]) REFERENCES [dbo].[AP_FlujoAprobacionTipos] ([TipoFlujoAprobacionId])
);

