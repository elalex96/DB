CREATE TABLE [dbo].[S_UsuarioAlmacen] (
    [IdUsuario] INT      NOT NULL,
    [IdAlmacen] INT      NOT NULL,
    [CreadoPor] INT      NOT NULL,
    [CreadoEl]  DATETIME NOT NULL,
    CONSTRAINT [PK_S_UsuarioAlmacen] PRIMARY KEY CLUSTERED ([IdUsuario] ASC, [IdAlmacen] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_S_UsuarioAlmacen_IN_Almacen] FOREIGN KEY ([IdAlmacen]) REFERENCES [dbo].[IN_Almacen] ([IdAlmacen]),
    CONSTRAINT [FK_S_UsuarioAlmacen_S_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

