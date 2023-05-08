CREATE TABLE [dbo].[OT_Convenio] (
    [IdOTConvenio]    INT           NOT NULL,
    [IdOTSolicitud]   INT           NOT NULL,
    [Aprobada]        BIT           NOT NULL,
    [FechaRegistro]   DATETIME      NOT NULL,
    [CreadoPor]       VARCHAR (200) NOT NULL,
    [AprobadaPor]     INT           NULL,
    [FechaAprobacion] DATETIME      NULL,
    [RechazadaPor]    INT           NULL,
    [FechaRechazo]    DATETIME      NULL,
    CONSTRAINT [PK_OT_Convenio] PRIMARY KEY CLUSTERED ([IdOTConvenio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_Convenio_AP_Usuario] FOREIGN KEY ([AprobadaPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_Convenio_AP_Usuario1] FOREIGN KEY ([RechazadaPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_Convenio_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

