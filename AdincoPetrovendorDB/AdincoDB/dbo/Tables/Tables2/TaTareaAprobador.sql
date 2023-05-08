CREATE TABLE [dbo].[TaTareaAprobador] (
    [IdTareaAprobador] INT            IDENTITY (1, 1) NOT NULL,
    [IdTarea]          INT            NULL,
    [IdUsuario]        INT            NULL,
    [IdEstatus]        INT            NULL,
    [Fecha]            DATETIME       NULL,
    [Comentario]       NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TaTareaAprobador] PRIMARY KEY CLUSTERED ([IdTareaAprobador] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__TareaApro__IdEst] FOREIGN KEY ([IdEstatus]) REFERENCES [dbo].[TaEstatus] ([IdEstatus]),
    CONSTRAINT [FK__TareaApro__IdTar] FOREIGN KEY ([IdTarea]) REFERENCES [dbo].[TaTarea] ([IdTarea]),
    CONSTRAINT [FK__TareaApro__IdUsu] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

