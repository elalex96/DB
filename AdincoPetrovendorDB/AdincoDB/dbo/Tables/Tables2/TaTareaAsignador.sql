CREATE TABLE [dbo].[TaTareaAsignador] (
    [IdTareaAsignador] INT IDENTITY (1, 1) NOT NULL,
    [IdTarea]          INT NULL,
    [IdUsuario]        INT NULL,
    CONSTRAINT [PK_TaTareaAsignador] PRIMARY KEY CLUSTERED ([IdTareaAsignador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__TareaAsig__IdTar] FOREIGN KEY ([IdTarea]) REFERENCES [dbo].[TaTarea] ([IdTarea]),
    CONSTRAINT [FK__TareaAsig__IdUsu] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

