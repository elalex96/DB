CREATE TABLE [dbo].[TaTareaDocumento] (
    [IdTareaDocumento] INT IDENTITY (1, 1) NOT NULL,
    [IdTarea]          INT NULL,
    [IdDocumento]      INT NULL,
    [IdUsuario]        INT NULL,
    [IdTipoUsuario]    INT NULL,
    CONSTRAINT [PK_TaTareaDocumento] PRIMARY KEY CLUSTERED ([IdTareaDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__TaTareaDo__IdDoc] FOREIGN KEY ([IdDocumento]) REFERENCES [dbo].[TaDocumento] ([IdDocumento]),
    CONSTRAINT [FK__TaTareaDo__IdTar] FOREIGN KEY ([IdTarea]) REFERENCES [dbo].[TaTarea] ([IdTarea]),
    CONSTRAINT [FK__TaTareaDo__IdTip] FOREIGN KEY ([IdTipoUsuario]) REFERENCES [dbo].[TaTipoUsuario] ([IdTipoUsuario]),
    CONSTRAINT [FK__TaTareaDo__IdUsu] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

