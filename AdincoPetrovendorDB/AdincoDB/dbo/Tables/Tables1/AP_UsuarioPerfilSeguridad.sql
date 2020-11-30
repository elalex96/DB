CREATE TABLE [dbo].[AP_UsuarioPerfilSeguridad] (
    [idUsuarioPerfilSeguridad] INT IDENTITY (1, 1) NOT NULL,
    [IdUsuario]                INT NULL,
    [IdPerfil]                 INT NULL,
    CONSTRAINT [PK_AP_UsuarioPerfilSeguridad] PRIMARY KEY CLUSTERED ([idUsuarioPerfilSeguridad] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

