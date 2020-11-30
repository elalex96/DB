CREATE TABLE [dbo].[OT_SolicitudAdicional] (
    [IdOTSolicitudAdicional] INT           NOT NULL,
    [IdOTSolicitud]          INT           NOT NULL,
    [IdEstatusAdicional]     TINYINT       NOT NULL,
    [Motivo]                 VARCHAR (300) NULL,
    [CreadoEl]               DATETIME      NOT NULL,
    [CreadoPor]              INT           NOT NULL,
    CONSTRAINT [PK_OT_SolicitudAdicional] PRIMARY KEY CLUSTERED ([IdOTSolicitudAdicional] ASC),
    CONSTRAINT [FK_OT_SolicitudAdicional_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudAdicional_OT_EstatusAdicional] FOREIGN KEY ([IdEstatusAdicional]) REFERENCES [dbo].[OT_EstatusAdicional] ([IdEstatusAdicional]),
    CONSTRAINT [FK_OT_SolicitudAdicional_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

