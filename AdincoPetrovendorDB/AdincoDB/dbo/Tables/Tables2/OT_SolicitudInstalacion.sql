CREATE TABLE [dbo].[OT_SolicitudInstalacion] (
    [IdOTSolicitud] INT      NOT NULL,
    [IdInstalacion] INT      NOT NULL,
    [CreadoPor]     INT      NOT NULL,
    [CreadoEl]      DATETIME NOT NULL,
    CONSTRAINT [PK_OT_SolicitudInstalacion] PRIMARY KEY CLUSTERED ([IdOTSolicitud] ASC, [IdInstalacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_SolicitudInstalacion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudInstalacion_CO_Instalacion] FOREIGN KEY ([IdInstalacion]) REFERENCES [dbo].[CO_Instalacion] ([IdInstalacion]),
    CONSTRAINT [FK_OT_SolicitudInstalacion_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

