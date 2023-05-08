CREATE TABLE [dbo].[AP_UsuarioNotificaciones] (
    [ContratoId]         INT      NOT NULL,
    [UsuarioId]          INT      NOT NULL,
    [TipoNotificacionId] SMALLINT NOT NULL,
    [Desactivar]         BIT      NULL,
    [CreadoEl]           DATETIME NULL,
    CONSTRAINT [PK_AP_UsuarioNotificaciones] PRIMARY KEY CLUSTERED ([TipoNotificacionId] ASC, [UsuarioId] ASC, [ContratoId] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_UsuarioNotificaciones_AP_Usuario] FOREIGN KEY ([UsuarioId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_AP_UsuarioNotificaciones_CO_Contrato] FOREIGN KEY ([ContratoId]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_AP_UsuarioNotificaciones_S_NotificacionTipoFlujo] FOREIGN KEY ([TipoNotificacionId]) REFERENCES [dbo].[S_NotificacionTipoFlujo] ([TipoNotificacionId])
);

