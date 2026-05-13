CREATE TABLE [dbo].[OT_SolicitudBitacora] (
    [IdOTBitacora]           INT           NOT NULL,
    [IdOTSolicitud]          INT           NOT NULL,
    [FlujoAprobacionTareaId] SMALLINT      NULL,
    [Descripcion]            VARCHAR (150) NULL,
    [CreadoEl]               DATETIME      NOT NULL,
    [UsuarioAdincoId]        INT           NULL,
    [UsuarioPetroId]         INT           NULL,
    [IdTipoMovimiento]       INT           NULL,
    CONSTRAINT [PK_OT_SolicitudBitacora] PRIMARY KEY CLUSTERED ([IdOTBitacora] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_SolicitudBitacora_AP_FlujoAprobacion_Tareas] FOREIGN KEY ([FlujoAprobacionTareaId]) REFERENCES [dbo].[AP_FlujoAprobacion_Tareas] ([FlujoAprobacionTareaId]),
    CONSTRAINT [FK_OT_SolicitudBitacora_AP_Usuario] FOREIGN KEY ([UsuarioAdincoId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudBitacora_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);


GO
CREATE NONCLUSTERED INDEX [IX_OT_SolicitudBitacora]
    ON [dbo].[OT_SolicitudBitacora]([IdOTSolicitud] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

