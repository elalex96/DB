CREATE TABLE [dbo].[RolesUsuarios] (
    [IdRolUsuario] INT NOT NULL,
    [IdRol]        INT NULL,
    [IdUsuario]    INT NULL,
    [Activo]       BIT NULL,
    CONSTRAINT [PK_RolesUsuarios] PRIMARY KEY CLUSTERED ([IdRolUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_RolesUsuarios_AP_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_RolesUsuarios_Roles] FOREIGN KEY ([IdRol]) REFERENCES [dbo].[Roles] ([IdRol])
);

