CREATE TABLE [dbo].[PR_EventosMensualesPozo] (
    [IdPozo]        INT            NOT NULL,
    [MesReporte]    DATE           NOT NULL,
    [Eventos]       VARCHAR (3000) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    CONSTRAINT [PK_PR_EventosMensualesPozo] PRIMARY KEY CLUSTERED ([IdPozo] ASC, [MesReporte] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PR_EventosMensualesPozo_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_EventosMensualesPozo_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PR_EventosMensualesPozo_PR_POZO] FOREIGN KEY ([IdPozo]) REFERENCES [dbo].[PR_Pozo] ([Id])
);

