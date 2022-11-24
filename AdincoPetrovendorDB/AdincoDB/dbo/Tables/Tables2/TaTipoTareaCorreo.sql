CREATE TABLE [dbo].[TaTipoTareaCorreo] (
    [IdTipoTareaCorreo] INT IDENTITY (1, 1) NOT NULL,
    [IdTipoTarea]       INT NULL,
    [IdCorreo]          INT NULL,
    [IdCorreoServidor]  INT NULL,
    CONSTRAINT [PK_TaTipoTareaCorreo] PRIMARY KEY CLUSTERED ([IdTipoTareaCorreo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__TipoTarea__IdCor] FOREIGN KEY ([IdCorreoServidor]) REFERENCES [dbo].[S_CorreoServidor] ([IdCorreoServidor]),
    CONSTRAINT [FK__TipoTarea__IdTip] FOREIGN KEY ([IdTipoTarea]) REFERENCES [dbo].[TaTipoTarea] ([IdTipoTarea])
);

