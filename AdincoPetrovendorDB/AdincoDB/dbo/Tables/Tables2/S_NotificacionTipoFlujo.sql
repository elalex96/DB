CREATE TABLE [dbo].[S_NotificacionTipoFlujo] (
    [TipoNotificacionId]    SMALLINT      NOT NULL,
    [TipoNotificacion]      VARCHAR (100) NULL,
    [Descripcion]           VARCHAR (250) NULL,
    [TipoFlujoAprobacionId] SMALLINT      NULL,
    [CreadoEl]              DATETIME      NULL,
    [Activo]                BIT           NULL,
    CONSTRAINT [PK_S_NotificacionTipoFlujo] PRIMARY KEY CLUSTERED ([TipoNotificacionId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_NotificacionTipoFlujo_AP_FlujoAprobacionTipos] FOREIGN KEY ([TipoFlujoAprobacionId]) REFERENCES [dbo].[AP_FlujoAprobacionTipos] ([TipoFlujoAprobacionId])
);

