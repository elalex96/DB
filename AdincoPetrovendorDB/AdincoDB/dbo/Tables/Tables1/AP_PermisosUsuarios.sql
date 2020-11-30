CREATE TABLE [dbo].[AP_PermisosUsuarios] (
    [UsuarioID]  INT NOT NULL,
    [IdPermiso]  INT NOT NULL,
    [BitActivo]  BIT NULL,
    [IdContrato] INT NOT NULL,
    CONSTRAINT [PK_AP_PermisosUsuarios] PRIMARY KEY CLUSTERED ([UsuarioID] ASC, [IdPermiso] ASC, [IdContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_PermisosUsuarios_AP_Permiso] FOREIGN KEY ([IdPermiso]) REFERENCES [dbo].[AP_Permiso] ([IdPermiso]),
    CONSTRAINT [FK_AP_PermisosUsuarios_AP_Usuario] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

