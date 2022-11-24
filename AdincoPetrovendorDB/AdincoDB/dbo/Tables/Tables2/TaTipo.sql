CREATE TABLE [dbo].[TaTipo] (
    [IdTipo]        INT IDENTITY (1, 1) NOT NULL,
    [IdTipoUsuario] INT NULL,
    [IdUsuario]     INT NULL,
    [IdTipoTarea]   INT NULL,
    CONSTRAINT [PK_TaUsuarioTarea] PRIMARY KEY CLUSTERED ([IdTipo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__TaTipo__IdTipoTa] FOREIGN KEY ([IdTipoTarea]) REFERENCES [dbo].[TaTipoTarea] ([IdTipoTarea]),
    CONSTRAINT [FK__Tipo__IdTipoUsua] FOREIGN KEY ([IdTipoUsuario]) REFERENCES [dbo].[TaTipoUsuario] ([IdTipoUsuario]),
    CONSTRAINT [FK__Tipo__IdUsuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

