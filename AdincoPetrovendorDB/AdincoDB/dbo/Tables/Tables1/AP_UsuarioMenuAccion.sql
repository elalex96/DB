CREATE TABLE [dbo].[AP_UsuarioMenuAccion] (
    [IdUsuario]    INT      NOT NULL,
    [MenuDId]      INT      NOT NULL,
    [IdAccion]     TINYINT  NOT NULL,
    [Permitir]     BIT      NOT NULL,
    [CreadoEl]     DATETIME NULL,
    [ModificadoEl] DATETIME NULL,
    [Id]           INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_AP_UsuarioMenuAccion] PRIMARY KEY CLUSTERED ([IdUsuario] ASC, [IdAccion] ASC, [MenuDId] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_UsuarioMenuAccion_AP_Acciones] FOREIGN KEY ([IdAccion]) REFERENCES [dbo].[AP_Acciones] ([IdAccion]),
    CONSTRAINT [FK_AP_UsuarioMenuAccion_AP_MenuD] FOREIGN KEY ([MenuDId]) REFERENCES [dbo].[AP_MenuD] ([MenuId]),
    CONSTRAINT [FK_AP_UsuarioMenuAccion_AP_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

