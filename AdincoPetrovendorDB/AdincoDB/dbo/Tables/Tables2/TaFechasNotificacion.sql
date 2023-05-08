CREATE TABLE [dbo].[TaFechasNotificacion] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [IdTarea]           INT      NULL,
    [IdUsuario]         INT      NULL,
    [FechaNotificacion] DATE     NULL,
    [FechaEnvio]        DATETIME NULL,
    [TipoNotificacion]  INT      NULL,
    CONSTRAINT [PK_TaFechasNotificacion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__TaFechasN] FOREIGN KEY ([IdTarea]) REFERENCES [dbo].[TaTarea] ([IdTarea]),
    CONSTRAINT [FK__TaFechasN__IdUsu] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

