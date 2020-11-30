CREATE TABLE [dbo].[OT_SolicitudTareas] (
    [IdOTTarea]               INT           NOT NULL,
    [IdOTSolicitud]           INT           NOT NULL,
    [Descripcion]             VARCHAR (250) NOT NULL,
    [FlujoAprobacionTareaId]  SMALLINT      NOT NULL,
    [RequiereCompletar]       BIT           NOT NULL,
    [Completada]              BIT           NULL,
    [UsuarioAdinRequeridoId]  INT           NULL,
    [UsuarioPetroRequeridoId] INT           NULL,
    [FechaCompletada]         DATETIME      NULL,
    [CreadoEl]                DATETIME      NOT NULL,
    [UrlAdinco]               VARCHAR (300) NULL,
    [UrlPetro]                VARCHAR (300) NULL,
    CONSTRAINT [PK_OT_SolicitudTareas] PRIMARY KEY CLUSTERED ([IdOTTarea] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_SolicitudTareas_AP_FlujoAprobacion_Tareas] FOREIGN KEY ([FlujoAprobacionTareaId]) REFERENCES [dbo].[AP_FlujoAprobacion_Tareas] ([FlujoAprobacionTareaId]),
    CONSTRAINT [FK_OT_SolicitudTareas_AP_Usuario] FOREIGN KEY ([UsuarioAdinRequeridoId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudTareas_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

