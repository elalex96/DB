CREATE TABLE [dbo].[OT_SolicitudTareaUsuarios] (
    [IdOTTareaUsuario] INT      NOT NULL,
    [IdOTTarea]        INT      NOT NULL,
    [UsuarioAdincoId]  INT      NOT NULL,
    [UsuarioPetroId]   INT      NOT NULL,
    [Completada]       BIT      NULL,
    [CreadoEl]         DATETIME NOT NULL,
    CONSTRAINT [PK_OT_SolicitudTareaUsuarios] PRIMARY KEY CLUSTERED ([IdOTTareaUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_SolicitudTareaUsuarios_AP_Usuario] FOREIGN KEY ([UsuarioAdincoId]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_SolicitudTareaUsuarios_OT_SolicitudTareas] FOREIGN KEY ([IdOTTarea]) REFERENCES [dbo].[OT_SolicitudTareas] ([IdOTTarea])
);

