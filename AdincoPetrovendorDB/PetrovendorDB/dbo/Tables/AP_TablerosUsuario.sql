CREATE TABLE [dbo].[AP_TablerosUsuario] (
    [Id]        INT      IDENTITY (1, 1) NOT NULL,
    [IdTablero] INT      NULL,
    [IdUsuario] INT      NULL,
    [Activo]    BIT      NULL,
    [CreadoEl]  DATETIME NULL,
    [CreadoPor] INT      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdTablero]) REFERENCES [dbo].[AP_Tableros] ([Id])
);

