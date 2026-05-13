CREATE TABLE [dbo].[AP_UsuarioPerfilSeguridad] (
    [idUsuarioPerfilSeguridad] INT IDENTITY (1, 1) NOT NULL,
    [IdUsuario]                INT NULL,
    [IdPerfil]                 INT NULL,
    CONSTRAINT [PK_AP_UsuarioPerfilSeguridad] PRIMARY KEY CLUSTERED ([idUsuarioPerfilSeguridad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

