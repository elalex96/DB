CREATE TABLE [dbo].[TaComentarioCancelacionTarea] (
    [IdComentario] INT            IDENTITY (1, 1) NOT NULL,
    [IdUsuario]    INT            NOT NULL,
    [IdTarea]      INT            NULL,
    [Comentario]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TaCometarioCancelacionTarea] PRIMARY KEY CLUSTERED ([IdComentario] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__TaComenta__IdUsu] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

