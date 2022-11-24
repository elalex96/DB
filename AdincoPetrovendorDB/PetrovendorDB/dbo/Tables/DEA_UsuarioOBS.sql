CREATE TABLE [dbo].[DEA_UsuarioOBS] (
    [IdUsuario]    INT      NOT NULL,
    [IdContrato]   INT      NOT NULL,
    [CreadoEl]     DATETIME NOT NULL,
    [ModificadoEl] DATETIME NULL,
    [Activo]       BIT      NOT NULL,
    CONSTRAINT [fk_DEA_UsuarioOBS_S_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[S_Usuario] ([IdUsuario])
);

