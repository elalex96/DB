CREATE TABLE [dbo].[AP_FlujoAprobacionEstatusUsuarios] (
    [FlujoAprobacionEstatusUsuarioId] INT      NOT NULL,
    [FlujoAprobacionEstatusId]        INT      NOT NULL,
    [UsuarioId]                       INT      NOT NULL,
    [CreadoEl]                        DATETIME NOT NULL,
    [ActivarNotificacion]             BIT      NULL,
    CONSTRAINT [PK_AP_FlujoAprobacionEstatusUsuarios] PRIMARY KEY CLUSTERED ([FlujoAprobacionEstatusUsuarioId] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_FlujoAprobacionEstatusUsuarios_AP_FlujoAprobacionEstatus] FOREIGN KEY ([FlujoAprobacionEstatusId]) REFERENCES [dbo].[AP_FlujoAprobacionEstatus] ([FlujoAprobacionEstatusId]),
    CONSTRAINT [FK_AP_FlujoAprobacionEstatusUsuarios_AP_Usuario] FOREIGN KEY ([UsuarioId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_AP_FlujoAprobacionEstatusUsuarios]
    ON [dbo].[AP_FlujoAprobacionEstatusUsuarios]([FlujoAprobacionEstatusId] ASC, [UsuarioId] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

